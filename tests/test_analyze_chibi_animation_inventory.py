import unittest
from tools.analyze_chibi_animation_inventory import HEROES, analyze


def make_inventory(clips=None):
    return {"heroes": [{"hero": hero, "animation_players": 1,
                        "clips": clips if hero == "warrior" and clips is not None else []}
                       for hero in sorted(HEROES)], "errors": []}


class ChibiAnimationCoverageTests(unittest.TestCase):
    def test_complete_empty_inventory_is_valid(self):
        result = analyze(make_inventory())
        self.assertTrue(result["valid_inventory"])
        self.assertEqual(result["heroes_with_imported_clips"], 0)
        self.assertEqual(result["total_imported_clips"], 0)
        self.assertFalse(result["unity_retargeting_verified"])

    def test_count_clips_and_keyframes(self):
        data = make_inventory([{"name": "idle", "tracks": [{"key_count": 3}]},
                               {"name": "run", "tracks": [{"key_count": 0}]}])
        result = analyze(data)
        self.assertEqual(result["total_imported_clips"], 2)
        self.assertEqual(result["heroes_with_imported_clips"], 1)
        self.assertEqual(result["coverage"]["warrior"]["clips_with_keys"], 1)

    def test_all_five_base_actions_detected(self):
        clips = [{"name": action, "tracks": [{"key_count": 2}]}
                 for action in ("Attack", "Dodge", "Hit", "Idle", "Walk")]
        result = analyze(make_inventory(clips))
        self.assertEqual(result["coverage"]["warrior"]["missing_base_actions"], [])
        self.assertEqual(result["coverage"]["warrior"]["action_clip_counts"]["Attack"], 1)

    def test_variants_count_without_false_prefix_match(self):
        clips = [{"name": "Attack"}, {"name": "Attack_001"},
                 {"name": "Attacker"}, {"name": "Walk_002"}]
        result = analyze(make_inventory(clips))
        self.assertEqual(result["coverage"]["warrior"]["action_clip_counts"]["Attack"], 2)
        self.assertEqual(result["coverage"]["warrior"]["action_clip_counts"]["Walk"], 1)
        self.assertIn("Idle", result["coverage"]["warrior"]["missing_base_actions"])

    def test_identical_keyframe_fingerprints_grouped(self):
        same = "a" * 64
        different = "b" * 64
        data = make_inventory([
            {"name": "Attack", "tracks": [{"key_count": 3}], "keyframe_fingerprint_sha256": same},
            {"name": "Attack_001", "tracks": [{"key_count": 3}], "keyframe_fingerprint_sha256": same},
            {"name": "Idle", "tracks": [{"key_count": 3}], "keyframe_fingerprint_sha256": different},
        ])
        result = analyze(data)
        warrior = result["coverage"]["warrior"]
        self.assertEqual(warrior["unique_keyframe_fingerprints"], 2)
        self.assertEqual(warrior["identical_keyframe_clip_groups"], [["Attack", "Attack_001"]])
        self.assertEqual(result["identical_keyframe_groups"], 1)

    def test_missing_fingerprints_do_not_imply_duplicates(self):
        data = make_inventory([
            {"name": "Attack", "tracks": []},
            {"name": "Attack_001", "tracks": []},
        ])
        result = analyze(data)
        self.assertEqual(result["coverage"]["warrior"]["fingerprint_coverage"], 0)
        self.assertEqual(result["identical_keyframe_groups"], 0)

    def test_missing_hero_rejected(self):
        data = make_inventory()
        data["heroes"].pop()
        self.assertFalse(analyze(data)["valid_inventory"])

    def test_duplicate_hero_rejected(self):
        data = make_inventory()
        data["heroes"].append(data["heroes"][0])
        self.assertFalse(analyze(data)["valid_inventory"])

    def test_export_error_rejected(self):
        data = make_inventory()
        data["errors"].append("Cannot load a model")
        self.assertFalse(analyze(data)["valid_inventory"])


if __name__ == "__main__":
    unittest.main()
