import ast
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FILES = ["tools/generate_chibi.py", "tools/validate_chibi_glb.py", "tools/check_chibi_import.py", "tools/render_chibi_previews.py"]
EXPECTED = "warrior paladin druid shaman hunter rogue mage warlock summoner priest brawler death_knight".split()


class ChibiPipelineTwelveClassesTests(unittest.TestCase):
    def test_all_pipeline_stages_cover_twelve_classes(self):
        for path in FILES:
            with self.subTest(path=path):
                text = (ROOT / path).read_text(encoding="utf-8")
                self.assertIn(" ".join(EXPECTED), text)

    def test_generator_has_twelve_colors(self):
        text = (ROOT / FILES[0]).read_text(encoding="utf-8")
        match = re.search(r"^COLORS=(\[[^\n]+\])", text, re.MULTILINE)
        self.assertIsNotNone(match)
        self.assertEqual(len(ast.literal_eval(match.group(1))), 12)

    def test_death_knight_has_unique_visual_details(self):
        text = (ROOT / FILES[0]).read_text(encoding="utf-8")
        self.assertIn('elif name=="death_knight":', text)
        self.assertIn('"ChestRune"', text)
        self.assertIn('"RuneHorn"', text)


if __name__ == "__main__":
    unittest.main()
