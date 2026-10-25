"""Structural regression checks for actual tank damage interception.

These tests are static; the Godot runtime workflow must verify combat behavior.
"""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
SOURCE = (ROOT / "scripts" / "battle_manager.gd").read_text(encoding="utf-8")


def body(name: str) -> str:
    found = re.search(r"(?m)^func " + re.escape(name) + r"\(", SOURCE)
    if not found:
        raise AssertionError(f"Missing {name}")
    following = re.search(r"(?m)^func ", SOURCE[found.end():])
    return SOURCE[found.start():found.end() + following.start()] if following else SOURCE[found.start():]


class TankInterceptionTransferTests(unittest.TestCase):
    def test_only_living_active_tank_intercepts(self):
        tank = body("_living_tank_slot")
        damage = body("_damage_heroes")
        self.assertIn("hero_hp[i] > 0", tank)
        self.assertIn("tank >= 0 and tank_intercept_until[tank] > skill_tick", damage)
        self.assertIn("var redirected_damage: int = 0", damage)

    def test_transfer_occurs_after_simultaneous_hero_hits(self):
        damage = body("_damage_heroes")
        self.assertIn("TitanTankInterceptionMath.prevented_hp_loss(previous, unprotected_damage, damage)", damage)
        self.assertLess(damage.index("var previous: int = hero_hp[index]"), damage.index("TitanTankInterceptionMath.prevented_hp_loss("))
        self.assertLess(damage.index("for index in unique_targets:"), damage.index("if redirected_damage > 0 and tank >= 0:"))
        self.assertIn("hero_hp[tank] = maxi(0, tank_before - redirected_damage)", damage)
        self.assertIn("_show_hero_combat_number(tank, tank_taken, false)", damage)

    def test_no_tank_resurrection(self):
        damage = body("_damage_heroes")
        self.assertIn("if tank_before > 0 and hero_hp[tank] == 0", damage)
        self.assertNotIn("hero_hp[tank] += ", damage)

    def test_visual_and_combat_end_at_same_tick(self):
        damage = body("_damage_heroes")
        visuals = body("_refresh_tank_defense_visuals")
        self.assertIn("tank_intercept_until[tank] > skill_tick", damage)
        self.assertIn("tank_intercept_until[slot] > skill_tick", visuals)

    def test_shield_visual_updates_after_damage_and_before_defeat_handling(self):
        damage = body("_damage_heroes")
        self.assertLess(
            damage.index("_sync_team_health()"),
            damage.index("_refresh_tank_defense_visuals()"),
        )
        self.assertLess(
            damage.index("_refresh_tank_defense_visuals()"),
            damage.index('if team_hp <= 0:'),
        )


if __name__ == "__main__":
    unittest.main()
