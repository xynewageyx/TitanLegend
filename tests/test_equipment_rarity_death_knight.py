"""Regression guard for all twelve class armor previews and Death Knight runeblade.

Static source checks supplement, but do not replace, Godot runtime/visual tests.
"""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]


def source(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


class EquipmentRarityAndDeathKnightTests(unittest.TestCase):
    def test_all_twelve_classes_have_distinct_armor_branches(self):
        armor = source("scripts/equipment/chibi_armor_piece.gd")
        self.assertIn("@export_range(0,11) var class_id", armor)
        self.assertIn("func _add_class_silhouette()", armor)
        for class_id in range(12):
            with self.subTest(class_id=class_id):
                self.assertRegex(armor, rf"(?m)^\s*{class_id}:\s*#")
        self.assertIn("11: # Death Knight", armor)

    def test_six_rarities_and_class_safe_sockets(self):
        armor = source("scripts/equipment/chibi_armor_piece.gd")
        weapons = source("scripts/weapons/procedural_weapon_preview.gd")
        sockets = source("scripts/equipment/hero_equipment_sockets.gd")
        self.assertIn("@export_range(0,5) var rarity", armor)
        self.assertIn("@export_range(0, 5) var rarity", weapons)
        self.assertIn("clampi(hero_class, 0, 11)", sockets)
        self.assertIn("clampi(weapon_type, 0, 12)", sockets)
        self.assertIn("clampi(rarity, 0, 5)", sockets)

    def test_death_knight_weapon_exists_and_is_not_only_a_recolor(self):
        weapons = source("scripts/weapons/procedural_weapon_preview.gd")
        self.assertIn("@export_range(0, 12) var weapon_type", weapons)
        self.assertIn('"death_knight_runeblade"', weapons)
        self.assertIn("func _build_death_knight_runeblade(", weapons)
        self.assertIn("if weapon_type == 12:", weapons)
        self.assertIn("if rarity >= 3:", weapons)
        self.assertIn("if rarity >= 4:", weapons)
        self.assertIn("if rarity >= 5:", weapons)

    def test_armor_has_thirteen_attachment_slots(self):
        sockets = source("scripts/equipment/hero_equipment_sockets.gd")
        slots = sockets.split("const SLOT_NAMES := [", 1)[1].split("]", 1)[0]
        self.assertEqual(slots.count("Socket"), 13)
        self.assertIn('"RightHandSocket"', sockets)
        self.assertIn('"LeftHandSocket"', sockets)


if __name__ == "__main__":
    unittest.main()
