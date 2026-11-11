"""Prevent missing chibi hero palettes from breaking Blender's 12-class export.

This test reads generator source via AST without importing Blender (bpy).
"""
import ast
from pathlib import Path
import unittest

GENERATOR = Path(__file__).resolve().parents[1] / "tools" / "generate_chibi.py"


class ChibiPaletteTests(unittest.TestCase):
    def test_all_classes_have_hair_and_iris_colors(self):
        tree = ast.parse(GENERATOR.read_text(encoding="utf-8"))
        names = colors = iris = None
        for node in ast.walk(tree):
            if isinstance(node, ast.Assign):
                for target in node.targets:
                    if not isinstance(target, ast.Name):
                        continue
                    if target.id == "NAMES":
                        value = node.value
                        if isinstance(value, ast.Call) and isinstance(value.func, ast.Attribute) and value.func.attr == "split":
                            names = ast.literal_eval(value.func.value).split()
                    elif target.id == "COLORS":
                        colors = ast.literal_eval(node.value)
                    elif target.id == "iris_colors":
                        iris = ast.literal_eval(node.value)
        self.assertIsNotNone(names)
        self.assertEqual(len(names), 12)
        self.assertEqual(len(set(names)), len(names))
        self.assertEqual(len(colors), len(names), "Each hero needs a hair color")
        self.assertEqual(len(iris), len(names), "Each hero needs an iris color")
        for palette in (colors, iris):
            for rgb in palette:
                self.assertEqual(len(rgb), 3)
                self.assertTrue(all(isinstance(c, (float, int)) and 0 <= c <= 1 for c in rgb))


if __name__ == "__main__":
    unittest.main()
