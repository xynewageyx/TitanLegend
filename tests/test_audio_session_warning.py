import pathlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
AUDIO = (ROOT / "scripts/audio_manager.gd").read_text(encoding="utf-8")

class AudioSessionWarningTests(unittest.TestCase):
    def test_session_cleanup_does_not_stop_shared_boss_warning(self):
        cleanup = AUDIO.split("func stop_session_combat_sfx() -> void:", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("for player in effects:", cleanup)
        self.assertNotIn("boss_warning_player.stop()", cleanup)
        self.assertNotIn("_animate_boss_duck(", cleanup)

    def test_local_hero_changes_use_session_cleanup(self):
        local = AUDIO.split("func set_local_hero_slot(", 1)[1]
        self.assertIn("stop_session_combat_sfx()", local)
        self.assertNotIn("stop_sfx()", local)

    def test_global_stop_still_stops_boss_warning(self):
        global_stop = AUDIO.split("func stop_sfx() -> void:", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("boss_warning_player.stop()", global_stop)

if __name__ == "__main__":
    unittest.main()
