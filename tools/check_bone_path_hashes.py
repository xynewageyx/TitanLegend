#!/usr/bin/env python3
"""Compare candidate 32-bit bone hash functions against *full hierarchy paths*.

Input CSV columns: path, hash. The hash may be decimal or 0x-prefixed.
The CSV is local input: never commit proprietary bone paths or original assets.
No assumption is made that Unity uses any of these algorithms.
"""
import argparse
import csv
import json
import zlib
from pathlib import Path


def fnv1a(data):
    h = 2166136261
    for byte in data:
        h = ((h ^ byte) * 16777619) & 0xffffffff
    return h


def djb2(data):
    h = 5381
    for byte in data:
        h = ((h * 33) + byte) & 0xffffffff
    return h


def variants(path):
    normalized = path.replace("\\", "/").strip("/")
    parts = normalized.split("/")
    if len(parts) < 2 or any(not part for part in parts):
        raise ValueError("Bone path must contain a prefab root and at least one nonempty bone segment")
    choices = {
        "full_slash": normalized,
        "full_backslash": normalized.replace("/", "\\"),
        "full_no_separator": "".join(parts),
        "without_root": "/".join(parts[1:]),
        "leaf": parts[-1],
    }
    for key, value in choices.items():
        yield key, value
        yield key + "_lower", value.lower()


def compare(rows):
    methods = {"crc32": lambda b: zlib.crc32(b) & 0xffffffff,
               "fnv1a": fnv1a, "djb2": djb2}
    results = {}
    for path, expected in rows:
        for variant, value in variants(path):
            for method, fn in methods.items():
                key = variant + ":" + method
                item = results.setdefault(key, {"matches": 0, "tested": 0})
                item["tested"] += 1
                item["matches"] += fn(value.encode("utf-8")) == expected
    return dict(sorted(results.items(),
                       key=lambda item: (-item[1]["matches"], item[0])))


def main():
    p = argparse.ArgumentParser()
    p.add_argument("csv_file", type=Path, help="Local CSV with path and hash columns")
    args = p.parse_args()
    with args.csv_file.open(newline="", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        if not {"path", "hash"}.issubset(reader.fieldnames or []):
            p.error("CSV must contain path and hash columns")
        rows = [(row["path"], int(row["hash"], 0)) for row in reader]
    if not rows:
        p.error("CSV has no rows")
    print(json.dumps({"sample_count": len(rows), "results": compare(rows)},
                     indent=2))


if __name__ == "__main__":
    main()
