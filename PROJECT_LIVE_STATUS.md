# Titan Legends – Gemeinsamer Live-Projektstatus

Automatisch erzeugt: **2026-11-03 17:23 UTC**
Git-Stand: **86564a9769f42628e655e28922dcccb256483619** auf Branch **main**

> Diese Datei wird nach Repository-Änderungen aktualisiert. Sie synchronisiert keine Chat-Verläufe und beweist keine bestandenen Tests. Jeder Fach-Chat liest sie vor der Arbeit und dokumentiert eigene Änderungen per GitHub-Commit.

## Zuständigkeiten und letzte Änderungen

### Charaktere — Charaktere-Chat
- `3401585` (2026-11-03): Generate eleven original chibi hero GLB assets
- `fe681ec` (2026-11-03): test(chibi): verify five named animation clips and rotation channels in each GLB
- `0575c6d` (2026-11-03): Generate eleven original chibi hero GLB assets

### Gegner/Bosse — Gegner-/Boss-Chat
- `fee4740` (2026-11-03): test(forest): verify the actual BattleManager presenter loads and plays all nine enemy models
- `0575c6d` (2026-11-03): Generate eleven original chibi hero GLB assets

### Landschaften — Landschaften-Chat
- `0575c6d` (2026-11-03): Generate eleven original chibi hero GLB assets

### Ausrüstung — Ausrüstungs-Chat
- `0575c6d` (2026-11-03): Generate eleven original chibi hero GLB assets

### UI — UI-Chat
- `0575c6d` (2026-11-03): Generate eleven original chibi hero GLB assets

### Gameplay — Gameplay-/Talent-Chat
- `be50c1a` (2026-11-03): test(talents): guard safe counting of malformed saved rank values
- `db23d37` (2026-11-03): fix(talents): safely count spent ranks when legacy saved data has invalid types
- `fee4740` (2026-11-03): test(forest): verify the actual BattleManager presenter loads and plays all nine enemy models
- `c3001a2` (2026-11-03): ci(forest): run animation validation on battle and visual controller changes
- `f56ba0c` (2026-11-03): Avoid redundant combat visual updates during adaptive resolution changes

### Skills und Animationen — Skills-und-Animationen-Chat
- `0575c6d` (2026-11-03): Generate eleven original chibi hero GLB assets

### Grafiktreiber / Rendering — Grafiktreiber-Chat
- `f56ba0c` (2026-11-03): Avoid redundant combat visual updates during adaptive resolution changes
- `0ef3b48` (2026-11-03): Test deduplicated scene visual cleanup connections
- `8cada32` (2026-11-03): Prevent duplicate visual cleanup signal connections during scene cache rebuilds
- `0575c6d` (2026-11-03): Generate eleven original chibi hero GLB assets

### Titan Chat / Moderation — Titan-Chat-Chat
- `0575c6d` (2026-11-03): Generate eleven original chibi hero GLB assets

### Audio — Audio-Erstellung-Chat
- `652b325` (2026-11-03): Avoid updating SFX player volumes on every ambience and ducking tween frame (#22)
- `0575c6d` (2026-11-03): Generate eleven original chibi hero GLB assets

### Integration/CI — GitHub-/Integrations-Chat
- `c3001a2` (2026-11-03): ci(forest): run animation validation on battle and visual controller changes
- `0575c6d` (2026-11-03): Generate eleven original chibi hero GLB assets

## Bereichsübergreifende Änderungen

- Keine in den letzten 15 Commits.

## Regeln für alle Fach-Chats

1. Vor Arbeitsbeginn `PROJECT_COORDINATION.md`, `VISUAL_QUALITY_GATE.md` und diese Datei lesen.
2. Eigene Änderungen mit aussagekräftigen Commit-Meldungen und möglichst getrennten Dateien einreichen.
3. Bei Konflikten oder Abhängigkeiten einen GitHub-Issue/PR mit betroffenen Bereichen anlegen.
4. Erfolge nur anhand der zugehörigen GitHub-Actions-Läufe melden; diese Übersicht klassifiziert Commits, nicht deren Qualität.

## Aktuelle Prüfläufe

Siehe [GitHub Actions](https://github.com/xynewageyx/TitanLegend/actions) für den tatsächlichen aktuellen Status.
