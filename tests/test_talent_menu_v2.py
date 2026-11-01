"""Regression checks for the optional mobile talent editor.

These are source-level guards; Godot runtime rendering still requires an Android build.
"""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
TREE = (ROOT / "scripts/talent_tree_v2.gd").read_text(encoding="utf-8")
TEAM = (ROOT / "scripts/team_formation.gd").read_text(encoding="utf-8")
MENU = (ROOT / "scripts/talent_menu_v2.gd").read_text(encoding="utf-8")
SAVE = (ROOT / "scripts/save_manager.gd").read_text(encoding="utf-8")
BATTLE = (ROOT / "scripts/battle_manager.gd").read_text(encoding="utf-8")


class TalentMenuV2IntegrationTests(unittest.TestCase):
    def test_tree_has_budget_and_prerequisite_validation(self):
        for token in ("TALENTS_PER_BRANCH: int = 15", "MAX_RANK: int = 5",
                      "available_points(level, build) <= 0", "earlier >= row * 5",
                      "static func validate_build("):
            with self.subTest(token=token):
                self.assertIn(token, TREE)

    def test_team_owns_purchases_and_persists(self):
        start = TEAM.index("func upgrade_talent_v2(")
        end = TEAM.index("\nfunc ", start + 5)
        section = TEAM[start:end]
        self.assertIn("TALENT_TREES_V2.upgrade(", section)
        self.assertIn("set_talent_build_v2(", section)
        self.assertIn("SaveManager.save_game()", section)
        self.assertIn("TALENT_MENU_V2.new()", TEAM)

    def test_menu_uses_atomic_purchase_not_direct_mutation(self):
        start = MENU.index("func _upgrade(")
        section = MENU[start:]
        self.assertIn("team.upgrade_talent_v2(", section)
        self.assertNotIn("TREES.upgrade(", section)
        self.assertIn("ScrollContainer.new()", MENU)
        self.assertIn("panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)", MENU)

    def test_close_button_stays_outside_scroll_area(self):
        header = MENU.index("var header := HBoxContainer.new()")
        close = MENU.index('close_button.text = "Schliessen"')
        scroll = MENU.index("var scroll := ScrollContainer.new()")
        grid = MENU.index("talent_grid = GridContainer.new()")
        self.assertLess(header, close)
        self.assertLess(close, scroll)
        self.assertLess(scroll, grid)
        self.assertIn("scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO", MENU)
        self.assertIn("scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED", MENU)

    def test_portrait_talent_grid_has_touch_sized_buttons(self):
        self.assertIn("talent_grid.columns = 2", MENU)
        self.assertIn("button.custom_minimum_size = Vector2(112, 64)", MENU)
        self.assertNotIn("talent_grid.columns = 3", MENU)

    def test_hero_class_labels_guard_class_indices(self):
        self.assertIn("class_index >= 0 and class_index < team.CLASS_NAMES.size()", MENU)
        self.assertIn("hero_picker.set_item_text(", MENU)

    def test_invalid_talent_ranks_are_rejected(self):
        self.assertIn("if current_rank < 0 or current_rank >= MAX_RANK:", TREE)
        self.assertIn("if available_points(level, build) <= 0:", TREE)

    def test_android_talent_navigation_remains_touch_friendly(self):
        self.assertIn("scroll.follow_focus = true", MENU)
        self.assertIn("hero_picker.custom_minimum_size = Vector2(0, 52)", MENU)
        self.assertIn("branch_picker.custom_minimum_size = Vector2(0, 52)", MENU)
        self.assertIn("button.size_flags_horizontal = Control.SIZE_EXPAND_FILL", MENU)
        self.assertIn("points_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART", MENU)

    def test_save_and_combat_connections_exist(self):
        self.assertIn('"talent_builds_v2"', SAVE)
        self.assertIn("get_saved_talent_builds_v2()", TEAM)
        self.assertIn("TALENT_COMBAT_V2.bonuses(", BATTLE)


if __name__ == "__main__":
    unittest.main()
