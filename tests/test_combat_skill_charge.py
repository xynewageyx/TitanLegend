import unittest
from tools.combat_skill_charge import SOURCE, method, skill_hit_cost, charge_sequence


class SkillChargeTests(unittest.TestCase):
    def test_costs_match_godot_source(self):
        body = method("_skill_hit_cost")
        for line in ("if role == 0 and choice == 8:", "return 3 # Spott",
                     "if role == 0 and choice == 9:", "return 5 # Gruppenschaden abfangen",
                     "7: return 4 # Unterbrechung", "5: return 5 # Bossbrecher",
                     "return MAX_SKILL_HITS"):
            self.assertIn(line, body)
        for choice, cost in {0: 2, 1: 3, 2: 4, 3: 2, 4: 4, 5: 5, 6: 3, 7: 4}.items():
            self.assertEqual(skill_hit_cost(1, choice), cost)

    def test_four_slots_cast_in_strict_order(self):
        self.assertEqual(charge_sequence(1, [0, 1, 2, 7], 13),
                         [(2, 0, 0), (5, 1, 1), (9, 2, 2), (13, 3, 7)])

    def test_order_restarts_after_fourth_slot(self):
        self.assertEqual(charge_sequence(1, [0, 0, 0, 0], 10),
                         [(2, 0, 0), (4, 1, 0), (6, 2, 0), (8, 3, 0), (10, 0, 0)])

    def test_tank_special_costs(self):
        self.assertEqual(skill_hit_cost(0, 8), 3)
        self.assertEqual(skill_hit_cost(0, 9), 5)

    def test_healer_hot_cost(self):
        self.assertEqual(skill_hit_cost(2, 8), 4)

    def test_invalid_loadout_rejected(self):
        with self.assertRaises(ValueError):
            charge_sequence(1, [9, 0, 0, 0], 20)

    def test_real_godot_uses_hit_charge_and_reset(self):
        attack = method("_hero_attack")
        cast = method("_try_cast_charged_skill")
        self.assertIn("skill_hit_charge[slot] + 1", attack)
        self.assertIn("_try_cast_charged_skill(slot, role)", attack)
        self.assertIn("skill_hit_charge[slot] = 0", cast)
        self.assertIn("next_skill_slot[slot] = (index + 1) % loadout.size()", cast)
        self.assertIn("_execute_equipped_skill(slot, role, choice)", cast)


if __name__ == "__main__":
    unittest.main()
