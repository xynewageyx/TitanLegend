"""Synthetic regression tests for AnimationClip inventory summaries."""
import unittest
from tools.summarize_unity_animation_headers import summarize


class AnimationHeaderSummaryTests(unittest.TestCase):
    def test_case_insensitive_clip_names_and_legacy(self):
        rows = [{"file": "male@n_idle.anim_ab", "clip_name": "Male@n_idle",
                 "object_bytes": 4000, "legacy": 0, "compressed": 0,
                 "high_quality": 1},
                {"file": "man@ball.anim_ab", "clip_name": "Man@ball",
                 "object_bytes": 3000, "legacy": 1, "compressed": 0,
                 "high_quality": 1}]
        result = summarize(rows)
        self.assertEqual(result["clips"], 2)
        self.assertEqual(result["legacy_files"], ["man@ball.anim_ab"])
        self.assertEqual(result["name_mismatches_or_duplicates"], [])

    def test_duplicate_and_mismatch_are_reported(self):
        row = {"file": "a.anim_ab", "clip_name": "b",
               "object_bytes": 2000, "legacy": 0, "compressed": 0,
               "high_quality": 1}
        self.assertEqual(len(summarize([row, row])["name_mismatches_or_duplicates"]), 3)

    def test_empty_inventory_rejected(self):
        with self.assertRaises(ValueError):
            summarize([])


if __name__ == "__main__":
    unittest.main()
