"""Check the organic trail mesh remains cosmetic and forest-scoped."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
TRAIL = (ROOT / "scripts/organic_forest_trail.gd").read_text(encoding="utf-8")
BIOME = (ROOT / "scripts/biome_manager.gd").read_text(encoding="utf-8")


class OrganicForestTrailTests(unittest.TestCase):
    def test_forest_wiring(self):
        self.assertIn('preload("res://scripts/organic_forest_trail.gd").create(terrain)', BIOME)
        self.assertIn('trail.name = "OrganicForestTrail"', TRAIL)

    def test_vertex_colored_mesh(self):
        for marker in ("SurfaceTool.new()", "Mesh.PRIMITIVE_TRIANGLES", "surface.generate_normals()", "material.vertex_color_use_as_albedo = true"):
            self.assertIn(marker, TRAIL)

    def test_visual_only(self):
        self.assertNotIn("CollisionShape3D", TRAIL)
        self.assertNotIn("CharacterBody3D", TRAIL)
        self.assertIn("rng.seed = 20261029", TRAIL)


if __name__ == "__main__":
    unittest.main()
