#!/usr/bin/env python3
"""Compare GLB source geometry with Godot-imported geometry, without assuming
they are identical. A discrepancy is diagnostic, not automatically a failure.
"""
import argparse
import csv
import re
from pathlib import Path

LINE = re.compile(r"^(forest_[a-z0-9_]+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+)$")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--godot-log", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    with args.source.open(newline="", encoding="utf-8") as f:
        source = {r["file"].removesuffix(".glb"): r for r in csv.DictReader(f)}
    imported = {}
    for line in args.godot_log.read_text(encoding="utf-8", errors="replace").splitlines():
        match = LINE.fullmatch(line.strip())
        if match:
            name, meshes, surfaces, materials, skins, animations, vertices, triangles = match.groups()
            imported[name] = dict(mesh_instances=int(meshes), surfaces=int(surfaces),
                                  material_slots=int(materials), skin_instances=int(skins),
                                  animations=int(animations), vertices=int(vertices),
                                  triangles=int(triangles))
    if not imported:
        raise SystemExit("No imported forest geometry measurements found")
    if set(source) != set(imported):
        raise SystemExit(f"Model mismatch: source-only={sorted(set(source)-set(imported))}, "
                         f"Godot-only={sorted(set(imported)-set(source))}")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=[
            "enemy", "source_triangles", "source_scene_triangles",
            "godot_triangles", "triangle_delta_vs_scene",
            "source_vertices", "godot_vertices", "vertex_delta",
            "godot_surfaces", "godot_material_slots", "godot_skin_instances",
            "godot_animations"])
        writer.writeheader()
        for name in sorted(source):
            src, imp = source[name], imported[name]
            writer.writerow(dict(
                enemy=name, source_triangles=src["triangles"],
                source_scene_triangles=src["scene_triangles"],
                godot_triangles=imp["triangles"],
                triangle_delta_vs_scene=imp["triangles"] - int(src["scene_triangles"]),
                source_vertices=src["vertices"], godot_vertices=imp["vertices"],
                vertex_delta=imp["vertices"] - int(src["vertices"]),
                godot_surfaces=imp["surfaces"],
                godot_material_slots=imp["material_slots"],
                godot_skin_instances=imp["skin_instances"],
                godot_animations=imp["animations"]))
    print(f"FOREST GEOMETRY COMPARISON PASSED: {len(source)} scenes, report={args.output}")

if __name__ == "__main__":
    main()
