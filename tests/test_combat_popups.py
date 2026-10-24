"""Static checks for hero-specific combat number rendering.

A Godot runtime run is still required to validate actual rendering.
"""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
BATTLE = ROOT / "scripts" / "battle_manager.gd"
FLOATING = ROOT / "scripts" / "floating_text.gd"


class CombatPopupTests(unittest.TestCase):
    def test_combat_popups_use_real_visual_script(self):
        text = BATTLE.read_text(encoding="utf-8")
        start = text.index("func _show_hero_combat_number(")
        end = text.index("\nfunc ", start + 5)
        method = text[start:end]
        self.assertIn('preload("res://scripts/floating_text.gd")', method)
        self.assertIn('popup.set("damage_amount", value)', method)
        self.assertIn('popup.set("heal", is_heal)', method)
        self.assertIn("hero.add_child(popup)", method)

    def test_popup_counts_are_slot_local_and_capped(self):
        text = BATTLE.read_text(encoding="utf-8")
        start = text.index("func _show_hero_combat_number(")
        end = text.index("\nfunc ", start + 5)
        method = text[start:end]
        self.assertIn("team_formation.heroes[slot]", method)
        self.assertIn("hero.get_children()", method)
        self.assertIn("active_labels.size() >= 3", method)
        self.assertIn("active_labels[0].queue_free()", method)

    def test_float_script_supports_damage_and_healing(self):
        text = FLOATING.read_text(encoding="utf-8")
        self.assertIn("extends Label3D", text)
        self.assertIn("var damage_amount: int", text)
        self.assertIn("var heal: bool", text)


if __name__ == "__main__":
    unittest.main()
