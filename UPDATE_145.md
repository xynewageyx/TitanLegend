# Update 145 – Reparatur des Helden-Kampfscripts

Auf dem Android-Screenshot meldet Godot 4.7.2 einen Parser-/Preload-Fehler bei `res://scripts/hero_combat_motion.gd` (aufgerufen aus `team_formation.gd`, Zeile 554).

- Das Script ist im hochgeladenen Update 144 vorhanden; eine fehlende ZIP-Datei ist also nicht die Ursache.
- Die bisherige komplexe Implementierung wurde als `hero_combat_motion_original_144.txt` gesichert.
- `scripts/hero_combat_motion.gd` wurde durch eine vereinfachte, auf die tatsächlich aufgerufenen Schnittstellen abgestimmte Version ersetzt.
- Enthalten: klassenspezifische Basis-Angriffsbewegungen, Laufbewegung, Trefferreaktionen, einfache Tank-Verteidigungsringe, Waffen am rechten Arm.
- **Einschränkung:** Einige aufwendige Sekundäranimationen der alten Implementierung sind vorübergehend nicht enthalten. Keine Kampfwerte wurden absichtlich geändert.
- Der Godot-Parser konnte in dieser Umgebung nicht ausgeführt werden. Bitte nach Import in Godot 4.7.2 auf Android testen.
