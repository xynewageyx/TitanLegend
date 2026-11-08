# Titan Legends – Gemeinsamer Live-Projektstatus

Automatisch erzeugt: **2026-11-08 20:32 UTC**
Git-Stand: **d4519e91ab25327f366a34cca2269558e1f068a2** auf Branch **main**

> Diese Datei wird nach Repository-Änderungen aktualisiert. Sie synchronisiert keine Chat-Verläufe und beweist keine bestandenen Tests. Jeder Fach-Chat liest sie vor der Arbeit und dokumentiert eigene Änderungen per GitHub-Commit.

## Zuständigkeiten und letzte Änderungen

### Charaktere — Charaktere-Chat
- `82cba1f` (2026-11-08): fix: decouple imported Chibi equipment sockets and validate 12 GLB rigs (#206)
- `b2254ac` (2026-11-08): Animate live Titan Legends equipment on original GLB rigs (12 classes, 180 sockets) (#193)
- `0af3db6` (2026-11-08): Improve portrait hero HP labels and visual states (#202)
- `a9a22f1` (2026-11-08): test(classes): guard class and role validation in mobile class menu

### Gegner/Bosse — Gegner-/Boss-Chat
- `a9a22f1` (2026-11-08): test(classes): guard class and role validation in mobile class menu

### Landschaften — Landschaften-Chat
- `a9a22f1` (2026-11-08): test(classes): guard class and role validation in mobile class menu

### Ausrüstung — Ausrüstungs-Chat
- `358b44a` (2026-11-08): fix: avoid equipment mesh churn on unchanged inventory refresh (#210)
- `82cba1f` (2026-11-08): fix: decouple imported Chibi equipment sockets and validate 12 GLB rigs (#206)
- `b2254ac` (2026-11-08): Animate live Titan Legends equipment on original GLB rigs (12 classes, 180 sockets) (#193)
- `a9a22f1` (2026-11-08): test(classes): guard class and role validation in mobile class menu

### UI — UI-Chat
- `a9a22f1` (2026-11-08): test(classes): guard class and role validation in mobile class menu

### Gameplay — Gameplay-/Talent-Chat
- `b2254ac` (2026-11-08): Animate live Titan Legends equipment on original GLB rigs (12 classes, 180 sockets) (#193)
- `a9a22f1` (2026-11-08): test(classes): guard class and role validation in mobile class menu

### Skills und Animationen — Skills-und-Animationen-Chat
- `a9a22f1` (2026-11-08): test(classes): guard class and role validation in mobile class menu

### Grafiktreiber / Rendering — Grafiktreiber-Chat
- `b2254ac` (2026-11-08): Animate live Titan Legends equipment on original GLB rigs (12 classes, 180 sockets) (#193)
- `a9a22f1` (2026-11-08): test(classes): guard class and role validation in mobile class menu

### Titan Chat / Moderation — Titan-Chat-Chat
- `a9a22f1` (2026-11-08): test(classes): guard class and role validation in mobile class menu

### Audio — Audio-Erstellung-Chat
- `a9a22f1` (2026-11-08): test(classes): guard class and role validation in mobile class menu

### APK-Gesamtbuild — APK-Erstellung-des-gesamten-Projekts-Chat
- `a9a22f1` (2026-11-08): test(classes): guard class and role validation in mobile class menu

### Integration/CI — GitHub-/Integrations-Chat
- `d4519e9` (2026-11-08): ci(forest): run geometry comparison regression tests on every relevant push
- `82cba1f` (2026-11-08): fix: decouple imported Chibi equipment sockets and validate 12 GLB rigs (#206)
- `657887a` (2026-11-08): ci(forest): publish source-versus-Godot geometry comparison artifact
- `b2254ac` (2026-11-08): Animate live Titan Legends equipment on original GLB rigs (12 classes, 180 sockets) (#193)
- `a9a22f1` (2026-11-08): test(classes): guard class and role validation in mobile class menu

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
