# Titan Legends – Gemeinsamer Live-Projektstatus

Automatisch erzeugt: **2026-11-05 16:58 UTC**
Git-Stand: **7bc7479fd5603eed4d220e55efbbbaed49c607f2** auf Branch **main**

> Diese Datei wird nach Repository-Änderungen aktualisiert. Sie synchronisiert keine Chat-Verläufe und beweist keine bestandenen Tests. Jeder Fach-Chat liest sie vor der Arbeit und dokumentiert eigene Änderungen per GitHub-Commit.

## Zuständigkeiten und letzte Änderungen

### Charaktere — Charaktere-Chat
- `7bc7479` (2026-11-05): Add reusable Chibi animation controller for imported idle walk attack hit dodge clips
- `b2d185e` (2026-11-05): Add regression tests for five Chibi action types and numbered clip variants
- `3ecfe9d` (2026-11-05): Fix malformed duplicated block in Chibi AnimationPlayer smoke test
- `db093e4` (2026-11-05): Exercise idle run attack AnimationPlayer bone playback on all Chibi rigs
- `680c8a2` (2026-11-04): Run AnimationPlayer skeleton playback smoke test in CI

### Gegner/Bosse — Gegner-/Boss-Chat
- `680c8a2` (2026-11-04): Run AnimationPlayer skeleton playback smoke test in CI

### Landschaften — Landschaften-Chat
- `680c8a2` (2026-11-04): Run AnimationPlayer skeleton playback smoke test in CI

### Ausrüstung — Ausrüstungs-Chat
- `680c8a2` (2026-11-04): Run AnimationPlayer skeleton playback smoke test in CI

### UI — UI-Chat
- `680c8a2` (2026-11-04): Run AnimationPlayer skeleton playback smoke test in CI

### Gameplay — Gameplay-/Talent-Chat
- `f55da2b` (2026-11-05): test(forest): assert idle loops and combat animations remain one-shot
- `680c8a2` (2026-11-04): Run AnimationPlayer skeleton playback smoke test in CI

### Skills und Animationen — Skills-und-Animationen-Chat
- `680c8a2` (2026-11-04): Run AnimationPlayer skeleton playback smoke test in CI

### Grafiktreiber / Rendering — Grafiktreiber-Chat
- `680c8a2` (2026-11-04): Run AnimationPlayer skeleton playback smoke test in CI

### Titan Chat / Moderation — Titan-Chat-Chat
- `680c8a2` (2026-11-04): Run AnimationPlayer skeleton playback smoke test in CI

### Audio — Audio-Erstellung-Chat
- `680c8a2` (2026-11-04): Run AnimationPlayer skeleton playback smoke test in CI

### APK-Gesamtbuild — APK-Erstellung-des-gesamten-Projekts-Chat
- `680c8a2` (2026-11-04): Run AnimationPlayer skeleton playback smoke test in CI

### Integration/CI — GitHub-/Integrations-Chat
- `680c8a2` (2026-11-04): Run AnimationPlayer skeleton playback smoke test in CI

## Bereichsübergreifende Änderungen

- `8193537` (2026-11-05): Report per-class Attack Dodge Hit Idle Walk clip coverage
- `d6bbc54` (2026-11-05): fix(forest): force one-shot attack hit death clips and prevent death restart
- `785eb5f` (2026-11-05): Restore complete 33-case AnimationPlayer smoke test after accidental truncation
- `f321bc6` (2026-11-05): test(forest): ensure death is terminal and reused presenters reset on respawn

## Regeln für alle Fach-Chats

1. Vor Arbeitsbeginn `PROJECT_COORDINATION.md`, `VISUAL_QUALITY_GATE.md` und diese Datei lesen.
2. Eigene Änderungen mit aussagekräftigen Commit-Meldungen und möglichst getrennten Dateien einreichen.
3. Bei Konflikten oder Abhängigkeiten einen GitHub-Issue/PR mit betroffenen Bereichen anlegen.
4. Erfolge nur anhand der zugehörigen GitHub-Actions-Läufe melden; diese Übersicht klassifiziert Commits, nicht deren Qualität.

## Aktuelle Prüfläufe

Siehe [GitHub Actions](https://github.com/xynewageyx/TitanLegend/actions) für den tatsächlichen aktuellen Status.
