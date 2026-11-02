"""Validate the Blender-generated GLB without third-party Python packages."""
import json
import struct
import sys
from pathlib import Path

path = Path(sys.argv[1] if len(sys.argv) > 1 else "/tmp/grasland.glb")
raw = path.read_bytes()
assert len(raw) >= 20, "GLB too small"
magic, version, total = struct.unpack_from("<4sII", raw)
assert magic == b"glTF" and version == 2, "Invalid GLB v2 header"
assert total == len(raw), "GLB declared length differs from actual size"
chunk_length, chunk_type = struct.unpack_from("<I4s", raw, 12)
assert chunk_type == b"JSON", "First GLB chunk must be JSON"
assert 20 + chunk_length <= len(raw), "Truncated JSON chunk"
document = json.loads(raw[20:20 + chunk_length])
names = [node.get("name", "") for node in document.get("nodes", [])]
required = ("Continuous meadow ground", "River", "Ancient tree trunk", "Boss clearing")
for name in required:
    assert name in names, f"Missing landmark: {name}"
for prefix, minimum in (("Tree trunk", 44), ("Stone ", 65), ("Grass tuft", 170), ("Flower ", 75), ("Path segment", 55)):
    count = sum(name.startswith(prefix) for name in names)
    assert count >= minimum, f"{prefix}: expected >= {minimum}, got {count}"
assert len(document.get("meshes", [])) > 0, "GLB contains no meshes"
assert len(document.get("materials", [])) >= 8, "Insufficient material variety"
print(f"Landscape GLB OK: {len(names)} nodes, {len(document['meshes'])} meshes, {len(document['materials'])} materials")
