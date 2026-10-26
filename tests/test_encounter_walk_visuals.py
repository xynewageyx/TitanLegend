"""Static safeguards for encounter walking and Android pause cancellation."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
TEAM = (ROOT / "scripts/team_formation.gd").read_text(encoding="utf-8")
BATTLE = (ROOT / "scripts/battle_manager.gd").read_text(encoding="utf-8")


class EncounterWalkTests(unittest.TestCase):
    def test_walk_uses_eased_tween(self):
        self.assertIn('position.z - 2.0, 1.25', TEAM)
        self.assertIn('Tween.TRANS_SINE', TEAM)
        self.assertIn('Tween.EASE_IN_OUT', TEAM)

    def test_cancelled_walk_does_not_finish(self):
        self.assertIn('func stop_walking()', TEAM)
        self.assertIn('walk_tween.kill()', TEAM)
        self.assertIn('if not is_walking:', TEAM)
        self.assertIn('walking_finished.emit()', TEAM)

    def test_battle_cancels_walk_on_pause(self):
        self.assertIn('NOTIFICATION_APPLICATION_PAUSED', BATTLE)
        self.assertIn('_cancel_pending_walk()', BATTLE)
        self.assertIn('_encounter_request_id += 1', BATTLE)


if __name__ == "__main__":
    unittest.main()
