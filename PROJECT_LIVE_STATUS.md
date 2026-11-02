# Titan Legends – Gemeinsamer Live-Projektstatus

Automatisch erzeugt: **2026-11-02 21:42 UTC**
Git-Stand: **c7fe0a11e6ce4f68ec186316f2aefbb74ecf101b** auf Branch **main**

> Diese Datei wird nach Repository-Änderungen aktualisiert. Sie synchronisiert keine Chat-Verläufe und beweist keine bestandenen Tests. Jeder Fach-Chat liest sie vor der Arbeit und dokumentiert eigene Änderungen per GitHub-Commit.

## Zuständigkeiten und letzte Änderungen

### Charaktere — Charaktere-Chat
- `f04ab3e` (2026-11-02): fix(chibi): use Blender 5 compatible EEVEE render engine for preview generation

### Gegner/Bosse — Gegner-/Boss-Chat
- `11570e2` (2026-11-02): test(forest): verify imported enemies contain real MeshInstance3D geometry

### Landschaften — Landschaften-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 15 Commits (kein Nachweis für Inaktivität).

### Ausrüstung — Ausrüstungs-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 15 Commits (kein Nachweis für Inaktivität).

### UI — UI-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 15 Commits (kein Nachweis für Inaktivität).

### Gameplay — Gameplay-/Talent-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 15 Commits (kein Nachweis für Inaktivität).

### Skills und Animationen — Skills-und-Animationen-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 15 Commits (kein Nachweis für Inaktivität).

### Grafiktreiber / Rendering — Grafiktreiber-Chat
- `f04ab3e` (2026-11-02): fix(chibi): use Blender 5 compatible EEVEE render engine for preview generation
- `07c5bd5` (2026-11-02): Reset graphics sampling after manual preset changes and simplify persistence
- `2d6db43` (2026-11-02): Reset adaptive FPS sampling after scene transitions

### Titan Chat / Moderation — Titan-Chat-Chat
- `c7fe0a1` (2026-11-02): Run peer authorization security regression in moderation CI
- `f60f990` (2026-11-02): Add security regression tests for peer-bound owner authorization
- `7e53706` (2026-11-02): Add server-owned peer authorization boundary for moderation requests

### Audio — Audio-Erstellung-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 15 Commits (kein Nachweis für Inaktivität).

### Integration/CI — GitHub-/Integrations-Chat
- `c7fe0a1` (2026-11-02): Run peer authorization security regression in moderation CI

## Bereichsübergreifende Änderungen

- `d5811f4` (2026-11-02): test(forest): sample midpoint of short animation clips and validate nonzero 3D motion

## Regeln für alle Fach-Chats

1. Vor Arbeitsbeginn `PROJECT_COORDINATION.md`, `VISUAL_QUALITY_GATE.md` und diese Datei lesen.
2. Eigene Änderungen mit aussagekräftigen Commit-Meldungen und möglichst getrennten Dateien einreichen.
3. Bei Konflikten oder Abhängigkeiten einen GitHub-Issue/PR mit betroffenen Bereichen anlegen.
4. Erfolge nur anhand der zugehörigen GitHub-Actions-Läufe melden; diese Übersicht klassifiziert Commits, nicht deren Qualität.

## Aktuelle Prüfläufe

Siehe [GitHub Actions](https://github.com/xynewageyx/TitanLegend/actions) für den tatsächlichen aktuellen Status.
