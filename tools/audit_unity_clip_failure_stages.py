#!/usr/bin/env python3
"""Diagnose exact AnimationClip parser failure locations from local trace JSON.

Does not patch object lengths or declare failed clips valid.
"""
from collections import Counter
import argparse
import json
from pathlib import Path
import re

PATTERN = re.compile(
    r"^overrun (\S+) (\d+)/(\d+) at schema-node (\d+), "
    r"start (\d+), size (\d+), flags (0x[0-9a-fA-F]+)$"
)


def audit(data):
    if data["files"] != len(data["rows"]) + len(data["errors"]):
        raise ValueError("Inconsistent file count")
    stages = Counter()
    overruns, other = [], []
    for entry in data["errors"]:
        match = PATTERN.fullmatch(entry["error"])
        if not match:
            other.append(entry)
            continue
        name, end, limit, node, start, size, flags = match.groups()
        end, limit, node, start, size = map(int, (end, limit, node, start, size))
        if end <= limit:
            raise ValueError("Invalid overrun")
        stages[name] += 1
        overruns.append({
            "file": entry["file"], "field": name, "schema_node": node,
            "overrun_bytes": end - limit, "leaf_size": size,
            "starts_at_object_end": start == limit, "flags": flags,
        })
    return {
        "files": data["files"], "fully_consumed": len(data["rows"]),
        "failed": len(data["errors"]), "overrun_count": len(overruns),
        "boundary_start_overruns": sum(row["starts_at_object_end"] for row in overruns),
        "field_counts": dict(sorted(stages.items())),
        "other_errors": other, "overruns": overruns,
        "caution": "Failure location is not proof of the root cause.",
    }


def main():
    p = argparse.ArgumentParser()
    p.add_argument("trace", type=Path)
    p.add_argument("--output", type=Path)
    args = p.parse_args()
    report = audit(json.loads(args.trace.read_text(encoding="utf-8")))
    payload = json.dumps(report, ensure_ascii=False, indent=2) + "\n"
    if args.output:
        args.output.write_text(payload, encoding="utf-8")
    print(payload)


if __name__ == "__main__":
    main()
