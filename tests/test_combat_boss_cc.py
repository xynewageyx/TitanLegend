import unittest
from tools.combat_boss_cc import SOURCE, boss_cast, interrupt_cast, source_method


class BossCCTests(unittest.TestCase):
    def test_guardian_every_third_cast_interruptible(self):
        self.assertEqual([boss_cast(0, i)["required"] for i in range(1, 7)],
                         [0, 0, 1, 0, 0, 1])

    def test_stormcaller_fusion_requires_three_hits(self):
        self.assertEqual(boss_cast(1, 1)["required"], 2)
        self.assertEqual(boss_cast(1, 1, True)["required"], 3)
        self.assertEqual(boss_cast(1, 1, True)["window_ticks"], 7)

    def test_rune_keeper_heal_interruptible(self):
        self.assertEqual(boss_cast(2, 1)["kind"], "self_heal")
        self.assertEqual(boss_cast(2, 1)["required"], 1)
        self.assertEqual(boss_cast(2, 2)["required"], 0)

    def test_ancient_titan_aoe_fusion(self):
        self.assertEqual(boss_cast(3, 2, True)["required"], 2)

    def test_non_interruptible_cast(self):
        self.assertFalse(interrupt_cast(boss_cast(0, 1), 10)["interrupted"])

    def test_multiple_cc_hits_required(self):
        cast = boss_cast(1, 1, True)
        self.assertFalse(interrupt_cast(cast, 2)["interrupted"])
        self.assertTrue(interrupt_cast(cast, 3, 20)["interrupted"])
        self.assertEqual(interrupt_cast(cast, 3, 20)["vulnerable_until"], 24)

    def test_source_rules_remain_aligned(self):
        begin = source_method("_begin_boss_cast")
        apply = source_method("_apply_boss_cc_hit")
        for expected in ("boss_cast_index % 3 == 0", "3 if is_fusion_boss else 2",
                         "boss_cast_index % 2 == 0",
                         "3 + maxi(0, boss_cc_required - 1) * 2"):
            self.assertIn(expected, begin)
        self.assertIn("boss_cc_progress += 1", apply)
        self.assertIn("boss_cc_progress >= boss_cc_required", apply)
        self.assertIn("skill_tick + INTERRUPT_VULNERABILITY_TICKS", apply)
        self.assertIn("const INTERRUPT_VULNERABILITY_TICKS: int = 4", SOURCE)


if __name__ == "__main__":
    unittest.main()
