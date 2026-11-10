#!/usr/bin/env python3
"""Summarize Godot original 12-class bone movement; detect DK attack-hand regressions."""
import argparse
import json
from pathlib import Path

CLASSES = "warrior paladin druid shaman hunter rogue mage warlock summoner priest brawler death_knight".split()
ACTIONS = ["Idle", "Walk", "Attack", "Dodge"]

def summarize(data):
    by_key = {(x["class"], x["action"]): x for x in data.get("rows", [])}
    problems = []
    if data.get("errors"):
        problems.extend(str(e) for e in data["errors"])
    for name in CLASSES:
        for action in ACTIONS:
            if (name, action) not in by_key:
                problems.append(f"Missing action {name}/{action}")
    stats = []
    for name in CLASSES:
        row = {"class": name}
        target = "Hand_R_2" if name == "death_knight" else "Arm_R"
        for action in ACTIONS:
            entry = by_key.get((name, action), {})
            role = next((b for b in entry.get("tracked_bones", []) if b["bone"] == target), None)
            if role is None:
                problems.append(f"{name}/{action}: missing motion data for {target}")
                continue
            row[action.lower()+"_right_hand_degrees"] = float(role["max_rotation_degrees"])
            row[action.lower()+"_right_hand_translation"] = float(role["max_position_delta"])
        stats.append(row)
    dk = stats[-1]
    # Existing test data: DK right-hand Attack = 62.145°, shift = 0.18977.
    if dk.get("attack_right_hand_degrees", 0) < 20.0:
        problems.append("Death Knight attack hand rotation unexpectedly below 20 degrees")
    if dk.get("attack_right_hand_translation", 0) < 0.03:
        problems.append("Death Knight attack hand displacement unexpectedly below 0.03 units")
    observations = []
    if dk.get("idle_right_hand_degrees", 0) < 0.5:
        observations.append("Death Knight idle hand nearly static: consider adding subtle original breathing/hand movement")
    if dk.get("walk_right_hand_degrees", 0) < 10.0:
        observations.append("Death Knight Walk hand swing subdued compared to base rig: visual tuning candidate")
    return {"valid": not problems, "issues": problems, "observations": observations,
            "profiles": stats, "unity_retargeting_verified": False,
            "note": "Checks Godot animation samples, not Android visuals or original reference game animations"}

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    output = summarize(json.loads(args.source.read_text(encoding="utf-8")))
    result = json.dumps(output, indent=2, ensure_ascii=False) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(result, encoding="utf-8")
    print(result)
    if not output["valid"]:
        raise SystemExit(1)

if __name__ == "__main__":
    main()
