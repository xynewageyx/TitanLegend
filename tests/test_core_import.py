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

    def test_skills_charge_from_normal_hits_at_most_five(self):
        code = source("battle_manager.gd")
        self.assertIn("const MAX_SKILL_HITS: int = 5", code)
        self.assertIn("skill_hit_charge[slot] + 1", code)
        self.assertIn("_try_cast_charged_skill(slot, role)", code)
        self.assertIn("next_skill_slot[slot] = (index + 1) % loadout.size()", code)
        body = code.split("func _try_cast_charged_skill(", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("var index: int = next_skill_slot[slot] % loadout.size()", body)
        self.assertNotIn("for offset in range(loadout.size())", body)
        self.assertIn("if not _skill_is_usable(slot, role, choice):", body)
        self.assertIn("if skill_hit_charge[slot] < required_hits:", code)
        self.assertIn("skill_hit_charge[slot] = 0", code)
        self.assertNotIn("func _activate_tank_skill(slot: int)", code)

    def test_tank_skills_are_separate_equipped_automatic_skills(self):
        code = source("battle_manager.gd")
        self.assertIn("if role == 0 and choice == 8:", code)
        self.assertIn("if role == 0 and choice == 9:", code)
        self.assertIn("tank_taunt_until[slot] = skill_tick + 3", code)
        self.assertIn("tank_intercept_until[slot] = skill_tick + 4", code)
        self.assertIn("return 5 # Gruppenschaden abfangen", code)
        self.assertIn("if skill_tick % 4 == 0:", code)
        self.assertIn("_damage_heroes(damage, group_targets)", code)
        self.assertIn("tank_intercept_until[tank] >= skill_tick", code)
        self.assertIn('last_ability = "Gruppenschaden abfangen"', code)
        self.assertNotIn("hp_regeneration", code)

    def test_skill_display_and_boss_cast(self):
        battle = source("battle_manager.gd")
        menu = source("skill_menu.gd")
        self.assertIn("boss_cast_ticks = 3", battle)
        self.assertIn("skill_hit_charge.fill(0)", battle)
        self.assertIn("next_skill_slot.fill(0)", battle)
        self.assertIn("battle_manager.next_skill_slot[hero]", menu)
        self.assertIn("battle_manager.skill_hit_charge[hero]", menu)

    def test_update_171_skill_bars_and_fx(self):
        menu = source("skill_menu.gd")
        battle = source("battle_manager.gd")
        motion = source("hero_combat_motion.gd")
        self.assertIn("var charge_bars: Array[ProgressBar]", menu)
        self.assertIn("var charge_labels: Array[Label]", menu)
        self.assertIn("charge_bars[index].value", menu)
        self.assertIn("battle_manager.skill_hit_charge[hero]", menu)
        self.assertIn('motion.call("play_skill_cast", role, choice)', battle)
        self.assertIn("func play_skill_cast(role: int, choice: int)", motion)
        self.assertIn("skill_flash_remaining", motion)

    def test_timed_cc_and_boss_attack_variety(self):
        battle = source("battle_manager.gd")
        self.assertIn("boss_cc_progress += 1", battle)
        self.assertIn("boss_cc_progress >= boss_cc_required", battle)
        self.assertIn('boss_cast_kind = "self_heal"', battle)
        self.assertIn('boss_cast_kind = "single"', battle)
        self.assertIn('boss_cast_kind = "aoe"', battle)
        self.assertIn("boss_cast_ticks = 3", battle)
        self.assertIn("enemy_hp = mini(enemy_max_hp", battle)
        self.assertIn("boss_cc_required = 3 if is_fusion_boss else 2", battle)

    def test_healer_hot_is_timed_and_cannot_revive(self):
        battle = source("battle_manager.gd")
        skills = source("skill_system.gd")
        menu = source("skill_menu.gd")
        self.assertIn("func _apply_heal_over_time(", battle)
        self.assertIn("func _tick_heal_over_time()", battle)
        self.assertIn("if hero_hp[i] <= 0:", battle)
        self.assertIn("hero_hot_ticks[i] -= 1", battle)
        self.assertIn('"hot_ticks":4', skills)
        self.assertIn("9 if role == 2 else 8", menu)
        self.assertIn("hero_hot_ticks.fill(0)", battle)

    def test_save_manager_is_present(self):
        text = source("save_manager.gd")
        self.assertIn("func save_game()", text)
        self.assertIn("func load_game()", text)

    def test_no_accidental_binary_commits(self):
        for forbidden in ("*.apk", "*.aab", "*.keystore", "*.jks"):
            self.assertEqual(list(ROOT.rglob(forbidden)), [])


if __name__ == "__main__":
    unittest.main()
