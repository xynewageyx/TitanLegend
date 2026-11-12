#!/usr/bin/env python3
"""Verify boss-framing screenshots from the genuine Godot CameraFollow boss branch."""
import argparse
import json
from pathlib import Path

def validate(report):
    issues=[]
    if not report.get("valid",False) or report.get("hero_count") != 4:
        issues.append("Missing four-hero boss QA")
    if report.get("source_camera") != "res://scripts/camera_follow.gd":
        issues.append("Not using production camera-follow script")
    if report.get("boss_art_source") != "res://scripts/boss_art.gd":
        issues.append("Not using original procedural boss models")
    if report.get("boss_motion_source") != "res://scripts/boss_motion.gd":
        issues.append("Not using original boss warning motion")
    if report.get("screenshots") != 4:
        issues.append("Expected 4 boss preview screenshots")
    if report.get("real_android_device_tested") is not False or report.get("hud_production_validated") is not False:
        issues.append("Do not claim a real Android or production HUD test")
    cases=report.get("scenarios",[])
    if len(cases)!=2 or [x.get("scenario") for x in cases]!=["fire","earth"]:
        issues.append("Expected fire and earth original Titan boss variants")
    for item in cases:
        name=item.get("scenario","?")
        for key in ("boss_body_box","boss_warning_box"):
            box=item.get(key,{})
            if not box.get("valid"):
                issues.append(f"{name} {key}: boss off camera")
                continue
            if not 0.0 <= float(box.get("viewport_fraction",-1)) <= 1.0:
                issues.append(f"{name} {key}: invalid viewport measurement")
            width=float(box.get("bbox_px",[0,0,0,0])[2])
            height=float(box.get("bbox_px",[0,0,0,0])[3])
            if width < 25 or height < 40:
                issues.append(f"{name} {key}: boss silhouette too small")
        hero_boxes=item.get("hero_boxes",[])
        if len(hero_boxes)!=4:
            issues.append(f"{name}: missing 4 heroes")
        for i,hero in enumerate(hero_boxes):
            if not hero.get("valid") or float(hero.get("viewport_fraction",0)) < 0.80:
                issues.append(f"{name}: hero {i} is not sufficiently visible")
        if not item.get("boss_warning_visible"):
            issues.append(f"{name}: real warning ring inactive")
        if float(item.get("fov_degrees",0))!=56.0:
            issues.append(f"{name}: wrong gameplay field of view")
        for key,suffix in (("idle_image","idle"),("windup_image","windup")):
            if item.get(key) != f"boss_{name}_{suffix}.png":
                issues.append(f"{name}: missing {suffix} capture")
    return {"valid":not issues,"errors":issues,
        "note":"Original boss art and camera branch, but HUD is a diagnostic mock and Android is untested"}

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument("file",type=Path)
    args=parser.parse_args()
    output=validate(json.loads(args.file.read_text(encoding="utf-8")))
    print(json.dumps(output,ensure_ascii=False,indent=2))
    if not output["valid"]:
        raise SystemExit(1)
if __name__=="__main__":
    main()
