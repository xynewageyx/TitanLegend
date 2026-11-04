#!/usr/bin/env python3
"""Validate explicit Unity-to-Godot Skeleton3D bone mappings (metadata only)."""
import argparse
import json
from pathlib import Path


def validate(candidates, skeleton, mapping):
    errors = []
    expected = {b["unity_path_crc32"]: b for b in candidates["bones"]}
    if len(expected) != len(candidates["bones"]):
        errors.append("Duplicate candidate CRC32")
    bones = skeleton["bones"]
    names = [b["name"] for b in bones]
    if len(set(names)) != len(names):
        errors.append("Duplicate Skeleton3D bone names")
    parents = {b["name"]: b.get("parent") for b in bones}
    for name, parent in parents.items():
        if parent is not None and parent not in parents:
            errors.append(f"Unknown parent for {name}: {parent}")
        visited = set()
        node = name
        while node is not None and node in parents:
            if node in visited:
                errors.append(f"Parent cycle involving {name}")
                break
            visited.add(node)
            node = parents[node]
    assigned = {}
    used_targets = set()
    for entry in mapping["mappings"]:
        h, target = entry["unity_path_crc32"], entry["godot_bone_name"]
        if h not in expected:
            errors.append(f"Unknown Unity CRC32: {h}")
        if h in assigned:
            errors.append(f"Duplicate Unity mapping: {h}")
        if target not in parents:
            errors.append(f"Unknown Godot bone: {target}")
        if target in used_targets:
            errors.append(f"Duplicate Godot target: {target}")
        assigned[h] = target
        used_targets.add(target)
    return {
        "valid": not errors,
        "candidate_bones": len(expected),
        "mapped_bones": len(set(assigned) & set(expected)),
        "unmapped_hashes": sorted(set(expected) - set(assigned)),
        "errors": sorted(set(errors)),
        "rest_pose_verified": False,
        "animation_playback_verified": False,
        "note": "Checks hierarchy integrity, not rest-pose transforms.",
    }


def main():
    p = argparse.ArgumentParser()
    p.add_argument("candidates", type=Path)
    p.add_argument("skeleton", type=Path)
    p.add_argument("mapping", type=Path)
    p.add_argument("--output", type=Path)
    args = p.parse_args()
    data = [json.loads(path.read_text(encoding="utf-8"))
            for path in (args.candidates, args.skeleton, args.mapping)]
    result = validate(*data)
    output = json.dumps(result, ensure_ascii=False, indent=2) + "\n"
    if args.output:
        args.output.write_text(output, encoding="utf-8")
    print(output)
    if not result["valid"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
