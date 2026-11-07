"""Static safety checks for the standalone PR #10 layered armor port."""
from pathlib import Path
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/equipment/chibi_armor_piece.gd"

class ArmorGeometryTests(unittest.TestCase):
    def test_all_thirteen_slots_have_original_layered_geometry(self):
        source = SCRIPT.read_text(encoding="utf-8")
        for slot in ("0:", "1:", "2:", "3, 4:", "5, 6, 9, 10:", "7, 8:", "11, 12:"):
            self.assertIn(slot, source)
        self.assertIn("BoxMesh.new()", source)
        self.assertIn("SphereMesh.new()", source)
        self.assertIn("CylinderMesh.new()", source)
        self.assertIn("COLORS[clampi(rarity", source)

    def test_final_rarity_adds_silhouette_details(self):
        source = SCRIPT.read_text(encoding="utf-8")
        for token in ("if rarity >= 3:", "if rarity >= 4:", "if rarity >= 5",
                      "_spike(", "emission_enabled = true", "base_size.x * 0.50"):
            self.assertIn(token, source)
        self.assertIn("@export_range(0,11) var class_id", source)

    def test_mesh_count_stays_bounded_per_piece(self):
        source = SCRIPT.read_text(encoding="utf-8")
        self.assertNotIn("for rarity in", source)
        self.assertNotIn("for slot_index in", source)

if __name__ == "__main__":
    unittest.main()
