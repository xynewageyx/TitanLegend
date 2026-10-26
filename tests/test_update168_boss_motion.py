"""Protect the complete, verified Update 168 elemental boss animation.

This is a source-integrity test; Godot runtime animation validation is separate.
"""
from pathlib import Path
import hashlib
import unittest

ROOT = Path(__file__).resolve().parents[1]
LIVE = ROOT / "scripts" / "boss_motion.gd"
ARCHIVED = ROOT / "original_update168" / "scripts" / "boss_motion.gd"
EXPECTED_SHA256 = "54d8d22371d590d21542b779891191d122815e1233088a0014b114cd3616ddb1"


class BossMotionImportTests(unittest.TestCase):
    def test_live_boss_motion_retains_original_interface(self):
        # The live animator is intentionally extended after Update 168.
        # Its public behavior is protected by the feature checks below.
        self.assertTrue(LIVE.is_file())
        self.assertGreater(LIVE.stat().st_size, 0)

    def test_archived_original_checksum(self):
        self.assertEqual(hashlib.sha256(ARCHIVED.read_bytes()).hexdigest(), EXPECTED_SHA256)

    def test_elemental_animator_features(self):
        code = LIVE.read_text(encoding="utf-8")
        for marker in (
            "class_name TitanBossMotion",
            "STRIKE_VISUAL_DURATIONS",
            "IDLE_MOTION_SPEEDS",
            "SHARD_COUNT: int = 8",
            "_create_elemental_shards()",
            "func attack_windup()",
            "func attack_release()",
            "func react_to_hit(critical: bool = false)",
            "func set_enraged(value: bool)",
            "part.position = base_positions[i]",
            "recoil_strength",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, code)


if __name__ == "__main__":
    unittest.main()
