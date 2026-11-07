"""Structural and deterministic combat-timing regression checks."""
import unittest
from tools.combat_simulator import (
    ALLOWED_ROLES, BOSS_LIMIT, CLASS_NAMES, Hero, INTERVALS,
    simulate_boss, standard_team,
)


class CombatSimulatorTests(unittest.TestCase):
    def test_twelve_classes_including_death_knight(self):
        self.assertEqual(len(CLASS_NAMES), 12)
        self.assertEqual(CLASS_NAMES[11], "Todesritter")
        self.assertIn(0, ALLOWED_ROLES[11])

    def test_source_timing(self):
        self.assertEqual(BOSS_LIMIT, 60.0)
        self.assertEqual(INTERVALS, (1.25, 0.75, 1.5))

    def test_small_boss_won(self):
        result = simulate_boss(standard_team(), 100)
        self.assertTrue(result["won"])
        self.assertLessEqual(result["time"], BOSS_LIMIT)

    def test_large_boss_times_out(self):
        result = simulate_boss(standard_team(), 5000)
        self.assertFalse(result["won"])
        self.assertEqual(result["time"], BOSS_LIMIT)

    def test_rejects_multiple_tanks(self):
        heroes = (Hero(0, 0, 10), Hero(11, 0, 10), Hero(6, 1, 10), Hero(9, 2, 10))
        with self.assertRaises(ValueError):
            simulate_boss(heroes, 100)

    def test_rejects_illegal_role(self):
        heroes = (Hero(0, 0, 10), Hero(4, 2, 10), Hero(6, 1, 10), Hero(9, 2, 10))
        with self.assertRaises(ValueError):
            simulate_boss(heroes, 100)

    def test_deterministic(self):
        self.assertEqual(simulate_boss(standard_team(), 1000),
                         simulate_boss(standard_team(), 1000))


if __name__ == "__main__":
    unittest.main()
