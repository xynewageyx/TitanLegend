# Titan Legends – Gemeinsamer Live-Projektstatus

Automatisch erzeugt: **2026-11-03 17:03 UTC**
Git-Stand: **7cfdf7c7cc2d3a53c27f44314f7d587bb1b5681b** auf Branch **main**

> Diese Datei wird nach Repository-Änderungen aktualisiert. Sie synchronisiert keine Chat-Verläufe und beweist keine bestandenen Tests. Jeder Fach-Chat liest sie vor der Arbeit und dokumentiert eigene Änderungen per GitHub-Commit.

## Zuständigkeiten und letzte Änderungen

### Charaktere — Charaktere-Chat
- `312f754` (2026-11-03): feat(animation): differentiate melee, hunter and caster attack poses across classes
- `de9b92d` (2026-11-03): Generate eleven original chibi hero GLB assets
- `06c0cfc` (2026-11-03): fix(animation): add quarter-cycle keyframes so walk and idle actually move
- `8d0e78b` (2026-11-03): Fix typed moderation admin smoke test access for Godot static analyzer

### Gegner/Bosse — Gegner-/Boss-Chat
- `b58b0bc` (2026-11-03): Reserve an audio channel for critical boss cast warnings (#20)
- `79a13fc` (2026-11-03): fix(forest): preserve defeated forest enemies briefly before next encounter
- `8d0e78b` (2026-11-03): Fix typed moderation admin smoke test access for Godot static analyzer

### Landschaften — Landschaften-Chat
- `8d0e78b` (2026-11-03): Fix typed moderation admin smoke test access for Godot static analyzer

### Ausrüstung — Ausrüstungs-Chat
- `8d0e78b` (2026-11-03): Fix typed moderation admin smoke test access for Godot static analyzer

### UI — UI-Chat
- `7cfdf7c` (2026-11-03): Require server access response before displaying moderation menu
- `938ba6b` (2026-11-03): Add server-authorized moderation menu access handshake
- `8d0e78b` (2026-11-03): Fix typed moderation admin smoke test access for Godot static analyzer

### Gameplay — Gameplay-/Talent-Chat
- `80e3399` (2026-11-03): test(talents): cover recovery of malformed saved rank types
- `d52d8b1` (2026-11-03): fix(talents): safely ignore non-integer saved ranks during talent build recovery
- `79a13fc` (2026-11-03): fix(forest): preserve defeated forest enemies briefly before next encounter
- `8d0e78b` (2026-11-03): Fix typed moderation admin smoke test access for Godot static analyzer

### Skills und Animationen — Skills-und-Animationen-Chat
- `8d0e78b` (2026-11-03): Fix typed moderation admin smoke test access for Godot static analyzer

### Grafiktreiber / Rendering — Grafiktreiber-Chat
- `8d0e78b` (2026-11-03): Fix typed moderation admin smoke test access for Godot static analyzer

### Titan Chat / Moderation — Titan-Chat-Chat
- `7cfdf7c` (2026-11-03): Require server access response before displaying moderation menu
- `938ba6b` (2026-11-03): Add server-authorized moderation menu access handshake
- `8d0e78b` (2026-11-03): Fix typed moderation admin smoke test access for Godot static analyzer

### Audio — Audio-Erstellung-Chat
- `b58b0bc` (2026-11-03): Reserve an audio channel for critical boss cast warnings (#20)
- `8d0e78b` (2026-11-03): Fix typed moderation admin smoke test access for Godot static analyzer

### Integration/CI — GitHub-/Integrations-Chat
- `8d0e78b` (2026-11-03): Fix typed moderation admin smoke test access for Godot static analyzer

## Bereichsübergreifende Änderungen

- `b69cf80` (2026-11-03): Add pause and resume controls to developer-only FPS measurements
- `5c4cb92` (2026-11-03): Show elapsed measurement time in developer FPS overlay

## Regeln für alle Fach-Chats

1. Vor Arbeitsbeginn `PROJECT_COORDINATION.md`, `VISUAL_QUALITY_GATE.md` und diese Datei lesen.
2. Eigene Änderungen mit aussagekräftigen Commit-Meldungen und möglichst getrennten Dateien einreichen.
3. Bei Konflikten oder Abhängigkeiten einen GitHub-Issue/PR mit betroffenen Bereichen anlegen.
4. Erfolge nur anhand der zugehörigen GitHub-Actions-Läufe melden; diese Übersicht klassifiziert Commits, nicht deren Qualität.

## Aktuelle Prüfläufe

Siehe [GitHub Actions](https://github.com/xynewageyx/TitanLegend/actions) für den tatsächlichen aktuellen Status.
