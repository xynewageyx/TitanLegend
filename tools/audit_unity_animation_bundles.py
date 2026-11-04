#!/usr/bin/env python3
"""Audit UnityFS animation bundles without exporting copyrighted clip data.

Requires Python package lz4. Supports the observed UnityFS v7 / SerializedFile
v21 layout; rejects other formats instead of silently guessing.
"""
import argparse
from collections import Counter
import json
from pathlib import Path
import struct
import lz4.block

from inspect_unity_objects import inspect_serialized


def unpack_unityfs(data):
    if not data.startswith(b"UnityFS\0"):
        raise ValueError("Not a UnityFS bundle")
    pos = len(b"UnityFS\0")
    version = struct.unpack_from(">I", data, pos)[0]
    pos += 4
    if version != 7:
        raise ValueError(f"Unsupported UnityFS version {version}")
    for _ in range(2):
        pos = data.index(b"\0", pos) + 1
    size, compressed, uncompressed, flags = struct.unpack_from(">QIII", data, pos)
    pos = (pos + 20 + 15) & ~15
    if size != len(data):
        raise ValueError("UnityFS file size mismatch")
    start = len(data) - compressed if flags & 0x80 else pos
    block = data[start:start + compressed]
    if len(block) != compressed:
        raise ValueError("Truncated UnityFS metadata")
    if flags & 63 in (2, 3):
        meta = lz4.block.decompress(block, uncompressed_size=uncompressed)
    elif flags & 63 == 0:
        meta = block
    else:
        raise ValueError("Unsupported metadata compression")
    if not flags & 0x80:
        pos = start + compressed
    offset = 16
    block_count = struct.unpack_from(">I", meta, offset)[0]
    offset += 4
    blocks = []
    for _ in range(block_count):
        blocks.append(struct.unpack_from(">IIH", meta, offset))
        offset += 10
    node_count = struct.unpack_from(">I", meta, offset)[0]
    offset += 4
    for _ in range(node_count):
        _, name_len, _ = struct.unpack_from(">QQI", meta, offset)
        offset += 20 + name_len
    output = bytearray()
    for raw_size, packed_size, block_flags in blocks:
        raw = data[pos:pos + packed_size]
        pos += packed_size
        kind = block_flags & 63
        if kind in (2, 3):
            output.extend(lz4.block.decompress(raw, uncompressed_size=raw_size))
        elif kind == 0:
            output.extend(raw)
        else:
            raise ValueError(f"Unsupported data compression {kind}")
    return bytes(output)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("files", type=Path, nargs="+")
    p.add_argument("--output", type=Path)
    a = p.parse_args()
    entries = []
    for file in a.files:
        record = inspect_serialized(unpack_unityfs(file.read_bytes()))
        entries.append({"file": file.name, **record})
    classes = Counter()
    for entry in entries:
        classes.update(entry["classes"])
    report = {"bundles": len(entries), "class_totals": dict(classes),
              "objects": sum(e["object_count"] for e in entries),
              "details": entries}
    output = json.dumps(report, indent=2, ensure_ascii=False) + "\n"
    if a.output:
        a.output.write_text(output, encoding="utf-8")
    print(output)


if __name__ == "__main__":
    main()
