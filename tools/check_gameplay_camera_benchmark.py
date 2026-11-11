#!/usr/bin/env python3
"""Validate live gameplay perspective-capture and honest Linux frame timing."""
import argparse
import json
from pathlib import Path

def validate(data):
    errors = []
    camera = data.get("camera", {})
    bench = data.get("benchmark", {})
    captures = data.get("captures", [])
    if not data.get("valid"):
        errors.append("Unsuccessful gameplay render capture")
    if camera.get("source_script") != "res://scripts/camera_follow.gd":
        errors.append("Not using actual gameplay camera script")
    if camera.get("projection") != "perspective":
        errors.append("Gameplay camera must be perspective")
    if abs(float(camera.get("fov_degrees", 0)) - 56.0) > 0.1:
        errors.append("Gameplay camera field of view changed")
    if len(captures) != 2 or [x.get("pose") for x in captures] != ["idle","attack"]:
        errors.append("Expected Idle and Attack gameplay frames")
    for capture in captures:
        if capture.get("frame_width") != 720 or capture.get("frame_height") != 1280:
            errors.append("Unexpected portrait image dimensions")
        if len(capture.get("body_visibility", [])) != 4:
            errors.append("Missing class visibility measurements")
        if not 0 <= float(capture.get("minimum_body_viewport_fraction", -1)) <= 1:
            errors.append("Invalid body viewport fraction")
    if bench.get("measured_frames") != 90 or bench.get("warmup_frames") != 20:
        errors.append("Insufficient measured render frames")
    for metric in ("mean_frame_ms", "median_frame_ms", "p95_frame_ms", "estimated_mean_fps"):
        if not 0 < float(bench.get(metric, 0)) < 100000:
            errors.append("Missing or invalid "+metric)
    if bench.get("real_android_device_tested") is not False:
        errors.append("Linux CI timing cannot be labeled Android device tested")
    if not str(bench.get("renderer", "")).find("Mesa") >= 0:
        errors.append("Runner renderer must be documented")
    return {"valid": not errors, "errors": errors, "warning": "CI render timings are not real Android FPS"}

def main():
    p=argparse.ArgumentParser()
    p.add_argument("report",type=Path)
    args=p.parse_args()
    result=validate(json.loads(args.report.read_text(encoding="utf-8")))
    print(json.dumps(result,indent=2))
    if not result["valid"]:
        raise SystemExit(1)
if __name__=="__main__":
    main()
