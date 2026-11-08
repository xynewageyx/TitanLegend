"""Static regression checks for equipment UI and visual bridge (Godot runtime tested separately)."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


def script(path):
    return (ROOT / path).read_text(encoding="utf-8")


class EquipmentUiIntegrationTests(unittest.TestCase):
    def test_inventory_filter_only_cycles_matching_slots(self):
        ui = script("scripts/ui_manager.gd")
        self.assertIn("func _matching_loot_indices() -> Array[int]:", ui)
        self.assertIn('int(GameManager.equipment_inventory[index].get("slot", -1)) == loot_selected_slot', ui)
        self.assertIn("var matches := _matching_loot_indices()", ui)
        self.assertIn("loot_selected_index = matches[(current + 1) % matches.size()]", ui)
        self.assertIn("if not matches.has(loot_selected_index):", ui)

    def test_thirteen_touch_tiles_and_empty_filter_guard(self):
        ui = script("scripts/ui_manager.gd")
        self.assertIn("for slot_index in range(GameManager.LOOT_SLOTS.size()):", ui)
        self.assertIn("slot_button.pressed.connect(_select_loot_slot.bind(slot_index))", ui)
        self.assertIn("if filtered_loot.is_empty():", ui)
        self.assertIn("loot_equip_button.disabled = true", ui)

    def test_visual_bridge_preserves_slot_mapping(self):
        bridge = script("scripts/equipment/equipment_inventory_visual_bridge.gd")
        manager = script("scripts/game_manager.gd")
        self.assertEqual(bridge.split("const ARMOR_SLOTS := [", 1)[1].split("]", 1)[0].count("Socket"), 13)
        self.assertIn('controller.call("unequip", anchor)', bridge)
        self.assertIn('controller.call("equip_armor_slot", anchor,', bridge)
        self.assertIn('const MAX_LOOT_ITEMS: int = 120', manager)

    def test_death_knight_class_equipment_visual_mapping(self):
        import re
        bridge = script("scripts/equipment/equipment_inventory_visual_bridge.gd")
        adapter = script("scripts/equipment/formation_equipment_adapter.gd")
        match = re.search(r"const CLASS_WEAPONS := \[([^\]]+)\]", adapter)
        self.assertIsNotNone(match, "Expected a weapon mapping for all classes")
        weapons = [int(value.strip()) for value in match.group(1).split(",")]
        self.assertEqual(len(weapons), 12, "Visual weapon mapping must include the Death Knight")
        self.assertEqual(weapons[11], 1, "Death Knight must use the greatsword preview")
        self.assertIn('controller.call("equip_weapon", ADAPTER.weapon_type_for_class(class_id)', bridge)
        self.assertIn('clampi(class_id,0,11)', bridge)
        inspection = script("scripts/equipment/modular_equipment_inspection.gd")
        self.assertIn("@export_range(0, 11) var hero_class", inspection)

    def test_archived_boss_motion_is_original(self):
        import hashlib
        archived = (ROOT / "original_update168/scripts/boss_motion.gd").read_bytes()
        self.assertEqual(hashlib.sha256(archived).hexdigest(),
                         "54d8d22371d590d21542b779891191d122815e1233088a0014b114cd3616ddb1")


if __name__ == "__main__":
    unittest.main()
