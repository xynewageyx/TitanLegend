#!/usr/bin/env python3
"""Summarize local AnimationClip header inventory; no proprietary clip payloads."""
import argparse
from collections import Counter
import json
from pathlib import Path


def summarize(rows):
    if not rows:
        raise ValueError("Empty clip inventory")
    seen = set()
    problems = []
    flags = Counter()
    groups = Counter()
    for row in rows:
        name = row["file"]
        if name in seen:
            problems.append(f"Duplicate bundle filename: {name}")
        seen.add(name)
        if row["clip_name"].casefold() != name.removesuffix(".anim_ab").casefold():
            problems.append(f"Clip name mismatch: {name}")
        flags[(int(row["legacy"]), int(row["compressed"]),
               int(row["high_quality"]))] += 1
        prefix = name.split("@", 1)[0] if "@" in name else "other"
        groups[prefix] += 1
    return {
        "clips": len(rows),
        "name_mismatches_or_duplicates": problems,
        "legacy_files": sorted(row["file"] for row in rows if row["legacy"]),
        "clip_size_min": min(row["object_bytes"] for row in rows),
        "clip_size_max": max(row["object_bytes"] for row in rows),
        "flags": {"/".join(map(str, key)): count for key, count in sorted(flags.items())},
        "filename_groups": dict(sorted(groups.items())),
    }


def main():
    p = argparse.ArgumentParser()
    p.add_argument("input", type=Path)
    p.add_argument("--output", type=Path)
    args = p.parse_args()
    rows = json.loads(args.input.read_text(encoding="utf-8"))
    result = summarize(rows)
    output = json.dumps(result, indent=2, ensure_ascii=False) + "\n"
    if args.output:
        args.output.write_text(output, encoding="utf-8")
    print(output)
    if result["name_mismatches_or_duplicates"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
