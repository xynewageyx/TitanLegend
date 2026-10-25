"""Unit tests for safe original archive migration (no real ZIP required)."""
import importlib.util
from pathlib import Path
import tempfile
import unittest
import zipfile

SCRIPT = Path(__file__).resolve().parents[1] / "tools" / "import_update168.py"
spec = importlib.util.spec_from_file_location("update168_import", SCRIPT)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class ImportToolTests(unittest.TestCase):
    def test_only_expected_archive_prefix(self):
        self.assertIsNone(module.safe_relative_path("other/scripts/x.gd"))
        self.assertEqual(
            module.safe_relative_path(module.ARCHIVE_PREFIX + "scripts/x.gd"),
            Path("scripts/x.gd"),
        )

    def test_prevent_unsafe_archive_paths(self):
        for value in ("../../outside.gd", "scripts/../bad.gd",
                      "scripts/evil\\name.gd", "scripts/C:evil.gd"):
            with self.subTest(value=value):
                self.assertIsNone(module.safe_relative_path(module.ARCHIVE_PREFIX + value))

    def test_existing_files_are_preserved_during_import(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            archive = root / "sample.zip"
            (root / "scripts").mkdir()
            (root / "scripts" / "old.gd").write_text("current improvements", encoding="utf-8")
            with zipfile.ZipFile(archive, "w") as z:
                z.writestr(module.ARCHIVE_PREFIX + "scripts/old.gd", "original")
                z.writestr(module.ARCHIVE_PREFIX + "scripts/new.gd", "new")
            old_root = module.ROOT
            try:
                module.ROOT = root
                result = module.audit(archive, True)
            finally:
                module.ROOT = old_root
            self.assertEqual(result, (1, 1, 0))
            self.assertEqual((root / "scripts" / "old.gd").read_text(), "current improvements")
            self.assertEqual((root / "scripts" / "new.gd").read_text(), "new")


if __name__ == "__main__":
    unittest.main()
