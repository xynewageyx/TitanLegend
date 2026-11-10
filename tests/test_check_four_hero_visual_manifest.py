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
                "depth_silhouette_masks": ({
                    "valid": True,
                    "mask_images": 16,
                    "heroes": [
                        {
                            "slot": idx, "class": hero_name,
                            "baseline_visible_body_pixels": 12000,
                            "baseline_image": f"formation_mask_{idx}_baseline.png",
                            **{
                                f"{category}_{field}": (11500 if field == "visible_body_pixels" else 500 if field == "hidden_body_pixels" else f"formation_mask_{idx}_{category}.png")
                                for category in ("weapon", "pet", "effect")
                                for field in ("visible_body_pixels", "hidden_body_pixels", "image")
                            }
                        }
                        for idx, hero_name in enumerate(EXPECTED_CLASSES)
                    ],
                } if pose == "attack" else {}),
                "pixel_differential": ({
                    "valid": True,
                    "categories": {
                        kind: {
                            "valid": True,
                            "total_pixels": 720 * 1280,
                            "changed_pixels": 4000,
                            "counterfactual_image": f"formation_mythic_attack_without_{kind}.png",
                            "body_regions": [
                                {"slot": idx, "changed_pixels": 250, "body_rectangle_area_px": 10000}
                                for idx in range(4)
                            ],
                        } for kind in ("weapon", "pet", "effect")
                    },
                } if pose == "attack" else {}),
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
    def test_missing_pixel_category_fails(self):
        manifest = example()
        manifest["renders"][2]["screen_visibility"]["pixel_differential"]["categories"].pop("pet")
        self.assertFalse(audit(manifest)["valid"])
    def test_pixel_count_cannot_exceed_frame(self):
        manifest = example()
        metrics = manifest["renders"][2]["screen_visibility"]["pixel_differential"]["categories"]["effect"]
        metrics["changed_pixels"] = metrics["total_pixels"] + 1
        self.assertFalse(audit(manifest)["valid"])
    def test_missing_depth_mask_fails(self):
        manifest = example()
        manifest["renders"][2]["screen_visibility"]["depth_silhouette_masks"]["heroes"].pop()
        self.assertFalse(audit(manifest)["valid"])
    def test_inconsistent_depth_pixel_counts_fail(self):
        manifest = example()
        manifest["renders"][2]["screen_visibility"]["depth_silhouette_masks"]["heroes"][0]["weapon_hidden_body_pixels"] = 50
        self.assertFalse(audit(manifest)["valid"])
    def test_opaque_attack_flash_over_35_percent_fails(self):
        manifest = example()
        dk = manifest["renders"][2]["screen_visibility"]["depth_silhouette_masks"]["heroes"][2]
        dk["effect_visible_body_pixels"] = 7000
        dk["effect_hidden_body_pixels"] = 5000
        self.assertFalse(audit(manifest)["valid"])
    def test_attack_flash_below_35_percent_passes(self):
        self.assertTrue(audit(example())["valid"])
    def test_wider_fx_rectangle_is_a_measurement_not_pixel_collision(self):
        manifest = example()
        manifest["renders"][2]["screen_visibility"]["max_effect_vs_body_bbox_overlap"] = 0.9
        self.assertTrue(audit(manifest)["valid"])

if __name__ == "__main__":
    unittest.main()
