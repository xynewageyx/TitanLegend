#!/usr/bin/env python3
"""Read-only UnityFS object inventory for legally obtained reference bundles.

Usage: python tools/analysis/inspect_unity_bundles.py --input /path/to/bundles --output report.csv
Requires: pip install UnityPy
No mesh/texture/animation bytes are exported.
"""
import argparse
import csv
from collections import Counter
from pathlib import Path

FIELDS = ("bundle", "status", "object_count", "mesh", "skinned_mesh_renderer",
          "animation_clip", "animator", "material", "transform",
          "game_object", "other", "clip_names", "clip_durations_s", "mesh_names",
          "mesh_vertices_total", "skinned_bones_max", "error")

def inspect(path):
    import UnityPy
    row = dict.fromkeys(FIELDS, "")
    row["bundle"] = path.name
    try:
        env = UnityPy.load(str(path))
        counts = Counter(str(obj.type.name) for obj in env.objects)
        clip_names = []
        clip_durations = []
        mesh_names = []
        vertex_counts = []
        bone_counts = []
        for obj in env.objects:
            if obj.type.name not in ("AnimationClip", "Mesh", "SkinnedMeshRenderer"):
                continue
            try:
                tree = obj.read_typetree()
                name = str(tree.get("m_Name", ""))
                if obj.type.name == "Mesh":
                    mesh_names.append(name)
                    vertex_data = tree.get("m_VertexData", {})
                    if isinstance(vertex_data, dict) and isinstance(vertex_data.get("m_VertexCount"), int):
                        vertex_counts.append(vertex_data["m_VertexCount"])
                elif obj.type.name == "SkinnedMeshRenderer":
                    bones = tree.get("m_Bones")
                    if isinstance(bones, list):
                        bone_counts.append(len(bones))
                else:
                    clip_names.append(name)
                    start = tree.get("m_StartTime")
                    stop = tree.get("m_StopTime")
                    if isinstance(start, (int, float)) and isinstance(stop, (int, float)):
                        clip_durations.append(f"{max(0.0, stop - start):.3f}")
                    else:
                        clip_durations.append("unknown")
            except Exception:
                if obj.type.name == "SkinnedMeshRenderer":
                    pass
                elif obj.type.name == "AnimationClip":
                    clip_names.append("<unreadable>")
                    clip_durations.append("unknown")
                else:
                    mesh_names.append("<unreadable>")
        row.update({
            "status": "ok",
            "object_count": sum(counts.values()),
            "mesh": counts["Mesh"],
            "skinned_mesh_renderer": counts["SkinnedMeshRenderer"],
            "animation_clip": counts["AnimationClip"],
            "animator": counts["Animator"],
            "material": counts["Material"],
            "transform": counts["Transform"],
            "game_object": counts["GameObject"],
            "clip_names": ";".join(clip_names),
            "clip_durations_s": ";".join(clip_durations),
            "mesh_names": ";".join(mesh_names),
            "mesh_vertices_total": sum(vertex_counts) if vertex_counts else "",
            "skinned_bones_max": max(bone_counts) if bone_counts else "",
            "other": sum(v for k, v in counts.items() if k not in {
                "Mesh", "SkinnedMeshRenderer", "AnimationClip", "Animator",
                "Material", "Transform", "GameObject"}),
        })
    except Exception as exc:
        row["status"] = "error"
        row["error"] = f"{type(exc).__name__}: {exc}"[:400]
    return row

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    if not args.input.is_dir():
        parser.error("--input must be a directory of extracted UnityFS bundles")
    paths = sorted(p for p in args.input.rglob("*") if p.is_file()
                   and (p.name.endswith(".prefab_ab") or p.name.endswith(".prefab_ab_shared")))
    if not paths:
        parser.error("No .prefab_ab or .prefab_ab_shared files found")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=FIELDS)
        writer.writeheader()
        for path in paths:
            row = inspect(path)
            writer.writerow(row)
            print(f"{path.name}: {row['status']}; objects={row['object_count']}")
    print(f"Wrote {len(paths)} bundle rows to {args.output}")

if __name__ == "__main__":
    main()
