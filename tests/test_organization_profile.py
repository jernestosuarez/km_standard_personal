import json
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VALIDATOR = ROOT / "scripts" / "validate_organization_profile.py"


def valid_profile():
    return {
        "schema_version": "1.0",
        "profile_id": "urn:example:km-profile:main",
        "profile_revision": "profile-1",
        "organization": {"id": "urn:example:organization:main", "name": "Example Organization"},
        "approval": {"record_id": "urn:example:approval:42", "approved_at": "2026-08-01"},
        "canonical_compatibility": {"minimum": "1.14", "maximum_exclusive": "2.0"},
        "enterprise_binding": {
            "namespace": "urn:example:enterprise:",
            "contract_revision": "contract-7",
        },
        "policy_references": ["urn:example:policy:evidence"],
        "supervisor_binding": {"profile_operation": "resolve_organization_profile"},
        "operations": [],
        "forbidden_operations": [
            "replace_canonical_initializer",
            "copy_canonical_template",
            "weaken_canonical_governance",
            "replace_generic_agent_instructions",
            "copy_enterprise_records",
            "enable_module_without_eligibility",
        ],
        "effective_date": "2026-08-01",
        "lifecycle": "active",
    }


class OrganizationProfileValidatorTests(unittest.TestCase):
    def run_validator(self, profile):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "profile.json"
            path.write_text(json.dumps(profile), encoding="utf-8")
            return subprocess.run(
                ["python3", str(VALIDATOR), str(path), "--canonical-version", "1.14"],
                text=True,
                capture_output=True,
                check=False,
            )

    def assert_invalid(self, profile, expected):
        result = self.run_validator(profile)
        self.assertEqual(result.returncode, 1)
        self.assertIn("INVALID OrganizationProfile:", result.stderr)
        self.assertIn(expected, result.stderr)
        self.assertNotIn("Traceback", result.stderr)

    def test_accepts_minimal_valid_profile(self):
        result = self.run_validator(valid_profile())
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("VALID OrganizationProfile", result.stdout)

    def test_rejects_missing_approval(self):
        profile = valid_profile()
        del profile["approval"]
        result = self.run_validator(profile)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("missing required key: approval", result.stderr)

    def test_rejects_incompatible_canonical_version(self):
        profile = valid_profile()
        profile["canonical_compatibility"]["minimum"] = "1.15"
        result = self.run_validator(profile)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("canonical version 1.14 is incompatible", result.stderr)

    def test_rejects_absolute_or_parent_operation_paths(self):
        for target in ("/tmp/policy.md", "../policy.md"):
            profile = valid_profile()
            profile["operations"] = [{
                "kind": "add",
                "target": target,
                "source": "payload/policy.md",
                "sha256": "a" * 64,
            }]
            result = self.run_validator(profile)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("unsafe operation target", result.stderr)

    def test_rejects_module_without_eligibility_record(self):
        profile = valid_profile()
        profile["operations"] = [{
            "kind": "module",
            "module_id": "example-module",
            "source": "modules/example-module",
            "sha256": "b" * 64,
        }]
        result = self.run_validator(profile)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("module operation requires eligibility_record", result.stderr)

    def test_rejects_numeric_profile_revision(self):
        profile = valid_profile()
        profile["profile_revision"] = 7
        self.assert_invalid(profile, "profile_revision is invalid")

    def test_rejects_numeric_contract_revision(self):
        profile = valid_profile()
        profile["enterprise_binding"]["contract_revision"] = 7
        self.assert_invalid(profile, "enterprise contract_revision is invalid")

    def test_rejects_non_string_enterprise_namespace(self):
        profile = valid_profile()
        profile["enterprise_binding"]["namespace"] = 7
        self.assert_invalid(profile, "enterprise namespace must be a non-empty string")

    def test_rejects_invalid_module_id(self):
        for module_id in ("Example-module", "example_module"):
            with self.subTest(module_id=module_id):
                profile = valid_profile()
                profile["operations"] = [{
                    "kind": "module",
                    "module_id": module_id,
                    "source": "modules/example-module",
                    "sha256": "b" * 64,
                    "eligibility_record": "urn:example:eligibility:1",
                }]
                self.assert_invalid(profile, "module_id is invalid")

    def test_rejects_non_string_approval_record_id(self):
        profile = valid_profile()
        profile["approval"]["record_id"] = 42
        self.assert_invalid(profile, "approval record_id must be a non-empty string")

    def test_rejects_non_string_eligibility_record(self):
        profile = valid_profile()
        profile["operations"] = [{
            "kind": "module",
            "module_id": "example-module",
            "source": "modules/example-module",
            "sha256": "b" * 64,
            "eligibility_record": 42,
        }]
        self.assert_invalid(profile, "module operation requires eligibility_record")

    def test_rejects_non_string_sha256(self):
        profile = valid_profile()
        profile["operations"] = [{
            "kind": "add",
            "target": ".km/organization/policy.md",
            "source": "payload/policy.md",
            "sha256": int("1" * 64),
        }]
        self.assert_invalid(profile, "operations[0] has invalid sha256")

    def test_rejects_malformed_forbidden_operations_without_traceback(self):
        profile = valid_profile()
        profile["forbidden_operations"] = [{}]
        self.assert_invalid(
            profile,
            "forbidden_operations must contain exactly the six canonical prohibitions",
        )

    def test_rejects_malformed_lifecycle_without_traceback(self):
        profile = valid_profile()
        profile["lifecycle"] = {}
        self.assert_invalid(profile, "lifecycle is invalid")

    def test_rejects_non_utf8_profile_without_traceback(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "profile.json"
            path.write_bytes(b"\xff")
            result = subprocess.run(
                ["python3", str(VALIDATOR), str(path), "--canonical-version", "1.14"],
                text=True,
                capture_output=True,
                check=False,
            )
        self.assertEqual(result.returncode, 1)
        self.assertIn("INVALID OrganizationProfile:", result.stderr)
        self.assertNotIn("Traceback", result.stderr)


if __name__ == "__main__":
    unittest.main()
