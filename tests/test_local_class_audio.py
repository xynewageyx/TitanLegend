"""Static regression checks for local-only class audio prewarming."""
from pathlib import Path
import unittest

AUDIO = (Path(__file__).resolve().parents[1] / "scripts/audio_manager.gd").read_text(encoding="utf-8")


class LocalClassAudioTests(unittest.TestCase):
    def test_preload_requires_owned_slot_and_valid_class(self):
        self.assertIn("if local_hero_slot < 0 or class_id < 0 or class_id > 11:", AUDIO)
        self.assertIn('_get_event_stream("class_attack_%d" % class_id)', AUDIO)
        self.assertIn('_get_event_stream("class_skill_%d" % class_id)', AUDIO)

    def test_switch_and_disconnect_clear_class(self):
        self.assertIn("if local_hero_slot != slot:\n  stop_session_combat_sfx()\n  local_hero_class_id = -1", AUDIO)
        self.assertIn("func clear_local_hero() -> void:\n stop_session_combat_sfx()\n local_hero_slot = -1\n local_hero_class_id = -1", AUDIO)

    def test_authoritative_snapshot_validates_identity_and_class(self):
        self.assertIn("func bind_local_hero_with_classes(owner_peer_ids: Array[int], class_ids: Array[int], local_peer_id: int) -> bool:", AUDIO)
        self.assertIn("if class_ids.size() != 4:", AUDIO)
        self.assertIn("if not bind_local_hero_from_team(owner_peer_ids, local_peer_id):", AUDIO)
        self.assertIn("var class_id: int = class_ids[local_hero_slot]", AUDIO)
        self.assertIn("if class_id < 0 or class_id > 11:", AUDIO)
        self.assertIn("set_local_hero_class_id(class_id)", AUDIO)

    def test_remote_hero_events_remain_silent(self):
        self.assertIn("if slot != local_hero_slot or local_hero_slot < 0:\n  return", AUDIO)


if __name__ == "__main__":
    unittest.main()
