#!/usr/bin/env python3
"""Read UnityFS v7 / SerializedFile v21 AnimationClip values without exporting curves.

Crucial Unity TypeTree rule: for an array, apply alignment flags from BOTH
the parent field and its child Array node. This fixes the 21 previously
misparsed clips with non-four-byte-aligned string lengths.
Requires lz4; accepts local, authorized reference bundles only.
"""
import argparse
from collections import Counter
import json
from pathlib import Path
import struct

try:
    from tools.inspect_unity_animation_clip_headers import decode_bundle
except ModuleNotFoundError:
    from inspect_unity_animation_clip_headers import decode_bundle


def aligned(position):
    return (position + 3) & ~3


def array_needs_alignment(nodes, i, end):
    return (bool(nodes[i][3] & 0x4000)
            or (i + 1 < end and nodes[i + 1][1] in ("#0x31", "Array")
                and bool(nodes[i + 1][3] & 0x4000)))


def parse_clip(obj, nodes):
    pos = 0
    counts = Counter()
    values = {}
    length = len(obj)

    def subtree_end(i):
        j = i + 1
        while j < len(nodes) and nodes[j][0] > nodes[i][0]:
            j += 1
        return j

    def walk(i, depth=0):
        nonlocal pos
        if depth > 80:
            raise ValueError("TypeTree recursion limit")
        level, name, size, flags = nodes[i]
        end = subtree_end(i)
        if i + 1 < end and nodes[i + 1][1] in ("#0x31", "Array"):
            if pos + 4 > length:
                raise ValueError(f"Truncated array count at {name}")
            count = struct.unpack_from("<i", obj, pos)[0]
            pos += 4
            if count < 0 or count > 10_000_000:
                raise ValueError(f"Invalid array count at {name}: {count}")
            counts[name] += count
            element = i + 3
            if element >= end:
                raise ValueError(f"Missing array element at {name}")
            if nodes[element][2] > 0 and subtree_end(element) == element + 1:
                endpos = pos + count * nodes[element][2]
                if endpos > length:
                    raise ValueError(f"Array exceeds clip bounds at {name}")
                pos = endpos
            else:
                for _ in range(count):
                    walk(element, depth + 1)
        elif i + 1 < end:
            child = i + 1
            while child < end:
                walk(child, depth + 1)
                child = subtree_end(child)
        else:
            if size < 0 or pos + size > length:
                raise ValueError(f"Truncated field {name} at {pos}")
            if name in ("m_SampleRate", "m_StartTime", "m_StopTime") and size == 4:
                values.setdefault(name, []).append(struct.unpack_from("<f", obj, pos)[0])
            pos += size
        if array_needs_alignment(nodes, i, end):
            pos = aligned(pos)
        if pos > length:
            raise ValueError(f"Alignment exceeds clip bounds at {name}")
    walk(0)
    if pos != length:
        raise ValueError(f"Clip not fully consumed: {pos}/{length}")
    return {"bytes": length, "consumed": pos, "values": values,
            "counts": dict(counts)}


def parse_serialized(data):
    if len(data) < 32:
        return []
    metadata_size, file_size, version, data_offset = struct.unpack_from(">IIII", data)
    if version != 21 or file_size != len(data) or not 20 <= metadata_size <= data_offset <= len(data):
        raise ValueError("Expected valid SerializedFile v21")
    if data[16] != 0:
        raise ValueError("Only little-endian SerializedFile supported")
    pos = data.index(b"\0", 20, metadata_size) + 1

    def rd(fmt):
        nonlocal pos
        n = struct.calcsize(fmt)
        if pos + n > metadata_size:
            raise ValueError("Truncated metadata")
        result = struct.unpack_from("<" + fmt, data, pos)
        pos += n
        return result[0] if len(result) == 1 else result

    rd("i")
    if not rd("?"):
        raise ValueError("TypeTree required")
    type_count = rd("i")
    if not 0 <= type_count <= 10000:
        raise ValueError("Invalid type count")
    types = []
    for _ in range(type_count):
        class_id = rd("i")
        rd("?")
        script_index = rd("h")
        if class_id == 114 or script_index >= 0:
            pos += 16
        pos += 16
        node_count, string_size = rd("ii")
        if not 0 <= node_count <= 100000 or not 0 <= string_size <= metadata_size:
            raise ValueError("Invalid TypeTree dimensions")
        if pos + node_count * 32 + string_size > metadata_size:
            raise ValueError("Truncated TypeTree nodes")
        raw = data[pos:pos + node_count * 32]
        pos += node_count * 32
        strings = data[pos:pos + string_size]
        pos += string_size
        dependencies = rd("i")
        if not 0 <= dependencies <= 100000 or pos + 4 * dependencies > metadata_size:
            raise ValueError("Invalid dependencies")
        pos += 4 * dependencies
        if class_id != 74:
            types.append((class_id, None))
            continue
        nodes = []
        for i in range(node_count):
            _, level, _, _, name_offset, size, _, flags, _ = struct.unpack_from(
                "<HBBIIiiiQ", raw, i * 32)
            if name_offset & 0x80000000:
                name = "#0x%x" % (name_offset & 0x7fffffff)
            else:
                if name_offset >= len(strings):
                    raise ValueError("Invalid name offset")
                stop = strings.index(b"\0", name_offset)
                name = strings[name_offset:stop].decode("utf-8", "replace")
            nodes.append((level, name, size, flags))
        types.append((class_id, nodes))
    object_count = rd("i")
    if not 0 <= object_count <= 100000:
        raise ValueError("Invalid object count")
    results = []
    for _ in range(object_count):
        pos = aligned(pos)
        path_id, offset, size, type_index = rd("qIIi")
        if not 0 <= type_index < len(types):
            raise ValueError("Invalid object type index")
        class_id, nodes = types[type_index]
        if class_id != 74:
            continue
        if data_offset + offset + size > len(data):
            raise ValueError("Clip outside SerializedFile")
        results.append(parse_clip(data[data_offset + offset:data_offset + offset + size], nodes))
    return results


def inspect_bundle(path):
    data, segments = decode_bundle(path.read_bytes())
    clips = []
    for offset, size, _ in segments:
        clips.extend(parse_serialized(data[offset:offset + size]))
    return clips


def main():
    p = argparse.ArgumentParser()
    p.add_argument("bundles", nargs="+", type=Path)
    p.add_argument("--output", type=Path)
    args = p.parse_args()
    rows = []
    errors = []
    for path in args.bundles:
        try:
            for clip in inspect_bundle(path):
                rows.append({"file": path.name, **clip})
        except Exception as exc:
            errors.append({"file": path.name, "error": str(exc)})
    report = {"files": len(args.bundles), "decoded": len(rows),
              "errors": errors, "rows": rows}
    output = json.dumps(report, ensure_ascii=False, indent=2) + "\n"
    if args.output:
        args.output.write_text(output, encoding="utf-8")
    print(f"Decoded {len(rows)} clips; {len(errors)} failed")
    if errors:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
