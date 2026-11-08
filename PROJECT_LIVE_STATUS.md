# Titan Legends – Gemeinsamer Live-Projektstatus

Automatisch erzeugt: **2026-11-08 21:05 UTC**
Git-Stand: **1e63335d215da9372989a775f44548c895ef030e** auf Branch **main**

> Diese Datei wird nach Repository-Änderungen aktualisiert. Sie synchronisiert keine Chat-Verläufe und beweist keine bestandenen Tests. Jeder Fach-Chat liest sie vor der Arbeit und dokumentiert eigene Änderungen per GitHub-Commit.

## Zuständigkeiten und letzte Änderungen

### Charaktere — Charaktere-Chat
- `82cba1f` (2026-11-08): fix: decouple imported Chibi equipment sockets and validate 12 GLB rigs (#206)
- `b2254ac` (2026-11-08): Animate live Titan Legends equipment on original GLB rigs (12 classes, 180 sockets) (#193)
- `0af3db6` (2026-11-08): Improve portrait hero HP labels and visual states (#202)

### Gegner/Bosse — Gegner-/Boss-Chat
- `4928963` (2026-11-08): ci(forest): publish Android seven-enemy scene complexity estimate
- `d4b841c` (2026-11-08): feat(forest): estimate seven-enemy Android geometry load from imported model metrics
- `0af3db6` (2026-11-08): Improve portrait hero HP labels and visual states (#202)

### Landschaften — Landschaften-Chat
- `0af3db6` (2026-11-08): Improve portrait hero HP labels and visual states (#202)

### Ausrüstung — Ausrüstungs-Chat
- `358b44a` (2026-11-08): fix: avoid equipment mesh churn on unchanged inventory refresh (#210)
- `82cba1f` (2026-11-08): fix: decouple imported Chibi equipment sockets and validate 12 GLB rigs (#206)
- `b2254ac` (2026-11-08): Animate live Titan Legends equipment on original GLB rigs (12 classes, 180 sockets) (#193)
- `0af3db6` (2026-11-08): Improve portrait hero HP labels and visual states (#202)

### UI — UI-Chat
- `0af3db6` (2026-11-08): Improve portrait hero HP labels and visual states (#202)

### Gameplay — Gameplay-/Talent-Chat
- `b2254ac` (2026-11-08): Animate live Titan Legends equipment on original GLB rigs (12 classes, 180 sockets) (#193)
- `0af3db6` (2026-11-08): Improve portrait hero HP labels and visual states (#202)

### Skills und Animationen — Skills-und-Animationen-Chat
- `0af3db6` (2026-11-08): Improve portrait hero HP labels and visual states (#202)

### Grafiktreiber / Rendering — Grafiktreiber-Chat
- `b2254ac` (2026-11-08): Animate live Titan Legends equipment on original GLB rigs (12 classes, 180 sockets) (#193)
- `0af3db6` (2026-11-08): Improve portrait hero HP labels and visual states (#202)

### Titan Chat / Moderation — Titan-Chat-Chat
- `0af3db6` (2026-11-08): Improve portrait hero HP labels and visual states (#202)

### Audio — Audio-Erstellung-Chat
- `0af3db6` (2026-11-08): Improve portrait hero HP labels and visual states (#202)

### APK-Gesamtbuild — APK-Erstellung-des-gesamten-Projekts-Chat
- `0af3db6` (2026-11-08): Improve portrait hero HP labels and visual states (#202)

### Integration/CI — GitHub-/Integrations-Chat
- `4928963` (2026-11-08): ci(forest): publish Android seven-enemy scene complexity estimate
- `d4519e9` (2026-11-08): ci(forest): run geometry comparison regression tests on every relevant push
- `82cba1f` (2026-11-08): fix: decouple imported Chibi equipment sockets and validate 12 GLB rigs (#206)
- `657887a` (2026-11-08): ci(forest): publish source-versus-Godot geometry comparison artifact
- `b2254ac` (2026-11-08): Animate live Titan Legends equipment on original GLB rigs (12 classes, 180 sockets) (#193)

## Bereichsübergreifende Änderungen

- `d031003` (2026-11-08): test(forest): validate geometry comparison and missing-model errors
- `31c9f15` (2026-11-08): feat(forest): compare source GLB and Godot-imported geometry in CSV report
- `e77ed30` (2026-11-08): fix(forest): reject zero-triangle imports and validate triangle index counts

## Regeln für alle Fach-Chats

1. Vor Arbeitsbeginn `PROJECT_COORDINATION.md`, `VISUAL_QUALITY_GATE.md` und diese Datei lesen.
2. Eigene Änderungen mit aussagekräftigen Commit-Meldungen und möglichst getrennten Dateien einreichen.
3. Bei Konflikten oder Abhängigkeiten einen GitHub-Issue/PR mit betroffenen Bereichen anlegen.
4. Erfolge nur anhand der zugehörigen GitHub-Actions-Läufe melden; diese Übersicht klassifiziert Commits, nicht deren Qualität.

## Aktuelle Prüfläufe

Siehe [GitHub Actions](https://github.com/xynewageyx/TitanLegend/actions) für den tatsächlichen aktuellen Status.
