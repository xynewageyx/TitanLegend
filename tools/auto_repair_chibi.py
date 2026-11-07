#!/usr/bin/env python3
"""Bounded AI repair for the original chibi Blender generator only.

Requires OPENAI_API_KEY. Changes are reviewed via pull request, never merged here.
"""
import ast
import json
import os
import pathlib
import subprocess
import sys
import urllib.error
import urllib.request

GENERATOR = pathlib.Path("tools/generate_chibi.py")
VALIDATOR = pathlib.Path("tools/validate_chibi_glb.py")
OUTPUT = pathlib.Path("assets/heroes/chibi")
EXPECTED = "warrior paladin druid shaman hunter rogue mage warlock summoner priest brawler death_knight".split()


def run_check():
    commands = [
        [sys.executable, "-m", "py_compile", str(GENERATOR), str(VALIDATOR)],
        ["blender", "-b", "--python", str(GENERATOR)],
        [sys.executable, str(VALIDATOR), "--require-extended-rig"],
    ]
    logs = []
    for command in commands:
        try:
            p = subprocess.run(command, text=True, stdout=subprocess.PIPE,
                               stderr=subprocess.STDOUT, timeout=240)
        except (OSError, subprocess.TimeoutExpired) as exc:
            logs.append(f"{command}: {exc}")
            return False, "\n".join(logs)
        logs.append(f"$ {' '.join(command)}\n{p.stdout[-12000:]}")
        if p.returncode:
            return False, "\n".join(logs)
    if any(not (OUTPUT / (name + ".glb")).is_file() for name in EXPECTED):
        return False, "Missing generated GLB files"
    return True, "\n".join(logs)


def request_fix(source, failure):
    prompt = (
        "Fix only this Python Blender character generator for the reported test failure. "
        "Keep all 12 classes, original geometry, 24-bone rigs, five clips and Blender compatibility. "
        "Return a JSON object with a single key 'content' containing the COMPLETE corrected Python source. "
        "Do not add shell commands, secrets, network access, or unrelated features.\n\n"
        "FAILURE:\n" + failure[-14000:] + "\n\nSOURCE:\n" + source
    )
    payload = json.dumps({
        "model": os.environ.get("REPAIR_MODEL", "gpt-4.1-mini"),
        "messages": [{"role": "user", "content": prompt}],
        "response_format": {"type": "json_object"},
        "temperature": 0,
    }).encode()
    request = urllib.request.Request(
        "https://api.openai.com/v1/chat/completions",
        data=payload,
        headers={"Authorization": "Bearer " + os.environ["OPENAI_API_KEY"],
                 "Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=120) as response:
        data = json.load(response)
    return json.loads(data["choices"][0]["message"]["content"])["content"]


def main():
    if not os.environ.get("OPENAI_API_KEY"):
        print("OPENAI_API_KEY not configured; no AI repair attempted.")
        return 2
    for attempt in range(1, 4):
        ok, log = run_check()
        if ok:
            print(f"All export checks passed on attempt {attempt}.")
            return 0
        print(f"Export check failed on attempt {attempt}:\n{log[-5000:]}", flush=True)
        original = GENERATOR.read_text()
        try:
            replacement = request_fix(original, log)
            ast.parse(replacement)
            if not all(token in replacement for token in ("death_knight", "export_scene.gltf", "rig_and_animate")):
                raise ValueError("Candidate removed required generator features")
            if replacement == original:
                raise ValueError("Candidate made no changes")
            GENERATOR.write_text(replacement)
        except (ValueError, KeyError, TypeError, urllib.error.URLError, TimeoutError, SyntaxError) as exc:
            GENERATOR.write_text(original)
            print(f"Repair request rejected: {exc}")
            return 1
    ok, log = run_check()
    print(log[-5000:])
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
