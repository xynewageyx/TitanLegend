#!/usr/bin/env python3
"""Report actual triangle and vertex counts from generated GLB files.

Reports mesh-resource counts and scene-node instanced triangle counts separately. GLTF TRIANGLES
mode=4, TRIANGLE_STRIP=5 and TRIANGLE_FAN=6 are handled separately; points/lines
are not counted. Indexed and non-indexed primitives are supported.
"""
import argparse
import csv
import json
import struct
from pathlib import Path

def analyze(path):
    raw = path.read_bytes()
    if len(raw) < 20 or raw[:4] != b"glTF":
        raise ValueError(f"Invalid GLB: {path}")
    magic, version, total = struct.unpack_from("<4sII", raw)
    if version != 2 or total != len(raw):
        raise ValueError(f"Invalid GLB version/length: {path}")
    length, chunk_type = struct.unpack_from("<II", raw, 12)
    if chunk_type != 0x4E4F534A or 20 + length > len(raw):
        raise ValueError(f"Invalid JSON chunk: {path}")
    doc = json.loads(raw[20:20 + length])
    accessors = doc.get("accessors", [])
    def count(index):
        if not isinstance(index, int) or index < 0 or index >= len(accessors):
            raise ValueError(f"Invalid accessor index in {path}: {index}")
        return int(accessors[index]["count"])
    vertices = triangles = primitives = 0
    mesh_triangles = []
    unsupported = []
    for mesh in doc.get("meshes", []):
        mesh_triangle_count = 0
        for primitive in mesh.get("primitives", []):
            attrs = primitive.get("attributes", {})
            if "POSITION" not in attrs:
                raise ValueError(f"Missing POSITION in {path}")
            nverts = count(attrs["POSITION"])
            nindices = count(primitive["indices"]) if "indices" in primitive else nverts
            mode = primitive.get("mode", 4)
            vertices += nverts
            primitives += 1
            if mode == 4:
                if nindices % 3:
                    raise ValueError(f"Triangle indices not divisible by 3 in {path}")
                triangles += nindices // 3
                mesh_triangle_count += nindices // 3
            elif mode in (5, 6):
                triangles += max(0, nindices - 2)
                mesh_triangle_count += max(0, nindices - 2)
            else:
                unsupported.append(str(mode))
        mesh_triangles.append(mesh_triangle_count)
    mesh_instances = 0
    scene_triangles = 0
    for node in doc.get("nodes", []):
        mesh_index = node.get("mesh")
        if mesh_index is not None:
            if not isinstance(mesh_index, int) or not 0 <= mesh_index < len(mesh_triangles):
                raise ValueError(f"Invalid mesh reference in {path}: {mesh_index}")
            mesh_instances += 1
            scene_triangles += mesh_triangles[mesh_index]
    return dict(file=path.name, meshes=len(doc.get("meshes", [])),
                primitives=primitives, vertices=vertices, triangles=triangles,
                mesh_instances=mesh_instances, scene_triangles=scene_triangles,
                nodes=len(doc.get("nodes", [])), skins=len(doc.get("skins", [])),
                animations=len(doc.get("animations", [])),
                non_triangle_modes=";".join(unsupported))

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    paths = sorted(args.input.glob("*.glb"))
    if not paths:
        parser.error("No GLB files found")
    rows = [analyze(path) for path in paths]
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    for row in rows:
        print(f"{row['file']}: {row['vertices']} vertices, {row['triangles']} triangles, {row['animations']} animations")
    print(f"TOTAL: {sum(r['triangles'] for r in rows)} triangles across {len(rows)} GLBs")

if __name__ == "__main__":
    main()
