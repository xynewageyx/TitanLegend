#!/usr/bin/env python3
"""Validate exported Skeleton3D inventory before publishing a CI artifact."""
import argparse
import json
import math
from pathlib import Path


def validate(data):
    errors = []
    skeletons = data.get("skeletons", [])
    if not skeletons:
        errors.append("No Skeleton3D nodes exported")
    if data.get("warnings"):
        errors.extend("Exporter warning: " + str(w) for w in data["warnings"])
    for skeleton in skeletons:
        scene = skeleton.get("scene", "<unknown>")
        bones = skeleton.get("bones", [])
        if not bones:
            errors.append(f"{scene}: skeleton contains no bones")
        names = [b.get("name") for b in bones]
        if len(names) != len(set(names)):
            errors.append(f"{scene}: duplicate bone names")
        parent_map = {b.get("name"): b.get("parent") for b in bones}
        for name in names:
            visited = set()
            current = name
            while current is not None and current in parent_map:
                if current in visited:
                    errors.append(f"{scene}: parent cycle involving {name}")
                    break
                visited.add(current)
                current = parent_map[current]
        for b in bones:
            name = b.get("name")
            parent = b.get("parent")
            if parent is not None and parent not in names:
                errors.append(f"{scene}: {name} missing parent {parent}")
            index = b.get("index")
            parent_index = b.get("parent_index")
            if not isinstance(index, int) or index < 0:
                errors.append(f"{scene}: {name} invalid bone index")
            if parent is None and parent_index != -1:
                errors.append(f"{scene}: {name} invalid root parent index")
            if parent is not None and (not isinstance(parent_index, int) or parent_index < 0 or parent_index >= len(bones)):
                errors.append(f"{scene}: {name} invalid parent index")
            elif parent is not None and bones[parent_index].get("name") != parent:
                errors.append(f"{scene}: {name} parent index/name mismatch")
            origin = b.get("rest_origin", [])
            basis = b.get("rest_basis", [])
            if len(origin) != 3 or len(basis) != 3 or any(len(row) != 3 for row in basis):
                errors.append(f"{scene}: {name} invalid rest transform dimensions")
                continue
            try:
                if not all(math.isfinite(float(v)) for v in origin + [v for row in basis for v in row]):
                    errors.append(f"{scene}: {name} nonfinite rest transform")
            except (ValueError, TypeError):
                errors.append(f"{scene}: {name} nonnumeric rest transform")
    return {"valid": not errors, "skeleton_count": len(skeletons),
            "bone_count": sum(len(s.get("bones", [])) for s in skeletons),
            "errors": errors, "unity_retargeting_verified": False}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("inventory", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    report = validate(json.loads(args.inventory.read_text(encoding="utf-8")))
    rendered = json.dumps(report, indent=2) + "\n"
    if args.output:
        args.output.write_text(rendered, encoding="utf-8")
    print(rendered)
    if not report["valid"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
