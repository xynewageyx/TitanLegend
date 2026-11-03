# Titan Legends – Gemeinsamer Live-Projektstatus

Automatisch erzeugt: **2026-11-03 18:14 UTC**
Git-Stand: **7291f9734457f404fcdf624ba471cdcb99d33960** auf Branch **main**

> Diese Datei wird nach Repository-Änderungen aktualisiert. Sie synchronisiert keine Chat-Verläufe und beweist keine bestandenen Tests. Jeder Fach-Chat liest sie vor der Arbeit und dokumentiert eigene Änderungen per GitHub-Commit.

## Zuständigkeiten und letzte Änderungen

### Charaktere — Charaktere-Chat
- `c848cd7` (2026-11-03): feat(chibi): add distinct spellcasting gestures for six magic classes
- `27b2a71` (2026-11-03): Generate eleven original chibi hero GLB assets
- `c85b6ac` (2026-11-03): feat(chibi): add full-body hit recoil and coordinated dodge poses

### Gegner/Bosse — Gegner-/Boss-Chat
- `cd99659` (2026-11-03): Keep prewarmed boss and interrupt cues resident in bounded LRU cache (#24)

### Landschaften — Landschaften-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### Ausrüstung — Ausrüstungs-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### UI — UI-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### Gameplay — Gameplay-/Talent-Chat
- `7291f97` (2026-11-03): Scale down more aggressively on severe sustained combat FPS drops

### Skills und Animationen — Skills-und-Animationen-Chat
- `cd99659` (2026-11-03): Keep prewarmed boss and interrupt cues resident in bounded LRU cache (#24)
- `c848cd7` (2026-11-03): feat(chibi): add distinct spellcasting gestures for six magic classes

### Grafiktreiber / Rendering — Grafiktreiber-Chat
- `7291f97` (2026-11-03): Scale down more aggressively on severe sustained combat FPS drops
- `136b1a7` (2026-11-03): Protect adaptive graphics hysteresis and visual profile caching with regression tests
- `f04d319` (2026-11-03): React to sustained Android FPS drops after two sampling windows

### Titan Chat / Moderation — Titan-Chat-Chat
- `864e697` (2026-11-03): Run moderation scene validation on pull requests as well as pushes
- `81065c8` (2026-11-03): Clear cached private moderation evidence when admin access is revoked

### Audio — Audio-Erstellung-Chat
- `cd99659` (2026-11-03): Keep prewarmed boss and interrupt cues resident in bounded LRU cache (#24)

### Integration/CI — GitHub-/Integrations-Chat
- `864e697` (2026-11-03): Run moderation scene validation on pull requests as well as pushes

## Bereichsübergreifende Änderungen

- `f603da3` (2026-11-03): fix(forest-ci): defer runtime test until SceneTree children can run _ready

## Regeln für alle Fach-Chats

1. Vor Arbeitsbeginn `PROJECT_COORDINATION.md`, `VISUAL_QUALITY_GATE.md` und diese Datei lesen.
2. Eigene Änderungen mit aussagekräftigen Commit-Meldungen und möglichst getrennten Dateien einreichen.
3. Bei Konflikten oder Abhängigkeiten einen GitHub-Issue/PR mit betroffenen Bereichen anlegen.
4. Erfolge nur anhand der zugehörigen GitHub-Actions-Läufe melden; diese Übersicht klassifiziert Commits, nicht deren Qualität.

## Aktuelle Prüfläufe

Siehe [GitHub Actions](https://github.com/xynewageyx/TitanLegend/actions) für den tatsächlichen aktuellen Status.
