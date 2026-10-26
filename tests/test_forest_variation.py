"""Checks for deterministic roadside forest dressing."""
from pathlib import Path
import unittest

BIOME = (Path(__file__).resolve().parents[1] / "scripts/biome_manager.gd").read_text(encoding="utf-8")


class ForestVariationTests(unittest.TestCase):
    def test_forest_only(self):
        self.assertIn("if current_biome == 3:", BIOME)
        self.assertIn("  _add_forest_variation()", BIOME)

    def test_layered_conifers(self):
        self.assertIn("func _add_forest_pines() -> void:", BIOME)
        self.assertIn("  _add_forest_pines()", BIOME)
        self.assertIn("rng.seed = 20261027", BIOME)
        self.assertIn("crown.radial_segments = 7", BIOME)
        self.assertIn("rng.randf_range(8.0, 20.0)", BIOME)

    def test_deterministic_and_outside_path(self):
        self.assertIn("rng.seed = 20261026", BIOME)
        self.assertIn("rng.randf_range(5.2, 12.0)", BIOME)
        self.assertIn("func _add_forest_variation() -> void:", BIOME)
        self.assertIn('Color("#f0d37e")', BIOME)


if __name__ == "__main__":
    unittest.main()
