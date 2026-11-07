"""Synthetic tests for explicit Skeleton3D mapping validation."""
import unittest
from tools.validate_titan_skeleton_mapping import validate

C = {"bones": [{"unity_path_crc32": 10}, {"unity_path_crc32": 20}]}
S = {"bones": [{"name": "Root", "parent": None},
               {"name": "Hand", "parent": "Root"}]}


class TestSkeletonMapping(unittest.TestCase):
    def test_explicit_partial_mapping(self):
        result = validate(C, S, {"mappings": [
            {"unity_path_crc32": 10, "godot_bone_name": "Hand"}]})
        self.assertTrue(result["valid"])
        self.assertEqual(result["unmapped_hashes"], [20])
        self.assertFalse(result["rest_pose_verified"])

    def test_duplicate_target(self):
        mapping = {"mappings": [
            {"unity_path_crc32": 10, "godot_bone_name": "Hand"},
            {"unity_path_crc32": 20, "godot_bone_name": "Hand"}]}
        self.assertFalse(validate(C, S, mapping)["valid"])

    def test_missing_parent(self):
        self.assertFalse(validate(C, {"bones": [
            {"name": "Hand", "parent": "Absent"}]},
            {"mappings": []})["valid"])

    def test_cycle(self):
        skeleton = {"bones": [{"name": "A", "parent": "B"},
                              {"name": "B", "parent": "A"}]}
        self.assertFalse(validate(C, skeleton, {"mappings": []})["valid"])


if __name__ == "__main__":
    unittest.main()
