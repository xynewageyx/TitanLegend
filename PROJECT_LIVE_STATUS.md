# Titan Legends – Gemeinsamer Live-Projektstatus

Automatisch erzeugt: **2026-11-03 17:13 UTC**
Git-Stand: **652b3259a62cc44e1b0246beabecdebe499866c9** auf Branch **main**

> Diese Datei wird nach Repository-Änderungen aktualisiert. Sie synchronisiert keine Chat-Verläufe und beweist keine bestandenen Tests. Jeder Fach-Chat liest sie vor der Arbeit und dokumentiert eigene Änderungen per GitHub-Commit.

## Zuständigkeiten und letzte Änderungen

### Charaktere — Charaktere-Chat
- `fe681ec` (2026-11-03): test(chibi): verify five named animation clips and rotation channels in each GLB
- `0575c6d` (2026-11-03): Generate eleven original chibi hero GLB assets

### Gegner/Bosse — Gegner-/Boss-Chat
- `40fcbff` (2026-11-03): Duck music and ambience while boss warning plays (#21)

### Landschaften — Landschaften-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### Ausrüstung — Ausrüstungs-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### UI — UI-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### Gameplay — Gameplay-/Talent-Chat
- `f56ba0c` (2026-11-03): Avoid redundant combat visual updates during adaptive resolution changes

### Skills und Animationen — Skills-und-Animationen-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### Grafiktreiber / Rendering — Grafiktreiber-Chat
- `f56ba0c` (2026-11-03): Avoid redundant combat visual updates during adaptive resolution changes
- `0ef3b48` (2026-11-03): Test deduplicated scene visual cleanup connections
- `8cada32` (2026-11-03): Prevent duplicate visual cleanup signal connections during scene cache rebuilds
- `108ab6b` (2026-11-03): Regression-test initial graphics cache setup before applying quality
- `8f4766a` (2026-11-03): Apply graphics quality to pre-existing scene lights and particles at startup

### Titan Chat / Moderation — Titan-Chat-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### Audio — Audio-Erstellung-Chat
- `652b325` (2026-11-03): Avoid updating SFX player volumes on every ambience and ducking tween frame (#22)
- `40fcbff` (2026-11-03): Duck music and ambience while boss warning plays (#21)

### Integration/CI — GitHub-/Integrations-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

## Bereichsübergreifende Änderungen

- Keine in den letzten 15 Commits.

## Regeln für alle Fach-Chats

1. Vor Arbeitsbeginn `PROJECT_COORDINATION.md`, `VISUAL_QUALITY_GATE.md` und diese Datei lesen.
2. Eigene Änderungen mit aussagekräftigen Commit-Meldungen und möglichst getrennten Dateien einreichen.
3. Bei Konflikten oder Abhängigkeiten einen GitHub-Issue/PR mit betroffenen Bereichen anlegen.
4. Erfolge nur anhand der zugehörigen GitHub-Actions-Läufe melden; diese Übersicht klassifiziert Commits, nicht deren Qualität.

## Aktuelle Prüfläufe

Siehe [GitHub Actions](https://github.com/xynewageyx/TitanLegend/actions) für den tatsächlichen aktuellen Status.
