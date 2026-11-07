"""Static guards for original modular armor geometry."""
from pathlib import Path
import re
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/equipment/chibi_armor_piece.gd"


class ArmorGeometryTests(unittest.TestCase):
    def test_all_slots_have_geometry(self):
        source = SCRIPT.read_text(encoding="utf-8")
        self.assertIn("MeshInstance3D.new()", source)
        self.assertIn("add_child(piece)", source)
        self.assertIn("material_override", source)
        self.assertIn("COLORS[rarity]", source)
        if "const SIZES :=" in source:
            match = re.search(r"const SIZES\s*:=\s*\[(.*?)\]", source, re.S)
            self.assertIsNotNone(match)
            self.assertEqual(len(re.findall(r"Vector3\s*\(", match.group(1))), 13)
            self.assertIn("SIZES[slot_index]", source)
            self.assertIn("SphereMesh.new()", source)
        else:
            for slot in ("0:", "1:", "2:", "3, 4:", "5, 6, 9, 10:", "7, 8:", "11, 12:"):
                self.assertIn(slot, source)
            self.assertIn("BoxMesh.new()", source)
            self.assertIn("SphereMesh.new()", source)


if __name__ == "__main__":
    unittest.main()
