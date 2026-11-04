#!/usr/bin/env python3
"""Inventory CAB tokens in local UnityFS bytes (heuristic, not PPtr resolution).

Only aggregate counts and filenames are printed; no proprietary asset bytes or
CAB identifiers are emitted. CAB strings can denote the bundle's own CAB.
"""
import argparse
from collections import Counter
import json
from pathlib import Path
import re

CAB = re.compile(rb"CAB-([0-9a-fA-F]{32})")


def scan(files):
    token_to_files = {}
    per_file = {}
    for path in files:
        data = Path(path).read_bytes()
        tokens = {token.lower() for token in CAB.findall(data)}
        per_file[Path(path).name] = len(tokens)
        for token in tokens:
            token_to_files.setdefault(token, set()).add(Path(path).name)
    shared = [sorted(names) for names in token_to_files.values() if len(names) > 1]
    return {"files_scanned": len(per_file),
            "unique_cab_tokens": len(token_to_files),
            "shared_token_groups": sorted(shared, key=lambda x: (-len(x), x)),
            "tokens_per_file": dict(sorted(per_file.items())),
            "warning": "Raw CAB tokens are not verified dependency edges."}


def main():
    p = argparse.ArgumentParser()
    p.add_argument("files", nargs="+", type=Path)
    p.add_argument("--output", type=Path)
    args = p.parse_args()
    result = scan(args.files)
    output = json.dumps(result, indent=2, ensure_ascii=False) + "\n"
    if args.output:
        args.output.write_text(output, encoding="utf-8")
    print(output)


if __name__ == "__main__":
    main()
