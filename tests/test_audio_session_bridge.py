import pathlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
BRIDGE = (ROOT / "scripts/audio_session_bridge.gd").read_text(encoding="utf-8")

class AudioSessionBridgeTests(unittest.TestCase):
    def test_authoritative_snapshot_binds_local_class(self):
        self.assertIn("AudioManager.bind_local_hero_with_classes(owner_peer_ids, class_ids, local_peer_id)", BRIDGE)

    def test_disconnect_clears_ownership(self):
        self.assertIn("func on_session_disconnected()", BRIDGE)
        self.assertIn("AudioManager.clear_local_hero()", BRIDGE)

    def test_team_and_character_change_rebind(self):
        self.assertIn("func on_team_changed(", BRIDGE)
        self.assertIn("func on_character_changed(", BRIDGE)
        self.assertEqual(BRIDGE.count("return apply_authoritative_team_snapshot("), 2)

if __name__ == "__main__":
    unittest.main()
