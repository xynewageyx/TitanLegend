"""Static regression checks for elemental boss attack warnings."""
from pathlib import Path
import unittest

BOSS = (Path(__file__).resolve().parents[1] / "scripts/boss_motion.gd").read_text(encoding="utf-8")


class BossWarningVisualTests(unittest.TestCase):
    def test_warning_accelerates_and_supports_fusion(self):
        self.assertIn("var pulse_speed: float = lerpf(2.0, 6.0, progress)", BOSS)
        self.assertIn("var warning_size: float = 1.18 if fusion else 1.0", BOSS)
        self.assertIn("warning_ring.scale = Vector3(pulse * warning_size", BOSS)
        self.assertIn("(0.08 if enraged else 0.0)", BOSS)

    def test_attack_timing_interface_unchanged(self):
        self.assertIn("func attack_windup() -> void:", BOSS)
        self.assertIn("func attack_release() -> void:", BOSS)
        self.assertIn("windup_remaining = windup_duration", BOSS)
        self.assertIn("windup_remaining = 0.0", BOSS)


if __name__ == "__main__":
    unittest.main()
