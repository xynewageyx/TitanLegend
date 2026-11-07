#!/usr/bin/env python3
"""Repair one failed GitHub Actions run using bounded, reviewable source edits."""
import ast
import json
import os
from pathlib import Path
import subprocess
import sys
import urllib.request

MAX_FILES = 3
ALLOWED = (".py", ".gd", ".yml", ".yaml", ".json", ".cfg", ".tscn", ".tres")
PROTECTED = (".github/", "secrets/", "addons/", "assets/", "build/")
MAX_BYTES = 80000


def command(*args, check=True):
    p = subprocess.run(args, text=True, stdout=subprocess.PIPE,
                       stderr=subprocess.STDOUT, timeout=180)
    if check and p.returncode:
        raise RuntimeError(p.stdout[-3000:])
    return p.stdout


def allowed(name):
    p = Path(name)
    return (not p.is_absolute() and ".." not in p.parts and
            not any(name.startswith(x) for x in PROTECTED) and
            p.suffix in ALLOWED and p.is_file() and p.stat().st_size <= MAX_BYTES)


def ask_model(log, candidates):
    source = {name: Path(name).read_text() for name in candidates}
    prompt = (
        "Repair a failed Godot/Android/Python/Blender GitHub Actions build. "
        "Return JSON object {\\\"files\\\":[{\\\"path\\\":\\\"existing/path\\\",\\\"content\\\":\\\"complete replacement\\\"}]}. "
        "Change at most 3 existing source files from the supplied candidates. "
        "Never change workflows, secrets, authentication, dependencies, security checks, or permissions. "
        "Preserve game rules and existing functionality. If no safe fix, return empty files.\\n"
        + "FAILURE LOG:\\n" + log[-16000:] + "\\nFILES:\\n" + json.dumps(source)
    )
    payload = json.dumps({
        "model": os.environ.get("REPAIR_MODEL", "gpt-4.1-mini"),
        "messages": [{"role": "user", "content": prompt}],
        "response_format": {"type": "json_object"},
        "temperature": 0,
    }).encode()
    req = urllib.request.Request(
        "https://api.openai.com/v1/chat/completions", data=payload,
        headers={"Authorization": "Bearer " + os.environ["OPENAI_API_KEY"],
                 "Content-Type": "application/json"}, method="POST")
    with urllib.request.urlopen(req, timeout=120) as response:
        return json.loads(json.load(response)["choices"][0]["message"]["content"])["files"]


def validate(changed):
    for name in changed:
        if name.endswith(".py"):
            ast.parse(Path(name).read_text())
    py = [name for name in changed if name.endswith(".py")]
    if py:
        command(sys.executable, "-m", "py_compile", *py)
    if any(name.endswith((".gd", ".tscn", ".tres", ".cfg")) for name in changed):
        # Use the project-local engine if installed by the workflow.
        command("godot", "--headless", "--path", ".", "--editor", "--quit", check=True)
    if any(name.startswith("tools/generate_chibi") for name in changed):
        command("blender", "-b", "--python", "tools/generate_chibi.py")
        command(sys.executable, "tools/validate_chibi_glb.py", "--require-extended-rig")


def main():
    log = Path(os.environ["FAILURE_LOG"]).read_text(errors="replace")
    # Only inspect existing files mentioned verbatim in the failure output.
    candidates = []
    for p in Path(".").rglob("*"):
        if len(candidates) >= 8:
            break
        if allowed(str(p)) and str(p).removeprefix("./") in log:
            candidates.append(str(p))
    if not candidates:
        print("No safely identifiable source files in failure log.")
        return 2
    original = {p: Path(p).read_text() for p in candidates}
    for attempt in range(1, 4):
        edits = ask_model(log, candidates)
        if not edits or len(edits) > MAX_FILES:
            print("No safe AI repair proposal.")
            return 2
        touched = set()
        try:
            for item in edits:
                name, content = item["path"], item["content"]
                if name not in original or name in touched or not isinstance(content, str) or len(content) > MAX_BYTES:
                    raise ValueError("Unsafe repair target")
                touched.add(name)
                Path(name).write_text(content)
            validate(touched)
            print(f"Validated candidate on attempt {attempt}: {sorted(touched)}")
            return 0
        except Exception as exc:
            print(f"Repair attempt {attempt} rejected: {exc}")
            for name, content in original.items():
                Path(name).write_text(content)
            log += f"\\nRepair attempt {attempt} failed validation: {exc}"
    return 1


if __name__ == "__main__":
    sys.exit(main())
