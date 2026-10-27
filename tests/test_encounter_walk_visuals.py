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

    def test_passive_pets_have_walk_aware_idle_motion(self):
        self.assertIn('hero.get_node_or_null("PassivePet")', TEAM)
        self.assertIn("pet_bob_speed: float = 5.2 if is_walking else 3.4", TEAM)
        self.assertIn("pet_bob_height: float = 0.10 if is_walking else 0.15", TEAM)
        self.assertIn("pet.position.z = -0.35 + (sin(pet_phase * 0.5) * 0.055 if is_walking else 0.0)", TEAM)
        self.assertIn("var tail_speed: float = 5.0 if is_walking else 2.8", TEAM)
        self.assertIn("pet.rotation.y = sin(animation_clock * 1.1 + float(i)) * 0.16", TEAM)
        self.assertIn("pet.scale = Vector3(breath, breath, breath)", TEAM)
        self.assertIn('pet.get_node_or_null("AnimatedWingLeft")', TEAM)
        self.assertIn('pet.get_node_or_null("AnimatedTail")', TEAM)
        self.assertIn("pet.rotation.z += serpent_sway", TEAM)

    def test_portrait_formation_spacing_and_hp_clearance(self):
        self.assertIn("var spacing: float = (1.82 if not in_front else 2.05) if row.size() <= 3 else 1.45", TEAM)
        self.assertIn("return Vector3(x, 0.0, depth)", TEAM)
        self.assertIn("var pet_offset: float = 1.48 if pet_species in [3, 4, 8] else 1.30", TEAM)
        self.assertIn("pet.position = Vector3(pet_side * pet_offset, 0.0, -0.35)", TEAM)
        self.assertIn("bar.position = Vector3(0.0, 3.02, 0.0)", TEAM)
        self.assertIn("(fill.mesh as QuadMesh).size = Vector2(0.82, 0.12)", TEAM)

    def test_pets_stay_on_outer_side_for_all_team_slots(self):
        self.assertIn("var anchor_x: float = _formation_position(i).x", TEAM)
        self.assertIn("var pet_side: float = -1.0 if anchor_x < 0.0 else 1.0", TEAM)
        self.assertIn("pet.position = Vector3(pet_side * pet_offset, 0.0, -0.35)", TEAM)
        for anchor_x in [-2.05, -1.025, 1.025, 2.05]:
            pet_side = -1.0 if anchor_x < 0.0 else 1.0
            for species in range(10):
                pet_offset = 1.48 if species in (3, 4, 8) else 1.30
                self.assertGreater(abs(anchor_x + pet_side * pet_offset), abs(anchor_x))
                self.assertEqual((anchor_x + pet_side * pet_offset) > 0.0, anchor_x > 0.0)

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
