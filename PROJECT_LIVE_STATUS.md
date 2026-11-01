# Titan Legends – Gemeinsamer Live-Projektstatus

Automatisch erzeugt: **2026-11-01 17:30 UTC**
Git-Stand: **e987497945e04fd83a23bdb082db1352b848d17e** auf Branch **main**

> Diese Datei wird nach Repository-Änderungen aktualisiert. Sie synchronisiert keine Chat-Verläufe und beweist keine bestandenen Tests. Jeder Fach-Chat liest sie vor der Arbeit und dokumentiert eigene Änderungen per GitHub-Commit.

## Zuständigkeiten und letzte Änderungen

### Charaktere — Charaktere-Chat
- \`07c83e8\` (2026-11-01): Correct Blender armature cleanup and explicit NLA strip frame ranges
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
- \`e987497\` (2026-11-01): ui(talents): wrap long stats and expand two-column touch targets on narrow Android screens

### Integration/CI — GitHub-/Integrations-Chat
- \`e23c106\` (2026-11-01): Add Blender round-trip import verification step to chibi workflow
- \`d6441d2\` (2026-11-01): ci: add event-driven shared project coordination
- \`ace0b1e\` (2026-11-01): ci: run eleven-class chibi GLB integration regressions on every validation
- \`5614d01\` (2026-11-01): ci: install numpy for Blender chibi GLB exporter

## Bereichsübergreifende Änderungen

- \`739d317\` (2026-11-01): Verify generated hero GLBs round-trip through Blender with armatures and skinning
- \`b4d2417\` (2026-11-01): ci: add event-driven shared project coordination
- \`4e98e04\` (2026-11-01): docs: add shared Android visual quality gate
- \`f2a3669\` (2026-11-01): assets: update generated animated warrior GLB

## Regeln für alle Fach-Chats

1. Vor Arbeitsbeginn \`PROJECT_COORDINATION.md\`, \`VISUAL_QUALITY_GATE.md\` und diese Datei lesen.
2. Eigene Änderungen mit aussagekräftigen Commit-Meldungen und möglichst getrennten Dateien einreichen.
3. Bei Konflikten oder Abhängigkeiten einen GitHub-Issue/PR mit betroffenen Bereichen anlegen.
4. Erfolge nur anhand der zugehörigen GitHub-Actions-Läufe melden; diese Übersicht klassifiziert Commits, nicht deren Qualität.

## Aktuelle Prüfläufe

Siehe [GitHub Actions](https://github.com/xynewageyx/TitanLegend/actions) für den tatsächlichen aktuellen Status.
