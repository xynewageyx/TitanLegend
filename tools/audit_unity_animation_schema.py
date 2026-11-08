#!/usr/bin/env python3
"""Inspect Unity AnimationClip TypeTree schemas without exporting animation data.

Supports the observed UnityFS v7 bundles and SerializedFile v21. For raw
UnityFS unpacking, use the project's existing inspect_unityfs utilities.
This module audits TypeTree metadata in an already-unpacked SerializedFile.
"""
import argparse
from collections import Counter
import json
from pathlib import Path
import struct


FIELDS = {"m_SampleRate", "m_StartTime", "m_StopTime", "m_LoopTime",
          "m_ClipBindingConstant", "genericBindings", "m_DenseClip",
          "m_StreamedClip", "m_MuscleClip", "m_RotationCurves",
          "m_PositionCurves", "m_Events"}


def inspect(data):
    if len(data) < 32:
        raise ValueError("Truncated serialized file")
    _, file_size, version, _ = struct.unpack_from(">IIII", data)
    if version != 21 or file_size != len(data):
        raise ValueError("Expected complete SerializedFile v21")
    endian = "<" if data[16] == 0 else ">"
    pos = 20
    end = data.index(b"\0", pos)
    unity = data[pos:end].decode("utf-8", "replace")
    pos = end + 1

    def read(fmt):
        nonlocal pos
        result = struct.unpack_from(endian + fmt, data, pos)
        pos += struct.calcsize(fmt)
        return result[0] if len(result) == 1 else result

    read("i")
    if not read("?"):
        raise ValueError("TypeTree disabled")
    count = read("i")
    if not 0 <= count <= 10000:
        raise ValueError("Invalid type count")
    schemas = []
    for _ in range(count):
        cid = read("i")
        read("?")
        script_index = read("h")
        if cid == 114 or script_index >= 0:
            pos += 16
        pos += 16
        node_count = read("i")
        string_bytes = read("i")
        if not 0 <= node_count <= 100000 or not 0 <= string_bytes <= len(data):
            raise ValueError("Invalid TypeTree length")
        nodes = data[pos:pos + node_count * 32]
        pos += node_count * 32
        strings = data[pos:pos + string_bytes]
        pos += string_bytes
        dependency_count = read("i")
        if not 0 <= dependency_count <= 100000:
            raise ValueError("Invalid dependency count")
        pos += dependency_count * 4
        if cid != 74:
            continue
        fields = []
        for index in range(node_count):
            _, level, _, type_offset, name_offset, size, _, _, _ = (
                struct.unpack_from(endian + "HBBIIiiiQ", nodes, index * 32))
            if name_offset & 0x80000000:
                continue
            if name_offset >= len(strings):
                raise ValueError("Invalid TypeTree string offset")
            end = strings.index(b"\0", name_offset)
            name = strings[name_offset:end].decode("utf-8", "replace")
            if name in FIELDS:
                fields.append((level, name, size))
        schemas.append(fields)
    return {"unity": unity, "animation_clip_types": len(schemas),
            "fields": schemas}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("serialized_files", nargs="+", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    results = [inspect(path.read_bytes()) for path in args.serialized_files]
    schemas = Counter(json.dumps(item["fields"], sort_keys=True) for item in results)
    report = {"files": len(results), "distinct_schemas": len(schemas),
              "schema_counts": sorted(schemas.values(), reverse=True),
              "sample_rate_fields_per_file": [
                  sum(field[1] == "m_SampleRate" for group in item["fields"]
                      for field in group) for item in results],
              "binding_fields_per_file": [
                  sum(field[1] == "genericBindings" for group in item["fields"]
                      for field in group) for item in results]}
    output = json.dumps(report, indent=2) + "\n"
    if args.output:
        args.output.write_text(output, encoding="utf-8")
    print(output)


if __name__ == "__main__":
    main()
