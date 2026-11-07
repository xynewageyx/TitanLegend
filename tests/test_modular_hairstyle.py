"""Static regression checks for the modular hairstyle integration."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]

class ModularHairTests(unittest.TestCase):
    def test_hair_script_exists(self):
        script = (ROOT / "scripts/equipment/procedural_hairstyle.gd").read_text(encoding="utf-8")
        self.assertIn("extends Node3D", script)
        self.assertIn("@export_range(0, 2) var style", script)
        self.assertIn("func _build()", script)

    def test_socket_script_has_valid_newlines_and_death_knight_support(self):
        script = (ROOT / "scripts/equipment/hero_equipment_sockets.gd").read_text(encoding="utf-8")
        self.assertNotIn(r"\\n", script)
        self.assertIn("clampi(hero_class, 0, 11)", script)
        self.assertIn("if found is Node3D:", script)
        self.assertIn("return found as Node3D", script)
        armor = (ROOT / "scripts/equipment/chibi_armor_piece.gd").read_text(encoding="utf-8")
        self.assertIn("@export_range(0,11) var class_id", armor)

    def test_equipment_bridge_preserves_existing_slots(self):
        script = (ROOT / "scripts/equipment/hero_equipment_sockets.gd").read_text(encoding="utf-8")
        for method in ("func equip_weapon(", "func equip_armor_slot(", "func unequip(", "func equip_hairstyle("):
            self.assertIn(method, script)
        self.assertIn('var socket := _socket("HeadSocket")', script)
        self.assertIn('equipped_nodes["hair"] = visual', script)

if __name__ == "__main__":
    unittest.main()
