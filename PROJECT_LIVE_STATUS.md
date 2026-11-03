# Titan Legends – Gemeinsamer Live-Projektstatus

Automatisch erzeugt: **2026-11-03 19:02 UTC**
Git-Stand: **d3ebfa718eb910852bb3847f2097a2a60524298c** auf Branch **main**

> Diese Datei wird nach Repository-Änderungen aktualisiert. Sie synchronisiert keine Chat-Verläufe und beweist keine bestandenen Tests. Jeder Fach-Chat liest sie vor der Arbeit und dokumentiert eigene Änderungen per GitHub-Commit.

## Zuständigkeiten und letzte Änderungen

### Charaktere — Charaktere-Chat
- `bdef4c4` (2026-11-03): fix(formation): space four heroes and companions to reduce visual overlap
- `6925c8c` (2026-11-03): Generate eleven original chibi hero GLB assets
- `cd99659` (2026-11-03): Keep prewarmed boss and interrupt cues resident in bounded LRU cache (#24)

### Gegner/Bosse — Gegner-/Boss-Chat
- `b181c17` (2026-11-03): fix(camera): widen portrait combat framing to reveal team and enemies
- `cd99659` (2026-11-03): Keep prewarmed boss and interrupt cues resident in bounded LRU cache (#24)

### Landschaften — Landschaften-Chat
- `cd99659` (2026-11-03): Keep prewarmed boss and interrupt cues resident in bounded LRU cache (#24)

### Ausrüstung — Ausrüstungs-Chat
- `cd99659` (2026-11-03): Keep prewarmed boss and interrupt cues resident in bounded LRU cache (#24)

### UI — UI-Chat
- `cd99659` (2026-11-03): Keep prewarmed boss and interrupt cues resident in bounded LRU cache (#24)

### Gameplay — Gameplay-/Talent-Chat
- `0b3d1a1` (2026-11-03): ci(android): gate APK export on all nine forest model and animation presenter tests
- `bdef4c4` (2026-11-03): fix(formation): space four heroes and companions to reduce visual overlap
- `b181c17` (2026-11-03): fix(camera): widen portrait combat framing to reveal team and enemies
- `7291f97` (2026-11-03): Scale down more aggressively on severe sustained combat FPS drops
- `cd99659` (2026-11-03): Keep prewarmed boss and interrupt cues resident in bounded LRU cache (#24)

### Skills und Animationen — Skills-und-Animationen-Chat
- `cd99659` (2026-11-03): Keep prewarmed boss and interrupt cues resident in bounded LRU cache (#24)

### Grafiktreiber / Rendering — Grafiktreiber-Chat
- `efcaa3c` (2026-11-03): Test adaptive resolution steps for severe sustained FPS drops
- `7291f97` (2026-11-03): Scale down more aggressively on severe sustained combat FPS drops
- `cd99659` (2026-11-03): Keep prewarmed boss and interrupt cues resident in bounded LRU cache (#24)

### Titan Chat / Moderation — Titan-Chat-Chat
- `d3ebfa7` (2026-11-03): Provide trusted login callback for binding verified moderation peer identities
- `94d8bf2` (2026-11-03): Regression-test admin revocation clearing cached private evidence
- `cd99659` (2026-11-03): Keep prewarmed boss and interrupt cues resident in bounded LRU cache (#24)

### Audio — Audio-Erstellung-Chat
- `cd99659` (2026-11-03): Keep prewarmed boss and interrupt cues resident in bounded LRU cache (#24)

### APK-Gesamtbuild — APK-Erstellung-des-gesamten-Projekts-Chat
- `d1f5f2a` (2026-11-03): Keep developer FPS APKs out of public releases and isolate their build concurrency
- `0b3d1a1` (2026-11-03): ci(android): gate APK export on all nine forest model and animation presenter tests
- `cd99659` (2026-11-03): Keep prewarmed boss and interrupt cues resident in bounded LRU cache (#24)

### Integration/CI — GitHub-/Integrations-Chat
- `d1f5f2a` (2026-11-03): Keep developer FPS APKs out of public releases and isolate their build concurrency
- `0b3d1a1` (2026-11-03): ci(android): gate APK export on all nine forest model and animation presenter tests
- `cd99659` (2026-11-03): Keep prewarmed boss and interrupt cues resident in bounded LRU cache (#24)

## Bereichsübergreifende Änderungen

- Keine in den letzten 15 Commits.

## Regeln für alle Fach-Chats

1. Vor Arbeitsbeginn `PROJECT_COORDINATION.md`, `VISUAL_QUALITY_GATE.md` und diese Datei lesen.
2. Eigene Änderungen mit aussagekräftigen Commit-Meldungen und möglichst getrennten Dateien einreichen.
3. Bei Konflikten oder Abhängigkeiten einen GitHub-Issue/PR mit betroffenen Bereichen anlegen.
4. Erfolge nur anhand der zugehörigen GitHub-Actions-Läufe melden; diese Übersicht klassifiziert Commits, nicht deren Qualität.

## Aktuelle Prüfläufe

Siehe [GitHub Actions](https://github.com/xynewageyx/TitanLegend/actions) für den tatsächlichen aktuellen Status.
