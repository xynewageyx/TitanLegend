"""Static guards for original modular armor geometry."""
from pathlib import Path
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/equipment/chibi_armor_piece.gd"

class ArmorGeometryTests(unittest.TestCase):
    def test_all_slots_have_geometry(self):
        source = SCRIPT.read_text(encoding="utf-8")
        for slot in ("0:", "1:", "2:", "3, 4:", "5, 6, 9, 10:", "7, 8:", "11, 12:"):
            self.assertIn(slot, source)
        self.assertIn("BoxMesh.new()", source)
        self.assertIn("SphereMesh.new()", source)
        self.assertIn("COLORS[clampi(rarity", source)

if __name__ == "__main__":
    unittest.main()
