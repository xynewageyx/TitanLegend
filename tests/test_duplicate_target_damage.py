"""Regression guard for one hit and dodge roll per hero per enemy attack.

This checks the GDScript implementation structurally. Godot runtime checks
are still needed before treating the game as playable.
"""
from pathlib import Path
import re
import unittest

BATTLE = Path(__file__).resolve().parents[1] / "scripts" / "battle_manager.gd"


def method_source(name: str) -> str:
    source = BATTLE.read_text(encoding="utf-8")
    match = re.search(r"(?m)^func " + re.escape(name) + r"\(", source)
    if not match:
        raise AssertionError(f"Missing function {name}")
    next_method = re.search(r"(?m)^func ", source[match.end():])
    return source[match.start():match.end() + next_method.start()] if next_method else source[match.start():]


class DuplicateTargetHitTests(unittest.TestCase):
    def test_unique_hero_slots_before_damage_resolution(self):
        method = method_source("_damage_heroes")
        self.assertIn("var unique_targets: Array[int] = []", method)
        self.assertRegex(method, r"for target_slot in targets:\s+if target_slot >= 0 and target_slot < 4 and not unique_targets\.has\(target_slot\):\s+unique_targets\.append\(target_slot\)")
        self.assertIn("for index in unique_targets:", method)
        self.assertNotIn("for index in targets:", method)

    def test_one_dodge_roll_per_unique_target(self):
        method = method_source("_damage_heroes")
        self.assertLess(method.index("for index in unique_targets:"), method.index("if _hero_dodges(index):"))
        self.assertLess(method.index("if _hero_dodges(index):"), method.index("hero_hp[index] = maxi(0, previous - damage)"))

    def test_tank_preselection_not_per_hit(self):
        method = method_source("_damage_heroes")
        self.assertLess(method.index("var tank: int = _living_tank_slot()"), method.index("for index in unique_targets:"))


if __name__ == "__main__":
    unittest.main()
