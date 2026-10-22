# Wiederherstellung aus Update 150 (Arbeitsbranch)

Quelle: vom Nutzer bereitgestelltes Archiv `Titan_Legends_Kritische_Treffer_Anzeige_Update_150(3).zip` (196 Einträge). Darin sind `scripts/team_formation.gd` und `scripts/battle_manager.gd` vorhanden; diese fehlen auf main.

## Vorgehen
1. Originaldateien nur auf diesem Branch importieren; andere neuere Dateien nicht blind überschreiben.
2. Update-150-`set_role` ist noch `void` und erlaubt die Verdrängung des Tanks. Ändern zu `func set_role(slot: int, role: int) -> bool`, bei besetzter Tankrolle `false` zurückgeben und vorhandenen Tank unverändert lassen.
3. Beim Laden gespeicherter Rollen ebenfalls nur einen Tank zulassen.
4. Kampfcode: zentralen lebenden aktiven Tank ermitteln; nur dieser darf Spott und Gruppenschadensabfangen ausführen. Keine automatische Tankübertragung, keine Wiederbelebung oder Tank-HP-Regeneration.
5. Boss-Zielwahl nicht durch Standardgegner-Zielwahl überschreiben; Ausweichen, Krit-Anzeige, Schaden und Heilung regressionsprüfen.
6. `python -m unittest discover -s tests -v` und Godot-Headless-Import/Smoke-Test ausführen. Vorher kein Merge nach main.

## Android / Termux
`git fetch origin && git switch restore-update150-core`

Die Quelldateien sind **noch nicht** in diesen Branch importiert. Die Quelle liegt als Chat-Anhang vor; dieser Branch enthält zunächst nur die Wiederherstellungsanleitung. Keine API-Schlüssel committen.
