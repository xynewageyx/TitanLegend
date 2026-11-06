import importlib.util
import tempfile
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "verify_ulala_volumes", Path(__file__).with_name("verify_ulala_volumes.py"))
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)


class VerifyVolumesTests(unittest.TestCase):
    def test_missing_volumes_are_reported(self):
        with tempfile.TemporaryDirectory() as directory:
            report = mod.verify(Path(directory))
            self.assertFalse(report["sizes_valid"])
            self.assertEqual(len(report["volumes"]), 9)
            self.assertEqual(report["archive_integrity"]["status"], "not_requested")

    def test_small_final_volume_and_missing_others(self):
        with tempfile.TemporaryDirectory() as directory:
            (Path(directory) / "ulala_backup.7z.009").write_bytes(b"x" * 4)
            report = mod.verify(Path(directory), hash_files=True, archive_test=True)
            self.assertFalse(report["sizes_valid"])
            self.assertEqual(report["archive_integrity"]["status"], "skipped_incomplete_volumes")
            self.assertEqual(len(report["volumes"][-1]["sha256"]), 64)

    def test_expected_total_size(self):
        self.assertEqual(sum(mod.EXPECTED.values()), 1_933_245_476)


if __name__ == "__main__":
    unittest.main()
