import csv
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).with_name("compare_forest_geometry.py")

class CompareForestGeometryTests(unittest.TestCase):
    def test_comparison_reports_import_delta(self):
        with tempfile.TemporaryDirectory() as d:
            folder = Path(d)
            source = folder / "source.csv"
            log = folder / "godot.log"
            report = folder / "comparison.csv"
            with source.open("w", newline="", encoding="utf-8") as f:
                writer = csv.DictWriter(f, fieldnames=[
                    "file", "triangles", "scene_triangles", "vertices"])
                writer.writeheader()
                writer.writerow(dict(file="forest_01_mooshuepfer.glb",
                                     triangles=10, scene_triangles=20, vertices=30))
            log.write_text(
                "Godot Engine v4.7.2\n"
                "enemy,mesh_instances,surfaces,material_slots,skin_instances,animations,imported_vertices,imported_triangles\n"
                "forest_01_mooshuepfer,2,3,3,0,4,32,21\n",
                encoding="utf-8")
            result = subprocess.run(
                [sys.executable, str(SCRIPT), "--source", str(source),
                 "--godot-log", str(log), "--output", str(report)],
                capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            with report.open(newline="", encoding="utf-8") as f:
                rows = list(csv.DictReader(f))
            self.assertEqual(len(rows), 1)
            self.assertEqual(rows[0]["triangle_delta_vs_scene"], "1")
            self.assertEqual(rows[0]["vertex_delta"], "2")

    def test_missing_import_is_error(self):
        with tempfile.TemporaryDirectory() as d:
            folder = Path(d)
            source = folder / "source.csv"
            log = folder / "godot.log"
            with source.open("w", newline="", encoding="utf-8") as f:
                writer = csv.DictWriter(f, fieldnames=[
                    "file", "triangles", "scene_triangles", "vertices"])
                writer.writeheader()
                writer.writerow(dict(file="forest_01_mooshuepfer.glb",
                                     triangles=10, scene_triangles=10, vertices=30))
            log.write_text("forest_02_pilzling,1,1,1,0,4,30,10\n", encoding="utf-8")
            result = subprocess.run(
                [sys.executable, str(SCRIPT), "--source", str(source),
                 "--godot-log", str(log), "--output", str(folder / "out.csv")],
                capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("Model mismatch", result.stderr + result.stdout)

if __name__ == "__main__":
    unittest.main()
