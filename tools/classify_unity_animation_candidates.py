#!/usr/bin/env python3
"""Classify Unity animation metadata into non-binding gameplay candidate groups.

Filename semantics are hints only. No curves, rig compatibility, licensing or
retargeting suitability are inferred. Input: local clip header JSON list.
"""
import argparse
from collections import Counter
import json
from pathlib import Path

KEYWORDS = {
    "idle": ("idle", "stand", "wait"),
    "locomotion": ("run", "walk", "move", "pao"),
    "attack": ("attack", "hit", "skill", "cast"),
    "pose": ("pose", "champion"),
    "mount": ("qima", "ride"),
    "fishing": ("fishing",),
}


def classify(rows):
    result = []
    for item in rows:
        name = item["clip_name"]
        lower = name.casefold()
        matched = [group for group, tokens in KEYWORDS.items()
                   if any(token in lower for token in tokens)]
        group = matched[0] if len(matched) == 1 else ("ambiguous" if matched else "other")
        result.append({
            "file": item["file"],
            "group": group,
            "legacy": bool(item["legacy"]),
            "bytes": int(item["object_bytes"]),
            "rig_verified": False,
        })
    counts = dict(sorted(Counter(row["group"] for row in result).items()))
    return {"clips": len(result), "groups": counts, "candidates": result,
            "disclaimer": "Filename-only grouping; no rig or curve compatibility verified."}


def main():
    p = argparse.ArgumentParser()
    p.add_argument("headers", type=Path)
    p.add_argument("--output", type=Path)
    a = p.parse_args()
    rows = json.loads(a.headers.read_text(encoding="utf-8"))
    report = classify(rows)
    payload = json.dumps(report, ensure_ascii=False, indent=2) + "\n"
    if a.output:
        a.output.write_text(payload, encoding="utf-8")
    print(payload)


if __name__ == "__main__":
    main()
