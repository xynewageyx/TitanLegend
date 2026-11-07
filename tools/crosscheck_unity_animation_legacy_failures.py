#!/usr/bin/env python3
"""Cross-check AnimationClip probe status against independently decoded headers."""
import argparse
import json
from collections import Counter
from pathlib import Path


def crosscheck(headers, probe):
    header_map = {r["file"]: r for r in headers}
    if len(header_map) != len(headers):
        raise ValueError("Duplicate clip headers")
    successes = {r["file"]: r for r in probe["rows"]}
    failures = {r["file"]: r for r in probe["errors"]}
    if set(successes) & set(failures) or set(header_map) != set(successes) | set(failures):
        raise ValueError("Mismatch between headers and probe files")
    result = {}
    for file, h in sorted(header_map.items()):
        legacy = bool(h["legacy"])
        status = "failed" if file in failures else "passed"
        result[file] = {
            "legacy": legacy, "status": status, "object_bytes": h["object_bytes"],
            "error": failures[file]["error"] if status == "failed" else None,
        }
        if status == "passed" and successes[file]["bytes"] != h["object_bytes"]:
            raise ValueError(f"Object size mismatch: {file}")
    breakdown = Counter(
        ("legacy" if v["legacy"] else "nonlegacy", v["status"])
        for v in result.values()
    )
    return {
        "files": len(result),
        "breakdown": {f"{kind}_{status}": n for (kind, status), n in sorted(breakdown.items())},
        "legacy_clips": {f: v for f, v in result.items() if v["legacy"]},
        "failed_nonlegacy": sorted(
            f for f, v in result.items() if not v["legacy"] and v["status"] == "failed"
        ),
        "caution": "Legacy flag is correlated with failures, not proof of causality.",
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("headers", type=Path)
    parser.add_argument("probe", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    result = crosscheck(
        json.loads(args.headers.read_text(encoding="utf-8")),
        json.loads(args.probe.read_text(encoding="utf-8")),
    )
    output = json.dumps(result, indent=2, ensure_ascii=False) + "\n"
    if args.output:
        args.output.write_text(output, encoding="utf-8")
    print(output)


if __name__ == "__main__":
    main()
