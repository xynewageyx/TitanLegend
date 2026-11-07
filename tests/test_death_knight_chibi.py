import ast
import re
import unittest
from pathlib import Path

SOURCE = (Path(__file__).resolve().parents[1] / "scripts/team_formation.gd").read_text(encoding="utf-8")


class DeathKnightChibiTests(unittest.TestCase):
    def test_model_names_cover_all_twelve_classes(self):
        match = re.search(r'var chibi_path: String = .*?\+ (\[[^\n]+?\])\[class_ids\[i\]\]', SOURCE)
        self.assertIsNotNone(match)
        models = ast.literal_eval(match.group(1))
        classes = re.search(r'const CLASS_NAMES := (\[[^\n]+\])', SOURCE)
        self.assertIsNotNone(classes)
        names = ast.literal_eval(classes.group(1))
        self.assertEqual(len(models), len(names))
        self.assertEqual(models[11], "death_knight")
        self.assertEqual(names[11], "Todesritter")

    def test_missing_glb_keeps_fallback(self):
        self.assertIn("if ResourceLoader.exists(chibi_path):", SOURCE)


if __name__ == "__main__":
    unittest.main()
