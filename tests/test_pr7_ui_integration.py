"""PR #7 UI integration smoke tests for the current Titan Legends architecture.

The historical PR #7 tests describe a retired HUD implementation. These
checks intentionally verify current invariants without rewriting runtime UI.
Run: python -m unittest discover -s tests -p 'test_pr7_ui_integration.py'
"""
from pathlib import Path
import hashlib
import json
import unittest

ROOT = Path(__file__).resolve().parents[1]


def source(path):
    return (ROOT / path).read_text(encoding="utf-8")


class PR7UIIntegrationTests(unittest.TestCase):
    def test_update168_archive_matches_manifest(self):
        manifest = json.loads(source("docs/update_168_import_manifest.json"))
        expected = next(
            item for item in manifest["files"]
            if item["path"] == "scripts/boss_motion.gd"
        )
        original = (ROOT / "original_update168/scripts/boss_motion.gd").read_bytes()
        self.assertEqual(len(original), expected["bytes"])
        self.assertEqual(hashlib.sha256(original).hexdigest(), expected["sha256"])

    def test_optional_editor_plugin_is_present(self):
        self.assertIn('script="plugin.gd"', source("addons/titan_ui/plugin.cfg"))
        self.assertIn("extends EditorPlugin", source("addons/titan_ui/plugin.gd"))

    def test_four_party_slots(self):
        hud = source("scripts/adventure_hud_overlay.gd")
        self.assertIn("for i in range(4):", hud)
        self.assertIn('tile.name = "PartySlot" + str(i + 1)', hud)

    def test_boss_panel_is_named(self):
        ui = source("scripts/ui_manager.gd")
        self.assertIn('boss_panel.name = "BossHP"', ui)
        self.assertIn("boss_time_remaining", ui)

    def test_class_menu_preserves_role_selection(self):
        classes = source("scripts/class_menu.gd")
        self.assertIn("team_formation.set_class", classes)
        self.assertIn("team_formation.set_role", classes)

    def test_skill_and_talent_menus_remain_connected(self):
        self.assertIn("skill_loadouts", source("scripts/skill_menu.gd"))
        self.assertIn("_invest.bind", source("scripts/talent_menu.gd"))


if __name__ == "__main__":
    unittest.main()
