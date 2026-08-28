import importlib.util
from copy import deepcopy
import subprocess
import sys
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


if __name__ == "__main__":
    unittest.main()
