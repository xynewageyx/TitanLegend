# Titan Legends – Gemeinsamer Live-Projektstatus

Automatisch erzeugt: **2026-11-03 16:52 UTC**
Git-Stand: **b69cf806f6890cc8b9c06a3f9fab71348c9c65b4** auf Branch **main**

> Diese Datei wird nach Repository-Änderungen aktualisiert. Sie synchronisiert keine Chat-Verläufe und beweist keine bestandenen Tests. Jeder Fach-Chat liest sie vor der Arbeit und dokumentiert eigene Änderungen per GitHub-Commit.

## Zuständigkeiten und letzte Änderungen

### Charaktere — Charaktere-Chat
- `06c0cfc` (2026-11-03): fix(animation): add quarter-cycle keyframes so walk and idle actually move
- `53bfceb` (2026-11-03): fix(talents): reject invalid rank values across all hero talent branches
- `cd297e7` (2026-11-03): Generate eleven original chibi hero GLB assets
- `d9ef28d` (2026-11-03): Validate PCM loop boundaries for all ten ambience files (#19)

### Gegner/Bosse — Gegner-/Boss-Chat
- `b58b0bc` (2026-11-03): Reserve an audio channel for critical boss cast warnings (#20)
- `79a13fc` (2026-11-03): fix(forest): preserve defeated forest enemies briefly before next encounter
- `d9ef28d` (2026-11-03): Validate PCM loop boundaries for all ten ambience files (#19)

### Landschaften — Landschaften-Chat
- `d9ef28d` (2026-11-03): Validate PCM loop boundaries for all ten ambience files (#19)

### Ausrüstung — Ausrüstungs-Chat
- `d9ef28d` (2026-11-03): Validate PCM loop boundaries for all ten ambience files (#19)

### UI — UI-Chat
- `d9ef28d` (2026-11-03): Validate PCM loop boundaries for all ten ambience files (#19)

### Gameplay — Gameplay-/Talent-Chat
- `79a13fc` (2026-11-03): fix(forest): preserve defeated forest enemies briefly before next encounter
- `92ca766` (2026-11-03): test(talents): cover malformed rank types and bounds
- `53bfceb` (2026-11-03): fix(talents): reject invalid rank values across all hero talent branches
- `d9ef28d` (2026-11-03): Validate PCM loop boundaries for all ten ambience files (#19)

### Skills und Animationen — Skills-und-Animationen-Chat
- `d9ef28d` (2026-11-03): Validate PCM loop boundaries for all ten ambience files (#19)

### Grafiktreiber / Rendering — Grafiktreiber-Chat
- `d9ef28d` (2026-11-03): Validate PCM loop boundaries for all ten ambience files (#19)

### Titan Chat / Moderation — Titan-Chat-Chat
- `8d0e78b` (2026-11-03): Fix typed moderation admin smoke test access for Godot static analyzer
- `d9ef28d` (2026-11-03): Validate PCM loop boundaries for all ten ambience files (#19)

### Audio — Audio-Erstellung-Chat
- `b58b0bc` (2026-11-03): Reserve an audio channel for critical boss cast warnings (#20)
- `d9ef28d` (2026-11-03): Validate PCM loop boundaries for all ten ambience files (#19)

### Integration/CI — GitHub-/Integrations-Chat
- `d9ef28d` (2026-11-03): Validate PCM loop boundaries for all ten ambience files (#19)

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
