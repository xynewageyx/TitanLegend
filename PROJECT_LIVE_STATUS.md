# Titan Legends – Gemeinsamer Live-Projektstatus

Automatisch erzeugt: **2026-11-03 18:06 UTC**
Git-Stand: **cd996590bfbc7941e9e8beacaba1a8516448f98e** auf Branch **main**

> Diese Datei wird nach Repository-Änderungen aktualisiert. Sie synchronisiert keine Chat-Verläufe und beweist keine bestandenen Tests. Jeder Fach-Chat liest sie vor der Arbeit und dokumentiert eigene Änderungen per GitHub-Commit.

## Zuständigkeiten und letzte Änderungen

### Charaktere — Charaktere-Chat
- `c848cd7` (2026-11-03): feat(chibi): add distinct spellcasting gestures for six magic classes
- `27b2a71` (2026-11-03): Generate eleven original chibi hero GLB assets
- `c85b6ac` (2026-11-03): feat(chibi): add full-body hit recoil and coordinated dodge poses
- `18cf7e9` (2026-11-03): Preload critical boss and interrupt sounds into bounded audio cache (#23)

### Gegner/Bosse — Gegner-/Boss-Chat
- `cd99659` (2026-11-03): Keep prewarmed boss and interrupt cues resident in bounded LRU cache (#24)
- `18cf7e9` (2026-11-03): Preload critical boss and interrupt sounds into bounded audio cache (#23)

### Landschaften — Landschaften-Chat
- `18cf7e9` (2026-11-03): Preload critical boss and interrupt sounds into bounded audio cache (#23)

### Ausrüstung — Ausrüstungs-Chat
- `18cf7e9` (2026-11-03): Preload critical boss and interrupt sounds into bounded audio cache (#23)

### UI — UI-Chat
- `18cf7e9` (2026-11-03): Preload critical boss and interrupt sounds into bounded audio cache (#23)

### Gameplay — Gameplay-/Talent-Chat
- `18cf7e9` (2026-11-03): Preload critical boss and interrupt sounds into bounded audio cache (#23)

### Skills und Animationen — Skills-und-Animationen-Chat
- `cd99659` (2026-11-03): Keep prewarmed boss and interrupt cues resident in bounded LRU cache (#24)
- `c848cd7` (2026-11-03): feat(chibi): add distinct spellcasting gestures for six magic classes
- `18cf7e9` (2026-11-03): Preload critical boss and interrupt sounds into bounded audio cache (#23)

### Grafiktreiber / Rendering — Grafiktreiber-Chat
- `136b1a7` (2026-11-03): Protect adaptive graphics hysteresis and visual profile caching with regression tests
- `f04d319` (2026-11-03): React to sustained Android FPS drops after two sampling windows
- `18cf7e9` (2026-11-03): Preload critical boss and interrupt sounds into bounded audio cache (#23)

### Titan Chat / Moderation — Titan-Chat-Chat
- `864e697` (2026-11-03): Run moderation scene validation on pull requests as well as pushes
- `81065c8` (2026-11-03): Clear cached private moderation evidence when admin access is revoked
- `8e51a79` (2026-11-03): Test rejection of peer account identity switching and privilege escalation
- `da453fa` (2026-11-03): Prevent moderation peer identity switching within authenticated session
- `18cf7e9` (2026-11-03): Preload critical boss and interrupt sounds into bounded audio cache (#23)

### Audio — Audio-Erstellung-Chat
- `cd99659` (2026-11-03): Keep prewarmed boss and interrupt cues resident in bounded LRU cache (#24)
- `18cf7e9` (2026-11-03): Preload critical boss and interrupt sounds into bounded audio cache (#23)

### Integration/CI — GitHub-/Integrations-Chat
- `864e697` (2026-11-03): Run moderation scene validation on pull requests as well as pushes
- `18cf7e9` (2026-11-03): Preload critical boss and interrupt sounds into bounded audio cache (#23)

## Bereichsübergreifende Änderungen

- `f603da3` (2026-11-03): fix(forest-ci): defer runtime test until SceneTree children can run _ready

## Regeln für alle Fach-Chats

1. Vor Arbeitsbeginn `PROJECT_COORDINATION.md`, `VISUAL_QUALITY_GATE.md` und diese Datei lesen.
2. Eigene Änderungen mit aussagekräftigen Commit-Meldungen und möglichst getrennten Dateien einreichen.
3. Bei Konflikten oder Abhängigkeiten einen GitHub-Issue/PR mit betroffenen Bereichen anlegen.
4. Erfolge nur anhand der zugehörigen GitHub-Actions-Läufe melden; diese Übersicht klassifiziert Commits, nicht deren Qualität.

## Aktuelle Prüfläufe

Siehe [GitHub Actions](https://github.com/xynewageyx/TitanLegend/actions) für den tatsächlichen aktuellen Status.
