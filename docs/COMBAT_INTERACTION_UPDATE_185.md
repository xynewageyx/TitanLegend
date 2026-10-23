# Titan Legends – Update 185: Prepared-heal / CC state audit

## Geprüfte Kollisionen
Der aktuelle `battle_manager.gd` verarbeitet Boss-Fertigkeiten und Routineangriffe in festen Ticks. Nach Schaden wird zunächst die Team-HP synchronisiert, dann – falls das Team noch lebt – die vorbereitete Heilung ausgelöst. Das bedeutet: Ein vollständiger Team-Wipe löst keine Wiederbelebung aus. HoTs heilen ausschließlich lebende Ziele.

Ein CC-Treffer kann auf Slot 4 vorgemerkt werden. Die Unterbrechung wird bei Beginn eines unterbrechbaren Boss-Casts auf lebende Helden beschränkt. Das allgemeine Boss-Zeitlimit bleibt bei 60 Sekunden. Verteidigung durch Tankrolle (30 %), Gruppenabfangen (35 %) und individuelle Talente wird multiplikativ berücksichtigt.

## Behobener Fehler
Beim Ändern eines ausgerüsteten Skills setzte `set_skill_loadout` die Skillfolge und Ladung zwar zurück, **aber nicht** die vorbereitete Heilung und den vorbereiteten CC-Treffer. Dadurch konnten Effekte eines entfernten Skills nach dem Ausrüsten einer anderen Fähigkeit weiter bestehen.

Nun werden bei jedem Skillwechsel des betroffenen Helden folgende Werte zurückgesetzt:
- `next_skill_slot[hero] = 0`
- `skill_hit_charge[hero] = 0`
- `prepared_cc[hero] = 0`
- `prepared_healing[hero] = -1`

Andere Helden behalten ihre geladenen und vorbereiteten Skills; der Teamstatus wird nicht unnötig komplett zurückgesetzt.

## Validierung
Der Quellcode wurde nach dem Commit erneut geprüft. Die Datei `tests/test_core_import.py` enthält einen Regressionstest für alle vier Reset-Felder einschließlich Sicherung des 60-Sekunden-Bosslimits.

**Keine vollständige Godot-4.7-Laufzeitausführung und keine belastbare numerische 12-Gebiete-Siegquoten-Simulation.** Diese Änderungen sind eine Zustands-/Exploit-Korrektur. Nach einem echten Laufzeittest sollte die Trennung von Heilungs-, CC- und Tank-Fortschritt inklusive mehrfacher Treffer im selben Tick noch einmal geprüft werden.
