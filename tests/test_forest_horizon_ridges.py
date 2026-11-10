"""Static regression tests for original, cheap, cosmetic forest horizon geometry."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
RIDGE = (ROOT / "scripts/forest_horizon_ridges.gd").read_text(encoding="utf-8")
BIOME = (ROOT / "scripts/biome_manager.gd").read_text(encoding="utf-8")


class ForestHorizonTests(unittest.TestCase):
    def test_nature_only_wiring(self):
        self.assertIn('preload("res://scripts/forest_horizon_ridges.gd").create(terrain)', BIOME)
        self.assertIn("if current_biome == 3:", BIOME)

    def test_combined_mesh_and_reproducibility(self):
        for marker in ("SurfaceTool.new()", "Mesh.PRIMITIVE_TRIANGLES",
                       "surface.generate_normals()", "rng.seed = 20261110",
                       'ridge.name = "ForestHorizonRidges"',
                       "material.vertex_color_use_as_albedo = true"):
            self.assertIn(marker, RIDGE)
        self.assertIn("var segments: int = 32", RIDGE)
        self.assertIn("for side in [-1.0, 1.0]:", RIDGE)

    def test_visual_only_and_road_clearance(self):
        for forbidden in ("CollisionShape3D", "StaticBody3D", "CharacterBody3D", "load(\"res://assets/"):
            self.assertNotIn(forbidden, RIDGE)
        self.assertIn("Vector3(side * 11.8, -0.1, z)", RIDGE)


if __name__ == "__main__":
    unittest.main()
