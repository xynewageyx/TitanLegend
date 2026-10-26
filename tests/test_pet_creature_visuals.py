"""Regression checks for passive elemental creature visual replacements."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
PETS = (ROOT / "scripts/pet_creature_visuals.gd").read_text(encoding="utf-8")
TEAM = (ROOT / "scripts/team_formation.gd").read_text(encoding="utf-8")


class PetCreatureVisualTests(unittest.TestCase):
    def test_new_creature_shapes_are_used(self):
        self.assertIn('preload("res://scripts/pet_creature_visuals.gd").decorate(pet, pet_element_ids[i], pet_species_ids[i])', TEAM)
        for marker in ("muzzle", "foot", "horn", "tail", "crest"):
            self.assertIn(marker, PETS)

    def test_ten_distinct_animal_profiles(self):
        self.assertIn("match clampi(species, 0, 9):", PETS)
        self.assertIn("var pet_species_ids: Array[int]", TEAM)
        self.assertIn("func set_pet_species(slot: int, species: int)", TEAM)
        self.assertIn("user://pet_species.json", TEAM)
        self.assertIn("clampi(species, 0, 9)", TEAM)
        self.assertIn("clampi(int(data[i]), 0, 9)", TEAM)
        for marker in ("fox_tail", "shell", "antler", "beak", "spine", "wolf_tail", "golem_chest", "lynx_tail", "phoenix_wing", "serpent_body"):
            self.assertIn(marker, PETS)

    def test_ten_elements_and_passive_only(self):
        self.assertIn("clampi(element, 0, 9)", PETS)
        self.assertGreaterEqual(PETS.count('Color("#'), 10 + 2)
        self.assertNotIn("play_attack(", PETS)
        self.assertNotIn("create_timer(", PETS)


if __name__ == "__main__":
    unittest.main()
