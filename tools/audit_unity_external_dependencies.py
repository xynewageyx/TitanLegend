#!/usr/bin/env python3
"""Audit external CAB references from locally extracted Unity metadata."""
import argparse
from collections import defaultdict
import json
from pathlib import Path


def audit(records):
    usage = defaultdict(list)
    invalid = []
    for bundle, refs in records.items():
        seen_file_ids = set()
        for ref in refs:
            file_id = ref.get("fileID")
            path = ref.get("path", "")
            if file_id in seen_file_ids:
                invalid.append({"bundle": bundle, "reason": "duplicate fileID", "fileID": file_id})
            seen_file_ids.add(file_id)
            if not path.startswith("archive:/CAB-"):
                invalid.append({"bundle": bundle, "reason": "unexpected CAB path", "fileID": file_id})
            usage[path].append({"bundle": bundle, "fileID": file_id})
    return {"bundles": len(records),
            "references": sum(len(refs) for refs in records.values()),
            "unique_external_paths": len(usage),
            "shared_external_paths": {path: refs for path, refs in usage.items() if len(refs) > 1},
            "per_bundle": {bundle: len(refs) for bundle, refs in sorted(records.items())},
            "issues": invalid}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("metadata", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    records = json.loads(args.metadata.read_text(encoding="utf-8"))
    result = audit(records)
    text = json.dumps(result, indent=2, ensure_ascii=False) + "\n"
    if args.output:
        args.output.write_text(text, encoding="utf-8")
    print(text)
    if result["issues"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
