# Titan Legends – Gemeinsamer Live-Projektstatus

Automatisch erzeugt: **2026-11-03 16:49 UTC**
Git-Stand: **b58b0bceac189d82874b45046bad52975df5ddfd** auf Branch **main**

> Diese Datei wird nach Repository-Änderungen aktualisiert. Sie synchronisiert keine Chat-Verläufe und beweist keine bestandenen Tests. Jeder Fach-Chat liest sie vor der Arbeit und dokumentiert eigene Änderungen per GitHub-Commit.

## Zuständigkeiten und letzte Änderungen

### Charaktere — Charaktere-Chat
- `06c0cfc` (2026-11-03): fix(animation): add quarter-cycle keyframes so walk and idle actually move
- `53bfceb` (2026-11-03): fix(talents): reject invalid rank values across all hero talent branches
- `cd297e7` (2026-11-03): Generate eleven original chibi hero GLB assets
- `8a53c49` (2026-11-03): fix(chibi): bind pupils to head, pair hunter pouches and reuse eye/sleeve materials
- `a1e8fa9` (2026-11-03): feat(forest): trigger death animations on mob casualties and defeated waves

### Gegner/Bosse — Gegner-/Boss-Chat
- `b58b0bc` (2026-11-03): Reserve an audio channel for critical boss cast warnings (#20)
- `79a13fc` (2026-11-03): fix(forest): preserve defeated forest enemies briefly before next encounter

### Landschaften — Landschaften-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### Ausrüstung — Ausrüstungs-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### UI — UI-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### Gameplay — Gameplay-/Talent-Chat
- `79a13fc` (2026-11-03): fix(forest): preserve defeated forest enemies briefly before next encounter
- `92ca766` (2026-11-03): test(talents): cover malformed rank types and bounds
- `53bfceb` (2026-11-03): fix(talents): reject invalid rank values across all hero talent branches
- `a1e8fa9` (2026-11-03): feat(forest): trigger death animations on mob casualties and defeated waves

### Skills und Animationen — Skills-und-Animationen-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### Grafiktreiber / Rendering — Grafiktreiber-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### Titan Chat / Moderation — Titan-Chat-Chat
- `8d0e78b` (2026-11-03): Fix typed moderation admin smoke test access for Godot static analyzer

### Audio — Audio-Erstellung-Chat
- `b58b0bc` (2026-11-03): Reserve an audio channel for critical boss cast warnings (#20)
- `d9ef28d` (2026-11-03): Validate PCM loop boundaries for all ten ambience files (#19)

### Integration/CI — GitHub-/Integrations-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

## Bereichsübergreifende Änderungen

- `5c4cb92` (2026-11-03): Show elapsed measurement time in developer FPS overlay

## Regeln für alle Fach-Chats

1. Vor Arbeitsbeginn `PROJECT_COORDINATION.md`, `VISUAL_QUALITY_GATE.md` und diese Datei lesen.
2. Eigene Änderungen mit aussagekräftigen Commit-Meldungen und möglichst getrennten Dateien einreichen.
3. Bei Konflikten oder Abhängigkeiten einen GitHub-Issue/PR mit betroffenen Bereichen anlegen.
4. Erfolge nur anhand der zugehörigen GitHub-Actions-Läufe melden; diese Übersicht klassifiziert Commits, nicht deren Qualität.

## Aktuelle Prüfläufe

Siehe [GitHub Actions](https://github.com/xynewageyx/TitanLegend/actions) für den tatsächlichen aktuellen Status.
