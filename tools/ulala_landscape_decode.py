#!/usr/bin/env python3
"""Inspect extracted Unity bundles locally; export metadata only, never copyrighted assets.

Usage: python tools/ulala_landscape_decode.py /path/to/extracted/assets --output report.json
Dependency: pip install UnityPy
"""
import argparse
import json
from collections import Counter
from pathlib import Path

KEYWORDS = ("forest", "terrain", "rain", "sun", "skymat", "afterglowforest",
            "water", "volcano", "desert", "coast", "glacier", "plain")

def inspect_bundle(path, unitypy):
    entry = {"path": str(path), "bytes": path.stat().st_size}
    try:
        env = unitypy.load(str(path))
        kinds = Counter()
        samples = []
        for obj in env.objects:
            kind = obj.type.name
            kinds[kind] += 1
            if kind in ("GameObject", "Mesh", "Material", "Texture2D", "TerrainData", "Shader"):
                try:
                    data = obj.read()
                    label = getattr(data, "m_Name", "")
                    if label and len(samples) < 80:
                        samples.append({"type": kind, "name": str(label)[:160]})
                except Exception as exc:
                    if len(samples) < 80:
                        samples.append({"type": kind, "read_error": type(exc).__name__})
        entry["object_types"] = dict(kinds)
        entry["named_objects"] = samples
        entry["status"] = "decoded"
    except Exception as exc:
        entry["status"] = "error"
        entry["error"] = type(exc).__name__ + ": " + str(exc)[:300]
    return entry

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("root", type=Path)
    parser.add_argument("--output", type=Path, default=Path("ulala_landscape_objects.json"))
    args = parser.parse_args()
    if not args.root.is_dir():
        parser.error("Directory not found")
    try:
        import UnityPy
    except ImportError:
        parser.error("UnityPy is required: pip install UnityPy")
    files = sorted(p for p in args.root.rglob("*") if p.is_file()
                   and any(word in p.as_posix().lower() for word in KEYWORDS)
                   and (p.name.endswith(("_ab", "_ab_shared"))))
    results = [inspect_bundle(p, UnityPy) for p in files]
    output = {"scope": "object types and names only; no asset payloads",
              "files_considered": len(files),
              "decoded": sum(r["status"] == "decoded" for r in results),
              "results": results}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(output, indent=2, ensure_ascii=False), encoding="utf-8")
    print("Decoded", output["decoded"], "of", len(files), "candidate bundles")
    print("Metadata report:", args.output)

if __name__ == "__main__":
    main()
