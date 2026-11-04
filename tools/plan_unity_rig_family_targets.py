#!/usr/bin/env python3
"""Select missing rig families from unresolved Unity AnimationClip hashes."""
import argparse
from collections import defaultdict
import json
from pathlib import Path


def targets(report):
    families = defaultdict(list)
    for row in report["priority"]:
        for family in {name.split("@", 1)[0] for name in row["clips"] if "@" in name}:
            families[family].append(row)
    return {
        "unresolved_hashes": len(report["priority"]),
        "families": {
            family: {
                "unresolved_hashes": len(items),
                "top_hashes": [
                    {"hash": item["hash"], "clip_count": item["clip_count"]}
                    for item in sorted(items, key=lambda x: (-x["clip_count"], x["hash"]))[:10]
                ],
            }
            for family, items in sorted(families.items(), key=lambda x: (-len(x[1]), x[0]))
        },
        "limitations": "Overlapping family counts; filename prefixes are not verified skeleton identities.",
    }


def main():
    p = argparse.ArgumentParser()
    p.add_argument("unresolved_priority_json", type=Path)
    p.add_argument("--output", type=Path)
    a = p.parse_args()
    result = targets(json.loads(a.unresolved_priority_json.read_text(encoding="utf-8")))
    output = json.dumps(result, ensure_ascii=False, indent=2) + "\n"
    if a.output:
        a.output.write_text(output, encoding="utf-8")
    print(output)


if __name__ == "__main__":
    main()
