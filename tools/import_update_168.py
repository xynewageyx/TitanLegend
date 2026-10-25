#!/usr/bin/env python3
"""Backward-compatible, NON-DESTRUCTIVE Update 168 importer.

Existing game files are NEVER overwritten. This legacy entry point forwards to
the safe importer, which imports only missing files. The original manifest is
preserved and no new ZIP archives are created.

Usage:
    python tools/import_update_168.py /path/to/Titan_Legends_Update_168_Gegner_KI_Tank_Fix.zip
"""
from __future__ import annotations

import hashlib
from pathlib import Path
import sys

from import_update168 import audit

EXPECTED_SOURCE_SHA256 = "6a756b5c7f5d6bbf4c569632f932ac134fc6c35fa094d5dd71ab465618390072"


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: python tools/import_update_168.py <existing-update-168-zip>", file=sys.stderr)
        return 2
    source = Path(sys.argv[1]).expanduser()
    if not source.is_file():
        print(f"Archive not found: {source}", file=sys.stderr)
        return 2

    # The original archive fingerprint protects against accidentally importing
    # a different Update under a misleading filename.
    if hashlib.sha256(source.read_bytes()).hexdigest() != EXPECTED_SOURCE_SHA256:
        print("Archive SHA-256 differs from verified Update 168; refusing import.", file=sys.stderr)
        return 1

    try:
        missing, different, identical = audit(source, import_missing=True)
    except (OSError, ValueError) as exc:
        print(f"Safe import failed: {exc}", file=sys.stderr)
        return 1
    print(
        f"Non-destructive import finished: {missing} missing copied; "
        f"{different} existing changed files preserved; {identical} identical."
    )
    print("No active script overwritten, no manifest rewritten, no ZIP created.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
