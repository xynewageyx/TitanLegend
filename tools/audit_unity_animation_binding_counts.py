#!/usr/bin/env python3
"""Audit genericBindings counts from successfully consumed AnimationClip probes.

Never interprets a binding count as a number of bones. Does not export curves.
"""
import argparse
import json
from pathlib import Path


def audit(probe):
    rows = probe["rows"]
    errors = probe["errors"]
    if probe["files"] != len(rows) + len(errors):
        raise ValueError("Probe counts inconsistent")
    binding_counts = {}
    for row in rows:
        counts = row.get("counts", {})
        if "genericBindings" not in counts:
            raise ValueError(f"Missing genericBindings count: {row['file']}")
        value = counts["genericBindings"]
        if not isinstance(value, int) or value < 0:
            raise ValueError("Invalid binding count")
        if row["file"] in binding_counts:
            raise ValueError("Duplicate clip file")
        binding_counts[row["file"]] = value
    return {
        "files": probe["files"],
        "fully_consumed": len(rows),
        "unverified": len(errors),
        "nonempty_binding_arrays": sum(n > 0 for n in binding_counts.values()),
        "empty_binding_arrays": sorted(name for name, n in binding_counts.items() if n == 0),
        "maximum_binding_array": max(binding_counts.values(), default=None),
        "maximum_binding_files": sorted(name for name, n in binding_counts.items()
                                        if n == max(binding_counts.values(), default=None)),
        "warning": "Binding array length is not a bone count or rig compatibility test."
    }


def main():
    p = argparse.ArgumentParser()
    p.add_argument("probe", type=Path)
    p.add_argument("--output", type=Path)
    args = p.parse_args()
    report = audit(json.loads(args.probe.read_text(encoding="utf-8")))
    output = json.dumps(report, indent=2, ensure_ascii=False) + "\n"
    if args.output:
        args.output.write_text(output, encoding="utf-8")
    print(output)


if __name__ == "__main__":
    main()
