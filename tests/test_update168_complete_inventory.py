"""Verify all 213 original Update 168 source paths remain present.

Active game scripts may evolve; original history docs are preserved byte-for-byte
except for three consciously updated historical/root files.
"""
from pathlib import Path
import hashlib
import json
import unittest

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "docs" / "update_168_import_manifest.json"
ALLOW_CHANGED_ROOT = {"README.md", "UPDATE_23.md", "UPDATE_25_PARSERFIX.md"}


def git_blob_sha1(data: bytes) -> str:
    return hashlib.sha1(b"blob " + str(len(data)).encode("ascii") + bytes([0]) + data).hexdigest()


class CompleteUpdate168ImportTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.record = json.loads(MANIFEST.read_text(encoding="utf-8"))
        cls.files = cls.record["files"]

    def test_manifest_has_all_original_entries(self):
        self.assertEqual(self.record["file_count"], 213)
        self.assertEqual(len(self.files), 213)
        self.assertEqual(sum(item["bytes"] for item in self.files), 371692)
        self.assertEqual(len({item["path"] for item in self.files}), 213)

    def test_every_original_path_exists(self):
        for item in self.files:
            with self.subTest(path=item["path"]):
                path = ROOT / item["path"]
                self.assertTrue(path.is_file(), f"Missing Update 168 file: {item['path']}")
                self.assertTrue(path.resolve().is_relative_to(ROOT.resolve()))

    def test_original_root_history_is_byte_identical(self):
        for item in self.files:
            name = item["path"]
            if "/" in name or name in ALLOW_CHANGED_ROOT or name == "project.godot":
                continue
            with self.subTest(path=name):
                data = (ROOT / name).read_bytes()
                self.assertEqual(git_blob_sha1(data), item["git_sha"],
                                 f"Historical Update 168 source changed: {name}")

    def test_all_original_scripts_scenes_and_project_exist(self):
        paths = [item["path"] for item in self.files]
        self.assertEqual(sum(p.startswith("scripts/") for p in paths), 46)
        self.assertEqual(sum(p.startswith("scenes/") for p in paths), 2)
        self.assertIn("project.godot", paths)
        self.assertTrue((ROOT / "original_update168/scripts/battle_manager.gd").is_file())
        self.assertTrue((ROOT / "original_update168/scripts/team_formation.gd").is_file())


if __name__ == "__main__":
    unittest.main()
