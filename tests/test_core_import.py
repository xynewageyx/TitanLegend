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
        self.assertIn("_deal_damage_to_enemy(slot, actual_damage)", attack)
        self.assertIn("_update_enemy_casualties()", text.split("func _deal_damage_to_enemy(", 1)[1].split("\nfunc ", 1)[0])

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

    def test_midgame_boss_minions_and_second_phase(self):
        boss = source("battle_manager.gd")
        balance = source("titan_combat_balance.gd")
        self.assertIn("stage >= 401", balance)
        self.assertIn("static func has_boss_minions(stage: int, fusion: bool)", balance)
        self.assertIn("boss_minion_hp = [boss_minion_max_hp, boss_minion_max_hp]", boss)
        self.assertIn("func _spawn_boss_minion_visuals()", boss)
        self.assertIn("func _boss_minions_attack()", boss)
        self.assertIn("func _on_boss_minion_defeated()", boss)
        self.assertIn("func _boss_phase_two_tick()", boss)
        self.assertIn('"heal"', boss)
        self.assertIn('"defense"', boss)
        self.assertIn('"attack"', boss)

    def test_passive_element_pets_and_healer_differences(self):
        boss = source("battle_manager.gd")
        balance = source("titan_combat_balance.gd")
        team = source("team_formation.gd")
        menu = source("skill_menu.gd")
        self.assertIn("static func passive_pet_stats(", balance)
        self.assertIn("static func damage_after_resistance(", balance)
        self.assertIn("pet_element_ids", team)
        self.assertIn("set_pet_element(", team)
        self.assertIn("_pet_stats(slot)", boss)
        self.assertIn("TitanCombatBalance.healer_profile(", boss)
        self.assertIn("pet_element_selector", menu)
        self.assertIn("ScrollContainer.new()", menu)

    def test_four_reusable_bosses_in_each_elemental_area(self):
        balance = source("titan_combat_balance.gd")
        battle = source("battle_manager.gd")
        biome = source("biome_manager.gd")
        self.assertIn('BOSS_TITLES := ["Waechter", "Sturmrufer", "Runenhueter", "Urtitan"]', balance)
        self.assertIn("posmod(maxi(1, stage) - 1, 100)", balance)
        self.assertIn("match boss_variant_id:", battle)
        self.assertIn("variant_hp_scale", battle)
        self.assertIn("[1.08, 0.96, 0.94, 1.05]", battle)
        self.assertIn("boss_cc_required = 3 if is_fusion_boss else 2", battle)
        self.assertIn("floori(float(stage - 1) / 100.0)", biome)
        self.assertIn("% 10", biome)

    def test_boss_variants_keep_one_element_and_different_silhouettes(self):
        battle = source("battle_manager.gd")
        balance = source("titan_combat_balance.gd")
        self.assertIn("boss_resistance = TitanCombatBalance.boss_resistance(boss_variant_id)", battle)
        self.assertIn("static func boss_resistance(variant: int)", balance)
        self.assertIn("const RESISTANCES:", balance)
        self.assertIn("match boss_variant_id:", battle)
        self.assertIn("tint = biome_manager.COLORS[biome_manager.current_biome]", battle)
        self.assertIn("VisualFactory.cylinder(mob", battle)
        self.assertIn("VisualFactory.box(mob", battle)

    def test_no_hero_attack_after_encounter_finishes(self):
        battle = source("battle_manager.gd")
        hero_attack = battle.split("func _hero_attack(", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("_deal_damage_to_enemy(slot, actual_damage)", hero_attack)
        self.assertIn("if not battle_active:", hero_attack)

    def test_area_difficulty_starts_at_stage_101(self):
        balance = source("titan_combat_balance.gd")
        battle = source("battle_manager.gd")
        self.assertIn("static func area_number(stage: int)", balance)
        self.assertIn("static func enemy_hp_scale(stage: int)", balance)
        self.assertIn("static func enemy_damage_scale(stage: int)", balance)
        self.assertIn("0.045 * completed + 0.003 * completed * completed", balance)
        self.assertIn("0.022 * completed + 0.0015 * completed * completed", balance)
        self.assertIn("TitanCombatBalance.enemy_hp_scale(current_level)", battle)
        self.assertGreaterEqual(battle.count("TitanCombatBalance.enemy_damage_scale(current_level)"), 5)
        self.assertIn("const BOSS_TIME_LIMIT: float = 60.0", battle)
        self.assertIn("boss_time_remaining = BOSS_TIME_LIMIT", battle)
        self.assertIn("boss_variant_id = TitanCombatBalance.boss_variant(current_level)", battle)
        self.assertIn("stage >= 401", balance)

    def test_aoe_applied_once_per_target(self):
        skill = source("skill_system.gd")
        battle = source("battle_manager.gd")
        body = skill.split("static func damage_for_skill(", 1)[1]
        self.assertNotIn("float(targets)", body)
        self.assertIn("damage_multiplier(role)", body)
        self.assertIn("if not is_boss and is_area:", battle)
        self.assertIn("dealt *= mini(maxi(enemies_remaining, 1), 7)", battle)
        self.assertIn("_deal_damage_to_enemy(slot, maxi(1, damage), bool(skill.get(\"aoe\", false)))", battle)

    def test_no_post_defeat_actions_in_same_frame(self):
        battle = source("battle_manager.gd")
        process = battle.split("func _process(", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("_attack_tick()\n  if not battle_active:\n   return", process)
        self.assertIn("for slot in range(4):\n  if not battle_active:", process)
        attack = battle.split("func _attack_tick(", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("_resolve_boss_cast()\n    if not battle_active:", attack)

    def test_hero_talents_and_jewels_reach_battle_formulas(self):
        battle = source("battle_manager.gd")
        balance = source("titan_combat_balance.gd")
        self.assertIn("static func hero_progression(", balance)
        self.assertIn("TitanTalentSystem.OFFENSE[cls]", balance)
        self.assertIn("TitanTalentSystem.DEFENSE[cls]", balance)
        self.assertIn("TitanTalentSystem.SUPPORT[cls]", balance)
        self.assertIn("minf(0.20", balance)
        self.assertIn("func _hero_progression(slot: int)", battle)
        self.assertIn("GameManager.jewel_level", battle)
        self.assertIn('get("attack", 0.0)', battle)
        self.assertIn('get("defense", 0.0)', battle)
        self.assertIn('get("healing", 0.0)', battle)

    def test_progression_scaling_is_gradual_and_talent_labels_match(self):
        balance = source("titan_combat_balance.gd")
        talents = source("talent_system.gd")
        self.assertIn("float(maxi(0, jewel_level - 1)) * 0.0001", balance)
        self.assertIn("float(TitanTalentSystem.OFFENSE[cls]) * 0.25", balance)
        self.assertIn("float(TitanTalentSystem.DEFENSE[cls]) * 0.10", balance)
        self.assertIn("float(TitanTalentSystem.SUPPORT[cls]) * 0.20", balance)
        self.assertIn("float(OFFENSE[class_id]) * 0.25", talents)
        self.assertIn("float(DEFENSE[class_id]) * 0.10", talents)
        self.assertIn("float(SUPPORT[class_id]) * 0.20", talents)
        self.assertIn("const MAX_RANK: int = 500", talents)

    def test_cc_slot_no_longer_blocks_strict_rotation(self):
        battle = source("battle_manager.gd")
        usability = battle.split("func _skill_is_usable(", 1)[1].split("\nfunc ", 1)[0]
        execute = battle.split("func _execute_equipped_skill(", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn('if choice == 7:\n  # The fourth slot must not deadlock', usability)
        self.assertIn('last_ability = "Kontrolle vorbereitet"', execute)
        self.assertIn("_apply_boss_cc_hit()", execute)
        self.assertIn("prepared_cc[slot] = 1", execute)
        cc = battle.split("func _apply_boss_cc_hit(", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("boss_cc_progress += 1", cc)
        self.assertIn('boss_cast_kind = ""', cc)
        self.assertIn("boss_cc_required = 0", cc)
        self.assertIn("next_skill_slot[slot] = (index + 1) % loadout.size()", battle)

    def test_multiple_cc_cast_window_without_changing_boss_timer(self):
        battle = source("battle_manager.gd")
        cast = battle.split("func _begin_boss_cast(", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("boss_cast_ticks = 3 + maxi(0, boss_cc_required - 1) * 2", cast)
        self.assertIn("boss_cc_required = 3 if is_fusion_boss else 2", cast)
        self.assertIn("const BOSS_TIME_LIMIT: float = 60.0", battle)
        # Required hits 1/2/3 => windows 3/5/7 enemy ticks.
        self.assertEqual([3 + max(0, n - 1) * 2 for n in (1, 2, 3)], [3, 5, 7])

    def test_prepared_cc_contributes_once_per_living_hero(self):
        battle = source("battle_manager.gd")
        self.assertIn("var prepared_cc: Array[int] = [0, 0, 0, 0]", battle)
        self.assertIn("prepared_cc.fill(0)", battle)
        cast = battle.split("func _begin_boss_cast(", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("if prepared_cc[slot] <= 0 or hero_hp[slot] <= 0:", cast)
        self.assertIn("prepared_cc[slot] = 0", cast)
        self.assertIn("_apply_boss_cc_hit()", cast)
        self.assertIn("if boss_cast_ticks <= 0:", cast)
        self.assertIn("const BOSS_TIME_LIMIT: float = 60.0", battle)

    def test_healer_slots_do_not_deadlock_at_full_health(self):
        battle = source("battle_manager.gd")
        usable = battle.split("func _skill_is_usable(", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("if role == 2 and choice == 8:\n  return true", usable)
        self.assertNotIn("hero_hp[i] < hero_max_hp[i]", usable)
        self.assertIn('last_ability = "Heilung vorbereitet"', battle)
        self.assertIn('last_ability = "Erneuerung vorbereitet"', battle)
        self.assertIn("next_skill_slot[slot] = (index + 1) % loadout.size()", battle)

    def test_prepared_heals_are_bounded_and_cannot_revive(self):
        battle = source("battle_manager.gd")
        self.assertIn("var prepared_healing: Array[int] = [-1, -1, -1, -1]", battle)
        self.assertIn("prepared_healing.fill(-1)", battle)
        self.assertIn("prepared_healing[slot] = choice", battle)
        helper = battle.split("func _trigger_prepared_healing(", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("hero_hp[slot] <= 0", helper)
        self.assertIn("prepared_healing[slot] = -1", helper)
        self.assertIn("if not _has_wounded_hero():", helper)
        self.assertIn("_trigger_prepared_healing()", battle)
        self.assertIn("const BOSS_TIME_LIMIT: float = 60.0", battle)

    def test_re_equipping_clears_prepared_combat_effects(self):
        battle = source("battle_manager.gd")
        setter = battle.split("func set_skill_loadout(", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("next_skill_slot[hero] = 0", setter)
        self.assertIn("skill_hit_charge[hero] = 0", setter)
        self.assertIn("prepared_cc[hero] = 0", setter)
        self.assertIn("prepared_healing[hero] = -1", setter)
        self.assertIn("SaveManager.save_game()", setter)
        self.assertIn("const BOSS_TIME_LIMIT: float = 60.0", battle)

    def test_multiple_healers_preserve_stronger_active_hot(self):
        battle = source("battle_manager.gd")
        hot = battle.split("func _apply_heal_over_time(", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("hero_hot_amount[target] = maxi(hero_hot_amount[target], new_amount)", hot)
        self.assertIn("hero_hot_ticks[target] = maxi(hero_hot_ticks[target], new_ticks)", hot)
        self.assertIn("hero_hp[i] <= 0", hot)
        prepared = battle.split("func _trigger_prepared_healing(", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("prepared_healing[slot] = -1", prepared)
        self.assertIn("_apply_heal_over_time(slot, skill)", prepared)
        self.assertIn("const BOSS_TIME_LIMIT: float = 60.0", battle)

    def test_simultaneous_aoe_uses_one_tank_intercept_snapshot(self):
        battle = source("battle_manager.gd")
        damage = battle.split("func _damage_heroes(", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("var tank: int = _living_tank_slot()", damage)
        self.assertIn("var intercept_active: bool = tank >= 0 and tank_intercept_until[tank] >= skill_tick", damage)
        self.assertIn("if intercept_active and index != tank:", damage)
        self.assertEqual(damage.count("_living_tank_slot()"), 1)
        self.assertLess(damage.index("var intercept_active:"), damage.index("for index in targets:"))
        self.assertIn("_trigger_prepared_healing()", damage)
        self.assertIn("const BOSS_TIME_LIMIT: float = 60.0", battle)

    def test_boss_spell_aoe_scales_for_each_living_hero(self):
        battle = source("battle_manager.gd")
        aoe = battle.split("func _resolve_boss_cast(", 1)[1].split("\nfunc ", 1)[0]
        damage = battle.split("func _damage_heroes(", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("_damage_heroes(0, targets, 0.13 if is_fusion_boss else 0.10)", aoe)
        self.assertNotIn("hero_max_hp[0]", aoe)
        self.assertIn("max_hp_fraction: float = 0.0", battle)
        self.assertIn("float(hero_max_hp[index]) * max_hp_fraction", damage)
        self.assertIn("TitanCombatBalance.enemy_damage_scale(current_level)", damage)
        self.assertIn("var intercept_active: bool =", damage)
        self.assertIn("const BOSS_TIME_LIMIT: float = 60.0", battle)

    def test_successful_cc_only_exposes_boss_for_four_ticks(self):
        battle = source("battle_manager.gd")
        self.assertIn("const INTERRUPT_VULNERABILITY_TICKS: int = 4", battle)
        self.assertIn("const INTERRUPT_BOSS_DAMAGE_BONUS: float = 0.15", battle)
        interrupt = battle.split("func _apply_boss_cc_hit(", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("if boss_cc_progress >= boss_cc_required:", interrupt)
        self.assertIn("boss_vulnerable_until_tick = skill_tick + INTERRUPT_VULNERABILITY_TICKS", interrupt)
        wave = battle.split("func spawn_wave(", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("boss_vulnerable_until_tick = -1", wave)
        damage = battle.split("func _deal_damage_to_enemy(", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("if is_boss and skill_tick < boss_vulnerable_until_tick else 1.0", damage)
        self.assertLess(damage.index("if is_boss and not boss_minion_hp.is_empty()"), damage.index("var vulnerability:"))
        self.assertIn("(1.0 - defense) * vulnerability", damage)
        self.assertIn("const BOSS_TIME_LIMIT: float = 60.0", battle)

    def test_cc_vulnerability_is_exactly_four_ticks(self):
        battle = source("battle_manager.gd")
        self.assertIn("boss_vulnerable_until_tick = skill_tick + INTERRUPT_VULNERABILITY_TICKS", battle)
        self.assertIn("skill_tick < boss_vulnerable_until_tick", battle)
        self.assertEqual([t for t in range(10, 17) if t < 10 + 4], [10, 11, 12, 13])
        self.assertIn("const BOSS_TIME_LIMIT: float = 60.0", battle)

    def test_weapon_upgrades_charge_gold_save_and_affect_both_attack_paths(self):
        game = source("game_manager.gd")
        save = source("save_manager.gd")
        battle = source("battle_manager.gd")
        ui = source("ui_manager.gd")
        self.assertIn("var weapon_levels: Array[int] = [0, 0, 0, 0]", game)
        self.assertIn("const MAX_WEAPON_LEVEL: int = 300", game)
        self.assertIn("return 500 * (weapon_levels[slot] + 1)", game)
        self.assertIn("return minf(0.15, float(weapon_levels[slot]) * 0.0005)", game)
        self.assertIn("add_gold(-cost)", game)
        self.assertIn('"weapon_levels": GameManager.weapon_levels.duplicate()', save)
        self.assertIn('data.get("weapon_levels", [0, 0, 0, 0])', save)
        self.assertIn("GameManager.weapon_attack_bonus(slot)", battle)
        self.assertGreaterEqual(battle.count("GameManager.weapon_attack_bonus(slot)"), 2)
        self.assertIn("GameManager.upgrade_weapon(weapon_hero_slot)", ui)
        self.assertIn("weapon_hero_slot = (weapon_hero_slot + 1) % 4", ui)
        self.assertIn("const BOSS_TIME_LIMIT: float = 60.0", battle)

    def test_four_hardening_fields_gold_cap_and_saves(self):
        game = source("game_manager.gd")
        save = source("save_manager.gd")
        battle = source("battle_manager.gd")
        ui = source("ui_manager.gd")
        self.assertIn("var hardening_levels: Array =", game)
        self.assertIn("if level >= maxi(1, character_level):", game)
        self.assertIn("return 1000 * (level + 1)", game)
        self.assertIn("if cost <= 0 or current_gold < cost:", game)
        self.assertIn("hardening_levels[hero][field] = int(hardening_levels[hero][field]) + 1", game)
        self.assertIn('"hardening_levels": GameManager.hardening_levels.duplicate(true)', save)
        self.assertIn('data.get("hardening_levels", [])', save)
        self.assertIn("GameManager.hardening_bonus(i, 2)", battle)
        self.assertIn("GameManager.hardening_bonus(index, 1)", battle)
        self.assertGreaterEqual(battle.count("GameManager.hardening_bonus(slot, 0)"), 2)
        self.assertIn("GameManager.hardening_bonus(slot, 3)", battle)
        self.assertIn("GameManager.upgrade_hardening(weapon_hero_slot, hardening_field)", ui)
        self.assertIn("const BOSS_TIME_LIMIT: float = 60.0", battle)

    def test_hardening_six_attributes_and_gold_rerolls(self):
        game = source("game_manager.gd")
        save = source("save_manager.gd")
        battle = source("battle_manager.gd")
        ui = source("ui_manager.gd")
        self.assertIn('const HARDENING_NAMES := ["Angriff", "Ruestung", "Lebenspunkte", "Krit-Schaden", "Ausweichen", "Aufspiessen"]', game)
        self.assertIn("var hardening_attributes: Array =", game)
        self.assertIn("for field in range(4):", game)
        self.assertIn("if int(hardening_attributes[hero][field]) == attribute:", game)
        self.assertIn("func select_hardening_attribute(", game)
        self.assertIn("func reroll_hardening_attribute(", game)
        self.assertIn("if current_gold < cost:", game)
        self.assertIn("add_gold(-cost)", game)
        self.assertIn('"hardening_attributes": GameManager.hardening_attributes.duplicate(true)', save)
        self.assertIn('data.get("hardening_attributes", [])', save)
        self.assertIn("GameManager.hardening_bonus(index, 4)", battle)
        self.assertIn("GameManager.hardening_bonus(slot, 5)", battle)
        self.assertIn("GameManager.select_hardening_attribute(", ui)
        self.assertIn("GameManager.reroll_hardening_attribute(", ui)
        self.assertIn("const BOSS_TIME_LIMIT: float = 60.0", battle)

    def test_six_weapon_rarity_tiers_and_promotions(self):
        game = source("game_manager.gd")
        save = source("save_manager.gd")
        ui = source("ui_manager.gd")
        battle = source("battle_manager.gd")
        self.assertIn('const WEAPON_RARITIES := ["Weiss", "Gruen", "Blau", "Gelb", "Gold", "Lila"]', game)
        self.assertIn("const WEAPON_RARITY_LEVELS := [0, 20, 50, 100, 180, 260]", game)
        self.assertIn("var weapon_rarities: Array[int] = [0, 0, 0, 0]", game)
        self.assertIn("func weapon_rarity_upgrade_cost(slot: int)", game)
        self.assertIn("if current_gold < cost:", game)
        self.assertIn("weapon_rarities[slot] += 1", game)
        self.assertIn("WEAPON_RARITY_BONUS[weapon_rarities[slot]]", game)
        self.assertIn('"weapon_rarities": GameManager.weapon_rarities.duplicate()', save)
        self.assertIn('data.get("weapon_rarities", [])', save)
        self.assertIn("GameManager.upgrade_weapon_rarity(weapon_hero_slot)", ui)
        self.assertIn("GameManager.weapon_attack_bonus(slot)", battle)
        self.assertIn("const BOSS_TIME_LIMIT: float = 60.0", battle)

    def test_save_manager_is_present(self):
        text = source("save_manager.gd")
        self.assertIn("func save_game()", text)
        self.assertIn("func load_game()", text)

    def test_no_accidental_binary_commits(self):
        for forbidden in ("*.apk", "*.aab", "*.keystore", "*.jks"):
            self.assertEqual(list(ROOT.rglob(forbidden)), [])


if __name__ == "__main__":
    unittest.main()
