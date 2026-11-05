# Titan Legends – Gemeinsamer Live-Projektstatus

Automatisch erzeugt: **2026-11-05 17:05 UTC**
Git-Stand: **b46fd149b49399255c76b766bfed1a04a0444aef** auf Branch **main**

> Diese Datei wird nach Repository-Änderungen aktualisiert. Sie synchronisiert keine Chat-Verläufe und beweist keine bestandenen Tests. Jeder Fach-Chat liest sie vor der Arbeit und dokumentiert eigene Änderungen per GitHub-Commit.

## Zuständigkeiten und letzte Änderungen

### Charaktere — Charaktere-Chat
- `89a61c1` (2026-11-05): test(talents): validate every hero build before persistence
- `9354605` (2026-11-05): fix(talents): normalize all four hero talent builds before persisting edits
- `7bc7479` (2026-11-05): Add reusable Chibi animation controller for imported idle walk attack hit dodge clips
- `b2d185e` (2026-11-05): Add regression tests for five Chibi action types and numbered clip variants

### Gegner/Bosse — Gegner-/Boss-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### Landschaften — Landschaften-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### Ausrüstung — Ausrüstungs-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### UI — UI-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### Gameplay — Gameplay-/Talent-Chat
- `89a61c1` (2026-11-05): test(talents): validate every hero build before persistence
- `9354605` (2026-11-05): fix(talents): normalize all four hero talent builds before persisting edits
- `f55da2b` (2026-11-05): test(forest): assert idle loops and combat animations remain one-shot

### Skills und Animationen — Skills-und-Animationen-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### Grafiktreiber / Rendering — Grafiktreiber-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### Titan Chat / Moderation — Titan-Chat-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### Audio — Audio-Erstellung-Chat
- `e628317` (2026-11-05): Fix Godot editor audio inspector plugin script path (#31)

### APK-Gesamtbuild — APK-Erstellung-des-gesamten-Projekts-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

### Integration/CI — GitHub-/Integrations-Chat
- Keine eindeutig zugeordneten Änderungen in den letzten 30 Commits (kein Nachweis für Inaktivität).

## Bereichsübergreifende Änderungen

- `b46fd14` (2026-11-05): Mount opt-in Android multiplayer client in main scene
- `8193537` (2026-11-05): Report per-class Attack Dodge Hit Idle Walk clip coverage
- `d6bbc54` (2026-11-05): fix(forest): force one-shot attack hit death clips and prevent death restart
- `785eb5f` (2026-11-05): Restore complete 33-case AnimationPlayer smoke test after accidental truncation

## Regeln für alle Fach-Chats

1. Vor Arbeitsbeginn `PROJECT_COORDINATION.md`, `VISUAL_QUALITY_GATE.md` und diese Datei lesen.
2. Eigene Änderungen mit aussagekräftigen Commit-Meldungen und möglichst getrennten Dateien einreichen.
3. Bei Konflikten oder Abhängigkeiten einen GitHub-Issue/PR mit betroffenen Bereichen anlegen.
4. Erfolge nur anhand der zugehörigen GitHub-Actions-Läufe melden; diese Übersicht klassifiziert Commits, nicht deren Qualität.

## Aktuelle Prüfläufe

Siehe [GitHub Actions](https://github.com/xynewageyx/TitanLegend/actions) für den tatsächlichen aktuellen Status.
