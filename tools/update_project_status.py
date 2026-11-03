#!/usr/bin/env python3
"""Generate shared Titan Legends coordination status from GitHub event and repository."""
import json
import os
import subprocess
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
AREAS = {
    "Charaktere": ("tools/generate_chibi.py", "tools/validate_chibi", "assets/heroes/", "scenes/heroes/", "scripts/hero", "tools/blender/generate_hero"),
    "Gegner/Bosse": ("assets/enemies/", "scripts/enemy", "scripts/boss", "tools/blender/generate_forest_mobs.py"),
    "Landschaften": ("scripts/biome", "assets/terrain/", "assets/environment/", "scenes/biome", "assets/landscape/", "assets/grassland/", "tools/blender/generate_grasland", "tools/blender/generate_grassland", "tools/generate_grasland", "tools/generate_grassland", "scripts/terrain", "scenes/terrain"),
    "Ausrüstung": ("scripts/equipment", "assets/weapons/", "assets/armor/"),
    "UI": ("scripts/ui", "scenes/ui/", "assets/ui/"),
    "Gameplay": ("scripts/team", "scripts/battle", "scripts/talent", "scripts/save", "scripts/game_manager"),
    "Skills und Animationen": ("scripts/skill", "scripts/ability", "scripts/combat_skill", "assets/skills/", "assets/vfx/", "assets/effects/", "scenes/skills/", "tools/skills/", "tests/test_skill", "tests/test_ability", "tools/blender/generate_skill"),
    "Grafiktreiber / Rendering": ("scripts/render", "scripts/graphics", "scripts/quality", "shaders/", "assets/shaders/", "materials/", "assets/materials/", "tools/render", "tools/graphics", "tests/test_render", "tests/test_graphics", "scenes/render"),
    "Titan Chat / Moderation": ("scripts/chat", "scripts/moderation", "scripts/chat_filter", "scenes/chat", "assets/chat/", "tools/chat/", "tests/test_chat", "tests/test_moderation", "server/chat", "server/moderation"),
    "Audio": ("assets/audio/", "audio/", "sounds/", "music/", "scripts/audio", "scenes/audio", "tools/audio/", "tests/test_audio"),
    "Integration/CI": (".github/workflows/", "project.godot", "export_presets.cfg"),
}
OWNERS = {
    "Charaktere": "Charaktere-Chat",
    "Gegner/Bosse": "Gegner-/Boss-Chat",
    "Landschaften": "Landschaften-Chat",
    "Ausrüstung": "Ausrüstungs-Chat",
    "UI": "UI-Chat",
    "Gameplay": "Gameplay-/Talent-Chat",
    "Skills und Animationen": "Skills-und-Animationen-Chat",
    "Grafiktreiber / Rendering": "Grafiktreiber-Chat",
    "Titan Chat / Moderation": "Titan-Chat-Chat",
    "Audio": "Audio-Erstellung-Chat",
    "Integration/CI": "GitHub-/Integrations-Chat",
}

def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT, text=True, stderr=subprocess.DEVNULL).strip()

def main():
    sha = git("rev-parse", "HEAD")
    branch = os.getenv("GITHUB_REF_NAME", "main")
    timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    try:
        lines = git("log", "-30", "--date=short", "--pretty=format:%h%x09%ad%x09%s", "--name-only").splitlines()
    except subprocess.CalledProcessError:
        lines = []
    commits = []
    current = None
    for line in lines:
        if "\t" in line and len(line.split("\t", 2)) == 3:
            if current:
                commits.append(current)
            h, date, subject = line.split("\t", 2)
            current = {"hash": h, "date": date, "subject": subject, "files": []}
        elif line.strip() and current:
            current["files"].append(line.strip())
    if current:
        commits.append(current)
    classified = {name: [] for name in AREAS}
    shared = []
    SUBJECT_HINTS = {
        "Charaktere": ("chibi", "character", "hero", "rigg", "skin weight"),
        "Gegner/Bosse": ("enemy", "enemies", "boss", "forest mob"),
        "Landschaften": ("landscape", "terrain", "grasland", "grassland", "biome", "vegetation"),
        "Ausrüstung": ("equipment", "weapon", "armor", "rüstung", "waffe"),
        "UI": ("ui(", "hud", "menu", "layout"),
        "Gameplay": ("talent", "xp", "combat", "battle", "team", "progression"),
        "Skills und Animationen": ("skill", "ability", "spell", "interrupt", "unterbrech", "vfx"),
        "Grafiktreiber / Rendering": ("render(", "graphics(", "grafiktreiber", "shader", "gpu", "postprocess", "antialias", "shadow quality", "rendering"),
        "Titan Chat / Moderation": ("chat(", "moderation", "profanity", "schimpfwort", "verwarn", "chatban", "chat ban", "mute"),
        "Audio": ("audio", "sound", "sfx", "soundtrack", "music", "musik", "ambient", "ambience", "pcm", "foley"),
        "Integration/CI": ("ci(", "build(", "workflow", "pipeline"),
    }
    for commit in commits:
        if "(coordination)" in commit["subject"].lower() or all(path in {"PROJECT_COORDINATION.md", "PROJECT_LIVE_STATUS.md", "VISUAL_QUALITY_GATE.md", "tools/update_project_status.py", ".github/workflows/project-coordination.yml"} for path in commit["files"]):
            continue
        subject = commit["subject"].lower()
        # Explicit audio work often mentions biomes, ambient landscapes or gameplay.
        # Prefer its primary subject over incidental keyword matches; keep genuine
        # cross-area edits when they touch files owned by other areas.
        path_matches = {
            name for name, prefixes in AREAS.items()
            if any(f.startswith(p) for f in commit["files"] for p in prefixes)
        }
        subject_matches = {
            name for name, hints in SUBJECT_HINTS.items()
            if any(hint in subject for hint in hints)
        }
        if "Audio" in subject_matches:
            subject_matches -= {"Landschaften", "Gameplay", "Integration/CI"}
        matched = [name for name in AREAS if name in path_matches or name in subject_matches]
        if not matched:
            shared.append(commit)
        else:
            for name in matched:
                classified[name].append(commit)
    output = [
        "# Titan Legends – Gemeinsamer Live-Projektstatus",
        "",
        f"Automatisch erzeugt: **{timestamp}**",
        f"Git-Stand: **{sha}** auf Branch **{branch}**",
        "",
        "> Diese Datei wird nach Repository-Änderungen aktualisiert. Sie synchronisiert keine Chat-Verläufe und beweist keine bestandenen Tests. Jeder Fach-Chat liest sie vor der Arbeit und dokumentiert eigene Änderungen per GitHub-Commit.",
        "",
        "## Zuständigkeiten und letzte Änderungen",
        "",
    ]
    for name, owner in OWNERS.items():
        output += [f"### {name} — {owner}"]
        items = classified[name][:5]
        output += [f"- `{c['hash']}` ({c['date']}): {c['subject']}" for c in items] if items else ["- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität)."]
        output.append("")
    output += ["## Bereichsübergreifende Änderungen", ""]
    output += [f"- `{c['hash']}` ({c['date']}): {c['subject']}" for c in shared[:8]] if shared else ["- Keine in den letzten 15 Commits."]
    output += ["", "## Regeln für alle Fach-Chats", "",
        "1. Vor Arbeitsbeginn `PROJECT_COORDINATION.md`, `VISUAL_QUALITY_GATE.md` und diese Datei lesen.",
        "2. Eigene Änderungen mit aussagekräftigen Commit-Meldungen und möglichst getrennten Dateien einreichen.",
        "3. Bei Konflikten oder Abhängigkeiten einen GitHub-Issue/PR mit betroffenen Bereichen anlegen.",
        "4. Erfolge nur anhand der zugehörigen GitHub-Actions-Läufe melden; diese Übersicht klassifiziert Commits, nicht deren Qualität.",
        "",
        "## Aktuelle Prüfläufe", "",
        "Siehe [GitHub Actions](https://github.com/xynewageyx/TitanLegend/actions) für den tatsächlichen aktuellen Status.",
        "",
    ]
    dest = ROOT / "PROJECT_LIVE_STATUS.md"
    dest.write_text("\n".join(output), encoding="utf-8")
    print(f"Updated {dest.name} for {sha[:12]} ({len(commits)} commits)")
    summary = Path(os.getenv("GITHUB_STEP_SUMMARY", "/dev/null"))
    if summary != Path("/dev/null"):
        with summary.open("a", encoding="utf-8") as f:
            f.write(f"### Titan Legends coordination\nGenerated project status for `{sha[:12]}`.\n")

if __name__ == "__main__":
    main()
