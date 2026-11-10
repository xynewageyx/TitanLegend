#!/usr/bin/env python3
"""Check coverage of twelve imported Titan Legends Godot Skeleton3D classes.

This checks inventory completeness only; it does not prove animation retargeting.
"""
import argparse
import json
from pathlib import Path

CLASSES = "warrior paladin druid shaman hunter rogue mage warlock summoner priest brawler death_knight".split()

def audit(data):
    records = {name: [] for name in CLASSES}
    for entry in data.get("skeletons", []):
        name = Path(str(entry.get("scene", ""))).stem.lower()
        if name in records:
            records[name].append(entry)
    classes = []
    for name in CLASSES:
        entries = records[name]
        status = ("missing" if not entries else "multiple" if len(entries) > 1
                  else "ok" if entries[0].get("bones") else "empty")
        classes.append({"class": name, "skeleton_count": len(entries),
                        "bone_counts": [len(entry.get("bones", [])) for entry in entries],
                        "status": status})
    return {"expected_classes": len(CLASSES),
            "covered_classes": sum(c["status"] == "ok" for c in classes),
            "complete": all(c["status"] == "ok" for c in classes),
            "classes": classes,
            "note": "Skeleton inventory coverage only; no Unity retargeting is verified."}

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("inventory", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    result = audit(json.loads(args.inventory.read_text(encoding="utf-8")))
    text = json.dumps(result, indent=2) + "\n"
    if args.output:
        args.output.write_text(text, encoding="utf-8")
    print(text)
    if not result["complete"]:
        raise SystemExit(1)

if __name__ == "__main__":
    main()
