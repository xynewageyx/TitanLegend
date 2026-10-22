"""Static regression checks for Titan Legend's imported Godot 4 source.

Run: python -m unittest discover -s tests -v
These checks are intentionally strict: a missing core script is a failure.
They do NOT substitute for a Godot runtime test.
"""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "scripts"


def source(name: str) -> str:
    path = SCRIPTS / name
    if not path.is_file():
        raise AssertionError(f"Required Godot script missing: {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


class ImportedCoreRegressionTests(unittest.TestCase):
    def test_godot_entrypoint(self):
        project = ROOT / "project.godot"
        self.assertTrue(project.is_file(), "project.godot is missing")
        text = project.read_text(encoding="utf-8")
        self.assertIn('run/main_scene="res://scenes/main.tscn"', text)
        self.assertTrue((ROOT / "scenes/main.tscn").is_file())

    def test_team_role_lock_has_no_displacement(self):
        text = source("team_formation.gd")
        self.assertRegex(text, r"func set_role\(slot: int, role: int\) -> bool:")
        body = text.split("func set_role(", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("role == 0", body)
        self.assertIn("role_ids[i] == 0", body)
        self.assertIn("return false", body)
        self.assertNotRegex(body, r"role_ids\[i\]\s*=\s*1")

    def test_tank_target_priority_matches_update_168(self):
        text = source("battle_manager.gd")
        body = text.split("func _choose_routine_enemy_target()", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("tank_taunt_until[active_tank] >= skill_tick", body)
        self.assertIn("randf() < 0.65", body)
        self.assertIn("survivors.erase(active_tank)", body)
        self.assertNotIn("role_ids[", body, "Enemy targeting must not change team roles")

    def test_enemy_combat_uses_single_living_tank(self):
        text = source("battle_manager.gd")
        self.assertIn("func _living_tank_slot()", text)
        self.assertIn("func _choose_routine_enemy_target()", text)

    def test_saved_progress_restores_stage_wave_and_skills(self):
        text = source("battle_manager.gd")
        self.assertIn("SaveManager.get_saved_battle_progress()", text)
        self.assertIn("current_level = maxi(1, saved_progress.x)", text)
        self.assertIn("current_wave = clampi(saved_progress.y, 1, BOSS_WAVE)", text)
        self.assertIn("SaveManager.get_saved_skill_choices()", text)
        self.assertIn("SaveManager.get_saved_skill_loadouts()", text)
        self.assertIn('add_to_group("battle_manager")', text)

    def test_normal_wave_preserves_party_health(self):
        text = source("battle_manager.gd")
        wave = text.split("func spawn_wave()", 1)[1].split("\nfunc ", 1)[0]
        self.assertNotIn("_reset_hero_health()", wave)
        self.assertIn("SaveManager.save_game()", text.split("func finish_wave()", 1)[1])

    def test_original_ten_wave_boss_flow(self):
        text = source("battle_manager.gd")
        self.assertIn("const BOSS_WAVE: int = 10", text)
        self.assertIn("is_boss = astral_active or current_wave == BOSS_WAVE", text)
        self.assertIn("enemies_remaining = 1 if is_boss else mini(2 + current_wave, 7)", text)
        self.assertIn("_spawn_enemy_visuals()", text)
        self.assertIn("enemy_spawn_node.add_child(mob)", text)
        self.assertNotIn("WAVE_ENEMY_COUNTS", text)

    def test_astral_round_trip_and_rewards(self):
        text = source("battle_manager.gd")
        self.assertIn("world_progress = Vector2i(current_level, current_wave)", text)
        self.assertIn("current_level = world_progress.x", text)
        self.assertIn("current_wave = world_progress.y", text)
        self.assertIn("GameManager.add_tickets(10)", text)
        self.assertIn("GameManager.add_gold(gold_reward)", text)
        self.assertIn("SaveManager.get_saved_astral()", text)

    def test_wave_enemy_casualties_are_visible(self):
        text = source("battle_manager.gd")
        self.assertIn("func _update_enemy_casualties()", text)
        self.assertIn("survivors = clampi(survivors, 0, enemy_visuals.size())", text)
        self.assertIn("mob.visible = false", text)
        self.assertIn("enemies_remaining = survivors", text)
        attack = text.split("func _hero_attack(", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("_update_enemy_casualties()", attack)

    def test_defeat_retries_same_wave_without_reassigning_tank(self):
        text = source("battle_manager.gd")
        defeat = text.split("func _on_team_defeat(", 1)[1].split("\nfunc ", 1)[0]
        retry = text.split("func _retry_defeated_encounter(", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("_retry_pending = true", defeat)
        self.assertIn("create_timer(2.0).timeout.connect(_retry_defeated_encounter)", defeat)
        self.assertIn("_reset_hero_health()", retry)
        self.assertIn("start_next_encounter()", retry)
        self.assertNotIn("current_wave +=", retry)
        self.assertNotIn("set_role(", retry)

    def test_individual_hero_hp_bars_are_real(self):
        text = source("team_formation.gd")
        self.assertIn('_create_hero_health_bar(hero)', text)
        self.assertIn('bar.name = "HeroHealthBar"', text)
        self.assertIn('value_label.name = "HPValue"', text)
        self.assertIn('fill.scale.x = maxf(0.0001, ratio)', text)
        self.assertIn('hp_label.text = "%d / %d"', text)
        self.assertIn('func _refresh_health_after_rebuild()', text)
        self.assertNotIn('pass # Core combat health is owned by BattleManager.', text)

    def test_save_manager_is_present(self):
        text = source("save_manager.gd")
        self.assertIn("func save_game()", text)
        self.assertIn("func load_game()", text)

    def test_no_accidental_binary_commits(self):
        for forbidden in ("*.apk", "*.aab", "*.keystore", "*.jks"):
            self.assertEqual(list(ROOT.rglob(forbidden)), [])


if __name__ == "__main__":
    unittest.main()
