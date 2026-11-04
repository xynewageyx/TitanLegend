#!/usr/bin/env python3
"""Match Unity AnimationClip path hashes to known rig paths (metadata only)."""
import argparse
import json
from pathlib import Path
import zlib


def compare(binding_inventory, equipment_comparison):
    rows = binding_inventory["rows"]
    paths = sorted({path for item in equipment_comparison
                    for key in ("only_a", "only_b")
                    for path in item.get(key, [])})
    by_hash = {}
    for row in rows:
        for binding in row.get("bindings", []):
            by_hash.setdefault(binding["path"], set()).add(row["file"])
    matched, unmatched = [], []
    for path in paths:
        hashed = zlib.crc32(path.encode("utf-8")) & 0xffffffff
        record = {"path": path, "hash": hashed}
        if hashed in by_hash:
            record["clip_count"] = len(by_hash[hashed])
            matched.append(record)
        else:
            unmatched.append(record)
    return {"unique_animation_hashes": len(by_hash),
            "candidate_paths": len(paths), "matched_paths": len(matched),
            "unmatched_paths": unmatched, "matches": matched}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("binding_inventory", type=Path)
    parser.add_argument("equipment_comparison", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    result = compare(json.loads(args.binding_inventory.read_text(encoding="utf-8")),
                     json.loads(args.equipment_comparison.read_text(encoding="utf-8")))
    text = json.dumps(result, indent=2, ensure_ascii=False) + "\n"
    if args.output:
        args.output.write_text(text, encoding="utf-8")
    print(f"{result['matched_paths']}/{result['candidate_paths']} path matches; "
          f"{result['unique_animation_hashes']} unique animation hashes")


if __name__ == "__main__":
    main()
