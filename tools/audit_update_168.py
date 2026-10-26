#!/usr/bin/env python3
"""Audit the checked-out Godot project against the original Update 168 ZIP.

Use on Android/Termux or a GitHub checkout:
  python tools/audit_update_168.py /path/to/Titan_Legends_Update_168_Gegner_KI_Tank_Fix.zip

The audit is READ ONLY. Existing newer code is never overwritten.
"""
from __future__ import annotations

import argparse
import hashlib
from pathlib import Path
import zipfile

ROOT = Path(__file__).resolve().parents[1]
PREFIX = "Titan_Legends_Complete_Android_Godot/"


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def audit(archive: Path) -> int:
    if not archive.is_file():
        print(f"ERROR: archive not found: {archive}")
        return 2
    matching: list[str] = []
    missing: list[str] = []
    changed: list[str] = []
    with zipfile.ZipFile(archive) as z:
        corrupted = z.testzip()
        if corrupted is not None:
            print(f"ERROR: corrupt ZIP entry: {corrupted}")
            return 2
        originals = [
            name for name in z.namelist()
            if name.startswith(PREFIX) and not name.endswith("/")
        ]
        for entry in originals:
            relative = entry[len(PREFIX):]
            file = ROOT / relative
            if not file.is_file():
                missing.append(relative)
            elif sha256(file.read_bytes()) == sha256(z.read(entry)):
                matching.append(relative)
            else:
                changed.append(relative)
    print(f"Update 168 archive files: {len(originals)}")
    print(f"Exact matches: {len(matching)}")
    print(f"Missing: {len(missing)}")
    print(f"Different (modified or incomplete): {len(changed)}")
    for title, group in [("MISSING", missing), ("DIFFERENT", changed)]:
        for relative in group:
            print(f"{title}: {relative}")
    print("No files were modified.")
    return 1 if missing or changed else 0


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("archive", type=Path, help="Update 168 original ZIP")
    args = parser.parse_args()
    raise SystemExit(audit(args.archive))
