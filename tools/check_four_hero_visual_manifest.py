#!/usr/bin/env python3
"""Validate four-hero original Godot OpenGL QA manifest.

Projected bounds are conservative, not proof of pixel occlusion or collision.
"""
import argparse
import json
from pathlib import Path

ACTIONS = ("idle", "walk", "attack", "dodge")
EXPECTED_CLASSES = ["warrior", "mage", "death_knight", "druid"]


def audit(manifest):
    frames = [r for r in manifest.get("renders", []) if r.get("class") == "formation"]
    errors = []
    result = []
    if len(frames) != 4:
        errors.append(f"Expected four formation screenshots, got {len(frames)}")
    by_pose = {}
    for frame in frames:
        pose = frame.get("pose", "")
        if pose in by_pose:
            errors.append(f"Duplicate formation pose {pose}")
        by_pose[pose] = frame
    for pose in ACTIONS:
        frame = by_pose.get(pose)
        if frame is None:
            errors.append("Missing formation pose " + pose)
            continue
        if frame.get("hero_count") != 4 or frame.get("weapon_anchors") != 4:
            errors.append(pose + ": missing heroes or weapon attachments")
        if frame.get("class_ids") != [0, 6, 11, 2]:
            errors.append(pose + ": unexpected class lineup")
        vis = frame.get("screen_visibility", {})
        body = vis.get("body_frames", [])
        if len(body) != 4 or [b.get("class") for b in body] != EXPECTED_CLASSES:
            errors.append(pose + ": unexpected body visibility set")
        full = float(vis.get("minimum_body_viewport_fraction", 0))
        if full < 0.95 or not vis.get("valid", False):
            errors.append(pose + f": body out of portrait frame (fraction={full})")
        effects = [x for x in vis.get("pet_effect_frames", []) if x.get("category") == "effect"]
        pets = [x for x in vis.get("pet_effect_frames", []) if x.get("category") == "pet"]
        if len(pets) != 4:
            errors.append(pose + f": expected four visible pet bboxes, got {len(pets)}")
        if pose == "attack":
            differential = vis.get("pixel_differential", {})
            if not differential.get("valid", False):
                errors.append("attack: missing real pixel-difference analysis")
            categories = differential.get("categories", {})
            for category in ("weapon", "pet", "effect"):
                stats = categories.get(category, {})
                if not stats.get("valid", False):
                    errors.append(f"attack: missing {category} counterfactual metrics")
                    continue
                if int(stats.get("total_pixels", 0)) <= 0:
                    errors.append(f"attack: invalid {category} pixel dimensions")
                if not 0 <= int(stats.get("changed_pixels", -1)) <= int(stats.get("total_pixels", -1)):
                    errors.append(f"attack: invalid {category} changed pixel count")
                if len(stats.get("body_regions", [])) != 4:
                    errors.append(f"attack: incomplete {category} body region breakdown")
                if stats.get("counterfactual_image") != f"formation_mythic_attack_without_{category}.png":
                    errors.append(f"attack: wrong {category} counterfactual filename")
        expected_fx = 4 if pose == "attack" else 0
        if len(effects) != expected_fx:
            errors.append(pose + f": expected {expected_fx} visible attack FX bboxes, got {len(effects)}")
        result.append({
            "pose": pose, "body_viewport_fraction": full,
            "body_bbox_overlap": vis.get("maximum_pair_bbox_overlap"),
            "weapon_to_other_body_bbox_overlap": vis.get("max_weapon_vs_other_body_bbox_overlap"),
            "pet_to_other_body_bbox_overlap": vis.get("max_pet_vs_other_body_bbox_overlap"),
            "attack_fx_to_body_bbox_overlap": vis.get("max_effect_vs_body_bbox_overlap"),
            "pet_count": len(pets), "active_attack_fx_count": len(effects),
            "pixel_differential": vis.get("pixel_differential") if pose == "attack" else None
        })
    return {
        "valid": not errors, "errors": errors, "actions": result,
        "measurement_type": "projected mesh bounding-box intersections, not actual pixels",
        "real_android_device_tested": False
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    report = audit(json.loads(args.manifest.read_text(encoding="utf-8")))
    rendered = json.dumps(report, indent=2, ensure_ascii=False) + "\n"
    print(rendered)
    if args.output is not None:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(rendered, encoding="utf-8")
    if not report["valid"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
