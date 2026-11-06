#!/usr/bin/env python3
"""Read-only, aggregate UnityFS metadata audit. Never exports source assets."""
import argparse
import json
from collections import Counter
from pathlib import Path

TYPES = ("Mesh", "AnimationClip", "Animator", "SkinnedMeshRenderer", "Material", "GameObject", "Avatar")
MAGIC = (b"UnityFS", b"UnityWeb", b"UnityRaw")


def number(obj, *names):
    for name in names:
        try:
            value = getattr(obj, name)
            if isinstance(value, (int, float)) and not isinstance(value, bool):
                return float(value)
        except (AttributeError, ValueError, TypeError):
            pass
    return None


def audit(root, max_bytes, max_files):
    import UnityPy
    totals = Counter()
    metrics = {"vertices": [], "bones": [], "clip_seconds": [], "clip_fps": []}
    errors = Counter()
    scanned = 0
    candidates = 0
    for path in sorted(root.rglob("*")):
        if not path.is_file():
            continue
        candidates += 1
        try:
            if path.stat().st_size > max_bytes:
                errors["oversize"] += 1
                continue
            with path.open("rb") as handle:
                if not handle.read(16).startswith(MAGIC):
                    continue
            if max_files and scanned >= max_files:
                break
            scanned += 1
            env = UnityPy.load(str(path))
            for obj in env.objects:
                typ = obj.type.name
                if typ not in TYPES:
                    continue
                totals[typ] += 1
                if typ not in ("Mesh", "AnimationClip", "SkinnedMeshRenderer"):
                    continue
                try:
                    data = obj.read()
                    if typ == "Mesh":
                        value = number(data, "m_VertexCount", "vertex_count")
                        if value is not None and value >= 0:
                            metrics["vertices"].append(int(value))
                    elif typ == "SkinnedMeshRenderer":
                        bones = getattr(data, "m_Bones", None)
                        if bones is not None:
                            metrics["bones"].append(len(bones))
                    elif typ == "AnimationClip":
                        duration = number(data, "m_StopTime")
                        start = number(data, "m_StartTime") or 0
                        if duration is not None and duration >= start:
                            metrics["clip_seconds"].append(round(duration - start, 4))
                        fps = number(data, "m_SampleRate")
                        if fps is not None and fps > 0:
                            metrics["clip_fps"].append(round(fps, 2))
                except Exception:
                    errors["object_read_failed"] += 1
        except Exception:
            errors["bundle_read_failed"] += 1

    def summarize(values):
        if not values:
            return {"count": 0}
        return {"count": len(values), "min": min(values), "max": max(values),
                "mean": round(sum(values) / len(values), 3)}

    return {
        "format": "aggregate UnityFS audit v1",
        "candidate_files": candidates,
        "scanned_bundles": scanned,
        "object_types": dict(sorted(totals.items())),
        "metrics": {key: summarize(values) for key, values in metrics.items()},
        "errors": dict(sorted(errors.items())),
        "limitations": [
            "Bone count is SkinnedMeshRenderer bone-reference count, not validated skeleton hierarchy.",
            "Clip duration uses m_StopTime minus m_StartTime when available.",
            "Only aggregate metadata is retained; no names, curves, geometry or textures."
        ],
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("root", type=Path)
    parser.add_argument("--output", type=Path, default=Path("ulala_aggregate_audit.json"))
    parser.add_argument("--max-files", type=int, default=0)
    parser.add_argument("--max-bytes", type=int, default=250 * 1024 * 1024)
    args = parser.parse_args()
    if not args.root.is_dir():
        parser.error("root must be an extracted directory")
    if args.max_files < 0 or args.max_bytes <= 0:
        parser.error("invalid scan limits")
    try:
        result = audit(args.root, args.max_bytes, args.max_files)
    except ImportError:
        parser.error("UnityPy missing: pip install UnityPy")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, indent=2), encoding="utf-8")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
