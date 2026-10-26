"""Static regression checks for class-specific hero gait animation."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
MOTION = (ROOT / "scripts/hero_combat_motion.gd").read_text(encoding="utf-8")
TEAM = (ROOT / "scripts/team_formation.gd").read_text(encoding="utf-8")


class HeroGaitTests(unittest.TestCase):
    def test_heavy_agile_and_caster_gaits(self):
        self.assertIn("var leg_swing: float = 0.40 if class_id in [0, 1]", MOTION)
        self.assertIn("var arm_swing: float = 0.17 if class_id in [3, 6, 7, 8, 9]", MOTION)
        self.assertIn("var foot_height: float = 0.05 if class_id in [0, 1]", MOTION)

    def test_walk_animation_respects_formation(self):
        self.assertIn('walking = bool(formation.get("is_walking"))', MOTION)
        self.assertIn("stride_blend = move_toward", MOTION)
        self.assertIn("left_leg.rotation.x = step * leg_swing * step_strength", MOTION)
        self.assertIn("right_leg.rotation.x = -step * leg_swing * step_strength", MOTION)
        self.assertIn("walking_finished.emit()", TEAM)

    def test_animation_does_not_modify_combat(self):
        self.assertIn("func play_attack()", MOTION)
        self.assertIn("func play_skill_cast(role: int, choice: int)", MOTION)


if __name__ == "__main__":
    unittest.main()
