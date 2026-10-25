"""Static checks for boss framing in the portrait camera.

Rendering and device aspect ratios still require a Godot runtime test.
"""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
CAMERA = (ROOT / "scripts" / "camera_follow.gd").read_text(encoding="utf-8")
BATTLE = (ROOT / "scripts" / "battle_manager.gd").read_text(encoding="utf-8")
SCENE = (ROOT / "scenes" / "main.tscn").read_text(encoding="utf-8")


class BossCameraTests(unittest.TestCase):
    def test_camera_tracks_real_boss_encounter_state(self):
        self.assertIn('NodePath("../BattleManager")', CAMERA)
        self.assertIn('NodePath("../EnemySpawn")', CAMERA)
        self.assertIn('battle_manager.get("battle_active")', CAMERA)
        self.assertIn('battle_manager.get("is_boss")', CAMERA)

    def test_boss_framing_keeps_both_team_and_boss(self):
        self.assertIn("(team_position + boss_position) * 0.5", CAMERA)
        self.assertIn("separation * 1.65", CAMERA)
        self.assertIn("look_at(focus, Vector3.UP)", CAMERA)

    def test_scene_has_expected_nodes_and_procedural_boss(self):
        self.assertIn('[node name="TeamFormation"', SCENE)
        self.assertIn('[node name="EnemySpawn"', SCENE)
        self.assertIn('[node name="BattleManager"', SCENE)
        self.assertIn("BOSS_ART.build(mob, element_id, is_fusion_boss)", BATTLE)


if __name__ == "__main__":
    unittest.main()
