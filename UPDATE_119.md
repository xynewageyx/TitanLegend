# Update 119 – Skill-Speicherfehler behoben

- Kritischen Regressionsfehler aus Update 118 in `scripts/save_manager.gd` korrigiert: `saved[hero][position]` verwendete versehentlich die Node-Eigenschaft `position` statt des Schleifenindexes `skill_slot`.
- Gespeicherte Skill-Belegungen werden wieder je Held und Slot geladen.
- Obergrenze des gespeicherten Skill-Index auf 10 angehoben, entsprechend `battle_manager.gd`.
- Keine Änderungen an Bosszeitlimit, Heilung oder Wiederbelebung.

Prüfung: ZIP-Integrität und gezielte Quelltextkontrolle. Godot-Laufzeittest nicht durchgeführt.
