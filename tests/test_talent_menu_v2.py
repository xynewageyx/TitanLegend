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

    def test_save_and_combat_connections_exist(self):
        self.assertIn('"talent_builds_v2"', SAVE)
        self.assertIn("get_saved_talent_builds_v2()", TEAM)
        self.assertIn("TALENT_COMBAT_V2.bonuses(", BATTLE)


if __name__ == "__main__":
    unittest.main()
