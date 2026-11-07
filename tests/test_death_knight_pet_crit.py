import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BALANCE = (ROOT / "scripts/titan_combat_balance.gd").read_text(encoding="utf-8")
FORMATION = (ROOT / "scripts/team_formation.gd").read_text(encoding="utf-8")


class DeathKnightPetCritTests(unittest.TestCase):
    def test_death_knight_is_damage_dealer(self):
        self.assertIn('"Todesritter"', FORMATION)
        self.assertIn('const MELEE_CLASSES := [0, 1, 5, 10, 11]', FORMATION)

    def test_death_knight_receives_pet_crit_bonus(self):
        self.assertIn("if class_id in [4, 5, 6, 7, 8, 10, 11]:", BALANCE)
        self.assertIn("crit += 0.015", BALANCE)

    def test_pet_crit_cap_remains(self):
        self.assertIn('"crit":minf(crit, 0.05)', BALANCE)


if __name__ == "__main__":
    unittest.main()
