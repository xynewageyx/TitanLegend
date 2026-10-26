"""Static checks for three original woodland enemy silhouettes."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
ART = (ROOT / "scripts/forest_enemy_art.gd").read_text(encoding="utf-8")
BATTLE = (ROOT / "scripts/battle_manager.gd").read_text(encoding="utf-8")


class ForestEnemyArtTests(unittest.TestCase):
    def test_three_distinct_enemy_shapes(self):
        self.assertIn('preload("res://scripts/forest_enemy_art.gd").decorate(mob, (i + current_wave) % 3, tint)', BATTLE)
        for marker in ("trunk", "crown", "snout", "tail", "carapace", "thorn"):
            self.assertIn(marker, ART)

    def test_visual_only(self):
        self.assertNotIn("apply_damage(", ART)
        self.assertNotIn("create_timer(", ART)
        self.assertIn("match variant:", ART)


if __name__ == "__main__":
    unittest.main()
