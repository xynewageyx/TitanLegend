#!/usr/bin/env python3
"""Read-only, aggregate audit of potential external activation of Plain flower groups.

Requires a locally extracted, lawfully held plain.unity_ab and UnityPy.
No proprietary bytes, coordinates, script bodies, or individual path IDs are exported.
This is reference analysis, not proof of runtime execution.
"""
import argparse
import json
from collections import Counter
from pathlib import Path

TARGETS = ("hua_001_group", "hua_002_group")


def pointer_ids(value):
    """Find explicit Unity PPtr path references, not arbitrary numeric values."""
    if isinstance(value, dict):
        path_id = value.get("m_PathID")
        file_id = value.get("m_FileID", value.get("m_FileId"))
        if isinstance(path_id, int) and isinstance(file_id, int):
            yield (file_id, path_id)
        for child in value.values():
            yield from pointer_ids(child)
    elif isinstance(value, (tuple, list)):
        for child in value:
            yield from pointer_ids(child)


def display_type(obj):
    return str(getattr(getattr(obj, "type", None), "name", "Unknown"))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--scene", type=Path, required=True, help="Original extracted plain.unity_ab")
    p.add_argument("--output", type=Path, required=True, help="Aggregate JSON report")
    args = p.parse_args()
    if not args.scene.is_file():
        p.error("Scene file does not exist")
    try:
        import UnityPy
    except ImportError as exc:
        p.error("UnityPy required (pip install UnityPy)")

    try:
        env = UnityPy.load(str(args.scene))
    except Exception as exc:
        p.error(f"Cannot open input scene: {type(exc).__name__}: {exc}")
    objects = list(env.objects)
    go_ids = set()
    transform_ids = set()
    group_counts = Counter()
    unreadable = Counter()
    gameobjects_total = 0
    for obj in objects:
        if display_type(obj) != "GameObject":
            continue
        gameobjects_total += 1
        try:
            record = obj.read_typetree()
        except Exception:
            unreadable["GameObject"] += 1
            continue
        name = record.get("m_Name", "")
        if name not in TARGETS:
            continue
        group_counts[name] += 1
        go_ids.add(int(obj.path_id))
        for component in record.get("m_Component", []):
            for file_id, path_id in pointer_ids(component):
                if file_id == 0:
                    transform_ids.add(path_id)

    if sum(group_counts.values()) != 10:
        raise SystemExit(
            "UNVERIFIED: expected 10 flower groups, got "
            + str(dict(group_counts)) + "; no conclusive report written"
        )

    targets = go_ids | transform_ids
    matches = Counter()
    reference_classes = Counter()
    scanned = Counter()
    totals = Counter()
    potential_clips = Counter()
    for obj in objects:
        cls = display_type(obj)
        if cls not in ("MonoBehaviour", "AnimationClip", "Animator",
                       "AnimatorController", "PlayableDirector"):
            continue
        totals[cls] += 1
        try:
            tree = obj.read_typetree()
        except Exception:
            unreadable[cls] += 1
            continue
        scanned[cls] += 1
        refs = set(pointer_ids(tree))
        if any(fid == 0 and pid in targets for fid, pid in refs):
            reference_classes[cls] += 1
            if cls == "MonoBehaviour":
                matches[cls] += 1
        if cls == "AnimationClip":
            # Animation binding names alone are leads, not runtime evidence.
            clip_repr = str(tree.get("m_Name", "")).lower()
            if "hua_" in clip_repr or "flower" in clip_repr:
                potential_clips["name_heuristic_only"] += 1

    report = {
        "status": "reference_scan_only",
        "scene_file": args.scene.name,
        "groups_found_by_name": dict(group_counts),
        "group_total": sum(group_counts.values()),
        "gameobjects_total": gameobjects_total,
        "gameobjects_scanned": gameobjects_total - unreadable["GameObject"],
        "gameobject_scan_complete": unreadable["GameObject"] == 0,
        "target_gameobjects": len(go_ids),
        "candidate_component_ids": len(transform_ids),
        "component_classes_total": dict(totals),
        "component_classes_scanned": dict(scanned),
        "objects_with_direct_local_references_by_class": dict(reference_classes),
        "monobehaviour_scan_complete": unreadable["MonoBehaviour"] == 0,
        "unreadable_type_trees": dict(unreadable),
        "monobehaviours_with_direct_local_pptr_to_group_or_component": matches["MonoBehaviour"],
        "animation_clip_name_leads_only": dict(potential_clips),
        "activation_proven": False,
        "result_interpretation": (
            "partial_scan_unreadable_objects" if any(unreadable.values()) else
            "direct_reference_candidates_found" if any(reference_classes.values()) else
            "no_direct_references_in_scanned_classes"
        ),
        "limitations": [
            "A direct PPtr reference does not establish that SetActive(true) executes.",
            "Zero direct references cannot exclude dynamic name searches or loaded scenes.",
            "Serialized clip bindings, animation state machines and managed runtime code are not fully analyzed.",
            "Only locally stored pointers (m_FileID==0) are compared.",
            "Readability of the TypeTree is necessary to identify serialized references.",
            "Objects in other UnityFS bundles may reference this scene indirectly."
        ]
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False))


if __name__ == "__main__":
    main()
