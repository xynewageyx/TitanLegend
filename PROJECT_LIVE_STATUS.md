# Titan Legends – Gemeinsamer Live-Projektstatus

Automatisch erzeugt: **2026-11-01 17:37 UTC**
Git-Stand: **42ae25dca321b968a72adc5829778ead84d177b7** auf Branch **main**

> Diese Datei wird nach Repository-Änderungen aktualisiert. Sie synchronisiert keine Chat-Verläufe und beweist keine bestandenen Tests. Jeder Fach-Chat liest sie vor der Arbeit und dokumentiert eigene Änderungen per GitHub-Commit.

## Zuständigkeiten und letzte Änderungen

### Charaktere — Charaktere-Chat
- \`42ae25d\` (2026-11-01): art(forest): remove redundant primitive limbs when sculpted connected limbs replace them
- \`8c72e7b\` (2026-11-01): art(forest): introduce connected tapered limb geometry for all nine forest enemies
- \`07c83e8\` (2026-11-01): Correct Blender armature cleanup and explicit NLA strip frame ranges

### Gegner/Bosse — Gegner-/Boss-Chat
- \`42ae25d\` (2026-11-01): art(forest): remove redundant primitive limbs when sculpted connected limbs replace them
- \`8c72e7b\` (2026-11-01): art(forest): introduce connected tapered limb geometry for all nine forest enemies

### Landschaften — Landschaften-Chat
- Keine passenden Änderungen in den letzten 15 Commits.

### Ausrüstung — Ausrüstungs-Chat
- Keine passenden Änderungen in den letzten 15 Commits.

### UI — UI-Chat
- Keine passenden Änderungen in den letzten 15 Commits.

### Gameplay — Gameplay-/Talent-Chat
- \`6a3204b\` (2026-11-01): fix(talents): guard invalid hero selection and stale upgrade callbacks in Android menu
- \`e987497\` (2026-11-01): ui(talents): wrap long stats and expand two-column touch targets on narrow Android screens

### Integration/CI — GitHub-/Integrations-Chat
- \`e23c106\` (2026-11-01): Add Blender round-trip import verification step to chibi workflow
- \`d6441d2\` (2026-11-01): ci: add event-driven shared project coordination

## Bereichsübergreifende Änderungen

- \`739d317\` (2026-11-01): Verify generated hero GLBs round-trip through Blender with armatures and skinning
- \`b4d2417\` (2026-11-01): ci: add event-driven shared project coordination

## Regeln für alle Fach-Chats

1. Vor Arbeitsbeginn \`PROJECT_COORDINATION.md\`, \`VISUAL_QUALITY_GATE.md\` und diese Datei lesen.
2. Eigene Änderungen mit aussagekräftigen Commit-Meldungen und möglichst getrennten Dateien einreichen.
3. Bei Konflikten oder Abhängigkeiten einen GitHub-Issue/PR mit betroffenen Bereichen anlegen.
4. Erfolge nur anhand der zugehörigen GitHub-Actions-Läufe melden; diese Übersicht klassifiziert Commits, nicht deren Qualität.

## Aktuelle Prüfläufe

Siehe [GitHub Actions](https://github.com/xynewageyx/TitanLegend/actions) für den tatsächlichen aktuellen Status.
