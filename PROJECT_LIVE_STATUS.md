# Titan Legends – Gemeinsamer Live-Projektstatus

Automatisch erzeugt: **2026-11-01 17:20 UTC**
Git-Stand: **d6441d217c8cebc0acfcc97ed3e9954208fd6032** auf Branch **main**

> Diese Datei wird nach Repository-Änderungen aktualisiert. Sie synchronisiert keine Chat-Verläufe und beweist keine bestandenen Tests. Jeder Fach-Chat liest sie vor der Arbeit und dokumentiert eigene Änderungen per GitHub-Commit.

## Zuständigkeiten und letzte Änderungen

### Charaktere — Charaktere-Chat
- \`804bd81\` (2026-11-01): art(forest): sculpt species-specific asymmetric primary body silhouettes
- \`9ac4060\` (2026-11-01): Generate eleven original chibi hero GLB assets

### Gegner/Bosse — Gegner-/Boss-Chat
- \`804bd81\` (2026-11-01): art(forest): sculpt species-specific asymmetric primary body silhouettes

### Landschaften — Landschaften-Chat
- Keine passenden Änderungen in den letzten 15 Commits.

### Ausrüstung — Ausrüstungs-Chat
- Keine passenden Änderungen in den letzten 15 Commits.

### UI — UI-Chat
- Keine passenden Änderungen in den letzten 15 Commits.

### Gameplay — Gameplay-/Talent-Chat
- \`626d625\` (2026-11-01): Prevent overlapping imported warrior GLBs when new chibi model exists
- \`b8fefe4\` (2026-11-01): Load generated chibi GLB models for all eleven classes when available

### Integration/CI — GitHub-/Integrations-Chat
- \`d6441d2\` (2026-11-01): ci: add event-driven shared project coordination
- \`ace0b1e\` (2026-11-01): ci: run eleven-class chibi GLB integration regressions on every validation
- \`5614d01\` (2026-11-01): ci: install numpy for Blender chibi GLB exporter
- \`993d5bd\` (2026-11-01): Make Blender generation self-triggering and upload GLB artifacts for inspection
- \`b0fcd48\` (2026-11-01): Add regression coverage for optional eleven-class chibi GLB integration

## Bereichsübergreifende Änderungen

- \`b4d2417\` (2026-11-01): ci: add event-driven shared project coordination
- \`4e98e04\` (2026-11-01): docs: add shared Android visual quality gate
- \`f2a3669\` (2026-11-01): assets: update generated animated warrior GLB
- \`1ce2f92\` (2026-11-01): docs: establish shared Titan Legends coordination rules
- \`9da5a6f\` (2026-11-01): Add optional sculpted chibi GLB visual with animation state bridge

## Regeln für alle Fach-Chats

1. Vor Arbeitsbeginn \`PROJECT_COORDINATION.md\`, \`VISUAL_QUALITY_GATE.md\` und diese Datei lesen.
2. Eigene Änderungen mit aussagekräftigen Commit-Meldungen und möglichst getrennten Dateien einreichen.
3. Bei Konflikten oder Abhängigkeiten einen GitHub-Issue/PR mit betroffenen Bereichen anlegen.
4. Erfolge nur anhand der zugehörigen GitHub-Actions-Läufe melden; diese Übersicht klassifiziert Commits, nicht deren Qualität.

## Aktuelle Prüfläufe

Siehe [GitHub Actions](https://github.com/xynewageyx/TitanLegend/actions) für den tatsächlichen aktuellen Status.
