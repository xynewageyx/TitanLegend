"""Deterministic resource-budget checks for Update 192.

Not a Godot runtime test. These figures assume all previous stages and nine
normal waves per stage were cleared and no gold was spent elsewhere.
"""
import math
import unittest


def earned_gold_before(stage):
    return 10_000 + sum(
        s * (9 * 50 + (500 if s % 10 == 0 else 250))
        for s in range(1, stage)
    )


def jewel_level_from_budget(gold_budget):
    # Upgrading from jewel level L to L+1 costs 250*L.
    level = max(1, (1 + math.isqrt(1 + 8 * gold_budget // 250)) // 2)
    while 250 * level * (level - 1) // 2 > gold_budget:
        level -= 1
    while 250 * (level + 1) * level // 2 <= gold_budget:
        level += 1
    return level


def equal_tree_rank_at_stage(stage):
    # One character level from each completed stage boss and 3 points/level.
    return min(500, max(0, stage - 1))


class ProgressionBudgetTests(unittest.TestCase):
    def test_stage_reward_budget(self):
        cases = {
            101: 3_682_500,
            401: 58_200_000,
            801: 232_390_000,
            1001: 362_985_000,
            1200: 521_440_000,
        }
        for stage, expected in cases.items():
            with self.subTest(stage=stage):
                self.assertEqual(earned_gold_before(stage), expected)

    def test_equal_talent_distribution(self):
        self.assertEqual(equal_tree_rank_at_stage(101), 100)
        self.assertEqual(equal_tree_rank_at_stage(401), 400)
        self.assertEqual(equal_tree_rank_at_stage(801), 500)
        self.assertEqual(equal_tree_rank_at_stage(1200), 500)

    def test_jewel_spending_is_quadratic(self):
        for level in (1, 10, 100, 500, 1000):
            spent = 250 * level * (level - 1) // 2
            self.assertEqual(jewel_level_from_budget(spent), level)
            self.assertLess(250 * level * (level - 1) // 2, spent + 1)


if __name__ == "__main__":
    unittest.main()
