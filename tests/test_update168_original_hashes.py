"""Confirm that preserved Update 168 originals match the original ZIP byte-for-byte.

Checksums were calculated from Titan_Legends_Update_168_Gegner_KI_Tank_Fix.zip.
The files under original_update168/ are snapshots; the live scripts may
continue evolving independently without changing these protected originals.
"""
from pathlib import Path
import hashlib
import unittest

ROOT = Path(__file__).resolve().parents[1]
EXPECTED = {
    "team_formation.gd": "19b26a83c256ed98613cc7ca958e54800ff4651d926a811f89508890e33e95e0",
    "battle_manager.gd": "a8466f771ae14906751043649b0b43936b5c004769760f45aa54b2f2e6b29f30",
    "ui_manager.gd": "724f9b9ec3e5a11d9efb14a85f234c300888a80f020a820d7b523050c9a48693",
    "boss_motion.gd": "54d8d22371d590d21542b779891191d122815e1233088a0014b114cd3616ddb1",
}


class Update168OriginalChecksums(unittest.TestCase):
    def test_preserved_sources_match_exact_archive_bytes(self):
        folder = ROOT / "original_update168" / "scripts"
        for name, expected_sha256 in EXPECTED.items():
            with self.subTest(source=name):
                original = folder / name
                self.assertTrue(original.is_file(), f"Missing preserved original: {original}")
                actual = hashlib.sha256(original.read_bytes()).hexdigest()
                self.assertEqual(actual, expected_sha256, f"Original source changed: {original}")

    def test_live_versions_stay_in_separate_paths(self):
        for name in EXPECTED:
            with self.subTest(source=name):
                self.assertTrue((ROOT / "scripts" / name).is_file())


if __name__ == "__main__":
    unittest.main()
