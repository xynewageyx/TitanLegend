#!/usr/bin/env python3
"""Inspect Unity SerializedFile v21 TypeTree field paths without exporting assets.

Input is a *decompressed SerializedFile*, not a UnityFS container.
Example: python tools/inspect_unity_typetree.py sample.assets --class-id 43 --filter BindPose
"""
import argparse
import json
import struct
from pathlib import Path

from inspect_unity_objects import Reader, inspect_serialized


def type_tree_paths(data, class_id=43, field_filter=None):
    inspect_serialized(data)
    endian = "<" if data[16] == 0 else ">"
    r = Reader(data, 20, endian)
    r.cstring()
    r.read("i")  # target platform
    r.read("?")  # enable type tree
    count = r.read("i")
    matches = []
    for _ in range(count):
        cid = r.read("i")
        r.read("?")
        script_index = r.read("h")
        if cid == 114 or script_index >= 0:
            r.skip(16)
        r.skip(16)
        node_count, string_size = r.read("ii")
        if node_count < 0 or node_count > 100000 or string_size < 0:
            raise ValueError("Invalid TypeTree lengths")
        nodes = []
        for _ in range(node_count):
            version, level, flags, type_off, name_off, size, index, meta, ref_hash = r.read("hBBIIiiiQ")
            nodes.append((level, type_off, name_off, size, meta))
        strings = data[r.offset:r.offset + string_size]
        r.skip(string_size)
        deps = r.read("i")
        if deps < 0 or deps > 100000:
            raise ValueError("Invalid type dependency count")
        r.skip(4 * deps)
        if cid != class_id:
            continue
        def decode(offset):
            if offset & 0x80000000:
                return "common:0x%08x" % (offset & 0x7fffffff)
            if offset >= len(strings):
                raise ValueError("TypeTree string offset outside buffer")
            end = strings.find(b"\0", offset)
            if end < 0:
                raise ValueError("Unterminated TypeTree string")
            return strings[offset:end].decode("utf-8", "replace")
        ancestors = []
        for level, type_off, name_off, size, meta in nodes:
            if level > len(ancestors):
                raise ValueError("TypeTree depth jumps unexpectedly")
            ancestors = ancestors[:level]
            name = decode(name_off)
            ancestors.append(name)
            path = "/".join(ancestors)
            if not field_filter or field_filter.lower() in path.lower():
                matches.append({"path": path, "type": decode(type_off),
                                "byte_size": size, "meta_flags": meta})
    return {"class_id": class_id, "matching_fields": matches}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("file", type=Path)
    parser.add_argument("--class-id", type=int, default=43)
    parser.add_argument("--filter", default=None)
    args = parser.parse_args()
    print(json.dumps(type_tree_paths(args.file.read_bytes(), args.class_id, args.filter),
                     indent=2, ensure_ascii=False))
