#!/usr/bin/env python3
"""Read GameObject/Transform links from decompressed Unity SerializedFile v21.

Metadata only. Does not export meshes, textures, avatars or animations.
Usage: python tools/inspect_unity_hierarchy.py path/to/decompressed.assets
"""
import argparse
import json
import struct
from pathlib import Path
from inspect_unity_objects import Reader, inspect_serialized


def hierarchy(data):
    inspect_serialized(data)  # validate header and object ranges first
    metadata_size, file_size, version, data_offset = struct.unpack_from(">IIII", data)
    endian = "<" if data[16] == 0 else ">"
    r = Reader(data, 20, endian)
    r.cstring()
    r.read("i")
    r.read("?")
    type_count = r.read("i")
    types = []
    for _ in range(type_count):
        cid = r.read("i")
        r.read("?")
        script_index = r.read("h")
        if cid == 114 or script_index >= 0:
            r.skip(16)
        r.skip(16)
        nodes, strings = r.read("ii")
        r.skip(nodes * 32 + strings)
        r.skip(r.read("i") * 4)
        types.append(cid)
    count = r.read("i")
    records = {}
    for _ in range(count):
        r.align()
        pid = r.read("q")
        start, length, type_index = r.read("IIi")
        if pid in records:
            raise ValueError("Duplicate path ID")
        records[pid] = (types[type_index], data[data_offset + start:data_offset + start + length])
    def ptr(raw, offset):
        if offset + 12 > len(raw):
            raise ValueError("Truncated PPtr")
        return struct.unpack_from(endian + "iq", raw, offset)
    names = {}
    components = {}
    for pid, (cid, raw) in records.items():
        if cid != 1:
            continue
        if len(raw) < 12:
            raise ValueError("Truncated GameObject")
        n = struct.unpack_from(endian + "i", raw)[0]
        if not 0 <= n <= 10000 or 4 + 12*n + 8 > len(raw):
            raise ValueError("Invalid GameObject component count")
        refs = [ptr(raw, 4 + i*12) for i in range(n)]
        off = 4 + 12*n + 4  # m_Layer
        size = struct.unpack_from(endian + "i", raw, off)[0]
        off += 4
        if size < 0 or off + size > len(raw):
            raise ValueError("Invalid GameObject name length")
        names[pid] = raw[off:off+size].decode("utf-8", "replace")
        components[pid] = refs
    transforms = {}
    for pid, (cid, raw) in records.items():
        if cid != 4:
            continue
        if len(raw) < 68:
            raise ValueError("Truncated Transform")
        game_object = ptr(raw, 0)
        child_count = struct.unpack_from(endian + "i", raw, 52)[0]
        if not 0 <= child_count <= 10000 or 68 + 12*child_count > len(raw):
            raise ValueError("Invalid Transform children array")
        children = [ptr(raw, 56 + 12*i) for i in range(child_count)]
        father = ptr(raw, 56 + 12*child_count)
        transforms[pid] = {
            "game_object": {"file_id": game_object[0], "path_id": game_object[1],
                            "name": names.get(game_object[1]) if game_object[0] == 0 else None},
            "children": [{"file_id": f, "path_id": p} for f, p in children],
            "father": {"file_id": father[0], "path_id": father[1]},
        }
    return {
        "game_objects": len(names), "transforms": len(transforms),
        "nodes": [{"transform_path_id": pid, **value} for pid, value in transforms.items()],
        "unresolved_internal_children": [
            {"parent": pid, "child": c["path_id"]}
            for pid, node in transforms.items() for c in node["children"]
            if c["file_id"] == 0 and c["path_id"] not in transforms
        ],
    }


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("files", nargs="+")
    args = p.parse_args()
    for filename in args.files:
        print(json.dumps({"file": Path(filename).name, **hierarchy(Path(filename).read_bytes())},
                         ensure_ascii=False, indent=2))
