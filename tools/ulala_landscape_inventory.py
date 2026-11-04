#!/usr/bin/env python3
"""Inventory extracted Ulala reference bundles without copying proprietary payloads.

Usage: python3 tools/ulala_landscape_inventory.py /path/to/extracted/assets --output landscape_inventory.json
Requires Python standard library only. Reads only headers and filenames.
"""
import argparse
import json
from collections import Counter
from pathlib import Path

BIOMES = ("forest", "plain", "desert", "coast", "volcano", "glacier", "snow", "ice", "swamp", "jungle")
CATEGORIES = {
    "terrain": ("terrain", "ground", "land", "floor", "road", "path", "dixing"),
    "vegetation": ("tree", "grass", "flower", "leaf", "bush", "plant", "forest", "cao", "huaduo", "baihuashu"),
    "water": ("water", "river", "lake", "sea", "ocean", "wave"),
    "rock": ("rock", "stone", "cliff", "yanshi"),
    "sky_weather": ("sky", "rain", "sun", "cloud", "weather", "fog", "snow"),
    "environment": ("scene", "environment", "light", "shadow", "prefab"),
}
def classify(path):
    name = path.as_posix().lower()
    return [key for key, words in CATEGORIES.items() if any(word in name for word in words)]

def unityfs_header(path):
    """Read UnityFS signature, big-endian version and NUL-terminated strings."""
    try:
        with path.open("rb") as stream:
            data = stream.read(512)
        signature = b"UnityFS\x00"
        if not data.startswith(signature) or len(data) < 16:
            return None
        version = int.from_bytes(data[len(signature):len(signature) + 4], "big")
        if not 1 <= version <= 10:
            return None
        remainder = data[len(signature) + 4:].split(b"\x00", 2)
        if len(remainder) < 3:
            return None
        return {
            "format": "UnityFS",
            "bundle_version": version,
            "unity_version": remainder[0].decode("ascii", "replace"),
            "revision": remainder[1].decode("ascii", "replace"),
        }
    except (OSError, ValueError):
        return None

def landscape_priority(relative_path):
    """Prioritize likely scene roots over incidental material-name matches."""
    path = relative_path.as_posix().lower()
    if "/scenes/forest/" in "/" + path and path.endswith(".prefab_ab"):
        return 0
    if "/scenes/" in "/" + path and path.endswith(".prefab_ab"):
        return 1
    if "/materials/terrain/" in "/" + path:
        return 2
    if "/materials/" in "/" + path:
        return 3
    return 4

def inspect(root):
    rows = []
    total = 0
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        total += 1
        rel = path.relative_to(root)
        lower = rel.as_posix().lower()
        cats = classify(rel)
        biomes = [biome for biome in BIOMES if biome in lower]
        if not cats and not biomes:
            continue
        try:
            with path.open("rb") as stream:
                header = stream.read(8)
            size = path.stat().st_size
        except OSError:
            continue
        header_info = unityfs_header(path) if header.startswith(b"UnityFS") else None
        rows.append({
            "path": rel.as_posix(), "bytes": size,
            "analysis_priority": landscape_priority(rel),
            "unityfs": header_info is not None,
            "unityfs_header": header_info,
            "categories": cats, "biomes": biomes,
        })
    rows.sort(key=lambda row: (row["analysis_priority"], row["path"]))
    return {
        "scope": "filename and first eight bytes only; not decoded mesh/material data",
        "total_files_scanned": total,
        "matching_files": len(rows),
        "categories": dict(Counter(cat for row in rows for cat in row["categories"])),
        "biomes": dict(Counter(b for row in rows for b in row["biomes"])),
        "priority_note": "0 forest scene prefabs; 1 other scene prefabs; 2 terrain materials; 3 other materials; 4 other matches",
        "entries": rows,
    }

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("root", type=Path, help="Directory containing extracted reference files")
    parser.add_argument("--output", type=Path, default=Path("landscape_inventory.json"))
    args = parser.parse_args()
    if not args.root.is_dir():
        parser.error("Extracted asset directory does not exist")
    result = inspect(args.root)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Scanned {result['total_files_scanned']} files; {result['matching_files']} landscape candidates")
    print(f"Inventory saved to {args.output}")

if __name__ == "__main__":
    main()
