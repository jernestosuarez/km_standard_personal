import importlib.util
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


if __name__ == "__main__":
    unittest.main()
