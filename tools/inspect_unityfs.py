#!/usr/bin/env python3
"""Inspect UnityFS bundle metadata without extracting copyrighted assets.

Requires: pip install lz4
Usage: python tools/inspect_unityfs.py path/to/bundle.prefab_ab
"""
import argparse
import json
import struct
from pathlib import Path

import lz4.block


def inspect(path):
    data = Path(path).read_bytes()
    if not data.startswith(b"UnityFS\0"):
        raise ValueError("Not a UnityFS file")
    pos = 8
    version = struct.unpack_from(">I", data, pos)[0]
    pos += 4

    def cstr():
        nonlocal pos
        end = data.index(0, pos)
        result = data[pos:end].decode("utf-8")
        pos = end + 1
        return result

    player = cstr()
    unity = cstr()
    total, compressed, uncompressed, flags = struct.unpack_from(">QIII", data, pos)
    pos += 20
    if total != len(data):
        raise ValueError("Bundle size mismatch")
    if version >= 7:
        pos = (pos + 15) & ~15
    info = data[-compressed:] if flags & 0x80 else data[pos:pos + compressed]
    codec = flags & 0x3f
    if codec in (2, 3):
        info = lz4.block.decompress(info, uncompressed_size=uncompressed)
    elif codec != 0:
        raise ValueError(f"Unsupported block-info codec {codec}")
    if len(info) != uncompressed:
        raise ValueError("Block info size mismatch")

    off = 16  # UnityFS block-info hash
    count = struct.unpack_from(">I", info, off)[0]
    off += 4
    blocks = []
    for _ in range(count):
        u, c, f = struct.unpack_from(">IIH", info, off)
        off += 10
        blocks.append((u, c, f))
    nodes = struct.unpack_from(">I", info, off)[0]
    off += 4
    entries = []
    for _ in range(nodes):
        offset, size, nflags = struct.unpack_from(">QQI", info, off)
        off += 20
        end = info.index(0, off)
        name = info[off:end].decode("utf-8", "replace")
        off = end + 1
        entries.append({"name": name, "offset": offset, "size": size, "flags": nflags})
    # Verify directory ranges before reporting them as valid.
    data_length = sum(x[0] for x in blocks)
    for entry in entries:
        if entry["offset"] + entry["size"] > data_length:
            raise ValueError("UnityFS entry exceeds decompressed data region")

    return {
        "file": Path(path).name,
        "unity": unity,
        "player": player,
        "format": version,
        "blocks": len(blocks),
        "decompressed_bytes": sum(x[0] for x in blocks),
        "entries": entries,
        "block_codecs": [x[2] & 0x3f for x in blocks],
        "metadata_at_end": bool(flags & 0x80),
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("files", nargs="+")
    args = parser.parse_args()
    for name in args.files:
        print(json.dumps(inspect(name), ensure_ascii=False))
