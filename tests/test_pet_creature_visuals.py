"""Regression checks for passive elemental creature visual replacements."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
PETS = (ROOT / "scripts/pet_creature_visuals.gd").read_text(encoding="utf-8")
TEAM = (ROOT / "scripts/team_formation.gd").read_text(encoding="utf-8")


class PetCreatureVisualTests(unittest.TestCase):
    def test_new_creature_shapes_are_used(self):
        self.assertIn('preload("res://scripts/pet_creature_visuals.gd").decorate(pet, pet_element_ids[i], i)', TEAM)
        for marker in ("muzzle", "foot", "horn", "tail", "crest"):
            self.assertIn(marker, PETS)

    def test_five_distinct_animal_profiles(self):
        self.assertIn("match posmod(element, 5):", PETS)
        for marker in ("fox_tail", "shell", "antler", "beak", "spine"):
            self.assertIn(marker, PETS)

    def test_ten_elements_and_passive_only(self):
        self.assertIn("clampi(element, 0, 9)", PETS)
        self.assertEqual(PETS.count('Color("#'), 10 + 3)
        self.assertNotIn("play_attack(", PETS)
        self.assertNotIn("create_timer(", PETS)


if __name__ == "__main__":
    unittest.main()
