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
