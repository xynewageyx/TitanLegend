# Titan Legends – Gemeinsamer Live-Projektstatus

Automatisch erzeugt: **2026-11-01 19:59 UTC**
Git-Stand: **cd45980c48921f75c2bfac7f05f9cbbdd2f34376** auf Branch **main**

> Diese Datei wird nach Repository-Änderungen aktualisiert. Sie synchronisiert keine Chat-Verläufe und beweist keine bestandenen Tests. Jeder Fach-Chat liest sie vor der Arbeit und dokumentiert eigene Änderungen per GitHub-Commit.

## Zuständigkeiten und letzte Änderungen

### Charaktere — Charaktere-Chat
- \`dcc9150\` (2026-11-01): Correct left-right limb skinning by mesh coordinates and parent generated meshes to rig
- \`42ae25d\` (2026-11-01): art(forest): remove redundant primitive limbs when sculpted connected limbs replace them

### Gegner/Bosse — Gegner-/Boss-Chat
- \`42ae25d\` (2026-11-01): art(forest): remove redundant primitive limbs when sculpted connected limbs replace them

### Landschaften — Landschaften-Chat
- Keine passenden Änderungen in den letzten 15 Commits.

### Ausrüstung — Ausrüstungs-Chat
- Keine passenden Änderungen in den letzten 15 Commits.

### UI — UI-Chat
- Keine passenden Änderungen in den letzten 15 Commits.

### Gameplay — Gameplay-/Talent-Chat
- \`a246df6\` (2026-11-01): fix(talents): reject invalid negative ranks before spending earned talent points
- \`d15182f\` (2026-11-01): ui(talents): enlarge hero and branch selectors and follow focused talent buttons on Android

### Skills und Animationen — Skills-und-Animationen-Chat
- Keine passenden Änderungen in den letzten 15 Commits.

### Integration/CI — GitHub-/Integrations-Chat
- \`cd45980\` (2026-11-01): test(talents): guard invalid rank rejection and Android talent navigation regressions

## Bereichsübergreifende Änderungen

- \`b5d6c3a\` (2026-11-01): ci(coordination): monitor skills and animations changes as dedicated area
- \`e49f80b\` (2026-11-01): Check all four limb skin-weight groups after GLB round-trip
- \`a7d44a3\` (2026-11-01): docs(coordination): register skills and animation chat with interfaces

## Regeln für alle Fach-Chats

1. Vor Arbeitsbeginn \`PROJECT_COORDINATION.md\`, \`VISUAL_QUALITY_GATE.md\` und diese Datei lesen.
2. Eigene Änderungen mit aussagekräftigen Commit-Meldungen und möglichst getrennten Dateien einreichen.
3. Bei Konflikten oder Abhängigkeiten einen GitHub-Issue/PR mit betroffenen Bereichen anlegen.
4. Erfolge nur anhand der zugehörigen GitHub-Actions-Läufe melden; diese Übersicht klassifiziert Commits, nicht deren Qualität.

## Aktuelle Prüfläufe

Siehe [GitHub Actions](https://github.com/xynewageyx/TitanLegend/actions) für den tatsächlichen aktuellen Status.
