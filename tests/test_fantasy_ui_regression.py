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
        original = (ROOT / 'original_update168/scripts/boss_motion.gd').read_bytes()
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

    def test_equipment_sections(self):
        ui = self.read_script("ui_manager.gd")
        for heading in ("HELD & WAFFE", "BEUTE & AUSRÜSTUNG", "AUSRÜSTUNGSHÄRTUNG"):
            self.assertIn(heading, ui)
        self.assertIn('action_scroll.vertical_scroll_mode', ui)


if __name__ == "__main__":
    unittest.main()
