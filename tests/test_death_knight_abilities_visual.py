import ast
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VISUAL = (ROOT / "scripts/chibi_glb_visual.gd").read_text(encoding="utf-8")
ABILITIES = (ROOT / "scripts/talent_abilities.gd").read_text(encoding="utf-8")


class DeathKnightAbilityVisualTests(unittest.TestCase):
    def test_visual_has_twelve_names(self):
        match = re.search(r"const NAMES := (\[[^\n]+\])", VISUAL)
        self.assertIsNotNone(match)
        names = ast.literal_eval(match.group(1))
        self.assertEqual(len(names), 12)
        self.assertEqual(names[11], "death_knight")

    def test_abilities_have_twelve_trees(self):
        start = ABILITIES.index("const ABILITY_NAMES :=")
        end = ABILITIES.index("static func ability_name", start)
        section = ABILITIES[start:end]
        rows = re.findall(r'^ \["[^\n]+"\],?$', section, flags=re.MULTILINE)
        self.assertEqual(len(rows), 12)
        self.assertIn('["Runenschlag", "Knochenschild", "Seelenentzug"]', section)

    def test_death_knight_index_and_damage_bonus(self):
        self.assertIn("clampi(class_id, 0, 11)", ABILITIES)
        self.assertIn("if class_id in [4, 5, 6, 7, 10, 11]", ABILITIES)


if __name__ == "__main__":
    unittest.main()
