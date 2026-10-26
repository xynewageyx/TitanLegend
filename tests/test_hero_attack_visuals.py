"""Static regression checks for class-specific combat animations."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
MOTION = (ROOT / "scripts/hero_combat_motion.gd").read_text(encoding="utf-8")


class HeroAttackVisualTests(unittest.TestCase):
    def test_attack_archetypes(self):
        self.assertIn("if class_id in [0, 1, 10]:", MOTION)
        self.assertIn("elif class_id in [4, 5]:", MOTION)
        self.assertIn("right_arm.rotation.x = -0.78 * swing", MOTION)
        self.assertIn("left_arm.rotation.x = -1.15 * swing", MOTION)

    def test_combat_interfaces_preserved(self):
        self.assertIn("func play_attack() -> void:", MOTION)
        self.assertIn("func play_skill_cast(role: int, choice: int) -> void:", MOTION)
        self.assertIn("func play_hit(critical: bool = false) -> void:", MOTION)
        self.assertIn("func play_dodge() -> void:", MOTION)


if __name__ == "__main__":
    unittest.main()
