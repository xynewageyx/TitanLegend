# Titan Legends – Gemeinsamer Live-Projektstatus

Automatisch erzeugt: **2026-11-05 17:43 UTC**
Git-Stand: **9c5be79dc120afd43c0f7434b50892cb856b6f47** auf Branch **main**

> Diese Datei wird nach Repository-Änderungen aktualisiert. Sie synchronisiert keine Chat-Verläufe und beweist keine bestandenen Tests. Jeder Fach-Chat liest sie vor der Arbeit und dokumentiert eigene Änderungen per GitHub-Commit.

## Zuständigkeiten und letzte Änderungen

### Charaktere — Charaktere-Chat
- `9c5be79` (2026-11-05): Smoke-test Chibi animation controller on all 11 imported hero models
- `89a61c1` (2026-11-05): test(talents): validate every hero build before persistence
- `9354605` (2026-11-05): fix(talents): normalize all four hero talent builds before persisting edits
- `7bc7479` (2026-11-05): Add reusable Chibi animation controller for imported idle walk attack hit dodge clips
- `b2d185e` (2026-11-05): Add regression tests for five Chibi action types and numbered clip variants

### Gegner/Bosse — Gegner-/Boss-Chat
- `f55da2b` (2026-11-05): test(forest): assert idle loops and combat animations remain one-shot

### Landschaften — Landschaften-Chat
- `f55da2b` (2026-11-05): test(forest): assert idle loops and combat animations remain one-shot

### Ausrüstung — Ausrüstungs-Chat
- `f55da2b` (2026-11-05): test(forest): assert idle loops and combat animations remain one-shot

### UI — UI-Chat
- `19afe28` (2026-11-05): feat(talents): refresh open talent menu when team data changes
- `f55da2b` (2026-11-05): test(forest): assert idle loops and combat animations remain one-shot

### Gameplay — Gameplay-/Talent-Chat
- `19afe28` (2026-11-05): feat(talents): refresh open talent menu when team data changes
- `89a61c1` (2026-11-05): test(talents): validate every hero build before persistence
- `9354605` (2026-11-05): fix(talents): normalize all four hero talent builds before persisting edits
- `f55da2b` (2026-11-05): test(forest): assert idle loops and combat animations remain one-shot

### Skills und Animationen — Skills-und-Animationen-Chat
- `f55da2b` (2026-11-05): test(forest): assert idle loops and combat animations remain one-shot

### Grafiktreiber / Rendering — Grafiktreiber-Chat
- `f55da2b` (2026-11-05): test(forest): assert idle loops and combat animations remain one-shot

### Titan Chat / Moderation — Titan-Chat-Chat
- `f55da2b` (2026-11-05): test(forest): assert idle loops and combat animations remain one-shot

### Audio — Audio-Erstellung-Chat
- `e628317` (2026-11-05): Fix Godot editor audio inspector plugin script path (#31)
- `f55da2b` (2026-11-05): test(forest): assert idle loops and combat animations remain one-shot

### APK-Gesamtbuild — APK-Erstellung-des-gesamten-Projekts-Chat
- `f55da2b` (2026-11-05): test(forest): assert idle loops and combat animations remain one-shot

### Integration/CI — GitHub-/Integrations-Chat
- `f55da2b` (2026-11-05): test(forest): assert idle loops and combat animations remain one-shot

## Bereichsübergreifende Änderungen

- `b46fd14` (2026-11-05): Mount opt-in Android multiplayer client in main scene
- `8193537` (2026-11-05): Report per-class Attack Dodge Hit Idle Walk clip coverage

## Regeln für alle Fach-Chats

1. Vor Arbeitsbeginn `PROJECT_COORDINATION.md`, `VISUAL_QUALITY_GATE.md` und diese Datei lesen.
2. Eigene Änderungen mit aussagekräftigen Commit-Meldungen und möglichst getrennten Dateien einreichen.
3. Bei Konflikten oder Abhängigkeiten einen GitHub-Issue/PR mit betroffenen Bereichen anlegen.
4. Erfolge nur anhand der zugehörigen GitHub-Actions-Läufe melden; diese Übersicht klassifiziert Commits, nicht deren Qualität.

## Aktuelle Prüfläufe

Siehe [GitHub Actions](https://github.com/xynewageyx/TitanLegend/actions) für den tatsächlichen aktuellen Status.
