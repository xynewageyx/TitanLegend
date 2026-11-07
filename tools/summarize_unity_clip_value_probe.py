#!/usr/bin/env python3
"""Summarize local AnimationClip TypeTree value probes without asset payloads."""
import argparse
from collections import Counter
import json
from pathlib import Path
import re

OVERRUN = re.compile(r"^overrun (.+) (\d+)/(\d+)$")


def summarize(probe):
    rows = probe["rows"]
    errors = probe["errors"]
    if probe["files"] != len(rows) + len(errors):
        raise ValueError("Probe file count does not match successes and failures")
    categories = Counter()
    for item in errors:
        error = item["error"]
        match = OVERRUN.fullmatch(error)
        if match:
            excess = int(match.group(2)) - int(match.group(3))
            categories[f"overrun_{excess}_bytes"] += 1
        elif error.startswith("bad array"):
            categories["invalid_array_length"] += 1
        else:
            categories["other"] += 1
    sample_rates = Counter()
    for row in rows:
        rates = row.get("values", {}).get("m_SampleRate", [])
        sample_rates[str(rates)] += 1
    return {
        "files": probe["files"],
        "fully_consumed": len(rows),
        "unverified": len(errors),
        "error_categories": dict(sorted(categories.items())),
        "sample_rate_pairs": dict(sorted(sample_rates.items())),
        "unverified_files": sorted(e["file"] for e in errors),
        "note": "Do not treat failed clips as parsed; a 4-byte overrun is not a safe offset correction."
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("probe", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    report = summarize(json.loads(args.probe.read_text(encoding="utf-8")))
    output = json.dumps(report, ensure_ascii=False, indent=2) + "\n"
    if args.output:
        args.output.write_text(output, encoding="utf-8")
    print(output)


if __name__ == "__main__":
    main()
