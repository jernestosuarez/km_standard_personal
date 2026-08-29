# km-unrepaired-tree: v1.64 | each new contract behavior was run RED before implementation; the UUID, destination, and idempotency guards were also disabled individually and their canaries failed before restoration.
import importlib.util
from copy import deepcopy
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
CONTRACTS = ROOT / "glassity" / "contracts"
VALIDATOR = CONTRACTS / "validate_contracts.py"


def load_validator():
    spec = importlib.util.spec_from_file_location("glassity_contract_validator", VALIDATOR)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


DESCRIPTOR_REQUIRED = {
    "case_id",
    "artifact",
    "operation",
    "path",
    "expected_reason",
}
DESCRIPTOR_OPERATIONS = {"remove", "replace", "add", "append_copy"}


def load_case_descriptors(path, reason_order):
    descriptors = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(descriptors, list):
        raise ValueError("descriptor file must contain a list")
    case_ids = set()
    for descriptor in descriptors:
        if not isinstance(descriptor, dict):
            raise ValueError("each descriptor must be an object")
        allowed = DESCRIPTOR_REQUIRED | {"value"}
        if set(descriptor) - allowed or not DESCRIPTOR_REQUIRED.issubset(descriptor):
            raise ValueError("descriptor has missing or unknown fields")
        case_id = descriptor["case_id"]
        if not isinstance(case_id, str) or not case_id or case_id in case_ids:
            raise ValueError("case_id must be non-empty and unique")
        case_ids.add(case_id)
        operation = descriptor["operation"]
        if operation not in DESCRIPTOR_OPERATIONS:
            raise ValueError("unknown mutation operation")
        if operation in {"replace", "add"} and "value" not in descriptor:
            raise ValueError("mutation operation requires value")
        if operation == "remove" and "value" in descriptor:
            raise ValueError("remove cannot declare value")
        if descriptor["expected_reason"] not in reason_order:
            raise ValueError("expected_reason is not in REASON_ORDER")
        if not isinstance(descriptor["path"], str) or not descriptor["path"].startswith("/"):
            raise ValueError("path must be an absolute JSON Pointer")
    return descriptors


def _pointer_tokens(pointer):
    return [token.replace("~1", "/").replace("~0", "~") for token in pointer[1:].split("/")]


def _pointer_parent(value, pointer):
    tokens = _pointer_tokens(pointer)
    parent = value
    for token in tokens[:-1]:
        parent = parent[int(token)] if isinstance(parent, list) else parent[token]
    return parent, tokens[-1]


def _descriptor_value(value):
    if isinstance(value, dict) and set(value) == {"repeat_text", "count"}:
        text = value["repeat_text"]
        count = value["count"]
        if not isinstance(text, str) or len(text) != 1 or not isinstance(count, int):
            raise ValueError("repeat_text value must declare one character and an integer count")
        return text * count
    return deepcopy(value)


def apply_case_mutation(baseline, descriptor):
    mutated = deepcopy(baseline)
    parent, token = _pointer_parent(mutated, descriptor["path"])
    key = int(token) if isinstance(parent, list) else token
    operation = descriptor["operation"]
    if operation == "remove":
        del parent[key]
    elif operation == "replace":
        if (isinstance(parent, list) and key >= len(parent)) or (
            isinstance(parent, dict) and key not in parent
        ):
            raise ValueError("replace target does not exist")
        parent[key] = _descriptor_value(descriptor["value"])
    elif operation == "add":
        if not isinstance(parent, dict) or key in parent:
            raise ValueError("add target must be a new object member")
        parent[key] = _descriptor_value(descriptor["value"])
    elif operation == "append_copy":
        if not isinstance(parent, list):
            raise ValueError("append_copy target must be a list item")
        copied = deepcopy(parent[key])
        if "value" in descriptor:
            if not isinstance(copied, dict) or not isinstance(descriptor["value"], dict):
                raise ValueError("append_copy override requires objects")
            copied.update(deepcopy(descriptor["value"]))
        parent.append(copied)
    else:
        raise ValueError("unknown mutation operation")
    return mutated


def validate_mutation_case(validator, valid_root, descriptor):
    baseline = json.loads(
        (valid_root / descriptor["artifact"]).read_text(encoding="utf-8")
    )
    mutated = apply_case_mutation(baseline, descriptor)
    schemas, registry, schema_issues = validator.load_schemas(CONTRACTS)
    issues = list(schema_issues)
    artifact = descriptor["artifact"]
    if artifact == "authority-matrix.json":
        issues.extend(validator.validate_schema("authority", mutated, schemas, registry))
        issues.extend(validator.validate_authority_matrix(mutated))
    elif artifact == "deployment-binding.json":
        issues.extend(
            validator.validate_schema("deployment-binding", mutated, schemas, registry)
        )
        issues.extend(validator.validate_binding(mutated))
    elif artifact == "provisioning-receipt.json":
        tenant_valid = CONTRACTS / "tenant-provisioning" / "fixtures" / "valid"
        binding_path = tenant_valid / "deployment-binding.json"
        binding = json.loads(binding_path.read_text(encoding="utf-8"))
        issues.extend(
            validator.validate_schema("provisioning-receipt", mutated, schemas, registry)
        )
        issues.extend(
            validator.validate_receipt(mutated, binding_path.read_bytes(), binding)
        )
    else:
        tenant_valid = CONTRACTS / "tenant-provisioning" / "fixtures" / "valid"
        authority = json.loads(
            (
                CONTRACTS
                / "authority-matrix"
                / "fixtures"
                / "valid"
                / "authority-matrix.json"
            ).read_text(encoding="utf-8")
        )
        binding = json.loads(
            (tenant_valid / "deployment-binding.json").read_text(encoding="utf-8")
        )
        issues.extend(
            validator.validate_schema("inbound-envelope", mutated, schemas, registry)
        )
        issues.extend(validator.validate_envelope(mutated, authority, binding).issues)
    return validator._ordered_unique(issues)


class InvalidFixtureDescriptorTests(unittest.TestCase):
    def test_committed_descriptor_sets_have_closed_valid_shapes(self):
        validator = load_validator()
        descriptor_paths = (
            CONTRACTS / "authority-matrix" / "fixtures" / "invalid" / "cases.json",
            CONTRACTS / "tenant-provisioning" / "fixtures" / "invalid" / "cases.json",
        )

        descriptors = []
        for path in descriptor_paths:
            descriptors.extend(load_case_descriptors(path, validator.REASON_ORDER))

        self.assertEqual(
            len({descriptor["case_id"] for descriptor in descriptors}),
            len(descriptors),
        )

    def test_descriptor_canaries_cover_every_validation_reason(self):
        validator = load_validator()
        descriptors = []
        for path in (
            CONTRACTS / "authority-matrix" / "fixtures" / "invalid" / "cases.json",
            CONTRACTS / "tenant-provisioning" / "fixtures" / "invalid" / "cases.json",
        ):
            descriptors.extend(load_case_descriptors(path, validator.REASON_ORDER))

        covered = {descriptor["expected_reason"] for descriptor in descriptors}
        covered.update({"JSON_INVALID", "DEPENDENCY_MISSING"})

        self.assertEqual(covered, set(validator.REASON_ORDER))

    def test_each_descriptor_is_one_mutation_with_one_named_result(self):
        validator = load_validator()
        fixture_groups = (
            (
                CONTRACTS / "authority-matrix" / "fixtures" / "invalid" / "cases.json",
                CONTRACTS / "authority-matrix" / "fixtures" / "valid",
            ),
            (
                CONTRACTS / "tenant-provisioning" / "fixtures" / "invalid" / "cases.json",
                CONTRACTS / "tenant-provisioning" / "fixtures" / "valid",
            ),
        )

        for descriptor_path, valid_root in fixture_groups:
            descriptors = load_case_descriptors(
                descriptor_path, validator.REASON_ORDER
            )
            for descriptor in descriptors:
                with self.subTest(case_id=descriptor["case_id"]):
                    issues = validate_mutation_case(
                        validator, valid_root, descriptor
                    )
                    self.assertEqual(
                        [issue.code for issue in issues],
                        [descriptor["expected_reason"]],
                    )

    def test_descriptor_loader_rejects_malformed_metadata(self):
        validator = load_validator()
        valid = {
            "case_id": "synthetic-case",
            "artifact": "upload-pointer.json",
            "operation": "replace",
            "path": "/tenant_id",
            "value": "tenant-other",
            "expected_reason": "TENANT_MISMATCH",
        }
        malformed_sets = []

        unknown_operation = deepcopy(valid)
        unknown_operation["operation"] = "copy"
        malformed_sets.append([unknown_operation])

        malformed_sets.append([valid, deepcopy(valid)])

        missing_reason = deepcopy(valid)
        del missing_reason["expected_reason"]
        malformed_sets.append([missing_reason])

        unknown_reason = deepcopy(valid)
        unknown_reason["expected_reason"] = "NOT_A_REASON"
        malformed_sets.append([unknown_reason])

        extra_field = deepcopy(valid)
        extra_field["comment"] = "not allowed"
        malformed_sets.append([extra_field])

        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "cases.json"
            for descriptors in malformed_sets:
                with self.subTest(descriptors=descriptors):
                    path.write_text(json.dumps(descriptors), encoding="utf-8")
                    with self.assertRaises(ValueError):
                        load_case_descriptors(path, validator.REASON_ORDER)


class BundleCliTests(unittest.TestCase):
    def valid_command(self):
        tenant_valid = CONTRACTS / "tenant-provisioning" / "fixtures" / "valid"
        return [
            sys.executable,
            str(VALIDATOR),
            "bundle",
            "--authority",
            str(
                CONTRACTS
                / "authority-matrix"
                / "fixtures"
                / "valid"
                / "authority-matrix.json"
            ),
            "--binding",
            str(tenant_valid / "deployment-binding.json"),
            "--receipt",
            str(tenant_valid / "provisioning-receipt.json"),
            "--envelope",
            str(tenant_valid / "upload-pointer.json"),
        ]

    def test_valid_bundle_cli_prints_one_success_line(self):
        result = subprocess.run(
            self.valid_command(), text=True, capture_output=True, check=False
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stderr, "")
        self.assertEqual(
            result.stdout.strip(),
            "VALID foundation-contracts: tenant-alpha "
            "deployment-alpha-eu-west-1 1 envelope(s)",
        )

    def test_invalid_bundle_cli_prints_issue_only(self):
        receipt_path = (
            CONTRACTS
            / "tenant-provisioning"
            / "fixtures"
            / "valid"
            / "provisioning-receipt.json"
        )
        receipt = json.loads(receipt_path.read_text(encoding="utf-8"))
        receipt["tenant_id"] = "tenant-other"
        with tempfile.TemporaryDirectory() as directory:
            mutated_path = Path(directory) / "provisioning-receipt.json"
            mutated_path.write_text(json.dumps(receipt), encoding="utf-8")
            command = self.valid_command()
            receipt_index = command.index("--receipt") + 1
            command[receipt_index] = str(mutated_path)

            result = subprocess.run(
                command, text=True, capture_output=True, check=False
            )

        self.assertEqual(result.returncode, 1)
        self.assertIn("TENANT_MISMATCH\t", result.stderr)
        self.assertNotIn("Traceback", result.stderr)
        self.assertNotIn("VALID", result.stdout)

    def test_missing_bundle_arguments_exit_two_with_usage(self):
        result = subprocess.run(
            [sys.executable, str(VALIDATOR), "bundle"],
            text=True,
            capture_output=True,
            check=False,
        )

        self.assertEqual(result.returncode, 2)
        self.assertIn("usage:", result.stderr)
        self.assertNotIn("Traceback", result.stderr)

    def test_malformed_json_exits_one_without_partial_success(self):
        with tempfile.TemporaryDirectory() as directory:
            malformed = Path(directory) / "authority.json"
            malformed.write_text("{not-json", encoding="utf-8")
            command = self.valid_command()
            authority_index = command.index("--authority") + 1
            command[authority_index] = str(malformed)

            result = subprocess.run(
                command, text=True, capture_output=True, check=False
            )

        self.assertEqual(result.returncode, 1)
        self.assertIn("JSON_INVALID\t", result.stderr)
        self.assertNotIn("Traceback", result.stderr)
        self.assertNotIn("VALID", result.stdout)

    def test_bundle_receipt_uses_exact_binding_file_bytes(self):
        tenant_valid = CONTRACTS / "tenant-provisioning" / "fixtures" / "valid"
        with tempfile.TemporaryDirectory() as directory:
            binding_path = Path(directory) / "deployment-binding.json"
            binding = json.loads(
                (tenant_valid / "deployment-binding.json").read_text(encoding="utf-8")
            )
            binding_path.write_text(
                json.dumps(binding, indent=4) + "\n", encoding="utf-8"
            )
            command = self.valid_command()
            binding_index = command.index("--binding") + 1
            command[binding_index] = str(binding_path)

            result = subprocess.run(
                command, text=True, capture_output=True, check=False
            )

        self.assertEqual(result.returncode, 1)
        self.assertIn("PROVISIONING_DIGEST_MISMATCH\t", result.stderr)
        self.assertNotIn("Traceback", result.stderr)
        self.assertNotIn("VALID", result.stdout)

    def test_bundle_issues_are_deduplicated_in_contract_order(self):
        receipt_path = (
            CONTRACTS
            / "tenant-provisioning"
            / "fixtures"
            / "valid"
            / "provisioning-receipt.json"
        )
        receipt = json.loads(receipt_path.read_text(encoding="utf-8"))
        receipt.update(
            {
                "tenant_id": "tenant-other",
                "deployment_id": "deployment-other",
                "overlay_parent_commit": "c" * 40,
                "binding_sha256": "0" * 64,
                "erasure_map_sha256": "0" * 64,
            }
        )
        with tempfile.TemporaryDirectory() as directory:
            mutated_path = Path(directory) / "provisioning-receipt.json"
            mutated_path.write_text(json.dumps(receipt), encoding="utf-8")
            command = self.valid_command()
            receipt_index = command.index("--receipt") + 1
            command[receipt_index] = str(mutated_path)

            result = subprocess.run(
                command, text=True, capture_output=True, check=False
            )

        codes = [line.split("\t", 1)[0] for line in result.stderr.splitlines()]
        self.assertEqual(result.returncode, 1)
        self.assertEqual(
            codes,
            [
                "TENANT_MISMATCH",
                "DEPLOYMENT_MISMATCH",
                "PROVISIONING_ORDER_INVALID",
                "PROVISIONING_DIGEST_MISMATCH",
            ],
        )


class DependencyAndCliTests(unittest.TestCase):
    def test_self_check_uses_draft_2020_12(self):
        result = subprocess.run(
            [sys.executable, str(VALIDATOR), "--self-check"],
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            result.stdout.strip(),
            "VALID Draft202012Validator jsonschema==4.25.1",
        )

    def test_missing_dependency_fails_closed(self):
        result = subprocess.run(
            [sys.executable, "-S", str(VALIDATOR), "--self-check"],
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(result.returncode, 1)
        self.assertIn("DEPENDENCY_MISSING", result.stderr)
        self.assertNotIn("Traceback", result.stderr)


class AuthorityMatrixTests(unittest.TestCase):
    def load_matrix(self):
        validator = load_validator()
        matrix, issues = validator.load_json(
            CONTRACTS
            / "authority-matrix"
            / "fixtures"
            / "valid"
            / "authority-matrix.json"
        )
        self.assertEqual(issues, [])
        return validator, matrix

    def test_complete_authority_matrix_passes_schema_and_semantics(self):
        validator, matrix = self.load_matrix()
        schemas, registry, schema_issues = validator.load_schemas(CONTRACTS)

        issues = validator.validate_schema("authority", matrix, schemas, registry)
        issues.extend(validator.validate_authority_matrix(matrix))

        self.assertEqual(schema_issues, [])
        self.assertEqual(issues, [])

    def test_missing_required_class_has_stable_reason(self):
        validator, matrix = self.load_matrix()
        mutated = deepcopy(matrix)
        mutated["rows"] = [
            row for row in mutated["rows"] if row["data_class"] != "raw_upload"
        ]

        issues = validator.validate_authority_matrix(mutated)

        self.assertEqual([issue.code for issue in issues], ["AUTHORITY_SET_INCOMPLETE"])

    def test_unknown_class_has_stable_reason(self):
        validator, matrix = self.load_matrix()
        mutated = deepcopy(matrix)
        unknown = deepcopy(mutated["rows"][0])
        unknown["data_class"] = "unknown_class"
        mutated["rows"].append(unknown)

        issues = validator.validate_authority_matrix(mutated)

        self.assertEqual([issue.code for issue in issues], ["AUTHORITY_SET_UNKNOWN"])

    def test_remapped_system_of_record_has_stable_reason(self):
        validator, matrix = self.load_matrix()
        mutated = deepcopy(matrix)
        pending = next(
            row for row in mutated["rows"] if row["data_class"] == "pending_answer"
        )
        pending["system_of_record"] = "tenant_hub"

        issues = validator.validate_authority_matrix(mutated)

        self.assertEqual([issue.code for issue in issues], ["AUTHORITY_SYSTEM_MISMATCH"])

    def test_remapped_hub_representation_has_stable_reason(self):
        validator, matrix = self.load_matrix()
        mutated = deepcopy(matrix)
        digest = next(
            row for row in mutated["rows"] if row["data_class"] == "digest"
        )
        digest["hub_representations"] = ["governed_claim"]

        issues = validator.validate_authority_matrix(mutated)

        self.assertEqual([issue.code for issue in issues], ["AUTHORITY_SYSTEM_MISMATCH"])

    def test_every_canonical_authority_field_is_pinned(self):
        validator, matrix = self.load_matrix()
        raw_upload = next(
            row for row in matrix["rows"] if row["data_class"] == "raw_upload"
        )
        mutations = {
            "system_of_record": "tenant_hub",
            "hub_representations": ["governed_claim"],
            "allowed_producers": ["worker"],
            "envelope_types": ["domain_event"],
            "classification_policy_refs": [
                "urn:glassity:synthetic:policy:other"
            ],
            "retention_policy_ref": "urn:glassity:synthetic:policy:other",
            "forbidden_locations": ["audit_store"],
        }

        for field, value in mutations.items():
            with self.subTest(field=field):
                mutated = deepcopy(matrix)
                row = next(
                    item
                    for item in mutated["rows"]
                    if item["data_class"] == "raw_upload"
                )
                row[field] = value
                issues = validator.validate_authority_matrix(mutated)
                self.assertEqual(
                    [issue.code for issue in issues],
                    ["AUTHORITY_SYSTEM_MISMATCH"],
                )

    def test_non_git_record_classes_cannot_be_remapped_to_tenant_hub(self):
        validator, matrix = self.load_matrix()
        for data_class in (
            "raw_upload",
            "app_object",
            "app_event",
            "pending_answer",
        ):
            with self.subTest(data_class=data_class):
                mutated = deepcopy(matrix)
                row = next(
                    item
                    for item in mutated["rows"]
                    if item["data_class"] == data_class
                )
                row["system_of_record"] = "tenant_hub"
                issues = validator.validate_authority_matrix(mutated)
                self.assertEqual(
                    [issue.code for issue in issues],
                    ["AUTHORITY_SYSTEM_MISMATCH"],
                )

    def test_duplicate_class_has_stable_reason(self):
        validator, matrix = self.load_matrix()
        mutated = deepcopy(matrix)
        mutated["rows"].append(deepcopy(mutated["rows"][0]))
        schemas, registry, schema_issues = validator.load_schemas(CONTRACTS)

        issues = schema_issues
        issues.extend(validator.validate_schema("authority", mutated, schemas, registry))
        issues.extend(validator.validate_authority_matrix(mutated))

        self.assertEqual([issue.code for issue in issues], ["AUTHORITY_SET_UNKNOWN"])


class DeploymentBindingTests(unittest.TestCase):
    def load_binding(self):
        validator = load_validator()
        binding, issues = validator.load_json(
            CONTRACTS
            / "tenant-provisioning"
            / "fixtures"
            / "valid"
            / "deployment-binding.json"
        )
        self.assertEqual(issues, [])
        return validator, binding

    def test_active_binding_with_complete_erasure_map_passes(self):
        validator, binding = self.load_binding()
        schemas, registry, schema_issues = validator.load_schemas(CONTRACTS)

        issues = validator.validate_schema("deployment-binding", binding, schemas, registry)
        issues.extend(validator.validate_binding(binding))

        self.assertEqual(schema_issues, [])
        self.assertEqual(issues, [])

    def test_frozen_binding_with_scoped_hold_passes(self):
        validator, binding = self.load_binding()
        mutated = deepcopy(binding)
        mutated["lifecycle"] = "frozen"
        mutated["legal_hold"] = {
            "status": "scoped",
            "decision_ref": "decisions/synthetic-legal-hold-v1",
            "scope_digest": "a" * 64,
            "legal_basis_ref": "legal/synthetic-basis-v1",
            "review_date": "2026-09-30",
        }
        schemas, registry, schema_issues = validator.load_schemas(CONTRACTS)

        issues = validator.validate_schema("deployment-binding", mutated, schemas, registry)
        issues.extend(validator.validate_binding(mutated))

        self.assertEqual(schema_issues, [])
        self.assertEqual(issues, [])

    def test_lifecycle_outside_ad_005_is_schema_invalid(self):
        validator, binding = self.load_binding()
        mutated = deepcopy(binding)
        mutated["lifecycle"] = "paused"
        schemas, registry, schema_issues = validator.load_schemas(CONTRACTS)

        issues = validator.validate_schema("deployment-binding", mutated, schemas, registry)

        self.assertEqual(schema_issues, [])
        self.assertEqual([issue.code for issue in issues], ["SCHEMA_INVALID"])

    def test_missing_erasure_category_has_stable_reason(self):
        validator, binding = self.load_binding()
        mutated = deepcopy(binding)
        mutated["erasure_map"]["entries"] = [
            entry
            for entry in mutated["erasure_map"]["entries"]
            if entry["category"] != "tenant_secret"
        ]
        schemas, registry, schema_issues = validator.load_schemas(CONTRACTS)

        schema_validation = validator.validate_schema(
            "deployment-binding", mutated, schemas, registry
        )
        semantic_validation = validator.validate_binding(mutated)

        self.assertEqual(schema_issues, [])
        self.assertEqual(
            [issue.code for issue in schema_validation], ["ERASURE_MAP_INCOMPLETE"]
        )
        self.assertEqual(
            [issue.code for issue in semantic_validation], ["ERASURE_MAP_INCOMPLETE"]
        )

    def test_missing_embedded_erasure_map_has_stable_reason(self):
        validator, binding = self.load_binding()
        mutated = deepcopy(binding)
        del mutated["erasure_map"]
        schemas, registry, schema_issues = validator.load_schemas(CONTRACTS)

        schema_validation = validator.validate_schema(
            "deployment-binding", mutated, schemas, registry
        )
        semantic_validation = validator.validate_binding(mutated)

        self.assertEqual(schema_issues, [])
        self.assertEqual(
            [issue.code for issue in schema_validation], ["ERASURE_MAP_INCOMPLETE"]
        )
        self.assertEqual(
            [issue.code for issue in semantic_validation], ["ERASURE_MAP_INCOMPLETE"]
        )

    def test_missing_erasure_map_does_not_mask_another_required_field(self):
        validator, binding = self.load_binding()
        mutated = deepcopy(binding)
        del mutated["erasure_map"]
        del mutated["lifecycle"]
        schemas, registry, schema_issues = validator.load_schemas(CONTRACTS)

        issues = validator.validate_schema(
            "deployment-binding", mutated, schemas, registry
        )

        self.assertEqual(schema_issues, [])
        self.assertEqual(
            [issue.code for issue in issues],
            ["SCHEMA_INVALID", "ERASURE_MAP_INCOMPLETE"],
        )

    def test_blanket_legal_hold_without_scope_digest_is_schema_invalid(self):
        validator, binding = self.load_binding()
        mutated = deepcopy(binding)
        mutated["legal_hold"] = {
            "status": "scoped",
            "decision_ref": "decisions/synthetic-legal-hold-v1",
            "legal_basis_ref": "legal/synthetic-basis-v1",
            "review_date": "2026-09-30",
        }
        schemas, registry, schema_issues = validator.load_schemas(CONTRACTS)

        issues = validator.validate_schema("deployment-binding", mutated, schemas, registry)

        self.assertEqual(schema_issues, [])
        self.assertEqual([issue.code for issue in issues], ["SCHEMA_INVALID"])

    def test_duplicate_erasure_category_has_stable_reason(self):
        validator, binding = self.load_binding()
        mutated = deepcopy(binding)
        mutated["erasure_map"]["entries"].append(
            deepcopy(mutated["erasure_map"]["entries"][0])
        )

        issues = validator.validate_binding(mutated)

        self.assertEqual([issue.code for issue in issues], ["ERASURE_MAP_INCOMPLETE"])

    def test_erasure_map_tenant_mismatch_has_stable_reason(self):
        validator, binding = self.load_binding()
        mutated = deepcopy(binding)
        mutated["erasure_map"]["tenant_id"] = "tenant-other"

        issues = validator.validate_binding(mutated)

        self.assertEqual([issue.code for issue in issues], ["TENANT_MISMATCH"])

    def test_erasure_map_deployment_mismatch_has_stable_reason(self):
        validator, binding = self.load_binding()
        mutated = deepcopy(binding)
        mutated["erasure_map"]["deployment_id"] = "deployment-other"

        issues = validator.validate_binding(mutated)

        self.assertEqual([issue.code for issue in issues], ["DEPLOYMENT_MISMATCH"])

    def test_scoped_hold_is_orthogonal_to_complete_lifecycle(self):
        validator, binding = self.load_binding()
        mutated = deepcopy(binding)
        mutated["lifecycle"] = "complete"
        mutated["legal_hold"] = {
            "status": "scoped",
            "decision_ref": "decisions/synthetic-legal-hold-v1",
            "scope_digest": "b" * 64,
            "legal_basis_ref": "legal/synthetic-basis-v1",
            "review_date": "2026-09-30",
        }
        schemas, registry, schema_issues = validator.load_schemas(CONTRACTS)

        issues = validator.validate_schema("deployment-binding", mutated, schemas, registry)
        issues.extend(validator.validate_binding(mutated))

        self.assertEqual(schema_issues, [])
        self.assertEqual(issues, [])


class ProvisioningReceiptTests(unittest.TestCase):
    def load_receipt_bundle(self):
        validator = load_validator()
        binding_path = (
            CONTRACTS
            / "tenant-provisioning"
            / "fixtures"
            / "valid"
            / "deployment-binding.json"
        )
        binding, binding_issues = validator.load_json(binding_path)
        receipt, receipt_issues = validator.load_json(
            CONTRACTS
            / "tenant-provisioning"
            / "fixtures"
            / "valid"
            / "provisioning-receipt.json"
        )
        self.assertEqual(binding_issues, [])
        self.assertEqual(receipt_issues, [])
        return validator, binding_path.read_bytes(), binding, receipt

    def test_declared_provisioning_receipt_passes(self):
        validator, binding_bytes, binding, receipt = self.load_receipt_bundle()
        schemas, registry, schema_issues = validator.load_schemas(CONTRACTS)

        issues = validator.validate_schema(
            "provisioning-receipt", receipt, schemas, registry
        )
        issues.extend(validator.validate_receipt(receipt, binding_bytes, binding))

        self.assertEqual(schema_issues, [])
        self.assertEqual(issues, [])

    def test_binding_digest_is_recomputed_from_exact_file_bytes(self):
        validator, binding_bytes, binding, receipt = self.load_receipt_bundle()
        mutated = deepcopy(receipt)
        mutated["binding_sha256"] = "0" * 64

        issues = validator.validate_receipt(mutated, binding_bytes, binding)

        self.assertEqual(
            [issue.code for issue in issues], ["PROVISIONING_DIGEST_MISMATCH"]
        )

    def test_erasure_map_digest_is_recomputed_from_canonical_json(self):
        validator, binding_bytes, binding, receipt = self.load_receipt_bundle()
        mutated = deepcopy(receipt)
        mutated["erasure_map_sha256"] = "0" * 64

        issues = validator.validate_receipt(mutated, binding_bytes, binding)

        self.assertEqual(
            [issue.code for issue in issues], ["PROVISIONING_DIGEST_MISMATCH"]
        )
        self.assertEqual(issues[0].path, "/erasure_map_sha256")

    def test_multiple_digest_defects_emit_the_reason_once(self):
        validator, binding_bytes, binding, receipt = self.load_receipt_bundle()
        mutated = deepcopy(receipt)
        mutated["binding_sha256"] = "0" * 64
        mutated["erasure_map_sha256"] = "0" * 64

        issues = validator.validate_receipt(mutated, binding_bytes, binding)

        self.assertEqual(
            [issue.code for issue in issues], ["PROVISIONING_DIGEST_MISMATCH"]
        )

    def test_overlay_parent_must_equal_declared_initialization_commit(self):
        validator, binding_bytes, binding, receipt = self.load_receipt_bundle()
        mutated = deepcopy(receipt)
        mutated["overlay_parent_commit"] = "c" * 40

        issues = validator.validate_receipt(mutated, binding_bytes, binding)

        self.assertEqual(
            [issue.code for issue in issues], ["PROVISIONING_ORDER_INVALID"]
        )

    def test_receipt_identity_and_pins_must_match_binding(self):
        validator, binding_bytes, binding, receipt = self.load_receipt_bundle()
        mutations = (
            ("tenant_id", "tenant-other", "TENANT_MISMATCH"),
            ("deployment_id", "deployment-other", "DEPLOYMENT_MISMATCH"),
            ("canonical_pin", "c" * 40, "PROVISIONING_ORDER_INVALID"),
            ("overlay_revision", "glassity-overlay-other", "PROVISIONING_ORDER_INVALID"),
        )

        for field, value, reason in mutations:
            with self.subTest(field=field):
                mutated = deepcopy(receipt)
                mutated[field] = value

                issues = validator.validate_receipt(mutated, binding_bytes, binding)

                self.assertEqual([issue.code for issue in issues], [reason])

    def test_proof_level_is_declared_parent_relationship_only(self):
        validator, _, _, receipt = self.load_receipt_bundle()
        mutated = deepcopy(receipt)
        mutated["proof_level"] = "git_ancestry_proved"
        schemas, registry, schema_issues = validator.load_schemas(CONTRACTS)

        issues = validator.validate_schema(
            "provisioning-receipt", mutated, schemas, registry
        )

        self.assertEqual(schema_issues, [])
        self.assertEqual([issue.code for issue in issues], ["SCHEMA_INVALID"])


class InboundEnvelopeTests(unittest.TestCase):
    def load_envelope_bundle(self, fixture_name):
        validator = load_validator()
        fixture_root = CONTRACTS / "tenant-provisioning" / "fixtures" / "valid"
        authority, authority_issues = validator.load_json(
            CONTRACTS
            / "authority-matrix"
            / "fixtures"
            / "valid"
            / "authority-matrix.json"
        )
        binding, binding_issues = validator.load_json(
            fixture_root / "deployment-binding.json"
        )
        envelope, envelope_issues = validator.load_json(fixture_root / fixture_name)
        self.assertEqual(authority_issues + binding_issues + envelope_issues, [])
        return validator, authority, binding, envelope

    def test_upload_pointer_without_extract_passes(self):
        validator, authority, binding, envelope = self.load_envelope_bundle(
            "upload-pointer.json"
        )
        schemas, registry, schema_issues = validator.load_schemas(CONTRACTS)

        issues = validator.validate_schema(
            "inbound-envelope", envelope, schemas, registry
        )
        result = validator.validate_envelope(envelope, authority, binding)

        self.assertEqual(schema_issues, [])
        self.assertEqual(issues, [])
        self.assertEqual(result.issues, [])
        self.assertFalse(result.intake_hold_required)

    def test_upload_pointer_with_classified_extract_passes(self):
        validator, authority, binding, envelope = self.load_envelope_bundle(
            "upload-pointer-with-extract.json"
        )
        schemas, registry, schema_issues = validator.load_schemas(CONTRACTS)

        issues = validator.validate_schema(
            "inbound-envelope", envelope, schemas, registry
        )
        result = validator.validate_envelope(envelope, authority, binding)

        self.assertEqual(schema_issues, [])
        self.assertEqual(issues, [])
        self.assertEqual(result.issues, [])
        self.assertFalse(result.intake_hold_required)

    def test_domain_event_with_resolved_date_passes(self):
        validator, authority, binding, envelope = self.load_envelope_bundle(
            "domain-event.json"
        )
        schemas, registry, schema_issues = validator.load_schemas(CONTRACTS)

        issues = validator.validate_schema(
            "inbound-envelope", envelope, schemas, registry
        )
        result = validator.validate_envelope(envelope, authority, binding)

        self.assertEqual(schema_issues, [])
        self.assertEqual(issues, [])
        self.assertEqual(result.issues, [])
        self.assertFalse(result.intake_hold_required)

    def test_unknown_date_is_valid_but_requires_intake_hold(self):
        validator, authority, binding, envelope = self.load_envelope_bundle(
            "unknown-date.json"
        )
        schemas, registry, schema_issues = validator.load_schemas(CONTRACTS)

        issues = validator.validate_schema(
            "inbound-envelope", envelope, schemas, registry
        )
        result = validator.validate_envelope(envelope, authority, binding)

        self.assertEqual(schema_issues, [])
        self.assertEqual(issues, [])
        self.assertEqual(result.issues, [])
        self.assertTrue(result.intake_hold_required)

    def assert_envelope_reason(self, envelope, expected_reason):
        validator, authority, binding, _ = self.load_envelope_bundle(
            "upload-pointer-with-extract.json"
        )
        result = validator.validate_envelope(envelope, authority, binding)
        self.assertEqual([issue.code for issue in result.issues], [expected_reason])

    def test_missing_pointer_has_stable_reason(self):
        _, _, _, envelope = self.load_envelope_bundle("upload-pointer.json")
        mutated = deepcopy(envelope)
        del mutated["source"]

        self.assert_envelope_reason(mutated, "POINTER_REQUIRED")

    def test_embedded_raw_content_has_stable_reason(self):
        _, _, _, envelope = self.load_envelope_bundle("upload-pointer.json")
        for forbidden_field in ("raw_content", "binary", "blob", "data"):
            with self.subTest(forbidden_field=forbidden_field):
                mutated = deepcopy(envelope)
                mutated[forbidden_field] = "synthetic forbidden content"
                self.assert_envelope_reason(mutated, "RAW_CONTENT_FORBIDDEN")

    def test_base64_transfer_encoding_has_stable_reason(self):
        _, _, _, envelope = self.load_envelope_bundle(
            "upload-pointer-with-extract.json"
        )
        mutated = deepcopy(envelope)
        mutated["extract"]["content_transfer_encoding"] = "base64"

        self.assert_envelope_reason(mutated, "EXTRACT_ENCODING_FORBIDDEN")

    def test_recognizable_base64_data_uri_has_stable_reason(self):
        _, _, _, envelope = self.load_envelope_bundle(
            "upload-pointer-with-extract.json"
        )
        mutated = deepcopy(envelope)
        mutated["extract"]["text"] = "DaTa:text/plain;BaSe64,U3ludGhldGlj"

        self.assert_envelope_reason(mutated, "EXTRACT_ENCODING_FORBIDDEN")

    def test_extract_over_utf8_byte_limit_has_stable_reason(self):
        _, _, _, envelope = self.load_envelope_bundle(
            "upload-pointer-with-extract.json"
        )
        mutated = deepcopy(envelope)
        mutated["extract"]["text"] = "a" * 65537

        self.assert_envelope_reason(mutated, "EXTRACT_TOO_LARGE")

    def test_extract_at_exact_utf8_byte_limit_passes(self):
        validator, authority, binding, envelope = self.load_envelope_bundle(
            "upload-pointer-with-extract.json"
        )
        mutated = deepcopy(envelope)
        mutated["extract"]["text"] = "é" * 32768
        length, digest = validator.extract_measurements(mutated["extract"])
        mutated["extract"]["utf8_byte_length"] = length
        mutated["extract"]["sha256"] = digest
        schemas, registry, schema_issues = validator.load_schemas(CONTRACTS)

        issues = validator.validate_schema(
            "inbound-envelope", mutated, schemas, registry
        )
        result = validator.validate_envelope(mutated, authority, binding)

        self.assertEqual(length, 65536)
        self.assertEqual(schema_issues, [])
        self.assertEqual(issues, [])
        self.assertEqual(result.issues, [])

    def test_false_extract_byte_length_has_stable_reason(self):
        _, _, _, envelope = self.load_envelope_bundle(
            "upload-pointer-with-extract.json"
        )
        mutated = deepcopy(envelope)
        mutated["extract"]["utf8_byte_length"] += 1

        self.assert_envelope_reason(mutated, "EXTRACT_LENGTH_MISMATCH")

    def test_changed_extract_with_old_digest_has_stable_reason(self):
        _, _, _, envelope = self.load_envelope_bundle(
            "upload-pointer-with-extract.json"
        )
        mutated = deepcopy(envelope)
        mutated["extract"]["text"] = mutated["extract"]["text"][:-1] + "!"

        self.assert_envelope_reason(mutated, "EXTRACT_DIGEST_MISMATCH")

    def test_missing_provenance_has_stable_reason(self):
        _, _, _, envelope = self.load_envelope_bundle("upload-pointer.json")
        mutated = deepcopy(envelope)
        del mutated["provenance"]

        self.assert_envelope_reason(mutated, "PROVENANCE_DATE_REQUIRED")

    def test_invalid_resolved_date_has_stable_reason(self):
        _, _, _, envelope = self.load_envelope_bundle("upload-pointer.json")
        mutated = deepcopy(envelope)
        mutated["provenance"]["source_date"] = "2026-02-30"

        self.assert_envelope_reason(mutated, "PROVENANCE_DATE_INVALID")

    def test_unknown_date_without_reason_has_stable_reason(self):
        _, _, _, envelope = self.load_envelope_bundle("unknown-date.json")
        mutated = deepcopy(envelope)
        del mutated["provenance"]["reason"]

        self.assert_envelope_reason(
            mutated, "PROVENANCE_UNKNOWN_REASON_REQUIRED"
        )

    def test_noncanonical_envelope_ids_have_stable_reason(self):
        _, _, _, envelope = self.load_envelope_bundle("upload-pointer.json")
        invalid_ids = (
            envelope["envelope_id"].upper(),
            "123e4567-e89b-12d3-a456-426614174000",
        )

        for envelope_id in invalid_ids:
            with self.subTest(envelope_id=envelope_id):
                mutated = deepcopy(envelope)
                mutated["envelope_id"] = envelope_id
                self.assert_envelope_reason(mutated, "ENVELOPE_ID_INVALID")

    def test_destination_mismatch_has_stable_reason(self):
        _, _, _, envelope = self.load_envelope_bundle("upload-pointer.json")
        mutated = deepcopy(envelope)
        mutated["destination"] = "sources/synthetic.json"

        self.assert_envelope_reason(mutated, "UNSAFE_DESTINATION")

    def test_changed_idempotency_tuple_with_old_key_has_stable_reason(self):
        _, _, _, envelope = self.load_envelope_bundle("upload-pointer.json")
        mutated = deepcopy(envelope)
        mutated["source"]["version_id"] = "version-002"

        self.assert_envelope_reason(mutated, "IDEMPOTENCY_KEY_MISMATCH")

    def test_pointer_system_must_match_envelope_authority(self):
        validator, authority, binding, envelope = self.load_envelope_bundle(
            "upload-pointer.json"
        )
        mutated = deepcopy(envelope)
        mutated["source"]["system"] = "event_store"
        mutated["idempotency_key"] = validator.expected_idempotency_key(mutated)

        result = validator.validate_envelope(mutated, authority, binding)

        self.assertEqual([issue.code for issue in result.issues], ["SCHEMA_INVALID"])

    def test_pointer_rejects_http_resolvers_and_credential_fields(self):
        validator, _, _, envelope = self.load_envelope_bundle("upload-pointer.json")
        schemas, registry, schema_issues = validator.load_schemas(CONTRACTS)
        mutations = []

        http_resolver = deepcopy(envelope)
        http_resolver["source"]["resolver_ref"] = "https://example.invalid/object"
        mutations.append(http_resolver)

        credential_field = deepcopy(envelope)
        credential_field["source"]["bearer_token"] = "synthetic-secret"
        mutations.append(credential_field)

        self.assertEqual(schema_issues, [])
        for mutated in mutations:
            with self.subTest(source=mutated["source"]):
                issues = validator.validate_schema(
                    "inbound-envelope", mutated, schemas, registry
                )
                self.assertEqual([issue.code for issue in issues], ["SCHEMA_INVALID"])

    def test_envelope_tenant_must_match_binding(self):
        validator, authority, binding, envelope = self.load_envelope_bundle(
            "upload-pointer.json"
        )
        mutated = deepcopy(envelope)
        mutated["tenant_id"] = "tenant-other"
        mutated["idempotency_key"] = validator.expected_idempotency_key(mutated)

        result = validator.validate_envelope(mutated, authority, binding)

        self.assertEqual([issue.code for issue in result.issues], ["TENANT_MISMATCH"])

    def test_envelope_deployment_must_match_binding(self):
        validator, authority, binding, envelope = self.load_envelope_bundle(
            "upload-pointer.json"
        )
        mutated = deepcopy(envelope)
        mutated["deployment_id"] = "deployment-other"

        result = validator.validate_envelope(mutated, authority, binding)

        self.assertEqual(
            [issue.code for issue in result.issues], ["DEPLOYMENT_MISMATCH"]
        )

    def test_envelope_policy_must_be_bound_to_tenant(self):
        validator, authority, binding, envelope = self.load_envelope_bundle(
            "upload-pointer.json"
        )
        mutated = deepcopy(envelope)
        mutated["classification_policy_ref"] = "policies/unbound-synthetic-policy"

        result = validator.validate_envelope(mutated, authority, binding)

        self.assertEqual([issue.code for issue in result.issues], ["SCHEMA_INVALID"])

    def test_only_active_binding_accepts_inbound_envelopes(self):
        validator, authority, binding, envelope = self.load_envelope_bundle(
            "upload-pointer.json"
        )
        frozen_binding = deepcopy(binding)
        frozen_binding["lifecycle"] = "frozen"

        result = validator.validate_envelope(envelope, authority, frozen_binding)

        self.assertEqual([issue.code for issue in result.issues], ["SCHEMA_INVALID"])

    def test_nested_classification_policies_must_be_bound_to_tenant(self):
        validator, authority, binding, upload = self.load_envelope_bundle(
            "upload-pointer-with-extract.json"
        )
        mutated_upload = deepcopy(upload)
        mutated_upload["extract"]["classification_policy_ref"] = (
            "policies/unbound-synthetic-policy"
        )
        _, _, _, domain_event = self.load_envelope_bundle("domain-event.json")
        mutated_event = deepcopy(domain_event)
        mutated_event["domain_assertion"]["classification_policy_refs"] = [
            "policies/unbound-synthetic-policy"
        ]

        for envelope in (mutated_upload, mutated_event):
            with self.subTest(envelope_type=envelope["envelope_type"]):
                result = validator.validate_envelope(envelope, authority, binding)
                self.assertEqual(
                    [issue.code for issue in result.issues], ["SCHEMA_INVALID"]
                )

    def test_schema_failures_use_their_named_envelope_reasons(self):
        validator, _, _, baseline = self.load_envelope_bundle(
            "upload-pointer-with-extract.json"
        )
        _, _, _, unknown_date = self.load_envelope_bundle("unknown-date.json")
        mutations = []

        uppercase_id = deepcopy(baseline)
        uppercase_id["envelope_id"] = uppercase_id["envelope_id"].upper()
        mutations.append((uppercase_id, "ENVELOPE_ID_INVALID"))

        unsafe_destination = deepcopy(baseline)
        unsafe_destination["destination"] = "sources/synthetic.json"
        mutations.append((unsafe_destination, "UNSAFE_DESTINATION"))

        missing_pointer = deepcopy(baseline)
        del missing_pointer["source"]
        mutations.append((missing_pointer, "POINTER_REQUIRED"))

        embedded_raw = deepcopy(baseline)
        embedded_raw["raw_content"] = "synthetic"
        mutations.append((embedded_raw, "RAW_CONTENT_FORBIDDEN"))

        base64_encoding = deepcopy(baseline)
        base64_encoding["extract"]["content_transfer_encoding"] = "base64"
        mutations.append((base64_encoding, "EXTRACT_ENCODING_FORBIDDEN"))

        missing_provenance = deepcopy(baseline)
        del missing_provenance["provenance"]
        mutations.append((missing_provenance, "PROVENANCE_DATE_REQUIRED"))

        invalid_date = deepcopy(baseline)
        invalid_date["provenance"]["source_date"] = "not-a-date"
        mutations.append((invalid_date, "PROVENANCE_DATE_INVALID"))

        missing_unknown_reason = deepcopy(unknown_date)
        del missing_unknown_reason["provenance"]["reason"]
        mutations.append(
            (missing_unknown_reason, "PROVENANCE_UNKNOWN_REASON_REQUIRED")
        )

        schemas, registry, schema_issues = validator.load_schemas(CONTRACTS)
        self.assertEqual(schema_issues, [])
        for envelope, expected_reason in mutations:
            with self.subTest(expected_reason=expected_reason):
                issues = validator.validate_schema(
                    "inbound-envelope", envelope, schemas, registry
                )
                self.assertEqual(
                    [issue.code for issue in issues], [expected_reason]
                )


class WorkflowContractTests(unittest.TestCase):
    def test_glassity_workflow_pins_runtime_dependency_and_explicit_suite(self):
        workflow = (ROOT / ".github" / "workflows" / "glassity-contracts.yml").read_text(
            encoding="utf-8"
        )
        required_fragments = (
            "actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683",
            "actions/setup-python@5fda3b95a4ea91299a34e894583c3862153e4b97",
            "python-version: '3.9'",
            "python -m pip install --disable-pip-version-check -r glassity/contracts/requirements-test.txt",
            "python glassity/contracts/validate_contracts.py --self-check",
            "python -m unittest discover -s glassity/contracts/spec_tests -p 'test_*.py' -v",
        )
        for fragment in required_fragments:
            with self.subTest(fragment=fragment):
                self.assertIn(fragment, workflow)

    def test_legacy_discovery_path_is_absent(self):
        self.assertFalse((CONTRACTS / "tests" / "test_contracts.py").exists())


if __name__ == "__main__":
    unittest.main()
