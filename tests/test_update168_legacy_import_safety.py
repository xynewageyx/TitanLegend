"""Protect newer Titan Legends gameplay from destructive legacy ZIP imports."""
from pathlib import Path
import ast
import unittest

ROOT = Path(__file__).resolve().parents[1]
LEGACY = ROOT / "tools" / "import_update_168.py"


class LegacyImportSafetyTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.code = LEGACY.read_text(encoding="utf-8")
        cls.module = ast.parse(cls.code)

    def test_legacy_tool_uses_safe_missing_only_importer(self):
        self.assertIn("from import_update168 import audit", self.code)
        self.assertIn("audit(source, import_missing=True)", self.code)

    def test_legacy_tool_rejects_wrong_source_archive(self):
        self.assertIn("EXPECTED_SOURCE_SHA256", self.code)
        self.assertIn("hashlib.sha256(source.read_bytes()).hexdigest()", self.code)

    def test_legacy_tool_does_not_replace_existing_scripts_or_manifest(self):
        # Any active write to project sources should happen in the safe
        # importer with its exclusive-create guard; this shim must not write.
        banned_calls = {"write_bytes", "write_text", "unlink", "replace", "rename"}
        for node in ast.walk(self.module):
            if isinstance(node, ast.Call) and isinstance(node.func, ast.Attribute):
                self.assertNotIn(node.func.attr, banned_calls, f"Unsafe operation: {node.func.attr}")

    def test_manifest_and_safe_importer_still_available(self):
        self.assertTrue((ROOT / "docs/update_168_import_manifest.json").is_file())
        self.assertTrue((ROOT / "tools/import_update168.py").is_file())


if __name__ == "__main__":
    unittest.main()
