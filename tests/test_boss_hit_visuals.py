"""Static checks for ten-element boss hit reactions."""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
BOSS = (ROOT / "scripts/boss_motion.gd").read_text(encoding="utf-8")


class BossHitVisualTests(unittest.TestCase):
    def test_all_ten_elements_have_recoil_profiles(self):
        match = re.search(r"const HIT_RECOIL_MULTIPLIERS: Array\[float\] = \[([^\]]+)\]", BOSS)
        self.assertIsNotNone(match)
        values = [float(value.strip()) for value in match.group(1).split(",")]
        self.assertEqual(len(values), 10)
        self.assertLess(values[2], values[6])
        self.assertLess(values[7], values[8])

    def test_recoil_remains_visual_only(self):
        self.assertIn("func react_to_hit(critical: bool = false)", BOSS)
        self.assertIn("HIT_RECOIL_MULTIPLIERS[clampi(element_id, 0, 9)]", BOSS)
        self.assertIn("part.position.z += recoil_curve", BOSS)
        self.assertIn("recoil_duration = 0.34 if critical else 0.24", BOSS)


if __name__ == "__main__":
    unittest.main()
