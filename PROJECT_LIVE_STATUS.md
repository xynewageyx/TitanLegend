# Titan Legends – Gemeinsamer Live-Projektstatus

Automatisch erzeugt: **2026-11-03 18:19 UTC**
Git-Stand: **08588d9dd2a127562fba564f7dac37b89af4a857** auf Branch **main**

> Diese Datei wird nach Repository-Änderungen aktualisiert. Sie synchronisiert keine Chat-Verläufe und beweist keine bestandenen Tests. Jeder Fach-Chat liest sie vor der Arbeit und dokumentiert eigene Änderungen per GitHub-Commit.

## Zuständigkeiten und letzte Änderungen

### Charaktere — Charaktere-Chat
- `c848cd7` (2026-11-03): feat(chibi): add distinct spellcasting gestures for six magic classes
- `27b2a71` (2026-11-03): Generate eleven original chibi hero GLB assets
- `81065c8` (2026-11-03): Clear cached private moderation evidence when admin access is revoked

### Gegner/Bosse — Gegner-/Boss-Chat
- `cd99659` (2026-11-03): Keep prewarmed boss and interrupt cues resident in bounded LRU cache (#24)
- `81065c8` (2026-11-03): Clear cached private moderation evidence when admin access is revoked

### Landschaften — Landschaften-Chat
- `81065c8` (2026-11-03): Clear cached private moderation evidence when admin access is revoked

### Ausrüstung — Ausrüstungs-Chat
- `81065c8` (2026-11-03): Clear cached private moderation evidence when admin access is revoked

### UI — UI-Chat
- `81065c8` (2026-11-03): Clear cached private moderation evidence when admin access is revoked

### Gameplay — Gameplay-/Talent-Chat
- `7291f97` (2026-11-03): Scale down more aggressively on severe sustained combat FPS drops
- `81065c8` (2026-11-03): Clear cached private moderation evidence when admin access is revoked

### Skills und Animationen — Skills-und-Animationen-Chat
- `cd99659` (2026-11-03): Keep prewarmed boss and interrupt cues resident in bounded LRU cache (#24)
- `c848cd7` (2026-11-03): feat(chibi): add distinct spellcasting gestures for six magic classes
- `81065c8` (2026-11-03): Clear cached private moderation evidence when admin access is revoked

### Grafiktreiber / Rendering — Grafiktreiber-Chat
- `efcaa3c` (2026-11-03): Test adaptive resolution steps for severe sustained FPS drops
- `7291f97` (2026-11-03): Scale down more aggressively on severe sustained combat FPS drops
- `136b1a7` (2026-11-03): Protect adaptive graphics hysteresis and visual profile caching with regression tests
- `81065c8` (2026-11-03): Clear cached private moderation evidence when admin access is revoked

### Titan Chat / Moderation — Titan-Chat-Chat
- `94d8bf2` (2026-11-03): Regression-test admin revocation clearing cached private evidence
- `864e697` (2026-11-03): Run moderation scene validation on pull requests as well as pushes
- `81065c8` (2026-11-03): Clear cached private moderation evidence when admin access is revoked

### Audio — Audio-Erstellung-Chat
- `cd99659` (2026-11-03): Keep prewarmed boss and interrupt cues resident in bounded LRU cache (#24)
- `81065c8` (2026-11-03): Clear cached private moderation evidence when admin access is revoked

### APK-Gesamtbuild — APK-Erstellung-des-gesamten-Projekts-Chat
- `81065c8` (2026-11-03): Clear cached private moderation evidence when admin access is revoked

### Integration/CI — GitHub-/Integrations-Chat
- `864e697` (2026-11-03): Run moderation scene validation on pull requests as well as pushes
- `81065c8` (2026-11-03): Clear cached private moderation evidence when admin access is revoked

## Bereichsübergreifende Änderungen

- `f603da3` (2026-11-03): fix(forest-ci): defer runtime test until SceneTree children can run _ready

## Regeln für alle Fach-Chats

1. Vor Arbeitsbeginn `PROJECT_COORDINATION.md`, `VISUAL_QUALITY_GATE.md` und diese Datei lesen.
2. Eigene Änderungen mit aussagekräftigen Commit-Meldungen und möglichst getrennten Dateien einreichen.
3. Bei Konflikten oder Abhängigkeiten einen GitHub-Issue/PR mit betroffenen Bereichen anlegen.
4. Erfolge nur anhand der zugehörigen GitHub-Actions-Läufe melden; diese Übersicht klassifiziert Commits, nicht deren Qualität.

## Aktuelle Prüfläufe

Siehe [GitHub Actions](https://github.com/xynewageyx/TitanLegend/actions) für den tatsächlichen aktuellen Status.
