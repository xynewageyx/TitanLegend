# Titan Legends – Gemeinsamer Live-Projektstatus

Automatisch erzeugt: **2026-11-03 19:43 UTC**
Git-Stand: **5d2bd06eff4ffb146c6dada681113d03770ff371** auf Branch **main**

> Diese Datei wird nach Repository-Änderungen aktualisiert. Sie synchronisiert keine Chat-Verläufe und beweist keine bestandenen Tests. Jeder Fach-Chat liest sie vor der Arbeit und dokumentiert eigene Änderungen per GitHub-Commit.

## Zuständigkeiten und letzte Änderungen

### Charaktere — Charaktere-Chat
- `bdef4c4` (2026-11-03): fix(formation): space four heroes and companions to reduce visual overlap
- `6925c8c` (2026-11-03): Generate eleven original chibi hero GLB assets

### Gegner/Bosse — Gegner-/Boss-Chat
- `b181c17` (2026-11-03): fix(camera): widen portrait combat framing to reveal team and enemies

### Landschaften — Landschaften-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### Ausrüstung — Ausrüstungs-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### UI — UI-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### Gameplay — Gameplay-/Talent-Chat
- `0b3d1a1` (2026-11-03): ci(android): gate APK export on all nine forest model and animation presenter tests
- `bdef4c4` (2026-11-03): fix(formation): space four heroes and companions to reduce visual overlap
- `b181c17` (2026-11-03): fix(camera): widen portrait combat framing to reveal team and enemies

### Skills und Animationen — Skills-und-Animationen-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### Grafiktreiber / Rendering — Grafiktreiber-Chat
- `9ad6e49` (2026-11-03): Guard developer-only FPS overlay and render-scale diagnostics with regression test

### Titan Chat / Moderation — Titan-Chat-Chat
- `5d2bd06` (2026-11-03): Test owner-access grants and revocation for authenticated peers
- `fe4e08f` (2026-11-03): Use centralized peer authorization for admin access RPC
- `20d9171` (2026-11-03): Centralize server owner-access check in authenticated peer authority
- `56296b7` (2026-11-03): Revoke moderation access immediately on trusted server logout
- `d3ebfa7` (2026-11-03): Provide trusted login callback for binding verified moderation peer identities

### Audio — Audio-Erstellung-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### APK-Gesamtbuild — APK-Erstellung-des-gesamten-Projekts-Chat
- `596af15` (2026-11-03): Show requested 3D render scale and compact two-line FPS metrics in developer-only APK
- `d1f5f2a` (2026-11-03): Keep developer FPS APKs out of public releases and isolate their build concurrency
- `0b3d1a1` (2026-11-03): ci(android): gate APK export on all nine forest model and animation presenter tests

### Integration/CI — GitHub-/Integrations-Chat
- `d1f5f2a` (2026-11-03): Keep developer FPS APKs out of public releases and isolate their build concurrency
- `0b3d1a1` (2026-11-03): ci(android): gate APK export on all nine forest model and animation presenter tests

## Bereichsübergreifende Änderungen

- `422cd4c` (2026-11-03): fix(forest): loop idle and return to idle after hit or attack while preserving death state

## Regeln für alle Fach-Chats

1. Vor Arbeitsbeginn `PROJECT_COORDINATION.md`, `VISUAL_QUALITY_GATE.md` und diese Datei lesen.
2. Eigene Änderungen mit aussagekräftigen Commit-Meldungen und möglichst getrennten Dateien einreichen.
3. Bei Konflikten oder Abhängigkeiten einen GitHub-Issue/PR mit betroffenen Bereichen anlegen.
4. Erfolge nur anhand der zugehörigen GitHub-Actions-Läufe melden; diese Übersicht klassifiziert Commits, nicht deren Qualität.

## Aktuelle Prüfläufe

Siehe [GitHub Actions](https://github.com/xynewageyx/TitanLegend/actions) für den tatsächlichen aktuellen Status.
