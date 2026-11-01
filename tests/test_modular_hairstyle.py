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

    def test_equipment_bridge_preserves_existing_slots(self):
        script = (ROOT / "scripts/equipment/hero_equipment_sockets.gd").read_text(encoding="utf-8")
        for method in ("func equip_weapon(", "func equip_armor_slot(", "func unequip(", "func equip_hairstyle("):
            self.assertIn(method, script)
        self.assertIn('var socket := _socket("HeadSocket")', script)
        self.assertIn('equipped_nodes["hair"] = visual', script)

if __name__ == "__main__":
    unittest.main()
