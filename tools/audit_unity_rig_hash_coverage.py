#!/usr/bin/env python3
"""Reproducible CRC32 rig/AnimationClip coverage audit (metadata only)."""
import argparse
from collections import defaultdict
import json
from pathlib import Path
import zlib


def audit(inventory, rigs):
    by_hash = defaultdict(set)
    for row in inventory["rows"]:
        for binding in row.get("bindings", []):
            by_hash[int(binding["path"])].add(row["file"])
    candidates = defaultdict(set)
    warnings = []
    for rig in rigs:
        nodes = {n["path_id"]: n for n in rig["nodes"]}

        def paths(pid, visited):
            if pid in visited:
                warnings.append({"rig": rig["file"], "error": "parent_cycle", "id": pid})
                return []
            node = nodes[pid]
            parent = node["father"][1]
            if parent and parent in nodes:
                return [p + "/" + node["name"] for p in paths(parent, visited | {pid})]
            return [node["name"]]

        for pid in nodes:
            for full in paths(pid, set()):
                parts = full.split("/")
                for start in range(len(parts)):
                    candidates["/".join(parts[start:])].add(rig["file"])
    matches = []
    for path, sources in sorted(candidates.items()):
        h = zlib.crc32(path.encode("utf-8")) & 0xffffffff
        if h in by_hash:
            matches.append({"path": path, "hash": h,
                            "sources": sorted(sources), "clips": sorted(by_hash[h])})
    known = {item["hash"] for item in matches}
    per_clip = []
    for row in inventory["rows"]:
        unique = {int(b["path"]) for b in row.get("bindings", [])}
        matched = unique & known
        per_clip.append({"file": row["file"], "unique_paths": len(unique),
                         "matched_paths": len(matched),
                         "coverage_pct": round(100 * len(matched) / len(unique), 2)
                         if unique else None})
    return {"rigs": len(rigs), "candidate_paths": len(candidates),
            "unique_binding_hashes": len(by_hash), "matching_hashes": len(known),
            "unmatched_hashes": len(set(by_hash) - known),
            "clips_with_matches": sum(bool(x["matched_paths"]) for x in per_clip),
            "matches": matches, "per_clip": per_clip, "warnings": warnings,
            "limitations": "CRC32 path match only; no proof of Godot playback."}


def main():
    p = argparse.ArgumentParser()
    p.add_argument("inventory", type=Path)
    p.add_argument("rigs", type=Path)
    p.add_argument("--output", type=Path)
    args = p.parse_args()
    report = audit(json.loads(args.inventory.read_text(encoding="utf-8")),
                   json.loads(args.rigs.read_text(encoding="utf-8")))
    output = json.dumps(report, indent=2, ensure_ascii=False) + "\n"
    if args.output:
        args.output.write_text(output, encoding="utf-8")
    print(json.dumps({k: v for k, v in report.items()
                      if k not in ("matches", "per_clip", "warnings")}))


if __name__ == "__main__":
    main()
