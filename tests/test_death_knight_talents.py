import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TALENTS = (ROOT / "scripts/talent_system.gd").read_text(encoding="utf-8")
BALANCE = (ROOT / "scripts/titan_combat_balance.gd").read_text(encoding="utf-8")
FORMATION = (ROOT / "scripts/team_formation.gd").read_text(encoding="utf-8")


class DeathKnightTalentTests(unittest.TestCase):
    def test_twelve_class_talent_arrays(self):
        for key in ("OFFENSE", "DEFENSE", "SUPPORT"):
            values = re.search(r"const " + key + r"\s*:=\s*\[([^]]+)\]", TALENTS)
            self.assertIsNotNone(values)
            self.assertEqual(len(values.group(1).split(",")), 12, key)
            self.assertTrue(all(re.fullmatch(r"\s*0\.\d+\s*", value) for value in values.group(1).split(",")), key)

    def test_death_knight_talent_tree(self):
        self.assertIn('["Runenklinge", "Knochenpanzer", "Seelenmacht"]', TALENTS)
        self.assertIn('"Todesritter"', FORMATION)

    def test_class_index_twelve_supported(self):
        self.assertNotIn("clampi(class_id, 0, 10)", TALENTS)
        self.assertNotIn("clampi(class_id, 0, 10)", BALANCE)
        self.assertIn("clampi(class_id, 0, 11)", BALANCE)
        self.assertIn("clampi(int(class_ids[slot]), 0, 11)", TALENTS)


if __name__ == "__main__":
    unittest.main()
