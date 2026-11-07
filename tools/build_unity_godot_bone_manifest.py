#!/usr/bin/env python3
"""Create a safe Godot 4 skeleton mapping candidate manifest from verified mesh hashes.

Does not distribute original meshes, clips, keyframes or claim retargeting success.
"""
import argparse
import json
from pathlib import Path


def make_manifest(report):
    rows = report.get("records", [])
    if len(rows) != report.get("unique_mesh_bone_hashes"):
        raise ValueError("Expected one record per unique mesh bone hash")
    seen_hashes = set()
    seen_names = set()
    bones = []
    for row in rows:
        name = row["name"]
        hash_value = row["hash"]
        if not isinstance(name, str) or not name:
            raise ValueError("Empty bone name")
        if not isinstance(hash_value, int) or not 0 <= hash_value < 2**32:
            raise ValueError("Invalid CRC32 hash")
        if name in seen_names or hash_value in seen_hashes:
            raise ValueError("Duplicate name or hash")
        seen_names.add(name)
        seen_hashes.add(hash_value)
        clips = row.get("clips", [])
        if len(set(clips)) != row["clip_count"]:
            raise ValueError("Inconsistent clip count")
        bones.append({
            "unity_bone_name": name,
            "unity_path_crc32": hash_value,
            "observed_clip_count": row["clip_count"],
            "godot_bone_name": None,
            "verified_transform_path": None,
            "retarget_status": "pending_hierarchy_and_rest_pose_validation",
        })
    if report.get("matched_animation_hashes") != len(bones):
        raise ValueError("Mesh/animation hash match count differs")
    return {
        "schema_version": 1,
        "target_engine": "Godot 4.7.2",
        "source": "Verified mesh-bone vs AnimationClip path CRC32 metadata",
        "verified_hash_matches": len(bones),
        "ready_for_animation_playback": False,
        "notes": [
            "CRC32 overlap is not a verified full Transform path.",
            "Do not infer Godot bone names or bind poses from names alone.",
            "Original Unity meshes and animation curves are not included.",
        ],
        "bones": sorted(bones, key=lambda x: x["unity_bone_name"]),
    }


def main():
    p = argparse.ArgumentParser()
    p.add_argument("mesh_animation_crosscheck", type=Path)
    p.add_argument("--output", type=Path, required=True)
    args = p.parse_args()
    report = json.loads(args.mesh_animation_crosscheck.read_text(encoding="utf-8"))
    result = make_manifest(report)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n",
                           encoding="utf-8")
    print(f"Prepared {len(result['bones'])} verified hash candidates for Godot")


if __name__ == "__main__":
    main()
