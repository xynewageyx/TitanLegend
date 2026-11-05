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
          "game_object", "other", "error")

def inspect(path):
    import UnityPy
    row = dict.fromkeys(FIELDS, "")
    row["bundle"] = path.name
    try:
        env = UnityPy.load(str(path))
        counts = Counter(str(obj.type.name) for obj in env.objects)
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
