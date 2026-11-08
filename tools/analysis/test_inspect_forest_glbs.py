import importlib.util
import json
import struct
import tempfile
import unittest
from pathlib import Path

script = Path(__file__).with_name("inspect_forest_glbs.py")
spec = importlib.util.spec_from_file_location("inspect_forest_glbs", script)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

def write_glb(path, primitives, accessors):
    doc = {"asset": {"version": "2.0"}, "meshes": [{"primitives": primitives}],
           "accessors": [{"count": n} for n in accessors], "nodes": [{}],
           "skins": [], "animations": []}
    chunk = json.dumps(doc).encode("utf-8")
    chunk += b" " * (-len(chunk) % 4)
    total = 20 + len(chunk)
    path.write_bytes(struct.pack("<4sIIII", b"glTF", 2, total, len(chunk), 0x4E4F534A) + chunk)

class ForestGeometryTests(unittest.TestCase):
    def test_indexed_and_nonindexed_triangles(self):
        with tempfile.TemporaryDirectory() as temp:
            p = Path(temp) / "forest.glb"
            write_glb(p, [
                {"attributes": {"POSITION": 0}, "indices": 1},
                {"attributes": {"POSITION": 2}},
                {"attributes": {"POSITION": 3}, "indices": 4, "mode": 1}
            ], [10, 12, 6, 4, 4])
            row = module.analyze(p)
            self.assertEqual(row["vertices"], 20)
            self.assertEqual(row["triangles"], 6)
            self.assertEqual(row["non_triangle_modes"], "1")

    def test_triangle_strip(self):
        with tempfile.TemporaryDirectory() as temp:
            p = Path(temp) / "strip.glb"
            write_glb(p, [{"attributes": {"POSITION": 0}, "mode": 5}], [5])
            self.assertEqual(module.analyze(p)["triangles"], 3)

    def test_invalid_triangle_indices_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            p = Path(temp) / "bad.glb"
            write_glb(p, [{"attributes": {"POSITION": 0}, "indices": 1}], [4, 5])
            with self.assertRaises(ValueError):
                module.analyze(p)

if __name__ == "__main__":
    unittest.main()
