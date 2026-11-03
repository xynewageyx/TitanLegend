#!/usr/bin/env python3
"""List Unity SerializedFile v21 object classes without exporting asset contents.

Input: a *decompressed* Unity SerializedFile, not a UnityFS wrapper.
Only Unity format 21 with TypeTree enabled is supported.
"""
import argparse
from collections import Counter
import json
from pathlib import Path
import struct

CLASS_NAMES = {
    1: "GameObject", 4: "Transform", 23: "MeshRenderer",
    33: "MeshFilter", 43: "Mesh", 74: "AnimationClip",
    90: "Avatar", 95: "Animator", 137: "SkinnedMeshRenderer",
    142: "AssetBundle", 221: "AnimatorOverrideController",
}


class Reader:
    def __init__(self, data, offset, endian):
        self.data, self.offset, self.endian = data, offset, endian

    def read(self, fmt):
        size = struct.calcsize(fmt)
        if self.offset + size > len(self.data):
            raise ValueError("Truncated SerializedFile metadata")
        result = struct.unpack_from(self.endian + fmt, self.data, self.offset)
        self.offset += size
        return result[0] if len(result) == 1 else result

    def skip(self, size):
        if size < 0 or self.offset + size > len(self.data):
            raise ValueError("Invalid SerializedFile metadata length")
        self.offset += size

    def cstring(self):
        end = self.data.find(b"\0", self.offset)
        if end < 0:
            raise ValueError("Unterminated SerializedFile string")
        value = self.data[self.offset:end].decode("utf-8", "replace")
        self.offset = end + 1
        return value

    def align(self):
        self.offset = (self.offset + 3) & ~3


def inspect_serialized(data):
    if len(data) < 32:
        raise ValueError("Truncated SerializedFile header")
    metadata_size, file_size, version, data_offset = struct.unpack_from(">IIII", data)
    if version != 21:
        raise ValueError("Only SerializedFile version 21 is supported")
    if file_size != len(data) or data_offset > file_size or metadata_size + 20 > file_size:
        raise ValueError("Invalid SerializedFile size or offset")
    endian_byte = data[16]
    if endian_byte not in (0, 1):
        raise ValueError("Invalid endianness")
    r = Reader(data, 20, "<" if endian_byte == 0 else ">")
    unity = r.cstring()
    platform = r.read("i")
    if not r.read("?"):
        raise ValueError("SerializedFile has no TypeTree")
    count = r.read("i")
    if count < 0 or count > 10000:
        raise ValueError("Invalid type count")
    types = []
    for _ in range(count):
        class_id = r.read("i")
        r.read("?")  # is stripped
        script_index = r.read("h")
        if class_id == 114 or script_index >= 0:
            r.skip(16)  # script hash
        r.skip(16)  # type hash
        node_count, string_bytes = r.read("ii")
        if not 0 <= node_count <= 100000 or not 0 <= string_bytes <= len(data):
            raise ValueError("Invalid TypeTree length")
        r.skip(node_count * 32 + string_bytes)
        dependency_count = r.read("i")
        if not 0 <= dependency_count <= 100000:
            raise ValueError("Invalid dependency count")
        r.skip(dependency_count * 4)
        types.append(class_id)
    object_count = r.read("i")  # no alignment before count
    if not 0 <= object_count <= 1000000:
        raise ValueError("Invalid object count")
    objects = Counter()
    for _ in range(object_count):
        r.align()
        r.read("q")  # path ID
        byte_start, byte_size, type_index = r.read("IIi")
        if type_index < 0 or type_index >= len(types):
            raise ValueError("Invalid object type index")
        if data_offset + byte_start + byte_size > file_size:
            raise ValueError("Object extends beyond SerializedFile")
        objects[types[type_index]] += 1
    if r.offset > metadata_size + 20:
        raise ValueError("Object directory extends beyond metadata")
    return {
        "unity": unity, "platform": platform, "serialized_version": version,
        "object_count": object_count,
        "classes": {f"{cid}:{CLASS_NAMES.get(cid, 'Unknown')}": n
                    for cid, n in sorted(objects.items())},
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("files", nargs="+")
    args = parser.parse_args()
    for filename in args.files:
        print(json.dumps({"file": Path(filename).name,
                          **inspect_serialized(Path(filename).read_bytes())},
                         ensure_ascii=False))
