#!/usr/bin/env python3
"""Audit or safely import the original Titan Legends Update 168 archive.

Run from the repository root:
    python tools/import_update168.py /path/to/Titan_Legends_Update_168_Gegner_KI_Tank_Fix.zip
    python tools/import_update168.py /path/to/archive.zip --import-missing

Existing GitHub files are NEVER overwritten by this tool. This avoids deleting
newer fixes from the compatibility implementation. The audit identifies the
remaining migration gap before further development.
"""
from __future__ import annotations

import argparse
import hashlib
from pathlib import Path, PurePosixPath
import sys
import zipfile

ARCHIVE_PREFIX = "Titan_Legends_Complete_Android_Godot/"
IGNORED_DIRS = {".godot", "__MACOSX", "__pycache__"}
IMPORTANT = (
    "project.godot",
    "scenes/main.tscn",
    "scripts/team_formation.gd",
    "scripts/battle_manager.gd",
    "scripts/ui_manager.gd",
    "scripts/boss_motion.gd",
    "scripts/boss_art.gd",
)
KNOWN_SOURCE_SHA256 = {
    "project.godot": "ff12442faa14359b1f3252e2b8e60d84d4f639e0429ef82b7c240421068fd0e5",
    "scenes/main.tscn": "e752dd42b15bc3b21158dec6ced89f745c79be14fcbb028e93c8cb3ba1748580",
    "scripts/team_formation.gd": "19b26a83c256ed98613cc7ca958e54800ff4651d926a811f89508890e33e95e0",
    "scripts/battle_manager.gd": "a8466f771ae14906751043649b0b43936b5c004769760f45aa54b2f2e6b29f30",
    "scripts/ui_manager.gd": "724f9b9ec3e5a11d9efb14a85f234c300888a80f020a820d7b523050c9a48693",
    "scripts/boss_motion.gd": "54d8d22371d590d21542b779891191d122815e1233088a0014b114cd3616ddb1",
    "scripts/boss_art.gd": "f3808b2ea01d1f650f66d66f3ba57c6c073750ec5e83c8a5da5e05ceb0d68e24",
}
ROOT = Path(__file__).resolve().parents[1]


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def safe_relative_path(name: str) -> Path | None:
    if not name.startswith(ARCHIVE_PREFIX):
        return None
    suffix = name[len(ARCHIVE_PREFIX):]
    part = PurePosixPath(suffix)
    if (not suffix or name.endswith("/") or part.is_absolute()
            or any(component in ("", ".", "..") for component in part.parts)
            or any(component in IGNORED_DIRS for component in part.parts)
            or "\\" in suffix or ":" in suffix):
        return None
    return Path(*part.parts)


def audit(zip_path: Path, import_missing: bool) -> tuple[int, int, int]:
    missing, modified, identical = [], [], []
    with zipfile.ZipFile(zip_path) as archive:
        files = [item for item in archive.infolist() if not item.is_dir()]
        candidates = [(item, safe_relative_path(item.filename)) for item in files]
        candidates = [(item, rel) for item, rel in candidates if rel is not None]
        for item, relative in candidates:
            source = archive.read(item)
            canonical = str(relative).replace("\\", "/")
            if canonical in KNOWN_SOURCE_SHA256 and digest(source) != KNOWN_SOURCE_SHA256[canonical]:
                raise ValueError("Original ZIP hash mismatch: " + canonical)
            target = ROOT / relative
            # Do not follow symlinks outside the checked-out repository.
            if not target.resolve().is_relative_to(ROOT.resolve()):
                raise ValueError("Unsafe destination: " + canonical)
            if not target.exists():
                missing.append(canonical)
                if import_missing:
                    target.parent.mkdir(parents=True, exist_ok=True)
                    with target.open("xb") as stream:
                        stream.write(source)
                    if target.read_bytes() != source:
                        raise IOError("Verification failed: " + canonical)
            elif target.read_bytes() == source:
                identical.append(canonical)
            else:
                modified.append(canonical)
    print(f"Archive files: {len(candidates)} | identical: {len(identical)} | "
          f"missing: {len(missing)} | different: {len(modified)}")
    for title, paths in (("MISSING", missing), ("DIFFERENT — not overwritten", modified)):
        print("\n" + title + ":")
        for path in paths:
            prefix = " [CORE]" if path in IMPORTANT else ""
            print("  " + path + prefix)
    if import_missing:
        print(f"\nSafely imported and verified {len(missing)} missing files.")
        print("Review 'git status' and commit only after validation.")
    return len(missing), len(modified), len(identical)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("archive", type=Path, help="Original Update 168 ZIP")
    parser.add_argument("--import-missing", action="store_true",
                        help="Copy and verify ONLY files absent from the checkout")
    args = parser.parse_args()
    if not args.archive.is_file():
        parser.error("ZIP file not found: " + str(args.archive))
    try:
        audit(args.archive, args.import_missing)
        return 0
    except (ValueError, OSError, zipfile.BadZipFile) as exc:
        print(f"Import failed: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
