"""Static regression checks for local-only class audio prewarming."""
from pathlib import Path
import unittest

AUDIO = (Path(__file__).resolve().parents[1] / "scripts/audio_manager.gd").read_text(encoding="utf-8")


class LocalClassAudioTests(unittest.TestCase):
    def test_preload_requires_owned_slot_and_valid_class(self):
        self.assertIn("if local_hero_slot < 0 or class_id < 0 or class_id > 10:", AUDIO)
        self.assertIn('_get_event_stream("class_attack_%d" % class_id)', AUDIO)
        self.assertIn('_get_event_stream("class_skill_%d" % class_id)', AUDIO)

    def test_switch_and_disconnect_clear_class(self):
        self.assertIn("if local_hero_slot != slot:\n  stop_sfx()\n  local_hero_class_id = -1", AUDIO)
        self.assertIn("func clear_local_hero() -> void:\n stop_sfx()\n local_hero_slot = -1\n local_hero_class_id = -1", AUDIO)

    def test_remote_hero_events_remain_silent(self):
        self.assertIn("if slot != local_hero_slot or local_hero_slot < 0:\n  return", AUDIO)


if __name__ == "__main__":
    unittest.main()
