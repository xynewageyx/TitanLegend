"""Static regression checks for visual-only hero movement improvements."""
from pathlib import Path
import unittest

SCRIPT = (Path(__file__).resolve().parents[1] / "scripts" / "hero_combat_motion.gd").read_text(encoding="utf-8")


class HeroMotionPolishTests(unittest.TestCase):
    def test_walk_transition_is_smoothed(self):
        self.assertIn("stride_blend = move_toward(", SCRIPT)
        self.assertIn("var step_strength: float = stride_blend", SCRIPT)

    def test_foot_lift_alternates(self):
        self.assertIn("left_leg.position.y = 0.60 + foot_lift", SCRIPT)
        self.assertIn("maxf(0.0, -step)", SCRIPT)

    def test_attack_has_anticipation_and_follow_through(self):
        self.assertIn("var windup: float = smoothstep(", SCRIPT)
        self.assertIn("var strike: float = smoothstep(", SCRIPT)
        self.assertIn("var recovery: float = 1.0 - smoothstep(", SCRIPT)

    def test_public_animation_api_remains_available(self):
        for method in ("configure", "play_attack", "play_hit", "play_dodge",
                       "play_skill_cast", "play_tank_skill_fx", "set_tank_defense_state"):
            self.assertIn("func " + method + "(", SCRIPT)


if __name__ == "__main__":
    unittest.main()
