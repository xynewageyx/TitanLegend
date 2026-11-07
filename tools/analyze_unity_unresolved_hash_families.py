#!/usr/bin/env python3
"""Group unresolved Unity path hashes by observed animation filename families.

Family names are heuristic labels, not verified rig identities.
"""
import argparse
from collections import Counter, defaultdict
import json
from pathlib import Path


def analyze(data):
    items = data["priority"]
    family_counts = Counter()
    exclusive = Counter()
    shared = []
    top = defaultdict(list)
    for item in items:
        families = sorted({name.split("@", 1)[0] if "@" in name
                           else name.removesuffix(".anim_ab")
                           for name in item["clips"]})
        for family in families:
            family_counts[family] += 1
            top[family].append({"hash": item["hash"],
                                "clip_count": item["clip_count"]})
        if len(families) == 1:
            exclusive[families[0]] += 1
        else:
            shared.append({"hash": item["hash"], "families": families,
                           "clip_count": item["clip_count"]})
    return {
        "unresolved_hashes": len(items),
        "hashes_by_filename_family": dict(family_counts.most_common()),
        "exclusive_hashes_by_family": dict(exclusive.most_common()),
        "shared_between_families": len(shared),
        "shared_examples": shared[:25],
        "top_by_family": {
            key: sorted(values, key=lambda x: (-x["clip_count"], x["hash"]))[:15]
            for key, values in top.items()
        },
        "caveat": "Filename prefixes are not verified skeleton or bone identities.",
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("priority_json", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    report = analyze(json.loads(args.priority_json.read_text(encoding="utf-8")))
    result = json.dumps(report, ensure_ascii=False, indent=2) + "\n"
    if args.output:
        args.output.write_text(result, encoding="utf-8")
    print(result)


if __name__ == "__main__":
    main()
