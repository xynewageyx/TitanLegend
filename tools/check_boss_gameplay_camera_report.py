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
    if report.get("hud_widget_source") != "res://scripts/ui_manager.gd" or not report.get("hud_production_widgets_rendered"):
        issues.append("Boss camera does not render production UIManager widgets")
    if report.get("hud_battle_state_live") is not False:
        issues.append("QA fixture cannot claim live BattleManager data")
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
            if float(box.get("viewport_fraction",-1)) < 0.98:
                issues.append(f"{name} {key}: boss clipped beyond 2 percent")
            if int(box.get("behind_vertices",-1)) != 0:
                issues.append(f"{name} {key}: boss corners behind camera")
            width=float(box.get("bbox_px",[0,0,0,0])[2])
            height=float(box.get("bbox_px",[0,0,0,0])[3])
            if width < 25 or height < 40:
                issues.append(f"{name} {key}: boss silhouette too small")
        hero_boxes=item.get("hero_boxes",[])
        if len(hero_boxes)!=4:
            issues.append(f"{name}: missing 4 heroes")
        for i,hero in enumerate(hero_boxes):
            if not hero.get("valid") or float(hero.get("viewport_fraction",0)) < 0.98 or int(hero.get("behind_vertices",-1)) != 0:
                issues.append(f"{name}: hero {i} is not sufficiently visible")
        # Ensure the warning does not intersect the four body bounding boxes.
        # This is a portrait-composition check, not a claim about the real HUD.
        warning_box=item.get("boss_warning_box", {})
        bb=warning_box.get("bbox_px", [0,0,0,0])
        if len(bb)==4:
            boss_top=float(bb[1])
            boss_bottom=float(bb[1])+float(bb[3])
            if boss_top < 180:
                issues.append(f"{name}: boss silhouette overlaps QA HUD safety zone")
            if hero_boxes:
                top_of_team=min(
                    float(h.get("bbox_px",[0,0,0,0])[1])
                    for h in hero_boxes if h.get("valid")
                ) if any(h.get("valid") for h in hero_boxes) else 0
                if top_of_team-boss_bottom < 20:
                    issues.append(f"{name}: boss warning lacks 20px visual gap above front row")
        if int(item.get("windup_changed_pixels_without_hud_text", 0)) < 20:
            issues.append(f"{name}: no real windup pixel change without HUD text")
        hud=item.get("hud_layout",{})
        warning=item.get("hud_warning_layout",{})
        if not all(hud.get(key) is True for key in ("boss_health_visible","boss_timer_visible","chat_visible")):
            issues.append(f"{name}: real HUD widgets not visible")
        if not str(hud.get("boss_timer_text","")).startswith("Boss-Zeit:"):
            issues.append(f"{name}: production countdown label missing")
        if not str(warning.get("boss_name","")).find("Unterbrechen") >= 0:
            issues.append(f"{name}: production boss warning label missing")
        if hud.get("source_script") != "res://scripts/ui_manager.gd":
            issues.append(f"{name}: HUD layout does not originate from UIManager")
        for component in ("boss_panel_rect","chat_panel_rect"):
            rect=hud.get(component,[])
            if len(rect)!=4 or float(rect[2])<=0 or float(rect[3])<=0:
                issues.append(f"{name}: invalid production {component}")
                continue
            if float(rect[0])<0 or float(rect[1])<0 or float(rect[0])+float(rect[2])>721 or float(rect[1])+float(rect[3])>1281:
                issues.append(f"{name}: production {component} extends outside portrait viewport")
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
