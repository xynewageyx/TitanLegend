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

    def test_class_specific_attack_flash(self):
        self.assertIn("magic_flash.position.z = (0.55 if class_id in [4, 5]", MOTION)
        self.assertIn("* swing * attack_fx_forward", MOTION)
        self.assertIn("magic_flash.position.y = (0.18 if class_id in [3, 6, 7, 8, 9]", MOTION)

    def test_imported_chibi_faces_forward_but_legacy_rig_keeps_direction(self):
        self.assertIn('hero.get_node_or_null("ChibiGLBVisual")', MOTION)
        self.assertIn("attack_fx_forward = 1.0 if imported != null else -1.0", MOTION)
        self.assertIn("Vector3(0.34, 1.10, 0.70)", MOTION)
        self.assertIn("Vector3(0.0, 1.45, -0.70)", MOTION)
        self.assertIn("_orient_attack_fx()", MOTION)

    def test_attack_flash_size_is_bounded(self):
        self.assertIn("MAX_ATTACK_FLASH_SCALE: float = 1.18", MOTION)
        self.assertIn("minf(MAX_ATTACK_FLASH_SCALE, 0.65 + 1.55 * swing * fx_strength)", MOTION)

    def test_combat_interfaces_preserved(self):
        self.assertIn("func play_attack() -> void:", MOTION)
        self.assertIn("func play_skill_cast(role: int, choice: int) -> void:", MOTION)
        self.assertIn("func play_hit(critical: bool = false) -> void:", MOTION)
        self.assertIn("func play_dodge() -> void:", MOTION)


if __name__ == "__main__":
    unittest.main()
