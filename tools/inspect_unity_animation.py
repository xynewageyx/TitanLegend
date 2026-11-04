#!/usr/bin/env python3
"""Metadata-only UnityFS AnimationClip inspector.

Usage: python tools/inspect_unity_animation.py /path/to/extracted/bundles --output report.json
Requires: pip install UnityPy
Do not commit or redistribute reference bundle payloads.
"""
import argparse
import json
from pathlib import Path

def inspect(root: Path):
    try:
        import UnityPy
    except ImportError as exc:
        raise SystemExit("UnityPy is required: pip install UnityPy") from exc
    report = []
    for path in sorted(root.rglob("*")):
        if not path.is_file() or path.suffix.lower() not in (".anim_ab", ".prefab_ab", ".overridecontroller_ab"):
            continue
        row = {"file": path.name, "objects": [], "error": None}
        try:
            env = UnityPy.load(str(path))
            for obj in env.objects:
                if obj.type.name not in ("AnimationClip", "AnimatorOverrideController", "AnimatorController", "GameObject"):
                    continue
                item = {"type": obj.type.name, "path_id": str(obj.path_id)}
                try:
                    tree = obj.read_typetree()
                    item["name"] = tree.get("m_Name", "")
                    if obj.type.name == "AnimationClip":
                        item["legacy"] = tree.get("m_Legacy")
                        item["sample_rate"] = tree.get("m_SampleRate")
                        item["wrap_mode"] = tree.get("m_WrapMode")
                        muscle = tree.get("m_MuscleClip", {})
                        if isinstance(muscle, dict):
                            item["start_time"] = muscle.get("m_StartTime")
                            item["stop_time"] = muscle.get("m_StopTime")
                            start = item["start_time"]
                            stop = item["stop_time"]
                            if isinstance(start, (int, float)) and isinstance(stop, (int, float)) and stop >= start:
                                item["duration_seconds"] = round(stop - start, 6)
                        curve_keys = (
                            "m_RotationCurves", "m_PositionCurves", "m_ScaleCurves",
                            "m_FloatCurves", "m_PPtrCurves"
                        )
                        item["curve_count"] = sum(
                            len(tree.get(k, [])) for k in curve_keys
                        )
                        item["curve_paths"] = sorted({
                            curve["path"]
                            for key in curve_keys
                            for curve in tree.get(key, [])
                            if isinstance(curve, dict)
                            and isinstance(curve.get("path"), str)
                        })
                        item["animated_path_count"] = len(item["curve_paths"])
                        item["curve_keyframe_counts"] = {
                            key: sum(
                                len(curve.get("curve", {}).get("m_Curve", []))
                                for curve in tree.get(key, [])
                                if isinstance(curve, dict)
                                and isinstance(curve.get("curve"), dict)
                            )
                            for key in curve_keys
                        }
                    elif obj.type.name == "AnimatorOverrideController":
                        item["clip_override_count"] = len(tree.get("m_Clips", []))
                except Exception as exc:
                    item["read_error"] = str(exc)[:200]
                row["objects"].append(item)
        except Exception as exc:
            row["error"] = str(exc)[:300]
        report.append(row)
    return report

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("bundle_dir", type=Path)
    parser.add_argument("--output", type=Path, default=Path("animation_metadata.json"))
    args = parser.parse_args()
    result = inspect(args.bundle_dir)
    args.output.write_text(json.dumps(result, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"Inspected {len(result)} bundles; report: {args.output}")
