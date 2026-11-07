"""Validate original Titan Legends chibi GLBs without third-party packages.

Default mode preserves the legacy eight-bone rig. Once the upgraded rig is
exported, run with --require-extended-rig to enforce the new attachment bones.
"""
import argparse
import json
import pathlib
import struct
import sys

NAMES = "warrior paladin druid shaman hunter rogue mage warlock summoner priest brawler death_knight".split()
LEGACY_BONES = {"Root", "Hips", "Spine", "Head", "Arm_L", "Arm_R", "Leg_L", "Leg_R"}
EXTENDED_BONES = {
    "Chest", "Neck", "Shoulder_L", "Shoulder_R",
    "UpperArm_L", "UpperArm_R", "Forearm_L", "Forearm_R",
    "Hand_L", "Hand_R", "UpperLeg_L", "UpperLeg_R",
    "LowerLeg_L", "LowerLeg_R", "Foot_L", "Foot_R",
}
EXPECTED_CLIPS = {"Idle", "Walk", "Attack", "Hit", "Dodge"}


def read_glb(path):
    raw = path.read_bytes()
    if len(raw) < 20 or raw[:4] != b"glTF":
        raise ValueError("invalid GLB header")
    version, length = struct.unpack_from("<II", raw, 4)
    if version != 2 or length != len(raw):
        raise ValueError("invalid GLB version or declared length")
    chunk_len, chunk_type = struct.unpack_from("<II", raw, 12)
    if chunk_type != 0x4E4F534A or chunk_len > len(raw) - 20:
        raise ValueError("missing or truncated JSON chunk")
    return json.loads(raw[20:20 + chunk_len])


def inspect(path, require_extended):
    doc = read_glb(path)
    errors = []
    nodes = doc.get("nodes", [])
    skins = doc.get("skins", [])
    animations = doc.get("animations", [])
    if not doc.get("meshes"):
        errors.append("no mesh")
    if not skins:
        errors.append("missing skeleton skin")
    if len(animations) != len(EXPECTED_CLIPS):
        errors.append(f"expected exactly {len(EXPECTED_CLIPS)} animations, got {len(animations)}")

    joint_indices = set()
    for skin in skins:
        for index in skin.get("joints", []):
            if not isinstance(index, int) or not 0 <= index < len(nodes):
                errors.append("skin references invalid joint node")
            else:
                joint_indices.add(index)
    joint_names = {nodes[i].get("name", "") for i in joint_indices}
    missing_legacy = LEGACY_BONES - joint_names
    if missing_legacy:
        errors.append("missing legacy joints: " + ", ".join(sorted(missing_legacy)))
    if require_extended:
        missing_extended = EXTENDED_BONES - joint_names
        if missing_extended:
            errors.append("missing extended joints: " + ", ".join(sorted(missing_extended)))

    clip_names = {clip.get("name", "") for clip in animations}
    # Blender may export NLA tracks with prefixes; accept e.g. 'ChibiRig|Idle'.
    normalized = {name.rsplit("|", 1)[-1] for name in clip_names}
    missing_clips = EXPECTED_CLIPS - normalized
    if missing_clips:
        errors.append("missing named clips: " + ", ".join(sorted(missing_clips)))

    for clip in animations:
        for channel in clip.get("channels", []):
            target = channel.get("target", {})
            idx = target.get("node")
            if idx is not None and (not isinstance(idx, int) or not 0 <= idx < len(nodes)):
                errors.append("animation channel targets invalid node")

    print(f"{path.stem}: skins={len(skins)} joints={len(joint_indices)} "
          f"animations={len(animations)} meshes={len(doc.get('meshes', []))}")
    return errors


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=pathlib.Path, default=pathlib.Path("assets/heroes/chibi"))
    parser.add_argument("--require-extended-rig", action="store_true")
    args = parser.parse_args()
    errors = []
    for name in NAMES:
        path = args.root / (name + ".glb")
        if not path.is_file():
            errors.append(f"{name}: missing GLB")
            continue
        try:
            for issue in inspect(path, args.require_extended_rig):
                errors.append(f"{name}: {issue}")
        except (OSError, ValueError, KeyError, json.JSONDecodeError) as exc:
            errors.append(f"{name}: {exc}")
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    print("All 12 chibi GLBs passed structural and rig validation")
    return 0


if __name__ == "__main__":
    sys.exit(main())
