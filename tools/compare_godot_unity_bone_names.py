#!/usr/bin/env python3
"""Compare a Godot Skeleton3D inventory with verified Unity bone-name candidates.

Name matches are suggestions only; never automatically authorize retargeting.
"""
import argparse
import json
from pathlib import Path


def compare(candidates, inventory):
    candidate_bones = candidates["bones"]
    skeletons = []
    for skeleton in inventory.get("skeletons", []):
        bones = skeleton["bones"]
        names = [b["name"] for b in bones]
        if len(names) != len(set(names)):
            raise ValueError("Duplicate bone names in " + skeleton["scene"])
        name_set = set(names)
        matches = [
            {"unity_path_crc32": b["unity_path_crc32"],
             "unity_bone_name": b["unity_bone_name"],
             "godot_bone_name": b["unity_bone_name"],
             "status": "name_only_unverified"}
            for b in candidate_bones if b["unity_bone_name"] in name_set
        ]
        skeletons.append({
            "scene": skeleton["scene"],
            "node_path": skeleton["node_path"],
            "godot_bone_count": len(bones),
            "name_match_count": len(matches),
            "name_matches": matches,
            "missing_unity_bone_names": sorted(
                b["unity_bone_name"] for b in candidate_bones
                if b["unity_bone_name"] not in name_set),
            "rest_pose_verified": False,
            "animation_playback_verified": False,
        })
    return {
        "schema_version": 1,
        "unity_candidate_count": len(candidate_bones),
        "godot_skeleton_count": len(skeletons),
        "skeletons": skeletons,
        "notes": "Name matches are unverified suggestions. Confirm paths, rest pose and animation playback before assigning mappings.",
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("candidates", type=Path)
    parser.add_argument("inventory", type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    result = compare(
        json.loads(args.candidates.read_text(encoding="utf-8")),
        json.loads(args.inventory.read_text(encoding="utf-8")))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print("Compared %d Godot skeletons against %d Unity bone names" %
          (result["godot_skeleton_count"], result["unity_candidate_count"]))


if __name__ == "__main__":
    main()
