#!/usr/bin/env python3
"""Verify a local split 7z backup before any Unity metadata processing.

Read-only: checks volume sizes, optional SHA-256 and optional 7z integrity.
No archive contents are extracted or copied to GitHub.
"""
import argparse
import hashlib
import json
import shutil
import subprocess
from pathlib import Path

PART_BYTES = 241_172_480
EXPECTED = {f"ulala_backup.7z.{i:03d}": PART_BYTES for i in range(1, 9)}
EXPECTED["ulala_backup.7z.009"] = 3_865_636


def verify(root: Path, hash_files=False, archive_test=False):
    rows = []
    complete = True
    for name, expected in EXPECTED.items():
        path = root / name
        present = path.is_file()
        actual = path.stat().st_size if present else None
        ok = present and actual == expected
        complete = complete and ok
        entry = {"volume": name, "present": present, "expected_bytes": expected,
                 "actual_bytes": actual, "size_ok": ok}
        if hash_files and present:
            digest = hashlib.sha256()
            with path.open("rb") as stream:
                for chunk in iter(lambda: stream.read(4 * 1024 * 1024), b""):
                    digest.update(chunk)
            entry["sha256"] = digest.hexdigest()
        rows.append(entry)

    archive = {"requested": archive_test, "status": "not_requested"}
    if archive_test:
        if not complete:
            archive["status"] = "skipped_incomplete_volumes"
        else:
            executable = shutil.which("7z") or shutil.which("7zz") or shutil.which("7za")
            if not executable:
                archive["status"] = "tool_missing"
            else:
                try:
                    result = subprocess.run(
                        [executable, "t", str(root / "ulala_backup.7z.001")],
                        capture_output=True, text=True, timeout=3600, check=False)
                    archive["status"] = "passed" if result.returncode == 0 else "failed"
                    archive["exit_code"] = result.returncode
                except subprocess.TimeoutExpired:
                    archive["status"] = "timeout"
    return {"expected_total_bytes": sum(EXPECTED.values()),
            "volumes": rows, "sizes_valid": complete, "archive_integrity": archive}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("directory", type=Path)
    parser.add_argument("--sha256", action="store_true")
    parser.add_argument("--test-archive", action="store_true")
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    if not args.directory.is_dir():
        parser.error("directory must exist")
    report = verify(args.directory, args.sha256, args.test_archive)
    rendered = json.dumps(report, indent=2)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(rendered + "\n", encoding="utf-8")
    print(rendered)
    if not report["sizes_valid"] or (
        args.test_archive and report["archive_integrity"]["status"] != "passed"
    ):
        raise SystemExit(1)


if __name__ == "__main__":
    main()
