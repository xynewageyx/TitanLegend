# Titan Legends – Gemeinsamer Live-Projektstatus

Automatisch erzeugt: **2026-11-03 17:02 UTC**
Git-Stand: **80e3399e68fb4795492abfa9903e7518ed45dedb** auf Branch **main**

> Diese Datei wird nach Repository-Änderungen aktualisiert. Sie synchronisiert keine Chat-Verläufe und beweist keine bestandenen Tests. Jeder Fach-Chat liest sie vor der Arbeit und dokumentiert eigene Änderungen per GitHub-Commit.

## Zuständigkeiten und letzte Änderungen

### Charaktere — Charaktere-Chat
- `de9b92d` (2026-11-03): Generate eleven original chibi hero GLB assets
- `06c0cfc` (2026-11-03): fix(animation): add quarter-cycle keyframes so walk and idle actually move
- `53bfceb` (2026-11-03): fix(talents): reject invalid rank values across all hero talent branches

### Gegner/Bosse — Gegner-/Boss-Chat
- `b58b0bc` (2026-11-03): Reserve an audio channel for critical boss cast warnings (#20)
- `79a13fc` (2026-11-03): fix(forest): preserve defeated forest enemies briefly before next encounter
- `53bfceb` (2026-11-03): fix(talents): reject invalid rank values across all hero talent branches

### Landschaften — Landschaften-Chat
- `53bfceb` (2026-11-03): fix(talents): reject invalid rank values across all hero talent branches

### Ausrüstung — Ausrüstungs-Chat
- `53bfceb` (2026-11-03): fix(talents): reject invalid rank values across all hero talent branches

### UI — UI-Chat
- `53bfceb` (2026-11-03): fix(talents): reject invalid rank values across all hero talent branches

### Gameplay — Gameplay-/Talent-Chat
- `80e3399` (2026-11-03): test(talents): cover recovery of malformed saved rank types
- `d52d8b1` (2026-11-03): fix(talents): safely ignore non-integer saved ranks during talent build recovery
- `79a13fc` (2026-11-03): fix(forest): preserve defeated forest enemies briefly before next encounter
- `92ca766` (2026-11-03): test(talents): cover malformed rank types and bounds
- `53bfceb` (2026-11-03): fix(talents): reject invalid rank values across all hero talent branches

### Skills und Animationen — Skills-und-Animationen-Chat
- `53bfceb` (2026-11-03): fix(talents): reject invalid rank values across all hero talent branches

### Grafiktreiber / Rendering — Grafiktreiber-Chat
- `53bfceb` (2026-11-03): fix(talents): reject invalid rank values across all hero talent branches

### Titan Chat / Moderation — Titan-Chat-Chat
- `8d0e78b` (2026-11-03): Fix typed moderation admin smoke test access for Godot static analyzer
- `53bfceb` (2026-11-03): fix(talents): reject invalid rank values across all hero talent branches

### Audio — Audio-Erstellung-Chat
- `b58b0bc` (2026-11-03): Reserve an audio channel for critical boss cast warnings (#20)
- `53bfceb` (2026-11-03): fix(talents): reject invalid rank values across all hero talent branches

### Integration/CI — GitHub-/Integrations-Chat
- `53bfceb` (2026-11-03): fix(talents): reject invalid rank values across all hero talent branches

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
