"""Static checks for distant landscape coverage and Android-safe forest depth.

These tests check source wiring; verify visuals separately on Android.
"""
from pathlib import Path
import re
import unittest

SOURCE = (Path(__file__).resolve().parents[1] / "scripts" / "biome_manager.gd").read_text(encoding="utf-8")


def method(name: str) -> str:
    found = re.search(r"(?m)^func " + re.escape(name) + r"\(", SOURCE)
    if found is None:
        raise AssertionError(f"Missing method {name}")
    following = re.search(r"(?m)^func ", SOURCE[found.end():])
    return SOURCE[found.start():found.end() + following.start()] if following else SOURCE[found.start():]


class LandscapeDepthTests(unittest.TestCase):
    def test_path_and_ground_extend_farther_than_original_scene(self):
        code = method("generate_terrain")
        self.assertIn("Vector3(48, 0.35, 160)", code)
        self.assertIn("Vector3(7, 0.06, 160)", code)
        self.assertEqual(code.count("Vector3(0, -0.3, -36)"), 1)
        self.assertEqual(code.count("Vector3(0, -0.08, -36)"), 1)

    def test_forest_extension_only_used_in_nature(self):
        code = method("generate_terrain")
        self.assertRegex(code, r"if current_biome == 3:\s+NatureArt\.forest\(terrain\)\s+_add_forest_depth\(\)")

    def test_fixed_seed_and_no_collision_nodes(self):
        code = method("_add_forest_depth")
        self.assertIn("rng.seed = 483721", code)
        self.assertIn("rng.randf_range(-105.0, -46.0)", code)
        self.assertIn("rng.randf_range(-95.0, 14.0)", code)
        self.assertNotIn("CollisionShape3D", code)
        self.assertNotIn("StaticBody3D", code)


if __name__ == "__main__":
    unittest.main()
