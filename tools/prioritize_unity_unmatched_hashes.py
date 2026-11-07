#!/usr/bin/env python3
"""Rank unresolved Unity animation path hashes by clip coverage; metadata only."""
import argparse
from collections import defaultdict
import json
from pathlib import Path


def prioritize(inventory, audit):
    known = {int(x["hash"]) for x in audit["matches"]}
    by_hash = defaultdict(set)
    for row in inventory["rows"]:
        for binding in row.get("bindings", []):
            by_hash[int(binding["path"])].add(row["file"])
    unknown = sorted(
        ({"hash": h, "clip_count": len(clips), "clips": sorted(clips)}
         for h, clips in by_hash.items() if h not in known),
        key=lambda item: (-item["clip_count"], item["hash"]),
    )
    return {
        "unique_hashes": len(by_hash),
        "known_hashes": len(known & by_hash.keys()),
        "unmatched_hashes": len(unknown),
        "priority": unknown,
        "note": "Hash frequency does not identify a bone; no Unity assets included.",
    }


def main():
    p = argparse.ArgumentParser()
    p.add_argument("inventory", type=Path)
    p.add_argument("rig_audit", type=Path)
    p.add_argument("--output", type=Path)
    args = p.parse_args()
    result = prioritize(
        json.loads(args.inventory.read_text(encoding="utf-8")),
        json.loads(args.rig_audit.read_text(encoding="utf-8")),
    )
    payload = json.dumps(result, ensure_ascii=False, indent=2) + "\n"
    if args.output:
        args.output.write_text(payload, encoding="utf-8")
    print(f"{result['unmatched_hashes']} unresolved hashes; highest frequency: "
          f"{result['priority'][0]['clip_count'] if result['priority'] else 0} clips")


if __name__ == "__main__":
    main()
