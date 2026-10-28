"""Update 218: static safety checks for optional imported Android GLB visuals."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
LOADER = (ROOT / "scripts/titan_model_loader.gd").read_text(encoding="utf-8")
FORMATION = (ROOT / "scripts/team_formation.gd").read_text(encoding="utf-8")
MOTION = (ROOT / "scripts/hero_combat_motion.gd").read_text(encoding="utf-8")


class Imported3DPipelineTests(unittest.TestCase):
    def test_missing_asset_retains_existing_visuals(self):
        self.assertIn("if not ResourceLoader.exists(path):", LOADER)
        self.assertIn("return null", LOADER)
        self.assertIn("if model == null:", FORMATION)
        self.assertIn("_hide_fallback_visuals(host, model)", FORMATION)
        self.assertIn("mesh_node.visible = false", FORMATION)
        self.assertIn('child.name == "HeroCombatMotion"', FORMATION)
        self.assertIn('child.name == "PassivePet"', FORMATION)

    def test_hero_and_passive_pet_models_have_separate_paths(self):
        self.assertIn('"heroes/class_%d"', FORMATION)
        self.assertIn('"pets/element_%d"', FORMATION)
        self.assertIn('hero.add_child(pet)', FORMATION)
        self.assertIn("TitanModelLoader.attach_model(host, model_id)", FORMATION)

    def test_animation_states_are_connected(self):
        for state in ('&"Idle"', '&"Run"', '&"Attack"', '&"Hit"', '&"Defeat"'):
            self.assertIn(state, MOTION)
        self.assertIn("imported_animation_player.play(resolved", MOTION)
        self.assertIn("get_animation_list()", MOTION)
        self.assertIn("clip.get_slice(", MOTION)
        self.assertIn("0.12 if imported_animation_state", MOTION)
        self.assertIn("TitanImportedModel", MOTION)

    def test_imported_motion_loops_only_travel_states(self):
        self.assertIn('state == &"Idle" or state == &"Run"', MOTION)
        self.assertIn("clip.loop_mode = Animation.LOOP_LINEAR", MOTION)
        self.assertIn("clip.loop_mode = Animation.LOOP_NONE", MOTION)
        self.assertIn("imported_animation_player.get_animation(resolved)", MOTION)

    def test_imported_model_hides_old_combat_parts(self):
        self.assertIn("_hide_procedural_limbs()", MOTION)
        self.assertIn("for part in [left_arm, right_arm, left_leg, right_leg]", MOTION)
        self.assertIn("part.visible = false", MOTION)
        self.assertIn('defense_ring.visible = false', MOTION)

    def test_loader_rejects_path_traversal(self):
        self.assertIn('model_id.contains("..")', LOADER)
        self.assertIn('model_id.begins_with("/")', LOADER)

    def test_no_pet_attack_logic_added(self):
        self.assertNotIn("play_attack", LOADER)
        self.assertNotIn("deal_damage", LOADER)


if __name__ == "__main__":
    unittest.main()
