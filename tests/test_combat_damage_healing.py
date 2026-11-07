import unittest
from tools.combat_damage_healing import (
    SOURCE, boss_self_heal, critical_chance, heal_party, normal_hit, source_method,
)


class DamageHealingTests(unittest.TestCase):
    def test_normal_attack_level_scaling(self):
        self.assertEqual(normal_hit(1, 1), 41)
        self.assertEqual(normal_hit(10, 1), 95)

    def test_critical_damage_and_bonus(self):
        self.assertEqual(normal_hit(1, 1, critical=True), 66)
        self.assertEqual(normal_hit(1, 1, critical=True, crit_damage_bonus=0.4), 82)

    def test_critical_chance_cap(self):
        self.assertAlmostEqual(critical_chance(0), 0.10)
        self.assertAlmostEqual(critical_chance(0.5), 0.30)

    def test_single_heal_lowest_relative_hp(self):
        self.assertEqual(heal_party([100, 60, 200, 100], [200, 300, 200, 100], 50),
                         [100, 110, 200, 100])

    def test_group_heal_and_no_resurrection(self):
        self.assertEqual(heal_party([0, 100, 190, 200], [200]*4, 80, group=True),
                         [0, 120, 200, 200])

    def test_boss_self_heal_capped(self):
        self.assertEqual(boss_self_heal(900, 1000), 950)
        self.assertEqual(boss_self_heal(980, 1000), 1000)

    def test_source_formulas_guarded(self):
        attack = source_method("_hero_attack")
        heal = source_method("_heal_heroes")
        cast = source_method("_resolve_boss_cast")
        for fragment in ("35 + current_level * 6", "TitanSkillSystem.damage_multiplier(role)",
                         "minf(0.30, 0.10 +", "1.6 + GameManager.hardening_bonus(slot, 3)"):
            self.assertIn(fragment, attack)
        for fragment in ("roundi(float(amount) / 4.0)", "hero_hp[i] > 0",
                         "float(hero_hp[i]) / float(maxi(1, hero_max_hp[i]))"):
            self.assertIn(fragment, heal)
        self.assertIn("float(enemy_max_hp) * 0.05", cast)


if __name__ == "__main__":
    unittest.main()
