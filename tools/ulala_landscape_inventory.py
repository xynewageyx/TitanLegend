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
        rows.append({
            "path": rel.as_posix(), "bytes": size,
            "unityfs": header.startswith(b"UnityFS"),
            "categories": cats, "biomes": biomes,
        })
    rows.sort(key=lambda row: row["path"])
    return {
        "scope": "filename and first eight bytes only; not decoded mesh/material data",
        "total_files_scanned": total,
        "matching_files": len(rows),
        "categories": dict(Counter(cat for row in rows for cat in row["categories"])),
        "biomes": dict(Counter(b for row in rows for b in row["biomes"])),
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
