# Titan Legends – Gemeinsamer Live-Projektstatus

Automatisch erzeugt: **2026-11-03 17:03 UTC**
Git-Stand: **40fcbff4ba5a32450868e370049aabb19f908d3b** auf Branch **main**

> Diese Datei wird nach Repository-Änderungen aktualisiert. Sie synchronisiert keine Chat-Verläufe und beweist keine bestandenen Tests. Jeder Fach-Chat liest sie vor der Arbeit und dokumentiert eigene Änderungen per GitHub-Commit.

## Zuständigkeiten und letzte Änderungen

### Charaktere — Charaktere-Chat
- `312f754` (2026-11-03): feat(animation): differentiate melee, hunter and caster attack poses across classes
- `de9b92d` (2026-11-03): Generate eleven original chibi hero GLB assets
- `06c0cfc` (2026-11-03): fix(animation): add quarter-cycle keyframes so walk and idle actually move

### Gegner/Bosse — Gegner-/Boss-Chat
- `40fcbff` (2026-11-03): Duck music and ambience while boss warning plays (#21)
- `b58b0bc` (2026-11-03): Reserve an audio channel for critical boss cast warnings (#20)
- `79a13fc` (2026-11-03): fix(forest): preserve defeated forest enemies briefly before next encounter

### Landschaften — Landschaften-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### Ausrüstung — Ausrüstungs-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### UI — UI-Chat
- `7cfdf7c` (2026-11-03): Require server access response before displaying moderation menu
- `938ba6b` (2026-11-03): Add server-authorized moderation menu access handshake

### Gameplay — Gameplay-/Talent-Chat
- `80e3399` (2026-11-03): test(talents): cover recovery of malformed saved rank types
- `d52d8b1` (2026-11-03): fix(talents): safely ignore non-integer saved ranks during talent build recovery
- `79a13fc` (2026-11-03): fix(forest): preserve defeated forest enemies briefly before next encounter

### Skills und Animationen — Skills-und-Animationen-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### Grafiktreiber / Rendering — Grafiktreiber-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### Titan Chat / Moderation — Titan-Chat-Chat
- `7cfdf7c` (2026-11-03): Require server access response before displaying moderation menu
- `938ba6b` (2026-11-03): Add server-authorized moderation menu access handshake

### Audio — Audio-Erstellung-Chat
- `40fcbff` (2026-11-03): Duck music and ambience while boss warning plays (#21)
- `b58b0bc` (2026-11-03): Reserve an audio channel for critical boss cast warnings (#20)

### Integration/CI — GitHub-/Integrations-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

## Bereichsübergreifende Änderungen

- `b69cf80` (2026-11-03): Add pause and resume controls to developer-only FPS measurements
- `5c4cb92` (2026-11-03): Show elapsed measurement time in developer FPS overlay

## Regeln für alle Fach-Chats

1. Vor Arbeitsbeginn `PROJECT_COORDINATION.md`, `VISUAL_QUALITY_GATE.md` und diese Datei lesen.
2. Eigene Änderungen mit aussagekräftigen Commit-Meldungen und möglichst getrennten Dateien einreichen.
3. Bei Konflikten oder Abhängigkeiten einen GitHub-Issue/PR mit betroffenen Bereichen anlegen.
4. Erfolge nur anhand der zugehörigen GitHub-Actions-Läufe melden; diese Übersicht klassifiziert Commits, nicht deren Qualität.

## Aktuelle Prüfläufe

Siehe [GitHub Actions](https://github.com/xynewageyx/TitanLegend/actions) für den tatsächlichen aktuellen Status.
