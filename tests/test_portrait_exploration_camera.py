"""Guard the portrait exploration camera against excessive empty foreground."""
from pathlib import Path
import unittest

CAMERA = (Path(__file__).resolve().parents[1] / "scripts/camera_follow.gd").read_text(encoding="utf-8")


class PortraitExplorationCameraTests(unittest.TestCase):
    def test_exploration_framing(self):
        self.assertIn("Vector3(0.0, 8.8, 13.2)", CAMERA)
        self.assertIn("Vector3(0.0, 1.45, -3.2)", CAMERA)

    def test_boss_camera_remains_independent(self):
        self.assertIn("if boss_active and enemy_spawn != null", CAMERA)
        self.assertIn("clampf(framing_distance * 1.65, 19.0, 34.0)", CAMERA)


if __name__ == "__main__":
    unittest.main()
