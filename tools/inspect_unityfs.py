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

    # Decode only the blocks needed for the first embedded SerializedFile header.
    # UnityFS stores block payloads immediately after the block-info region
    # unless its block-info table is at the end of the bundle.
    data_start = pos if flags & 0x80 else pos + compressed
    prefix = bytearray()
    cursor = data_start
    for raw_size, stored_size, block_flags in blocks:
        if len(prefix) >= 64:
            break
        payload = data[cursor:cursor + stored_size]
        if len(payload) != stored_size:
            raise ValueError("Truncated UnityFS data block")
        compression = block_flags & 0x3f
        if compression in (2, 3):
            decoded = lz4.block.decompress(payload, uncompressed_size=raw_size)
        elif compression == 0:
            decoded = payload
        else:
            raise ValueError(f"Unsupported data-block codec {compression}")
        if len(decoded) != raw_size:
            raise ValueError("Data block size mismatch")
        prefix.extend(decoded[:max(0, 64 - len(prefix))])
        cursor += stored_size

    serialized = None
    if entries and entries[0]["offset"] == 0 and len(prefix) >= 20:
        metadata_size, file_size, format_version, data_offset = struct.unpack_from(">IIII", prefix)
        if 5 <= format_version <= 21 and file_size <= data_length and data_offset <= file_size:
            endian = prefix[16]
            if endian in (0, 1):
                serialized = {
                    "metadata_bytes": metadata_size,
                    "file_bytes": file_size,
                    "format_version": format_version,
                    "data_offset": data_offset,
                    "endianness": "little" if endian == 0 else "big",
                }

    return {
        "serialized_file": serialized,
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
