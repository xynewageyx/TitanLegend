#!/usr/bin/env python3
"""Audit imported Chibi animation track metadata for suspicious duplicate clips.

Metadata-identical clips are *candidates*, not proven duplicates: keyframe values
are not present in the inventory. No source animation is modified.
"""
import argparse
import json
from collections import defaultdict
from pathlib import Path


def audit(inventory):
    results = []
    for hero in inventory.get("heroes", []):
        groups = defaultdict(list)
        empty = []
        for clip in hero.get("clips", []):
            tracks = clip.get("tracks", [])
            if not any(track.get("key_count", 0) > 0 for track in tracks):
                empty.append(clip.get("name"))
            signature = (
                round(float(clip.get("duration", 0)), 5),
                tuple(sorted((str(t.get("path")), int(t.get("type", -1)),
                              int(t.get("key_count", 0))) for t in tracks)),
            )
            groups[signature].append(clip.get("name"))
        candidates = [names for names in groups.values() if len(names) > 1]
        fingerprint_groups = defaultdict(list)
        for clip in hero.get("clips", []):
            fingerprint = clip.get("keyframe_fingerprint_sha256")
            if fingerprint:
                fingerprint_groups[(round(float(clip.get("duration", 0)), 5), fingerprint)].append(clip.get("name"))
        matching_keyframes = [names for names in fingerprint_groups.values() if len(names) > 1]
        results.append({
            "hero": hero.get("hero"),
            "clip_count": len(hero.get("clips", [])),
            "empty_clips": empty,
            "metadata_identical_groups": candidates,
            "matching_keyframe_fingerprint_groups": matching_keyframes,
            "metadata_identical_clip_count": sum(map(len, candidates)),
        })
    return {
        "schema_version": 1,
        "total_clips": sum(x["clip_count"] for x in results),
        "total_empty_clips": sum(len(x["empty_clips"]) for x in results),
        "total_metadata_identical_clip_candidates": sum(x["metadata_identical_clip_count"] for x in results),
        "total_matching_keyframe_fingerprint_groups": sum(len(x["matching_keyframe_fingerprint_groups"]) for x in results),
        "heroes": results,
        "warning": "Matching fingerprints indicate identical serialized keyframe data and timing, not necessarily equivalent runtime behavior. Do not delete clips automatically.",
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("inventory", type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    report = audit(json.loads(args.inventory.read_text(encoding="utf-8")))
    args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("Audited %d clips; %d empty; %d metadata-matching candidates" %
          (report["total_clips"], report["total_empty_clips"],
           report["total_metadata_identical_clip_candidates"]))


if __name__ == "__main__":
    main()
