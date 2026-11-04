#!/usr/bin/env python3
"""Summarize imported Chibi animation coverage without claiming Unity retargeting."""
import argparse
import json
from pathlib import Path

HEROES = {"brawler", "druid", "hunter", "mage", "paladin", "priest",
          "rogue", "shaman", "summoner", "warlock", "warrior"}


def analyze(inventory):
    errors = list(inventory.get("errors", []))
    entries = inventory.get("heroes", [])
    names = [entry.get("hero") for entry in entries]
    if len(names) != len(set(names)):
        errors.append("Duplicate hero entries")
    missing = sorted(HEROES - set(names))
    unexpected = sorted(set(names) - HEROES)
    if missing:
        errors.append("Missing heroes: " + ", ".join(missing))
    if unexpected:
        errors.append("Unexpected heroes: " + ", ".join(unexpected))
    coverage = {}
    for entry in entries:
        clips = entry.get("clips", [])
        coverage[entry.get("hero")] = {
            "animation_players": entry.get("animation_players", 0),
            "clip_count": len(clips),
            "clips_with_keys": sum(any(track.get("key_count", 0) > 0
                                      for track in clip.get("tracks", [])) for clip in clips),
            "clip_names": [clip.get("name") for clip in clips],
        }
    return {
        "valid_inventory": not errors,
        "errors": errors,
        "hero_count": len(entries),
        "heroes_with_imported_clips": sum(v["clip_count"] > 0 for v in coverage.values()),
        "total_imported_clips": sum(v["clip_count"] for v in coverage.values()),
        "coverage": coverage,
        "unity_retargeting_verified": False,
        "note": "Imported clip presence does not prove animation playback or Unity compatibility.",
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("inventory", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    result = analyze(json.loads(args.inventory.read_text(encoding="utf-8")))
    args.output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(result, indent=2))
    if not result["valid_inventory"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
