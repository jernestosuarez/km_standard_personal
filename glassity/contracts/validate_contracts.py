#!/usr/bin/env python3
import argparse
from dataclasses import dataclass
from datetime import date
import hashlib
from importlib import metadata
import json
from pathlib import Path
import re
import sys
from typing import Optional


REASON_ORDER = (
    "JSON_INVALID",
    "DEPENDENCY_MISSING",
    "SCHEMA_INVALID",
    "AUTHORITY_SET_INCOMPLETE",
    "AUTHORITY_SET_UNKNOWN",
    "AUTHORITY_SYSTEM_MISMATCH",
    "TENANT_MISMATCH",
    "DEPLOYMENT_MISMATCH",
    "ERASURE_MAP_INCOMPLETE",
    "PROVISIONING_ORDER_INVALID",
    "PROVISIONING_DIGEST_MISMATCH",
    "POINTER_REQUIRED",
    "RAW_CONTENT_FORBIDDEN",
    "ENVELOPE_ID_INVALID",
    "UNSAFE_DESTINATION",
    "EXTRACT_ENCODING_FORBIDDEN",
    "EXTRACT_TOO_LARGE",
    "EXTRACT_LENGTH_MISMATCH",
    "EXTRACT_DIGEST_MISMATCH",
    "IDEMPOTENCY_KEY_MISMATCH",
    "PROVENANCE_DATE_REQUIRED",
    "PROVENANCE_DATE_INVALID",
    "PROVENANCE_UNKNOWN_REASON_REQUIRED",
)


@dataclass(frozen=True)
class Issue:
    code: str
    path: str
    message: str


@dataclass(frozen=True)
class EnvelopeValidation:
    issues: list[Issue]
    intake_hold_required: bool


AUTHORITY = {
    "raw_upload": ("object_storage", {"pointer"}),
    "app_object": (
        "application_database",
        {"pointer", "digest", "claim", "decision"},
    ),
    "app_event": ("event_store", {"pointer", "digest", "claim", "decision"}),
    "digest": ("tenant_hub", {"governed_digest"}),
    "claim": ("tenant_hub", {"governed_claim"}),
    "decision": ("tenant_hub", {"governed_decision"}),
    "classified_extract": ("tenant_hub", {"classified_text_extract"}),
    "pointer": ("tenant_hub", {"resolvable_pointer"}),
    "owner_queue": ("tenant_hub", {"governed_queue_record"}),
    "execution_record": ("tenant_hub", {"governed_execution_record"}),
    "pending_answer": ("pending_answer_store", {"none_until_pull"}),
    "audit_event": ("audit_store", {"non_content_evidence_pointer"}),
}

ERASURE_CATEGORIES = {
    "iam_session",
    "worker_transient",
    "pending_answer_queue",
    "app_database_event",
    "derived_projection_index",
    "s3_object_version",
    "github_repository",
    "backup_recovery",
    "scan_event_finding",
    "audit_log",
    "anthropic_control_plane",
    "export_staging",
    "tenant_secret",
}

IDEMPOTENCY_NAMESPACE = "glassity.inbound-envelope.v1"
UUID4 = re.compile(
    r"^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$"
)
FORBIDDEN_CONTENT_FIELDS = {
    "raw_content",
    "raw_bytes",
    "blob",
    "binary",
    "binary_data",
    "data",
    "payload",
}


def canonical_json_bytes(value: object) -> bytes:
    return json.dumps(
        value, ensure_ascii=False, sort_keys=True, separators=(",", ":")
    ).encode("utf-8")


def sha256_hex(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def expected_idempotency_key(envelope: dict) -> str:
    fields = (
        IDEMPOTENCY_NAMESPACE,
        envelope["tenant_id"],
        envelope["envelope_type"],
        envelope["source"]["system"],
        envelope["source"]["object_id"],
        envelope["source"]["version_id"],
    )
    if any(not value or "\0" in value for value in fields):
        raise ValueError("idempotency tuple fields must be non-empty and NUL-free")
    return sha256_hex("\0".join(fields).encode("utf-8"))


def expected_destination(envelope_id: str) -> str:
    if not UUID4.fullmatch(envelope_id):
        raise ValueError("invalid canonical UUIDv4")
    return f"_inbox/{envelope_id}.json"


def _contains_forbidden_content_field(value: object) -> bool:
    if isinstance(value, dict):
        if FORBIDDEN_CONTENT_FIELDS.intersection(value):
            return True
        return any(_contains_forbidden_content_field(item) for item in value.values())
    if isinstance(value, list):
        return any(_contains_forbidden_content_field(item) for item in value)
    return False


def extract_measurements(extract: dict) -> tuple[int, str]:
    raw = extract["text"].encode("utf-8")
    return len(raw), sha256_hex(raw)


def _ordered_unique(issues: list[Issue]) -> list[Issue]:
    order = {code: index for index, code in enumerate(REASON_ORDER)}
    unique = {}
    for issue in issues:
        unique.setdefault(issue.code, issue)
    return sorted(
        unique.values(),
        key=lambda issue: order.get(issue.code, len(REASON_ORDER)),
    )


def load_json(path: Path) -> tuple[Optional[object], list[Issue]]:
    try:
        return json.loads(path.read_text(encoding="utf-8")), []
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        return None, [Issue("JSON_INVALID", "/", f"{path}: {error}")]


def _decode_json_bytes(path: Path, value: bytes) -> tuple[Optional[object], list[Issue]]:
    try:
        return json.loads(value), []
    except (UnicodeError, json.JSONDecodeError) as error:
        return None, [Issue("JSON_INVALID", "/", f"{path}: {error}")]


def load_schemas(root: Path) -> tuple[dict[str, dict], object, list[Issue]]:
    runtime = schema_runtime()
    if runtime is None:
        return {}, None, [
            Issue(
                "DEPENDENCY_MISSING",
                "/",
                "jsonschema==4.25.1 is required",
            )
        ]

    Draft202012Validator, Registry, Resource = runtime
    schemas = {}
    resources = []
    issues = []
    for path in sorted(root.rglob("*.schema.json")):
        schema, parse_issues = load_json(path)
        issues.extend(parse_issues)
        if schema is None:
            continue
        try:
            Draft202012Validator.check_schema(schema)
            resource = Resource.from_contents(schema)
        except Exception as error:  # jsonschema/referencing expose several subclasses
            issues.append(Issue("SCHEMA_INVALID", "/", f"{path}: {error}"))
            continue
        kind = path.name.removesuffix(".schema.json")
        if kind == "authority-matrix":
            kind = "authority"
        schemas[kind] = schema
        resources.append((schema["$id"], resource))

    registry = Registry().with_resources(resources)
    return schemas, registry, _ordered_unique(issues)


def validate_schema(
    kind: str, value: object, schemas: dict, registry: object
) -> list[Issue]:
    runtime = schema_runtime()
    if runtime is None:
        return [Issue("DEPENDENCY_MISSING", "/", "jsonschema==4.25.1 is required")]
    schema = schemas.get(kind)
    if schema is None:
        return [Issue("SCHEMA_INVALID", "/", f"schema is not loaded: {kind}")]

    Draft202012Validator, _, _ = runtime
    issues = []
    for error in Draft202012Validator(schema, registry=registry).iter_errors(value):
        path = "/" + "/".join(str(part) for part in error.absolute_path)
        path_parts = list(error.absolute_path)
        missing_erasure_map = (
            error.validator == "required"
            and isinstance(error.instance, dict)
            and "erasure_map" not in error.instance
            and not error.absolute_path
            and error.message == "'erasure_map' is a required property"
        )
        incomplete_erasure_entries = (
            error.validator == "minItems"
            and list(error.absolute_path) == ["erasure_map", "entries"]
        )
        if kind == "inbound-envelope":
            code = "SCHEMA_INVALID"
            if path_parts == ["envelope_id"]:
                code = "ENVELOPE_ID_INVALID"
            elif path_parts == ["destination"]:
                code = "UNSAFE_DESTINATION"
            elif path_parts == ["extract", "content_transfer_encoding"]:
                code = "EXTRACT_ENCODING_FORBIDDEN"
            elif path_parts == ["provenance"] and isinstance(
                error.instance, dict
            ):
                date_status = error.instance.get("date_status")
                if date_status == "resolved":
                    code = "PROVENANCE_DATE_INVALID"
                elif date_status == "unknown":
                    code = "PROVENANCE_UNKNOWN_REASON_REQUIRED"
                else:
                    code = "PROVENANCE_DATE_REQUIRED"
            elif error.validator == "required" and isinstance(
                error.instance, dict
            ):
                missing = set(error.validator_value) - set(error.instance)
                if "source" in missing:
                    code = "POINTER_REQUIRED"
                    path = "/source"
                elif "provenance" in missing or (
                    path_parts == ["provenance"] and "date_status" in missing
                ):
                    code = "PROVENANCE_DATE_REQUIRED"
                    path = "/provenance"
            elif error.validator == "additionalProperties" and isinstance(
                error.instance, dict
            ):
                allowed = set(error.schema.get("properties", {}))
                unexpected = set(error.instance) - allowed
                if unexpected.intersection(FORBIDDEN_CONTENT_FIELDS):
                    code = "RAW_CONTENT_FORBIDDEN"
            issues.append(Issue(code, path, error.message))
        elif kind == "deployment-binding" and (
            missing_erasure_map or incomplete_erasure_entries
        ):
            issues.append(
                Issue(
                    "ERASURE_MAP_INCOMPLETE",
                    (
                        "/erasure_map/entries"
                        if incomplete_erasure_entries
                        else "/erasure_map"
                    ),
                    "deployment binding must embed a complete erasure map",
                )
            )
        else:
            issues.append(Issue("SCHEMA_INVALID", path, error.message))
    return _ordered_unique(issues)


def validate_authority_matrix(value: dict) -> list[Issue]:
    rows = value.get("rows", []) if isinstance(value, dict) else []
    names = [row.get("data_class") for row in rows if isinstance(row, dict)]
    actual = set(names)
    issues = []
    if set(AUTHORITY) - actual:
        issues.append(
            Issue(
                "AUTHORITY_SET_INCOMPLETE",
                "/rows",
                "required authority rows are missing",
            )
        )
    if actual - set(AUTHORITY) or len(names) != len(actual):
        issues.append(
            Issue(
                "AUTHORITY_SET_UNKNOWN",
                "/rows",
                "unknown or duplicate authority rows are forbidden",
            )
        )
    for index, row in enumerate(rows):
        if not isinstance(row, dict) or row.get("data_class") not in AUTHORITY:
            continue
        expected_system, expected_representations = AUTHORITY[row["data_class"]]
        if (
            row.get("system_of_record") != expected_system
            or set(row.get("hub_representations", [])) != expected_representations
        ):
            issues.append(
                Issue(
                    "AUTHORITY_SYSTEM_MISMATCH",
                    f"/rows/{index}",
                    f"authority mapping changed for {row['data_class']}",
                )
            )
    return _ordered_unique(issues)


def validate_binding(value: dict) -> list[Issue]:
    if not isinstance(value, dict) or not isinstance(value.get("erasure_map"), dict):
        return [
            Issue(
                "ERASURE_MAP_INCOMPLETE",
                "/erasure_map",
                "deployment binding must embed an erasure map",
            )
        ]
    erasure_map = value["erasure_map"]
    entries = erasure_map.get("entries", []) if isinstance(erasure_map, dict) else []
    categories = [
        entry.get("category") for entry in entries if isinstance(entry, dict)
    ]
    issues = []
    if set(categories) != ERASURE_CATEGORIES or len(categories) != len(set(categories)):
        issues.append(
            Issue(
                "ERASURE_MAP_INCOMPLETE",
                "/erasure_map/entries",
                "erasure map must contain each required category exactly once",
            )
        )
    if erasure_map.get("tenant_id") != value.get("tenant_id"):
        issues.append(
            Issue(
                "TENANT_MISMATCH",
                "/erasure_map/tenant_id",
                "erasure map tenant differs from binding tenant",
            )
        )
    if erasure_map.get("deployment_id") != value.get("deployment_id"):
        issues.append(
            Issue(
                "DEPLOYMENT_MISMATCH",
                "/erasure_map/deployment_id",
                "erasure map deployment differs from binding deployment",
            )
        )
    return _ordered_unique(issues)


def validate_receipt(value: dict, binding_bytes: bytes, binding: dict) -> list[Issue]:
    issues = []
    if value.get("tenant_id") != binding.get("tenant_id"):
        issues.append(
            Issue(
                "TENANT_MISMATCH",
                "/tenant_id",
                "receipt tenant differs from binding tenant",
            )
        )
    if value.get("deployment_id") != binding.get("deployment_id"):
        issues.append(
            Issue(
                "DEPLOYMENT_MISMATCH",
                "/deployment_id",
                "receipt deployment differs from binding deployment",
            )
        )
    order_mismatch = (
        value.get("overlay_parent_commit")
        != value.get("canonical_initialization_commit")
        or value.get("canonical_pin") != binding.get("canonical_commit")
        or value.get("overlay_revision") != binding.get("overlay_revision")
    )
    if order_mismatch:
        issues.append(
            Issue(
                "PROVISIONING_ORDER_INVALID",
                "/",
                "receipt declaration differs from its binding or expected parent",
            )
        )
    erasure_map = binding.get("erasure_map") if isinstance(binding, dict) else None
    binding_digest_matches = value.get("binding_sha256") == sha256_hex(binding_bytes)
    erasure_map_digest_matches = value.get("erasure_map_sha256") == sha256_hex(
        canonical_json_bytes(erasure_map)
    )
    if not binding_digest_matches or not erasure_map_digest_matches:
        path = (
            "/binding_sha256"
            if not binding_digest_matches
            else "/erasure_map_sha256"
        )
        issues.append(
            Issue(
                "PROVISIONING_DIGEST_MISMATCH",
                path,
                "receipt digest does not match recomputed contract bytes",
            )
        )
    return _ordered_unique(issues)


def validate_envelope(
    value: dict, authority: dict, binding: dict
) -> EnvelopeValidation:
    issues = []
    provenance = value.get("provenance")
    if not isinstance(provenance, dict) or "date_status" not in provenance:
        return EnvelopeValidation(
            [
                Issue(
                    "PROVENANCE_DATE_REQUIRED",
                    "/provenance",
                    "a provenance date-status block is required",
                )
            ],
            False,
        )
    if provenance.get("date_status") == "resolved":
        try:
            source_date = provenance["source_date"]
            if not isinstance(source_date, str):
                raise ValueError("source_date must be text")
            date.fromisoformat(source_date)
            if provenance.get("date_kind") not in {"document", "event", "version"}:
                raise ValueError("invalid date_kind")
        except (KeyError, TypeError, ValueError):
            return EnvelopeValidation(
                [
                    Issue(
                        "PROVENANCE_DATE_INVALID",
                        "/provenance",
                        "resolved provenance requires a real ISO date and approved date kind",
                    )
                ],
                False,
            )
    if provenance.get("date_status") == "unknown" and not provenance.get("reason"):
        return EnvelopeValidation(
            [
                Issue(
                    "PROVENANCE_UNKNOWN_REASON_REQUIRED",
                    "/provenance/reason",
                    "unknown provenance requires a non-empty reason",
                )
            ],
            True,
        )
    if not isinstance(value.get("source"), dict):
        return EnvelopeValidation(
            [
                Issue(
                    "POINTER_REQUIRED",
                    "/source",
                    "a content-addressed source pointer is required",
                )
            ],
            isinstance(provenance, dict)
            and provenance.get("date_status") == "unknown",
        )
    if _contains_forbidden_content_field(value):
        return EnvelopeValidation(
            [
                Issue(
                    "RAW_CONTENT_FORBIDDEN",
                    "/",
                    "embedded raw, blob, binary, data, or payload fields are forbidden",
                )
            ],
            isinstance(provenance, dict)
            and provenance.get("date_status") == "unknown",
        )
    extract = value.get("extract")
    if isinstance(extract, dict):
        text = extract.get("text")
        base64_data_uri = isinstance(text, str) and re.match(
            r"^data:[^,]*;base64,", text, re.IGNORECASE
        )
        if extract.get("content_transfer_encoding") != "identity" or base64_data_uri:
            return EnvelopeValidation(
                [
                    Issue(
                        "EXTRACT_ENCODING_FORBIDDEN",
                        "/extract",
                        "extract must be identity-encoded UTF-8 text, not base64",
                    )
                ],
                isinstance(provenance, dict)
                and provenance.get("date_status") == "unknown",
            )
        try:
            extract_length, extract_digest = extract_measurements(extract)
        except (KeyError, AttributeError, TypeError, UnicodeError):
            extract_length = 0
            extract_digest = ""
        if extract_length > 65536:
            return EnvelopeValidation(
                [Issue("EXTRACT_TOO_LARGE", "/extract/text", "extract exceeds 65,536 UTF-8 bytes")],
                isinstance(provenance, dict)
                and provenance.get("date_status") == "unknown",
            )
        if extract.get("utf8_byte_length") != extract_length:
            return EnvelopeValidation(
                [
                    Issue(
                        "EXTRACT_LENGTH_MISMATCH",
                        "/extract/utf8_byte_length",
                        "declared extract length differs from exact UTF-8 bytes",
                    )
                ],
                isinstance(provenance, dict)
                and provenance.get("date_status") == "unknown",
            )
        if extract.get("sha256") != extract_digest:
            return EnvelopeValidation(
                [
                    Issue(
                        "EXTRACT_DIGEST_MISMATCH",
                        "/extract/sha256",
                        "declared extract digest differs from exact UTF-8 bytes",
                    )
                ],
                isinstance(provenance, dict)
                and provenance.get("date_status") == "unknown",
            )
    authority_rows = authority.get("rows", []) if isinstance(authority, dict) else []
    authorized_source = any(
        isinstance(row, dict)
        and row.get("system_of_record") == value["source"].get("system")
        and value.get("envelope_type") in row.get("envelope_types", [])
        and (
            value.get("envelope_type") != "upload_pointer"
            or row.get("data_class") == "raw_upload"
        )
        for row in authority_rows
    )
    if not authorized_source:
        issues.append(
            Issue(
                "SCHEMA_INVALID",
                "/source/system",
                "source system is not authoritative for this envelope type",
            )
        )
    if binding.get("lifecycle") != "active":
        issues.append(
            Issue(
                "SCHEMA_INVALID",
                "/lifecycle",
                "only an active deployment binding accepts inbound envelopes",
            )
        )
    if value.get("tenant_id") != binding.get("tenant_id"):
        issues.append(
            Issue(
                "TENANT_MISMATCH",
                "/tenant_id",
                "envelope tenant differs from binding tenant",
            )
        )
    if value.get("deployment_id") != binding.get("deployment_id"):
        issues.append(
            Issue(
                "DEPLOYMENT_MISMATCH",
                "/deployment_id",
                "envelope deployment differs from binding deployment",
            )
        )
    bound_policy_refs = set(binding.get("tenant_policy_refs", []))
    declared_policy_refs = [value.get("classification_policy_ref")]
    if isinstance(extract, dict):
        declared_policy_refs.append(extract.get("classification_policy_ref"))
    assertion = value.get("domain_assertion")
    if isinstance(assertion, dict) and isinstance(
        assertion.get("classification_policy_refs"), list
    ):
        declared_policy_refs.extend(assertion["classification_policy_refs"])
    if any(policy_ref not in bound_policy_refs for policy_ref in declared_policy_refs):
        issues.append(
            Issue(
                "SCHEMA_INVALID",
                "/classification_policy_ref",
                "classification policy is not present in the binding",
            )
        )
    try:
        if value.get("idempotency_key") != expected_idempotency_key(value):
            issues.append(
                Issue(
                    "IDEMPOTENCY_KEY_MISMATCH",
                    "/idempotency_key",
                    "idempotency key differs from recomputation",
                )
            )
    except (KeyError, TypeError, ValueError):
        issues.append(
            Issue(
                "IDEMPOTENCY_KEY_MISMATCH",
                "/idempotency_key",
                "idempotency tuple is invalid",
            )
        )
    try:
        if value.get("destination") != expected_destination(value.get("envelope_id", "")):
            issues.append(
                Issue(
                    "UNSAFE_DESTINATION",
                    "/destination",
                    "destination differs from the derived inbox path",
                )
            )
    except (TypeError, ValueError):
        issues.append(
            Issue(
                "ENVELOPE_ID_INVALID",
                "/envelope_id",
                "envelope ID is not canonical lowercase UUIDv4",
            )
        )
    return EnvelopeValidation(
        _ordered_unique(issues),
        isinstance(provenance, dict) and provenance.get("date_status") == "unknown",
    )


def validate_bundle(
    authority_path: Path,
    binding_path: Path,
    receipt_path: Path,
    envelope_paths: list[Path],
) -> list[Issue]:
    try:
        binding_bytes = binding_path.read_bytes()
    except OSError as error:
        return [Issue("JSON_INVALID", "/", f"{binding_path}: {error}")]

    binding, binding_load_issues = _decode_json_bytes(binding_path, binding_bytes)
    authority, authority_load_issues = load_json(authority_path)
    receipt, receipt_load_issues = load_json(receipt_path)
    envelopes = []
    envelope_load_issues = []
    for path in envelope_paths:
        envelope, load_issues = load_json(path)
        envelopes.append(envelope)
        envelope_load_issues.extend(load_issues)

    issues = (
        authority_load_issues
        + binding_load_issues
        + receipt_load_issues
        + envelope_load_issues
    )
    if issues:
        return _ordered_unique(issues)

    schemas, registry, schema_issues = load_schemas(Path(__file__).resolve().parent)
    issues.extend(schema_issues)
    if schema_issues:
        return _ordered_unique(issues)

    documents = [
        ("authority", authority),
        ("deployment-binding", binding),
        ("provisioning-receipt", receipt),
    ]
    documents.extend(("inbound-envelope", envelope) for envelope in envelopes)
    schema_results = []
    for kind, value in documents:
        result = validate_schema(kind, value, schemas, registry)
        schema_results.append(result)
        issues.extend(result)

    authority_schema, binding_schema, receipt_schema = schema_results[:3]
    envelope_schemas = schema_results[3:]
    if not authority_schema:
        issues.extend(validate_authority_matrix(authority))
    if not binding_schema:
        issues.extend(validate_binding(binding))
    if not receipt_schema and not binding_schema:
        issues.extend(validate_receipt(receipt, binding_bytes, binding))
    if not authority_schema and not binding_schema:
        for envelope, envelope_schema in zip(envelopes, envelope_schemas):
            if not envelope_schema:
                issues.extend(validate_envelope(envelope, authority, binding).issues)
    return _ordered_unique(issues)


def schema_runtime():
    try:
        from jsonschema import Draft202012Validator
        from referencing import Registry, Resource
    except ImportError:
        return None
    if metadata.version("jsonschema") != "4.25.1":
        return None
    return Draft202012Validator, Registry, Resource


def main(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-check", action="store_true")
    subparsers = parser.add_subparsers(dest="command")
    bundle_parser = subparsers.add_parser("bundle")
    bundle_parser.add_argument("--authority", type=Path, required=True)
    bundle_parser.add_argument("--binding", type=Path, required=True)
    bundle_parser.add_argument("--receipt", type=Path, required=True)
    bundle_parser.add_argument(
        "--envelope", type=Path, action="append", required=True
    )
    args = parser.parse_args(argv)
    if args.self_check and args.command is not None:
        parser.error("--self-check cannot be combined with a command")
    if not args.self_check and args.command != "bundle":
        parser.error("bundle command is required")
    runtime = schema_runtime()
    if runtime is None:
        print(
            "DEPENDENCY_MISSING\t/\tjsonschema==4.25.1 is required",
            file=sys.stderr,
        )
        return 1
    if args.self_check:
        print("VALID Draft202012Validator jsonschema==4.25.1")
        return 0
    issues = validate_bundle(
        args.authority,
        args.binding,
        args.receipt,
        args.envelope,
    )
    if issues:
        for issue in issues:
            print(
                f"{issue.code}\t{issue.path}\t{issue.message}",
                file=sys.stderr,
            )
        return 1
    binding, binding_issues = load_json(args.binding)
    if binding_issues or not isinstance(binding, dict):
        for issue in binding_issues or [
            Issue("JSON_INVALID", "/", "binding must be a JSON object")
        ]:
            print(
                f"{issue.code}\t{issue.path}\t{issue.message}",
                file=sys.stderr,
            )
        return 1
    print(
        "VALID foundation-contracts: "
        f"{binding['tenant_id']} {binding['deployment_id']} "
        f"{len(args.envelope)} envelope(s)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
