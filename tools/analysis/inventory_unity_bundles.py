#!/usr/bin/env python3
"""Read-only UnityFS metadata inventory for a locally extracted Ulala backup.

Usage:
  python -m pip install UnityPy
  python tools/analysis/inventory_unity_bundles.py /path/to/extracted/ulala --output report.json
Does not export any proprietary meshes, textures, animations or audio.
"""
import argparse
import json
from collections import Counter
from pathlib import Path

TYPES = {"Mesh", "AnimationClip", "Animator", "SkinnedMeshRenderer", "Material", "GameObject", "Texture2D", "Avatar"}
MAX_FILE_BYTES = 250 * 1024 * 1024


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("root", type=Path, help="Extracted backup directory")
    parser.add_argument("--output", type=Path, default=Path("ulala_unity_metadata.json"))
    parser.add_argument("--max-files", type=int, default=0, help="0 = unlimited")
    args = parser.parse_args()
    if not args.root.is_dir():
        parser.error("Root must be an extracted directory (not one .7z volume)")
    try:
        import UnityPy
    except ImportError:
        parser.error("UnityPy missing: python -m pip install UnityPy")
    results = []
    files = sorted(p for p in args.root.rglob("*") if p.is_file())
    scanned = 0
    for path in files:
        if args.max_files and scanned >= args.max_files:
            break
        if path.stat().st_size > MAX_FILE_BYTES:
            continue
        try:
            with path.open("rb") as f:
                header = f.read(16)
            if not header.startswith((b"UnityFS", b"UnityWeb", b"UnityRaw")):
                continue
            scanned += 1
            entry = {"path": str(path.relative_to(args.root)), "bytes": path.stat().st_size}
            try:
                env = UnityPy.load(str(path))
                counts = Counter(obj.type.name for obj in env.objects if obj.type.name in TYPES)
                entry["object_types"] = dict(sorted(counts.items()))
                entry["object_count"] = len(env.objects)
            except Exception as exc:
                entry["error"] = f"{type(exc).__name__}: {str(exc)[:200]}"
            results.append(entry)
        except OSError:
            continue
    summary = Counter()
    for entry in results:
        summary.update(entry.get("object_types", {}))
    report = {
        "format": "read-only UnityFS object-type inventory",
        "scanned_unity_bundles": scanned,
        "total_candidate_files": len(files),
        "object_type_totals": dict(sorted(summary.items())),
        "bundles": results,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Scanned {scanned} Unity bundles; report: {args.output}")
    print(json.dumps(report["object_type_totals"], ensure_ascii=False))


if __name__ == "__main__":
    main()
