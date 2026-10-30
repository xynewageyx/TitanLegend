"""Ensure the asset design generator never drops or reorders gameplay classes."""
import importlib.util
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
SOURCE = (ROOT / "scripts" / "team_formation.gd").read_text(encoding="utf-8")
MODULE_PATH = ROOT / "tools" / "asset_pipeline" / "character_creator.py"
spec = importlib.util.spec_from_file_location("character_creator", MODULE_PATH)
creator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(creator)


class CharacterCreatorConsistencyTests(unittest.TestCase):
    def test_all_gameplay_classes_in_correct_order(self):
        match = re.search(r"(?m)^const CLASS_NAMES := \[(.*?)\]", SOURCE)
        self.assertIsNotNone(match)
        names = re.findall(r'"([^"]+)"', match.group(1))
        heroes = creator.build_heroes()
        self.assertEqual([hero["game_name"] for hero in heroes], names)
        self.assertEqual([hero["class_id"] for hero in heroes], list(range(len(names))))

    def test_specs_not_mistaken_for_models(self):
        for hero in creator.build_heroes():
            self.assertEqual(hero["asset_status"], "design_spec_only")
            self.assertEqual(len(hero["reference_views"]), 3)
            self.assertEqual(len(hero["animations"]), 6)


if __name__ == "__main__":
    unittest.main()
