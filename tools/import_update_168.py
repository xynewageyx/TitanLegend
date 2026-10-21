#!/usr/bin/env python3
"""Import all files from an existing Titan Legends Update 168 archive.
No new ZIP archive is created. Run inside a clone of this GitHub repository:
    python tools/import_update_168.py /path/to/Titan_Legends_Update_168_Gegner_KI_Tank_Fix.zip
Then review: git status; git diff; git add -A; git commit -m "Import complete Update 168"; git push
"""
from __future__ import annotations
import hashlib
import json
import pathlib
import sys
import zipfile

EXPECTED_FILES = 213
EXPECTED_BYTES = 371692
EXCLUDED = {".godot", ".git", "__MACOSX", ".import"}
ROOT = pathlib.Path(__file__).resolve().parents[1]

def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: python tools/import_update_168.py <existing-update-168-zip>", file=sys.stderr)
        return 2
    source = pathlib.Path(sys.argv[1]).expanduser().resolve()
    if not source.is_file():
        print(f"Archive not found: {source}", file=sys.stderr)
        return 2
    with zipfile.ZipFile(source) as archive:
        records = [i for i in archive.infolist() if not i.is_dir()]
        total_size = sum(i.file_size for i in records)
        if len(records) != EXPECTED_FILES or total_size != EXPECTED_BYTES:
            raise ValueError(f"Unexpected archive: {len(records)} files, {total_size} bytes")
        planned = []
        for info in records:
            full = pathlib.PurePosixPath(info.filename)
            if full.is_absolute() or ".." in full.parts or len(full.parts) < 2:
                raise ValueError(f"Unsafe archive path: {info.filename}")
            rel = pathlib.PurePosixPath(*full.parts[1:])
            if any(segment in EXCLUDED for segment in rel.parts):
                continue
            dest = (ROOT / str(rel)).resolve()
            if not dest.is_relative_to(ROOT):
                raise ValueError(f"Unsafe destination: {rel}")
            # Existing GitHub project CI and docs should be preserved if not in original.
            planned.append((info, rel, dest))
        if len(set(str(item[1]) for item in planned)) != len(planned):
            raise ValueError("Duplicate source paths")
        manifest = []
        for info, rel, dest in planned:
            data = archive.read(info)
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_bytes(data)
            manifest.append({
                "path": rel.as_posix(),
                "bytes": len(data),
                "sha256": hashlib.sha256(data).hexdigest(),
            })
    report = ROOT / "docs" / "update_168_import_manifest.json"
    report.parent.mkdir(exist_ok=True)
    report.write_text(json.dumps({
        "source_file_count": len(records),
        "source_uncompressed_bytes": total_size,
        "imported_file_count": len(manifest),
        "files": sorted(manifest, key=lambda x: x["path"])
    }, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"Imported {len(manifest)} source files into {ROOT}")
    print(f"Wrote SHA-256 manifest: {report.relative_to(ROOT)}")
    print("Review changes before committing and pushing. No new archive was created.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
