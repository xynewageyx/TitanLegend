"""Static regression checks for the optional Ulala-inspired fantasy UI.

Run: python -m unittest tests/test_fantasy_ui_regression.py
These checks do not replace a Godot import or Android build.
"""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class FantasyUIRegression(unittest.TestCase):
    def read_script(self, name):
        return (ROOT / "scripts" / name).read_text(encoding="utf-8")

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

    def test_equipment_sections(self):
        ui = self.read_script("ui_manager.gd")
        for heading in ("HELD & WAFFE", "BEUTE & AUSRÜSTUNG", "AUSRÜSTUNGSHÄRTUNG"):
            self.assertIn(heading, ui)
        self.assertIn('action_scroll.vertical_scroll_mode', ui)


if __name__ == "__main__":
    unittest.main()
