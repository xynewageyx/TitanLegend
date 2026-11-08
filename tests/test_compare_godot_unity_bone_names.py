"""Synthetic coverage for Godot inventory versus Unity bone-name comparisons."""
import unittest
from tools.compare_godot_unity_bone_names import compare


class CompareGodotUnityBonesTests(unittest.TestCase):
    def test_name_match_remains_unverified(self):
        candidates = {"bones": [
            {"unity_path_crc32": 123, "unity_bone_name": "Spine"},
            {"unity_path_crc32": 456, "unity_bone_name": "Arm"}]}
        inventory = {"skeletons": [{
            "scene": "res://hero.tscn", "node_path": "Skeleton3D",
            "bones": [{"name": "Root", "parent": None},
                      {"name": "Spine", "parent": "Root"}]}]}
        result = compare(candidates, inventory)
        row = result["skeletons"][0]
        self.assertEqual(row["name_match_count"], 1)
        self.assertEqual(row["name_matches"][0]["status"], "name_only_unverified")
        self.assertEqual(row["missing_unity_bone_names"], ["Arm"])
        self.assertFalse(row["rest_pose_verified"])
        self.assertFalse(row["animation_playback_verified"])

    def test_empty_inventory(self):
        result = compare({"bones": []}, {"skeletons": []})
        self.assertEqual(result["godot_skeleton_count"], 0)

    def test_duplicate_godot_bone_name_rejected(self):
        with self.assertRaisesRegex(ValueError, "Duplicate bone names"):
            compare({"bones": []}, {"skeletons": [{
                "scene": "res://a.tscn", "node_path": "Skeleton3D",
                "bones": [{"name": "A"}, {"name": "A"}]}]})


if __name__ == "__main__":
    unittest.main()
