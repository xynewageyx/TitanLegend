"""Synthetic regression tests; no third-party asset bytes."""
import unittest
import zlib

from tools.verify_bone_hierarchy_hashes import verify


class HierarchyHashTests(unittest.TestCase):
    def test_root_relative_hash_and_duplicate_name_disambiguation(self):
        path = "Rig/Pelvis/Head"
        expected = zlib.crc32(path.encode("utf-8")) & 0xffffffff
        hierarchy = {
            "file": "test.prefab_ab",
            "nodes": [
                {"path_id": 1, "name": "Prefab", "father": [0, 0]},
                {"path_id": 2, "name": "Rig", "father": [0, 1]},
                {"path_id": 3, "name": "Pelvis", "father": [0, 2]},
                {"path_id": 4, "name": "Head", "father": [0, 3]},
                {"path_id": 5, "name": "Head", "father": [0, 1]},
            ],
        }
        alignment = {"records": [{"bundle": "test", "index": 0,
                                  "transform_name": "Head",
                                  "mesh_bone_hash": hex(expected)}]}
        result = verify([hierarchy], alignment)
        self.assertEqual(result["checked"], 1)
        self.assertEqual(result["uniquely_matched"], 1)
        self.assertEqual(result["failures"], [])

    def test_mismatch_is_reported(self):
        hierarchy = {"file": "test.prefab_ab", "nodes": [
            {"path_id": 1, "name": "Prefab", "father": [0, 0]},
            {"path_id": 2, "name": "Head", "father": [0, 1]}]}
        alignment = {"records": [{"bundle": "test", "index": 0,
                                  "transform_name": "Head",
                                  "mesh_bone_hash": "0x0"}]}
        result = verify([hierarchy], alignment)
        self.assertEqual(result["uniquely_matched"], 0)
        self.assertEqual(result["failures"][0]["matching_paths"], 0)


if __name__ == "__main__":
    unittest.main()
