"""Ensure the woodland guardian has distinct visual anatomy without combat logic."""
from pathlib import Path
import unittest

BOSS = (Path(__file__).resolve().parents[1] / "scripts/boss_art.gd").read_text(encoding="utf-8")


class ForestGuardianArtTests(unittest.TestCase):
    def test_nature_only(self):
        self.assertIn("if element == 3:\n  add_forest_guardian(parent, fused)", BOSS)
        self.assertIn("static func add_forest_guardian(parent: Node3D, fused: bool) -> void:", BOSS)

    def test_expressive_anatomy(self):
        for marker in ("var root :=", "var branch :=", "var twig :=", "var eye :=", "var jaw :=", "var center_crown :="):
            self.assertIn(marker, BOSS)

    def test_fusion_and_visual_only(self):
        self.assertIn('Color("#e19dff")', BOSS)
        method = BOSS.split("static func add_forest_guardian(", 1)[1]
        self.assertNotIn("CollisionShape3D", method)
        self.assertNotIn("take_damage", method)


if __name__ == "__main__":
    unittest.main()
