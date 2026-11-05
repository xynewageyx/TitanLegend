import unittest
from tools.audit_chibi_animation_duplicates import audit


class DuplicateAuditTests(unittest.TestCase):
    def test_equal_metadata_different_values_not_equal_fingerprint(self):
        inventory = {"heroes": [{"hero": "warrior", "clips": [
            {"name": "a", "duration": 1, "tracks": [{"path": "Arm_R", "type": 2, "key_count": 3}], "keyframe_fingerprint_sha256": "abc"},
            {"name": "b", "duration": 1, "tracks": [{"path": "Arm_R", "type": 2, "key_count": 3}], "keyframe_fingerprint_sha256": "def"},
        ]}]}
        result = audit(inventory)
        self.assertEqual(result["total_metadata_identical_clip_candidates"], 2)
        self.assertEqual(result["total_matching_keyframe_fingerprint_groups"], 0)

    def test_matching_fingerprint_detected(self):
        inventory = {"heroes": [{"hero": "warrior", "clips": [
            {"name": "a", "duration": 1, "tracks": [{"path": "Arm_R", "type": 2, "key_count": 3}], "keyframe_fingerprint_sha256": "same"},
            {"name": "b", "duration": 1, "tracks": [{"path": "Arm_R", "type": 2, "key_count": 3}], "keyframe_fingerprint_sha256": "same"},
        ]}]}
        result = audit(inventory)
        self.assertEqual(result["total_matching_keyframe_fingerprint_groups"], 1)
        self.assertEqual(result["heroes"][0]["matching_keyframe_fingerprint_groups"], [["a", "b"]])

    def test_missing_fingerprint_never_assumed_identical(self):
        inventory = {"heroes": [{"hero": "warrior", "clips": [
            {"name": "a", "duration": 1, "tracks": []},
            {"name": "b", "duration": 1, "tracks": []},
        ]}]}
        result = audit(inventory)
        self.assertEqual(result["total_matching_keyframe_fingerprint_groups"], 0)
        self.assertEqual(result["total_empty_clips"], 2)

    def test_different_duration_never_same_group(self):
        inventory = {"heroes": [{"hero": "warrior", "clips": [
            {"name": "a", "duration": 1, "tracks": [], "keyframe_fingerprint_sha256": "same"},
            {"name": "b", "duration": 2, "tracks": [], "keyframe_fingerprint_sha256": "same"},
        ]}]}
        self.assertEqual(audit(inventory)["total_matching_keyframe_fingerprint_groups"], 0)


if __name__ == "__main__":
    unittest.main()
