#!/usr/bin/env python3
"""Report per-clip overlap between Unity AnimationClip binding hashes and verified rig paths.

Only metadata is processed. A matching CRC32 is not proof of retargeting compatibility.
"""
import argparse
import json
from pathlib import Path


def coverage(inventory, rig_matches):
    known = {int(item["hash"]) for item in rig_matches["matches"]}
    rows = []
    for clip in inventory["rows"]:
        hashes = {int(item["path"]) for item in clip.get("bindings", [])}
        overlap = hashes & known
        rows.append({
            "file": clip["file"],
            "unique_paths": len(hashes),
            "matched_paths": len(overlap),
            "coverage_pct": round(100 * len(overlap) / len(hashes), 2) if hashes else None,
        })
    return {
        "known_rig_hashes": len(known),
        "clips_total": len(rows),
        "clips_with_matches": sum(row["matched_paths"] > 0 for row in rows),
        "clips_without_matches": sum(row["matched_paths"] == 0 for row in rows),
        "limitations": "CRC32 path overlap only; no evidence of successful Godot playback.",
        "clips": rows,
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("binding_inventory", type=Path)
    parser.add_argument("rig_matches", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    report = coverage(
        json.loads(args.binding_inventory.read_text(encoding="utf-8")),
        json.loads(args.rig_matches.read_text(encoding="utf-8")),
    )
    output = json.dumps(report, indent=2, ensure_ascii=False) + "\n"
    if args.output:
        args.output.write_text(output, encoding="utf-8")
    print(f"{report['clips_with_matches']}/{report['clips_total']} clips have known rig path matches")


if __name__ == "__main__":
    main()
