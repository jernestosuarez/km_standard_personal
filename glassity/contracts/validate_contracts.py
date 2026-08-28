#!/usr/bin/env python3
import argparse
from dataclasses import dataclass
from importlib import metadata
import json
from pathlib import Path
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


def _ordered_unique(issues: list[Issue]) -> list[Issue]:
    order = {code: index for index, code in enumerate(REASON_ORDER)}
    unique = {(issue.code, issue.path, issue.message): issue for issue in issues}
    return sorted(
        unique.values(),
        key=lambda issue: (
            order.get(issue.code, len(REASON_ORDER)),
            issue.path,
            issue.message,
        ),
    )


def load_json(path: Path) -> tuple[Optional[object], list[Issue]]:
    try:
        return json.loads(path.read_text(encoding="utf-8")), []
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
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
        if kind == "deployment-binding" and (
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
    args = parser.parse_args(argv)
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
    parser.error("bundle command is required")


if __name__ == "__main__":
    raise SystemExit(main())
