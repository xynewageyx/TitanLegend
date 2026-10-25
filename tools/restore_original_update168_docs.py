#!/usr/bin/env python3
"""Restore only missing Update 168 root history files from verified source data.

The payload is UTF-8 JSON packed with zlib and base64; it was generated
from the user's original Titan_Legends_Update_168_Gegner_KI_Tank_Fix.zip.
NEVER overwrite existing game scripts or other files.
"""
from __future__ import annotations

import base64
import hashlib
import json
from pathlib import Path
import re
import sys
import zlib

ROOT = Path(__file__).resolve().parents[1]
PACKED = ROOT / "migration/update168/missing_docs.zlib.b64"
EXPECTED_SHA256 = "f9ea33f56946f4e8c03159ea46dbb4abae0c8ec885efbed19a378584ef351fdf"
EXPECTED_COUNT = 98


def restore() -> int:
    data = base64.b64decode("".join(PACKED.read_text(encoding="ascii").split()), validate=True)
    if len(data) > 100000:
        raise ValueError("Packed source exceeds size limit")
    decompressor = zlib.decompressobj()
    raw = decompressor.decompress(data, 110000)
    raw += decompressor.flush()
    if not decompressor.eof or decompressor.unused_data or len(raw) > 110000:
        raise ValueError("Invalid compressed source")
    digest = hashlib.sha256(raw).hexdigest()
    if digest != EXPECTED_SHA256:
        raise ValueError("Update 168 source checksum mismatch")
    files = json.loads(raw.decode("utf-8"))
    if not isinstance(files, dict) or len(files) != EXPECTED_COUNT:
        raise ValueError("Wrong number of original archive entries")
    created = 0
    verified = 0
    for name, source in files.items():
        if not isinstance(name, str) or not isinstance(source, str):
            raise ValueError("Unexpected file entry")
        if not re.fullmatch(r"[A-Za-z0-9_]+\.(?:md|txt)", name):
            raise ValueError("Unsafe archive filename: " + name)
        content = source.encode("utf-8")
        target = ROOT / name
        if target.is_symlink():
            raise ValueError("Destination must not be a symlink: " + name)
        if target.exists():
            if target.read_bytes() != content:
                raise ValueError("Existing file differs from original; refusing overwrite: " + name)
            verified += 1
            continue
        with target.open("xb") as output:
            output.write(content)
        if target.read_bytes() != content:
            raise IOError("Read-back verification failed: " + name)
        created += 1
    print(f"Update 168 root docs: created {created}, verified existing {verified}, total {len(files)}")
    return created


if __name__ == "__main__":
    try:
        restore()
    except (OSError, ValueError, zlib.error, json.JSONDecodeError) as error:
        print("Update 168 docs import failed:", error, file=sys.stderr)
        raise SystemExit(1)
