"""Static regression tests for procedural hero appearances.

No runtime/Android rendering assertions are made here.
"""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
TEAM = (ROOT / "scripts/team_formation.gd").read_text(encoding="utf-8")
SILHOUETTE = (ROOT / "scripts/hero_silhouette_v2.gd").read_text(encoding="utf-8")


class HeroSilhouetteTests(unittest.TestCase):
    def test_all_eleven_classes_have_unique_details(self):
        for class_id in range(11):
            self.assertIn(f"  {class_id}: #", SILHOUETTE)
        self.assertIn("match class_id:", SILHOUETTE)

    def test_visuals_created_on_build_not_per_frame(self):
        self.assertIn('preload("res://scripts/hero_silhouette_v2.gd").decorate(hero, class_id, selected_role, slot)', TEAM)
        self.assertIn("func _decorate_class(", TEAM)
        self.assertNotIn("func _process(", SILHOUETTE)
        self.assertNotIn("create_tween(", SILHOUETTE)

    def test_only_visual_geometry(self):
        self.assertIn("VisualFactory.box(", SILHOUETTE)
        self.assertIn("VisualFactory.sphere(", SILHOUETTE)
        for forbidden in ("GameManager", "damage_heroes", "CollisionShape3D", "gain_character_xp"):
            self.assertNotIn(forbidden, SILHOUETTE)


if __name__ == "__main__":
    unittest.main()
