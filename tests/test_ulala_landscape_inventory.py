"""Tests for safe, metadata-only landscape inventory parsing."""
import importlib.util
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "tools" / "ulala_landscape_inventory.py"
spec = importlib.util.spec_from_file_location("landscape_inventory", SCRIPT)
inventory = importlib.util.module_from_spec(spec)
spec.loader.exec_module(inventory)

class UnityFSInventoryTests(unittest.TestCase):
    def test_unityfs_header(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "forest.prefab_ab"
            path.write_bytes(b"UnityFS\x00" + (6).to_bytes(4, "big") +
                             b"2019.4.16f1\x002019.4.16f1\x00" + bytes(64))
            result = inventory.unityfs_header(path)
            self.assertEqual(result["bundle_version"], 6)
            self.assertEqual(result["unity_version"], "2019.4.16f1")

    def test_invalid_header(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "broken.prefab_ab"
            path.write_bytes(b"not a bundle")
            self.assertIsNone(inventory.unityfs_header(path))

    def test_landscape_inventory(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            folder = root / "assets" / "lib" / "scenes" / "forest"
            folder.mkdir(parents=True)
            (folder / "rain.prefab_ab").write_bytes(
                b"UnityFS\x00" + (6).to_bytes(4, "big") +
                b"2019.4.16f1\x002019.4.16f1\x00" + bytes(32))
            result = inventory.inspect(root)
            self.assertEqual(result["matching_files"], 1)
            self.assertIn("forest", result["entries"][0]["biomes"])
            self.assertIn("sky_weather", result["entries"][0]["categories"])
            self.assertTrue(result["entries"][0]["unityfs"])

    def test_priorities(self):
        cases = [
            ("assets/lib/scenes/forest/rain.prefab_ab", 0),
            ("assets/lib/scenes/desert/dunes.prefab_ab", 1),
            ("assets/models/article/materials/terrain/ground.mat_ab", 2),
            ("assets/models/article/materials/common/water.mat_ab", 3),
            ("misc/grass.bin", 4),
        ]
        for name, expected in cases:
            with self.subTest(name=name):
                self.assertEqual(inventory.landscape_priority(Path(name)), expected)

    def test_invalid_unityfs_version(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "invalid.prefab_ab"
            path.write_bytes(b"UnityFS\x00" + (0).to_bytes(4, "big") +
                             b"2019.4.16f1\x002019.4.16f1\x00")
            self.assertIsNone(inventory.unityfs_header(path))

if __name__ == "__main__":
    unittest.main()
