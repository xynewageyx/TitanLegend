# Titan Legends – Gemeinsamer Live-Projektstatus

Automatisch erzeugt: **2026-11-03 18:35 UTC**
Git-Stand: **0b3d1a1d5786e36504000e172bdc8468708d5e44** auf Branch **main**

> Diese Datei wird nach Repository-Änderungen aktualisiert. Sie synchronisiert keine Chat-Verläufe und beweist keine bestandenen Tests. Jeder Fach-Chat liest sie vor der Arbeit und dokumentiert eigene Änderungen per GitHub-Commit.

## Zuständigkeiten und letzte Änderungen

### Charaktere — Charaktere-Chat
- `bdef4c4` (2026-11-03): fix(formation): space four heroes and companions to reduce visual overlap
- `6925c8c` (2026-11-03): Generate eleven original chibi hero GLB assets
- `c848cd7` (2026-11-03): feat(chibi): add distinct spellcasting gestures for six magic classes
- `136b1a7` (2026-11-03): Protect adaptive graphics hysteresis and visual profile caching with regression tests

### Gegner/Bosse — Gegner-/Boss-Chat
- `b181c17` (2026-11-03): fix(camera): widen portrait combat framing to reveal team and enemies
- `cd99659` (2026-11-03): Keep prewarmed boss and interrupt cues resident in bounded LRU cache (#24)
- `136b1a7` (2026-11-03): Protect adaptive graphics hysteresis and visual profile caching with regression tests

### Landschaften — Landschaften-Chat
- `136b1a7` (2026-11-03): Protect adaptive graphics hysteresis and visual profile caching with regression tests

### Ausrüstung — Ausrüstungs-Chat
- `136b1a7` (2026-11-03): Protect adaptive graphics hysteresis and visual profile caching with regression tests

### UI — UI-Chat
- `136b1a7` (2026-11-03): Protect adaptive graphics hysteresis and visual profile caching with regression tests

### Gameplay — Gameplay-/Talent-Chat
- `0b3d1a1` (2026-11-03): ci(android): gate APK export on all nine forest model and animation presenter tests
- `bdef4c4` (2026-11-03): fix(formation): space four heroes and companions to reduce visual overlap
- `b181c17` (2026-11-03): fix(camera): widen portrait combat framing to reveal team and enemies
- `7291f97` (2026-11-03): Scale down more aggressively on severe sustained combat FPS drops
- `136b1a7` (2026-11-03): Protect adaptive graphics hysteresis and visual profile caching with regression tests

### Skills und Animationen — Skills-und-Animationen-Chat
- `cd99659` (2026-11-03): Keep prewarmed boss and interrupt cues resident in bounded LRU cache (#24)
- `c848cd7` (2026-11-03): feat(chibi): add distinct spellcasting gestures for six magic classes
- `136b1a7` (2026-11-03): Protect adaptive graphics hysteresis and visual profile caching with regression tests

### Grafiktreiber / Rendering — Grafiktreiber-Chat
- `efcaa3c` (2026-11-03): Test adaptive resolution steps for severe sustained FPS drops
- `7291f97` (2026-11-03): Scale down more aggressively on severe sustained combat FPS drops
- `136b1a7` (2026-11-03): Protect adaptive graphics hysteresis and visual profile caching with regression tests

### Titan Chat / Moderation — Titan-Chat-Chat
- `94d8bf2` (2026-11-03): Regression-test admin revocation clearing cached private evidence
- `136b1a7` (2026-11-03): Protect adaptive graphics hysteresis and visual profile caching with regression tests

### Audio — Audio-Erstellung-Chat
- `cd99659` (2026-11-03): Keep prewarmed boss and interrupt cues resident in bounded LRU cache (#24)
- `136b1a7` (2026-11-03): Protect adaptive graphics hysteresis and visual profile caching with regression tests

### APK-Gesamtbuild — APK-Erstellung-des-gesamten-Projekts-Chat
- `0b3d1a1` (2026-11-03): ci(android): gate APK export on all nine forest model and animation presenter tests
- `136b1a7` (2026-11-03): Protect adaptive graphics hysteresis and visual profile caching with regression tests

### Integration/CI — GitHub-/Integrations-Chat
- `0b3d1a1` (2026-11-03): ci(android): gate APK export on all nine forest model and animation presenter tests
- `136b1a7` (2026-11-03): Protect adaptive graphics hysteresis and visual profile caching with regression tests

## Bereichsübergreifende Änderungen

- `f603da3` (2026-11-03): fix(forest-ci): defer runtime test until SceneTree children can run _ready

## Regeln für alle Fach-Chats

1. Vor Arbeitsbeginn `PROJECT_COORDINATION.md`, `VISUAL_QUALITY_GATE.md` und diese Datei lesen.
2. Eigene Änderungen mit aussagekräftigen Commit-Meldungen und möglichst getrennten Dateien einreichen.
3. Bei Konflikten oder Abhängigkeiten einen GitHub-Issue/PR mit betroffenen Bereichen anlegen.
4. Erfolge nur anhand der zugehörigen GitHub-Actions-Läufe melden; diese Übersicht klassifiziert Commits, nicht deren Qualität.

## Aktuelle Prüfläufe

Siehe [GitHub Actions](https://github.com/xynewageyx/TitanLegend/actions) für den tatsächlichen aktuellen Status.
