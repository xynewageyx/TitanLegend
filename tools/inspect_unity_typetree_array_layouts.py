#!/usr/bin/env python3
"""Inspect TypeTree array layouts in a SerializedFile v21 without reading asset curves.

Outputs schema metadata only; useful for investigating Keyframe arrays and alignment.
"""
import argparse
import json
import struct
from pathlib import Path


def inspect_arrays(data):
    if len(data) < 32:
        raise ValueError("Truncated serialized file")
    metadata_size, file_size, version, data_offset = struct.unpack_from(">IIII", data)
    if version != 21 or file_size != len(data):
        raise ValueError("Expected complete SerializedFile v21")
    endian = "<" if data[16] == 0 else ">"
    if data_offset > len(data) or metadata_size > len(data):
        raise ValueError("Invalid SerializedFile boundaries")
    try:
        pos = data.index(b"\0", 20, min(len(data), 256)) + 1
    except ValueError as exc:
        raise ValueError("Missing Unity version terminator") from exc

    def read(fmt):
        nonlocal pos
        size = struct.calcsize(fmt)
        if pos + size > len(data):
            raise ValueError("Truncated metadata")
        result = struct.unpack_from(endian + fmt, data, pos)
        pos += size
        return result[0] if len(result) == 1 else result

    read("i")
    if not read("?"):
        raise ValueError("TypeTree disabled")
    count = read("i")
    if not 0 <= count <= 10000:
        raise ValueError("Invalid type count")
    clips = []
    for _ in range(count):
        cid = read("i")
        read("?")
        script_index = read("h")
        if cid == 114 or script_index >= 0:
            pos += 16
        pos += 16
        if pos > len(data):
            raise ValueError("Truncated type metadata")
        node_count, string_bytes = read("ii")
        if not 0 <= node_count <= 100000 or not 0 <= string_bytes <= len(data):
            raise ValueError("Invalid TypeTree dimensions")
        if pos + node_count * 32 + string_bytes > len(data):
            raise ValueError("Truncated TypeTree")
        raw_nodes = data[pos:pos + node_count * 32]
        pos += node_count * 32
        strings = data[pos:pos + string_bytes]
        pos += string_bytes
        dependencies = read("i")
        if not 0 <= dependencies <= 100000 or pos + dependencies * 4 > len(data):
            raise ValueError("Invalid dependencies")
        pos += dependencies * 4
        if cid != 74:
            continue
        nodes = []
        for i in range(node_count):
            _, level, _, type_off, name_off, size, index, flags, ref_hash = (
                struct.unpack_from(endian + "HBBIIiiiQ", raw_nodes, i * 32))
            if name_off & 0x80000000:
                name = f"common:0x{name_off & 0x7fffffff:x}"
            else:
                if name_off >= len(strings):
                    raise ValueError("Invalid name offset")
                try:
                    end = strings.index(b"\0", name_off)
                except ValueError as exc:
                    raise ValueError("Unterminated TypeTree name") from exc
                name = strings[name_off:end].decode("utf-8", "replace")
            nodes.append({"index": i, "level": level, "name": name,
                          "size": size, "flags": flags})
        arrays = []
        for i, node in enumerate(nodes):
            # Unity's common TypeTree string-table entry 0x31 is "Array".
            if i + 3 >= len(nodes) or nodes[i + 1]["name"] not in ("common:0x31", "Array"):
                continue
            child = nodes[i + 1]
            if child["level"] != node["level"] + 1:
                continue
            size_node, element_node = nodes[i + 2], nodes[i + 3]
            if (size_node["level"] != child["level"] + 1
                    or element_node["level"] != child["level"] + 1):
                continue
            j = i + 2
            while j < len(nodes) and nodes[j]["level"] > node["level"]:
                j += 1
            arrays.append({
                "parent": node, "array_node": child,
                "children": nodes[i + 2:j],
                "element": element_node,
            })
        clips.append({"nodes": len(nodes), "arrays": arrays})
    return {"clip_schemas": clips, "metadata_size": metadata_size,
            "data_offset": data_offset}


def main():
    p = argparse.ArgumentParser()
    p.add_argument("serialized_files", nargs="+", type=Path)
    p.add_argument("--output", type=Path)
    args = p.parse_args()
    result = {str(path): inspect_arrays(path.read_bytes())
              for path in args.serialized_files}
    output = json.dumps(result, indent=2) + "\n"
    if args.output:
        args.output.write_text(output, encoding="utf-8")
    print(output)


if __name__ == "__main__":
    main()
