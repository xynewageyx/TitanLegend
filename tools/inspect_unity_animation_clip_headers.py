#!/usr/bin/env python3
"""Inspect AnimationClip headers from extracted UnityFS files; metadata only.

Requires lz4. UnityFS v7, SerializedFile v21 only. Does not export keyframes.
"""
import argparse
from collections import Counter
import json
from pathlib import Path
import struct
import lz4.block


def read_cstr(data, pos):
    end = data.index(b'\0', pos)
    return data[pos:end].decode('utf-8', 'replace'), end + 1


def decode_bundle(data):
    if not data.startswith(b'UnityFS\0'):
        raise ValueError('Not UnityFS')
    pos = 8
    version = struct.unpack_from('>I', data, pos)[0]
    pos += 4
    if version != 7:
        raise ValueError('Expected UnityFS v7')
    _, pos = read_cstr(data, pos)
    _, pos = read_cstr(data, pos)
    total, compressed, unpacked, flags = struct.unpack_from('>QIII', data, pos)
    pos = (pos + 20 + 15) & ~15
    if total != len(data) or flags & 0x80:
        raise ValueError('Unsupported bundle metadata placement')
    if flags & 63 not in (2, 3):
        raise ValueError('Expected LZ4 bundle metadata')
    meta = lz4.block.decompress(data[pos:pos + compressed],
                                uncompressed_size=unpacked)
    pos += compressed
    cursor = 16
    block_count = struct.unpack_from('>I', meta, cursor)[0]
    cursor += 4
    blocks = []
    for _ in range(block_count):
        blocks.append(struct.unpack_from('>IIH', meta, cursor))
        cursor += 10
    node_count = struct.unpack_from('>I', meta, cursor)[0]
    cursor += 4
    nodes = []
    for _ in range(node_count):
        offset, size, _ = struct.unpack_from('>QQI', meta, cursor)
        cursor += 20
        name, cursor = read_cstr(meta, cursor)
        nodes.append((offset, size, name))
    result = bytearray()
    for raw_size, packed_size, block_flags in blocks:
        chunk = data[pos:pos + packed_size]
        pos += packed_size
        if len(chunk) != packed_size:
            raise ValueError('Truncated UnityFS data block')
        kind = block_flags & 63
        if kind in (2, 3):
            chunk = lz4.block.decompress(chunk, uncompressed_size=raw_size)
        elif kind != 0:
            raise ValueError('Unsupported UnityFS block compression')
        result.extend(chunk)
    return bytes(result), nodes


def clip_headers(bundle):
    data, nodes = decode_bundle(bundle)
    results = []
    for start, size, _ in nodes:
        serialized = data[start:start + size]
        if len(serialized) < 32:
            continue
        metadata, file_size, version, data_offset = struct.unpack_from('>IIII', serialized)
        if version != 21 or file_size != len(serialized):
            continue
        endian = '<' if serialized[16] == 0 else '>'
        pos = 20
        _, pos = read_cstr(serialized, pos)
        def rd(fmt):
            nonlocal pos
            value = struct.unpack_from(endian + fmt, serialized, pos)
            pos += struct.calcsize(fmt)
            return value[0] if len(value) == 1 else value
        rd('i')
        if not rd('?'):
            raise ValueError('TypeTree required')
        types = []
        for _ in range(rd('i')):
            cid = rd('i')
            rd('?')
            script = rd('h')
            if cid == 114 or script >= 0:
                pos += 16
            pos += 16
            node_count, strings_size = rd('ii')
            pos += node_count * 32 + strings_size
            pos += 4 * rd('i')
            types.append(cid)
        for _ in range(rd('i')):
            pos = (pos + 3) & ~3
            _, offset, obj_size, type_idx = rd('qIIi')
            if types[type_idx] != 74:
                continue
            obj = serialized[data_offset + offset:data_offset + offset + obj_size]
            if len(obj) != obj_size or len(obj) < 12:
                raise ValueError('Truncated AnimationClip')
            name_len = struct.unpack_from(endian + 'I', obj)[0]
            if name_len > obj_size - 7:
                raise ValueError('Invalid clip name length')
            name = obj[4:4 + name_len].decode('utf-8')
            flag_offset = (4 + name_len + 3) & ~3
            legacy, compressed, quality = obj[flag_offset:flag_offset + 3]
            results.append({'name': name, 'bytes': obj_size,
                            'legacy': bool(legacy), 'compressed': bool(compressed),
                            'high_quality_curve': bool(quality)})
    return results


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('bundles', nargs='+', type=Path)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    rows = []
    for file in args.bundles:
        for clip in clip_headers(file.read_bytes()):
            rows.append({'bundle': file.name, **clip})
    summary = {'files': len(args.bundles), 'clips': len(rows),
               'legacy_clips': sum(row['legacy'] for row in rows),
               'compressed_clips': sum(row['compressed'] for row in rows),
               'details': rows}
    output = json.dumps(summary, indent=2, ensure_ascii=False) + '\n'
    if args.output:
        args.output.write_text(output, encoding='utf-8')
    print(output)


if __name__ == '__main__':
    main()
