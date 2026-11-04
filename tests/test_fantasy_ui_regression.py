"""Static regression checks for the optional Ulala-inspired fantasy UI.

Run: python -m unittest tests/test_fantasy_ui_regression.py
These checks do not replace a Godot import or Android build.
"""
from pathlib import Path
import hashlib
import json
import unittest

ROOT = Path(__file__).resolve().parents[1]


class FantasyUIRegression(unittest.TestCase):
    def read_script(self, name):
        return (ROOT / "scripts" / name).read_text(encoding="utf-8")

    def test_preserved_update168_boss_motion_matches_manifest(self):
        manifest = json.loads((ROOT / 'docs/update_168_import_manifest.json').read_text(encoding='utf-8'))
        expected = next(item for item in manifest['files'] if item['path'] == 'scripts/boss_motion.gd')
        archived_path = ROOT / 'original_update168/scripts/boss_motion.gd'
        if not archived_path.is_file():
            self.skipTest('Update 168 source archive is not included in this checkout')
        original = archived_path.read_bytes()
        self.assertEqual(len(original), expected['bytes'])
        self.assertEqual(hashlib.sha256(original).hexdigest(), expected['sha256'])

    def test_portrait_modals_are_raised_above_hud(self):
        ui = self.read_script("ui_manager.gd")
        self.assertIn('func _raise_fullscreen_menu(menu: Control)', ui)
        self.assertIn('move_child(menu, get_child_count() - 1)', ui)
        for target in ('$ClassMenu', '$SkillMenu', '$TalentMenu'):
            self.assertIn('_raise_fullscreen_menu(' + target + ')', ui)

    def test_talent_menu_blocks_world_and_scrolls_vertically(self):
        talent = self.read_script("talent_menu.gd")
        self.assertIn('shade.mouse_filter = Control.MOUSE_FILTER_STOP', talent)
        self.assertIn('scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED', talent)

    def test_legacy_canvaslayer_talent_editor_is_not_spawned(self):
        team = self.read_script("team_formation.gd")
        self.assertNotIn('TALENT_MENU_V2.new()', team)
        self.assertNotIn('talent_menu.name = "TalentMenuV2"', team)
        self.assertIn('set_meta("talent_builds_v2"', team)

    def test_obsolete_talent_shortcut_hidden(self):
        ui = self.read_script("ui_manager.gd")
        self.assertIn('func _suppress_legacy_shortcut()', ui)
        self.assertIn('text.strip_edges().begins_with("Talente +")', ui)
        self.assertIn('call_deferred("_suppress_legacy_shortcut")', ui)

    def test_class_menu_uses_single_scroll_container(self):
        menu = self.read_script("class_menu.gd")
        self.assertIn('scroll.add_child(v)', menu)
        self.assertNotIn('panel.add_child(v)', menu)
        self.assertIn('ScrollContainer.SCROLL_MODE_DISABLED', menu)

    def test_single_canonical_boss_panel(self):
        hud = self.read_script("adventure_hud_overlay.gd")
        ui = self.read_script("ui_manager.gd")
        self.assertNotIn('AdventureBossStatus', hud)
        self.assertIn('boss_panel.name = "BossHP"', ui)
        self.assertIn('battle_manager.is_boss', ui)
        self.assertIn('battle_manager.enemy_hp', ui)
        self.assertIn('battle_manager.boss_time_remaining', ui)

    def test_four_hero_portraits(self):
        hud = self.read_script("adventure_hud_overlay.gd")
        self.assertIn('for i in range(4):', hud)
        self.assertIn('party_portraits.append(portrait)', hud)
        self.assertIn('party_portraits[i].modulate', hud)

    def test_direct_game_load_rechecks_character_identity(self):
        manager = self.read_script("save_manager.gd")
        load = manager.split('func load_game() -> void:', 1)[1].split('func get_saved_battle_progress()', 1)[0]
        self.assertIn('CHARACTER_SAVE_SLOTS.load_slot(registry, active_character_slot)', load)
        self.assertIn('CHARACTER_PROFILES.character_save_path(registry, active_character_slot) != SAVE_PATH', load)
        self.assertIn('Character load blocked: identity or save path mismatch.', load)

    def test_character_save_name_identity_and_visible_startup_error(self):
        slots = self.read_script("character_save_slots.gd")
        startup = self.read_script("character_startup.gd")
        self.assertIn('data.has("character_name")', slots)
        self.assertIn('str(data.get("character_name", "")) != str(profile.get("name", ""))', slots)
        self.assertIn('selector.message_label.text = "Charakter konnte nicht geladen werden.', startup)

    def test_game_entry_requires_valid_session(self):
        startup = self.read_script("character_startup.gd")
        manager = self.read_script("save_manager.gd")
        self.assertEqual(startup.count('if not SaveManager.session_ready:'), 2)
        self.assertIn('if not character_switching_enabled or session_ready:', manager)
        self.assertIn('CHARACTER_SAVE_SLOTS.load_slot(registry, active_character_slot).is_empty()', manager)

    def test_character_startup_and_immutable_player_role(self):
        project = (ROOT / "project.godot").read_text(encoding="utf-8")
        team = self.read_script("team_formation.gd")
        startup = self.read_script("character_startup.gd")
        self.assertIn('run/main_scene="res://scenes/character_startup.tscn"', project)
        self.assertIn('SaveManager.character_switching_enabled = true', startup)
        self.assertIn('SaveManager.load_game()', startup)
        self.assertIn('class_ids[0] = int(profile.get("class_id"', team)
        self.assertIn('role_ids[0] = int(profile.get("role_id"', team)
        self.assertIn('if SaveManager.active_character_slot >= 0 and slot == 0:', team)

    def test_character_switch_failure_does_not_force_legacy_save(self):
        selection = self.read_script("character_selection.gd")
        select = selection.split('func _select(slot: int) -> void:', 1)[1]
        self.assertLess(select.index('PROFILES.save_registry(candidate)'), select.index('SaveManager.configure_character_save(slot)'))
        self.assertIn('PROFILES.save_registry(registry)', select)
        self.assertNotIn('SaveManager.use_legacy_save()', select)

    def test_interrupted_character_creation_is_recoverable_without_overwrite(self):
        selection = self.read_script("character_selection.gd")
        slots = self.read_script("character_save_slots.gd")
        self.assertIn('if save_error == ERR_ALREADY_EXISTS:', selection)
        self.assertIn('SAVE_SLOTS.recover_pending_creation(candidate, creation_slot)', selection)
        self.assertIn('static func recover_pending_creation(registry: Dictionary, slot: int)', slots)
        self.assertIn('saved.get("character_name", "")', slots)
        self.assertIn('saved.get("class_id", -1)', slots)
        self.assertIn('saved.get("role_id", -1)', slots)

    def test_character_registry_backup_recovery(self):
        profiles = self.read_script("character_profiles.gd")
        self.assertIn('static func _read_registry(path: String)', profiles)
        self.assertIn('PROFILE_PATH + ".bak"', profiles)
        self.assertIn('if _read_registry(temporary).is_empty():', profiles)
        self.assertIn('Character registry restored from backup.', profiles)

    def test_autosave_routes_active_character_through_validated_slot(self):
        manager = self.read_script("save_manager.gd")
        self.assertIn('if active_character_slot >= 0:', manager)
        self.assertIn('if profile_path != SAVE_PATH:', manager)
        self.assertIn('data["class_id"]', manager)
        self.assertIn('data["role_id"]', manager)
        self.assertIn('CHARACTER_SAVE_SLOTS.save_slot(registry, active_character_slot, data)', manager)

    def test_character_selection_reads_progress_from_own_save(self):
        selection = self.read_script("character_selection.gd")
        self.assertIn('SAVE_SLOTS.load_slot(registry, slot)', selection)
        self.assertIn('updated_profile["level"]', selection)
        self.assertIn('updated_profile["xp"]', selection)
        self.assertIn('updated_profile["reincarnation"]', selection)
        self.assertIn('PROFILES.save_registry(candidate)', selection)
        self.assertIn('character_selected.emit(slot)', selection)

    def test_class_menu_fixed_header_and_footer(self):
        classes = self.read_script("class_menu.gd")
        self.assertIn('header_close.pressed.connect', classes)
        self.assertIn('layout.add_child(scroll)', classes)
        self.assertIn('layout.add_child(apply)', classes)
        self.assertIn('layout.add_child(close)', classes)
        self.assertIn('scroll.add_child(v)', classes)

    def test_skill_menu_fixed_header_and_footer(self):
        skills = self.read_script("skill_menu.gd")
        self.assertIn('header_close.pressed.connect', skills)
        self.assertIn('layout.add_child(scroll)', skills)
        self.assertIn('layout.add_child(apply)', skills)
        self.assertIn('layout.add_child(close)', skills)
        self.assertIn('scroll.add_child(stack)', skills)

    def test_menus_preserve_actions(self):
        classes = self.read_script("class_menu.gd")
        skills = self.read_script("skill_menu.gd")
        talents = self.read_script("talent_menu.gd")
        self.assertIn('team_formation.set_role', classes)
        self.assertIn('ScrollContainer.new()', classes)
        self.assertIn('skill_loadouts', skills)
        self.assertIn('SKIN.style_menu_tree(margin)', skills)
        self.assertIn('SKIN.style_menu_tree(margin)', talents)
        self.assertIn('_invest.bind(tree, amount)', talents)

    def test_four_selectable_hardening_slots(self):
        ui = self.read_script("ui_manager.gd")
        self.assertIn('hardening_slot_grid.columns = 4', ui)
        self.assertIn('for field_index in range(4):', ui)
        self.assertIn('_choose_hardening_field.bind(field_index)', ui)
        self.assertIn('func _choose_hardening_field(field_index: int)', ui)
        self.assertIn('field_index == hardening_field', ui)

    def test_hardening_slot_caption_uses_escaped_newline(self):
        ui = self.read_script("ui_manager.gd")
        self.assertIn('slot_button.text = "◆ %d\\nLv %d"', ui)
        self.assertNotIn('slot_button.text = "◆ %d\nLv %d"', ui)

    def test_equipment_sections(self):
        ui = self.read_script("ui_manager.gd")
        for heading in ("HELD & WAFFE", "BEUTE & AUSRÜSTUNG", "AUSRÜSTUNGSHÄRTUNG"):
            self.assertIn(heading, ui)
        self.assertIn('action_scroll.vertical_scroll_mode', ui)


if __name__ == "__main__":
    unittest.main()
