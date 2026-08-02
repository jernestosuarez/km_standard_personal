#!/usr/bin/env python3
import argparse
import datetime as dt
import json
from pathlib import Path, PurePosixPath
import re
import sys

REQUIRED = {
    "schema_version", "profile_id", "profile_revision", "organization", "approval",
    "canonical_compatibility", "enterprise_binding", "policy_references",
    "supervisor_binding", "operations", "forbidden_operations", "effective_date", "lifecycle",
}
FORBIDDEN = {
    "replace_canonical_initializer", "copy_canonical_template",
    "weaken_canonical_governance", "replace_generic_agent_instructions",
    "copy_enterprise_records", "enable_module_without_eligibility",
}
REVISION = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$")
SHA256 = re.compile(r"^[0-9a-f]{64}$")
MODULE_ID = re.compile(r"^[a-z0-9][a-z0-9-]*$")


def parse_version(value):
    if not isinstance(value, str) or not re.fullmatch(r"[0-9]+\.[0-9]+", value):
        raise ValueError(f"invalid version: {value!r}")
    return tuple(int(part) for part in value.split("."))


def valid_date(value):
    if not isinstance(value, str):
        return False
    try:
        dt.date.fromisoformat(value)
    except ValueError:
        return False
    return True


def safe_relative(value):
    if not isinstance(value, str) or not value:
        return False
    path = PurePosixPath(value)
    return not path.is_absolute() and ".." not in path.parts


def exact_object(value, keys, label, errors):
    if not isinstance(value, dict):
        errors.append(f"{label} must be an object")
        return False
    missing = keys - set(value)
    unknown = set(value) - keys
    errors.extend(f"{label} missing key: {key}" for key in sorted(missing))
    errors.extend(f"{label} unknown key: {key}" for key in sorted(unknown))
    return not missing and not unknown


def validate_operations(operations, errors):
    if not isinstance(operations, list):
        errors.append("operations must be a list")
        return
    targets = set()
    for index, operation in enumerate(operations):
        label = f"operations[{index}]"
        if not isinstance(operation, dict):
            errors.append(f"{label} must be an object")
            continue
        kind = operation.get("kind")
        if kind == "add":
            exact_object(operation, {"kind", "target", "source", "sha256"}, label, errors)
            target = operation.get("target")
            if not safe_relative(target) or not target.startswith(".km/organization/"):
                errors.append(f"unsafe operation target: {target!r}")
            elif target in targets:
                errors.append(f"duplicate operation target: {target}")
            else:
                targets.add(target)
        elif kind == "module":
            exact_object(
                operation,
                {"kind", "module_id", "source", "sha256", "eligibility_record"},
                label,
                errors,
            )
            module_id = operation.get("module_id")
            if not isinstance(module_id, str) or not MODULE_ID.fullmatch(module_id):
                errors.append(f"{label} module_id is invalid")
            eligibility_record = operation.get("eligibility_record")
            if not isinstance(eligibility_record, str) or not eligibility_record:
                errors.append("module operation requires eligibility_record")
        else:
            errors.append(f"{label} has unsupported kind: {kind!r}")
        if not safe_relative(operation.get("source")):
            errors.append(f"unsafe operation source: {operation.get('source')!r}")
        sha256 = operation.get("sha256")
        if not isinstance(sha256, str) or not SHA256.fullmatch(sha256):
            errors.append(f"{label} has invalid sha256")


def validate_profile(profile, canonical_version):
    errors = []
    if not isinstance(profile, dict):
        return ["profile must be an object"]
    missing = REQUIRED - set(profile)
    unknown = set(profile) - REQUIRED
    errors.extend(f"missing required key: {key}" for key in sorted(missing))
    errors.extend(f"unknown top-level key: {key}" for key in sorted(unknown))
    if missing:
        return errors
    if profile["schema_version"] != "1.0":
        errors.append("schema_version must be 1.0")
    if not isinstance(profile["profile_id"], str) or not profile["profile_id"]:
        errors.append("profile_id must be a non-empty string")
    if not isinstance(profile["profile_revision"], str) or not REVISION.fullmatch(profile["profile_revision"]):
        errors.append("profile_revision is invalid")
    if exact_object(profile["organization"], {"id", "name"}, "organization", errors):
        if not all(isinstance(profile["organization"][key], str) and profile["organization"][key]
                   for key in ("id", "name")):
            errors.append("organization id and name must be non-empty strings")
    if exact_object(profile["approval"], {"record_id", "approved_at"}, "approval", errors):
        if (not isinstance(profile["approval"]["record_id"], str)
                or not profile["approval"]["record_id"]):
            errors.append("approval record_id must be a non-empty string")
        if not valid_date(profile["approval"]["approved_at"]):
            errors.append("approval approved_at must be a valid YYYY-MM-DD date")
    compatibility = profile["canonical_compatibility"]
    if exact_object(compatibility, {"minimum", "maximum_exclusive"}, "canonical_compatibility", errors):
        try:
            current = parse_version(canonical_version)
            minimum = parse_version(compatibility["minimum"])
            maximum = parse_version(compatibility["maximum_exclusive"])
            if not minimum <= current < maximum:
                errors.append(f"canonical version {canonical_version} is incompatible")
        except ValueError as exc:
            errors.append(str(exc))
    binding = profile["enterprise_binding"]
    if exact_object(binding, {"namespace", "contract_revision"}, "enterprise_binding", errors):
        if not isinstance(binding["namespace"], str) or not binding["namespace"]:
            errors.append("enterprise namespace must be a non-empty string")
        if (not isinstance(binding["contract_revision"], str)
                or not REVISION.fullmatch(binding["contract_revision"])):
            errors.append("enterprise contract_revision is invalid")
    references = profile["policy_references"]
    if not isinstance(references, list) or any(not isinstance(item, str) or not item for item in references):
        errors.append("policy_references must be a list of non-empty strings")
    elif len(references) != len(set(references)):
        errors.append("policy_references must be unique")
    supervisor = profile["supervisor_binding"]
    if exact_object(supervisor, {"profile_operation"}, "supervisor_binding", errors):
        if supervisor["profile_operation"] != "resolve_organization_profile":
            errors.append("unsupported supervisor profile_operation")
    validate_operations(profile["operations"], errors)
    forbidden = profile["forbidden_operations"]
    if (not isinstance(forbidden, list)
            or len(forbidden) != len(FORBIDDEN)
            or any(not isinstance(item, str) for item in forbidden)
            or set(forbidden) != FORBIDDEN):
        errors.append("forbidden_operations must contain exactly the six canonical prohibitions")
    if not valid_date(profile["effective_date"]):
        errors.append("effective_date must be a valid YYYY-MM-DD date")
    if (not isinstance(profile["lifecycle"], str)
            or profile["lifecycle"] not in {"active", "superseded", "retired"}):
        errors.append("lifecycle is invalid")
    return errors


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("profile", type=Path)
    parser.add_argument("--canonical-version", required=True)
    args = parser.parse_args()
    try:
        profile = json.loads(args.profile.read_text(encoding="utf-8"))
    except (OSError, UnicodeDecodeError, json.JSONDecodeError) as exc:
        print(f"INVALID OrganizationProfile: {exc}", file=sys.stderr)
        return 1
    try:
        errors = validate_profile(profile, args.canonical_version)
    except (KeyError, TypeError, ValueError):
        print("INVALID OrganizationProfile: malformed profile shape", file=sys.stderr)
        return 1
    if errors:
        for error in errors:
            print(f"INVALID OrganizationProfile: {error}", file=sys.stderr)
        return 1
    print(f"VALID OrganizationProfile: {profile['profile_id']}@{profile['profile_revision']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
