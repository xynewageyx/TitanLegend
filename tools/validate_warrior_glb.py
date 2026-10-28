"""Validate generated GLB structure without third-party dependencies.
Usage: python3 tools/validate_warrior_glb.py assets/models/heroes/class_0.glb
"""
import json
import struct
import sys
from pathlib import Path

def inspect(path: Path) -> dict:
    data = path.read_bytes()
    if len(data) < 20 or data[:4] != b"glTF":
        raise ValueError("Not a binary glTF (GLB)")
    version, total = struct.unpack_from("<II", data, 4)
    if version != 2 or total != len(data):
        raise ValueError("Invalid GLB version or length")
    chunk_size, chunk_type = struct.unpack_from("<I4s", data, 12)
    if chunk_type != b"JSON" or 20 + chunk_size > len(data):
        raise ValueError("Missing GLB JSON chunk")
    document = json.loads(data[20:20 + chunk_size].decode("utf-8"))
    meshes = document.get("meshes", [])
    nodes = document.get("nodes", [])
    if len(meshes) < 15 or len(nodes) < 15:
        raise ValueError("Warrior geometry is incomplete")
    names = {node.get("name", "").lower() for node in nodes}
    for part in ("breastplate", "helmet crown", "sword blade", "shield face"):
        if not any(part in name for name in names):
            raise ValueError(f"Missing warrior part: {part}")
    print(f"GLB OK: {len(meshes)} meshes, {len(nodes)} nodes, "
          f"{len(document.get('materials', []))} materials, "
          f"{len(document.get('animations', []))} animations")
    clips = {a.get("name", "").split("/")[-1] for a in document.get("animations", [])}
    expected = {"Idle", "Run", "Attack", "Hit", "Defeat"}
    if not expected.issubset(clips):
        raise ValueError(f"Missing prototype motion clips: {sorted(expected - clips)}")
    print("Prototype motion clips:", ", ".join(sorted(clips)))
    print("NOTICE: Object-level animations; skeletal rig and skinning still required.")
    return document

if __name__ == "__main__":
    inspect(Path(sys.argv[1]))
