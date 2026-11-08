#!/usr/bin/env python3
"""Independently verify bone CRC32 hashes against serialized hierarchy JSON.

Input is local analysis metadata only. Hierarchies may be a JSON array or a
sequence of JSON objects; neither format requires Unity asset payloads.
"""
import argparse
from collections import Counter, defaultdict
import json
from pathlib import Path
import zlib


def load_json_stream(path):
    raw = Path(path).read_text(encoding="utf-8")
    decoder = json.JSONDecoder()
    offset, values = 0, []
    while offset < len(raw):
        while offset < len(raw) and raw[offset].isspace():
            offset += 1
        if offset >= len(raw):
            break
        value, offset = decoder.raw_decode(raw, offset)
        values.extend(value if isinstance(value, list) else [value])
    return values


def verify(hierarchies, alignment):
    by_bundle = {entry["file"].removesuffix(".prefab_ab"): entry
                 for entry in hierarchies
                 if entry["file"].endswith(".prefab_ab")}
    summary = Counter()
    failures = []
    for entry in alignment["records"]:
        bundle = entry["bundle"]
        if bundle not in by_bundle:
            failures.append({"bundle": bundle, "index": entry["index"],
                             "reason": "missing hierarchy"})
            continue
        nodes = {node["path_id"]: node for node in by_bundle[bundle]["nodes"]}
        expected = int(entry["mesh_bone_hash"], 16)
        matches = 0
        for node in nodes.values():
            if node["name"] != entry["transform_name"]:
                continue
            parts, visited, current = [], set(), node["path_id"]
            while current in nodes:
                if current in visited:
                    raise ValueError("Cycle in transform hierarchy")
                visited.add(current)
                item = nodes[current]
                parts.append(item["name"])
                current = item["father"][1]
            parts.reverse()
            if len(parts) < 2:
                continue
            relative = "/".join(parts[1:])
            matches += (zlib.crc32(relative.encode("utf-8")) & 0xffffffff) == expected
        summary[bundle] += 1
        if matches != 1:
            failures.append({"bundle": bundle, "index": entry["index"],
                             "matching_paths": matches})
    return {"checked": len(alignment["records"]),
            "uniquely_matched": len(alignment["records"]) - len(failures),
            "by_bundle": dict(sorted(summary.items())),
            "failures": failures}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--hierarchies", type=Path, nargs="+", required=True)
    parser.add_argument("--alignment", type=Path, required=True)
    args = parser.parse_args()
    hierarchies = []
    for file in args.hierarchies:
        hierarchies.extend(load_json_stream(file))
    alignment = json.loads(args.alignment.read_text(encoding="utf-8"))
    result = verify(hierarchies, alignment)
    print(json.dumps(result, indent=2))
    if result["failures"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
