import copy
import unittest

from tools.check_four_hero_visual_manifest import audit, ACTIONS, EXPECTED_CLASSES


def example():
    frames = []
    for pose in ACTIONS:
        pet = [{"category": "pet", "source_slot": i} for i in range(4)]
        fx = [{"category": "effect", "source_slot": i} for i in range(4)] if pose == "attack" else []
        frames.append({
            "class": "formation", "pose": pose,
            "hero_count": 4, "weapon_anchors": 4, "class_ids": [0, 6, 11, 2],
            "screen_visibility": {
                "valid": True,
                "minimum_body_viewport_fraction": 1.0,
                "body_frames": [{"class": name} for name in EXPECTED_CLASSES],
                "pet_effect_frames": pet + fx,
                "maximum_pair_bbox_overlap": 0.0,
                "max_weapon_vs_other_body_bbox_overlap": 0.0,
                "max_pet_vs_other_body_bbox_overlap": 0.006,
                "max_effect_vs_body_bbox_overlap": 0.146 if pose == "attack" else 0.0,
            }
        })
    return {"renders": frames}


class FormationManifestTests(unittest.TestCase):
    def test_expected_four_poses_pass(self):
        report = audit(example())
        self.assertTrue(report["valid"], report["errors"])
        self.assertEqual(len(report["actions"]), 4)
        self.assertEqual(report["actions"][2]["active_attack_fx_count"], 4)
    def test_missing_attack_fx_fails(self):
        manifest = example()
        manifest["renders"][2]["screen_visibility"]["pet_effect_frames"] = [
            x for x in manifest["renders"][2]["screen_visibility"]["pet_effect_frames"]
            if x["category"] == "pet"]
        self.assertFalse(audit(manifest)["valid"])
    def test_one_hero_off_screen_fails(self):
        manifest = example()
        manifest["renders"][0]["screen_visibility"]["minimum_body_viewport_fraction"] = 0.5
        self.assertFalse(audit(manifest)["valid"])
    def test_missing_pet_fails(self):
        manifest = example()
        manifest["renders"][3]["screen_visibility"]["pet_effect_frames"].pop()
        self.assertFalse(audit(manifest)["valid"])
    def test_wider_fx_rectangle_is_a_measurement_not_pixel_collision(self):
        manifest = example()
        manifest["renders"][2]["screen_visibility"]["max_effect_vs_body_bbox_overlap"] = 0.9
        self.assertTrue(audit(manifest)["valid"])

if __name__ == "__main__":
    unittest.main()
