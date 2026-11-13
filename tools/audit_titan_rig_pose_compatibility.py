#!/usr/bin/env python3
"""Compare original Godot 4.7.2 class skeleton rest topology and equipment sockets.

Reads an export from tools/export_skeleton3d_inventory.gd. No Ulala assets.
Does not infer animation retargeting from matching names.
"""
import argparse
import json
from pathlib import Path

CLASSES = "warrior paladin druid shaman hunter rogue mage warlock summoner priest brawler death_knight".split()
BASE = ["Root", "Hips", "Spine", "Head", "Arm_L", "Arm_R", "Leg_L", "Leg_R"]
EXTENDED = {
    "RightHandSocket": "Hand_R_2", "LeftHandSocket": "Hand_L_2",
    "HeadSocket": "Head", "ChestSocket": "Chest", "BackSocket": "Chest",
    "ShoulderLeftSocket": "UpperArm_L_2", "ShoulderRightSocket": "UpperArm_R_2",
    "ArmLeftSocket": "Forearm_L_2", "ArmRightSocket": "Forearm_R_2",
    "GloveLeftSocket": "Hand_L_2", "GloveRightSocket": "Hand_R_2",
    "LegLeftSocket": "UpperLeg_L_2", "LegRightSocket": "UpperLeg_R_2",
    "BootLeftSocket": "Foot_L_2", "BootRightSocket": "Foot_R_2",
}
STANDARD = {
    "RightHandSocket": "Arm_R", "LeftHandSocket": "Arm_L",
    "HeadSocket": "Head", "ChestSocket": "Spine", "BackSocket": "Spine",
    "ShoulderLeftSocket": "Arm_L", "ShoulderRightSocket": "Arm_R",
    "ArmLeftSocket": "Arm_L", "ArmRightSocket": "Arm_R",
    "GloveLeftSocket": "Arm_L", "GloveRightSocket": "Arm_R",
    "LegLeftSocket": "Leg_L", "LegRightSocket": "Leg_R",
    "BootLeftSocket": "Leg_L", "BootRightSocket": "Leg_R",
}

def _diff(a, b):
    values_a = a["rest_origin"] + [v for row in a["rest_basis"] for v in row]
    values_b = b["rest_origin"] + [v for row in b["rest_basis"] for v in row]
    return max(abs(float(v) - float(w)) for v, w in zip(values_a, values_b))

def audit(data, tolerance=1e-5):
    sources = {}
    for item in data.get("skeletons", []):
        path = item.get("scene", "")
        if not path.startswith("res://assets/heroes/chibi/") or not path.endswith(".glb"):
            continue
        name = Path(path).stem
        if name in CLASSES:
            sources.setdefault(name, []).append(item)
    errors = []
    if any(len(sources.get(name, [])) != 1 for name in CLASSES):
        errors.append("Expected exactly one imported chibi skeleton for each of twelve classes")
    if errors:
        return {"valid": False, "errors": errors, "retargeting_verified": False}
    warrior = {b["name"]: b for b in sources["warrior"][0]["bones"]}
    if set(warrior) != set(BASE):
        errors.append("Warrior standard eight-bone fixture changed")
    result = []
    for name in CLASSES:
        bones = sources[name][0]["bones"]
        lookup = {b["name"]: b for b in bones}
        parent_mismatches = []
        rest_mismatches = []
        for key in BASE:
            if key not in warrior or key not in lookup:
                parent_mismatches.append(key + ":missing")
                continue
            if lookup[key]["parent"] != warrior[key]["parent"]:
                parent_mismatches.append(key)
            if _diff(lookup[key], warrior[key]) > tolerance:
                rest_mismatches.append(key)
        sockets = EXTENDED if name == "death_knight" else STANDARD
        missing_sockets = [k for k,v in sockets.items() if v not in lookup]
        if missing_sockets:
            errors.append(name + ": missing equipment socket bones " + ",".join(missing_sockets))
        if name != "death_knight" and (parent_mismatches or rest_mismatches or len(bones) != 8):
            errors.append(name + ": standard class rest skeleton diverges")
        if name == "death_knight" and len(bones) != 24:
            errors.append("Death Knight extended 24-bone skeleton changed")
        result.append({
            "class": name, "bone_count": len(bones),
            "shared_named_bones": sum(b in lookup for b in BASE),
            "base_parent_mismatches": parent_mismatches,
            "base_rest_mismatches": rest_mismatches,
            "required_sockets": len(sockets),
            "missing_socket_bones": missing_sockets,
            "compatible_with_standard_rest": not parent_mismatches and not rest_mismatches,
        })
    return {"valid": not errors, "errors": errors,
            "classes": result, "tolerance": tolerance,
            "retargeting_verified": False,
            "note": "Metadata comparison only. Runtime animations, bone weights and visual alignment remain unverified."}

def main():
    p = argparse.ArgumentParser()
    p.add_argument("inventory", type=Path)
    p.add_argument("--output", type=Path)
    args = p.parse_args()
    report = audit(json.loads(args.inventory.read_text(encoding="utf-8")))
    output = json.dumps(report, ensure_ascii=False, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(output, encoding="utf-8")
    print(output)
    if not report["valid"]:
        raise SystemExit(1)

if __name__ == "__main__":
    main()
