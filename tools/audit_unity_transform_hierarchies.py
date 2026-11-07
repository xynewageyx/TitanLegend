#!/usr/bin/env python3
"""Audit extracted Unity Transform metadata; never requires original assets."""
import argparse
import collections
import hashlib
import json
from pathlib import Path


def load_records(files):
    decoder = json.JSONDecoder()
    for file in files:
        text = Path(file).read_text(encoding="utf-8")
        pos = 0
        while pos < len(text):
            while pos < len(text) and text[pos].isspace():
                pos += 1
            if pos == len(text):
                break
            value, pos = decoder.raw_decode(text, pos)
            yield from value if isinstance(value, list) else [value]


def audit(bundle):
    nodes = bundle["nodes"]
    ids = [n["path_id"] for n in nodes]
    duplicate_ids = [pid for pid, count in collections.Counter(ids).items() if count > 1]
    lookup = {n["path_id"]: n for n in nodes}
    roots = [n for n in nodes if n["father"][1] not in lookup]
    problems = []
    for node in nodes:
        pid = node["path_id"]
        parent = node["father"][1]
        if parent in lookup and pid not in [c["path_id"] for c in lookup[parent]["children"]]:
            problems.append(f"parent-child mismatch: {pid}")
        for child in node["children"]:
            cid = child["path_id"]
            if cid not in lookup:
                problems.append(f"missing child: {pid}->{cid}")
            elif lookup[cid]["father"][1] != pid:
                problems.append(f"child-parent mismatch: {pid}->{cid}")
    visited, groups = set(), []
    for root in roots:
        stack, paths = [(root["path_id"], None)], []
        while stack:
            pid, prefix = stack.pop()
            if pid in visited:
                problems.append(f"cycle or duplicate reachability: {pid}")
                continue
            visited.add(pid)
            node = lookup[pid]
            path = prefix + "/" + node["name"] if prefix is not None else ""
            paths.append(path)
            for child in node["children"]:
                if child["path_id"] in lookup:
                    stack.append((child["path_id"], path))
        groups.append({"root_path_id": root["path_id"], "root_name": root["name"],
                       "transforms": len(paths), "unique_relative_paths": len(set(paths)),
                       "relative_paths_sha256": hashlib.sha256(
                           "\n".join(sorted(paths)).encode()).hexdigest()})
    if len(visited) != len(lookup):
        problems.append(f"unreachable transforms: {len(lookup)-len(visited)}")
    if duplicate_ids:
        problems.append(f"duplicate path ids: {duplicate_ids}")
    return {"file": bundle["file"], "transforms": len(nodes), "roots": groups,
            "problems": problems}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("files", nargs="+", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    result = [audit(b) for b in load_records(args.files)]
    payload = json.dumps(result, indent=2, ensure_ascii=False)
    if args.output:
        args.output.write_text(payload + "\n", encoding="utf-8")
    print(payload)
    if any(b["problems"] for b in result):
        raise SystemExit(1)


if __name__ == "__main__":
    main()
