#!/usr/bin/env python3
import argparse
from dataclasses import dataclass
from importlib import metadata
import sys


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
