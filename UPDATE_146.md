# Update 146 – Tank-Verteidigungsanzeige

Fix: Ein dauerhaft aktiver Tank-Verteidigungsstatus wird nicht mehr nach 0,3 Sekunden unsichtbar. Die kurzzeitigen Skill-Effekte bleiben zeitlich begrenzt. Deaktivierung über set_tank_defense_state(-1) blendet den Ring wieder aus. Kampfwerte und Cooldowns unverändert.

ZIP-Struktur geprüft; Android/Godot-Laufzeittest nicht durchgeführt.
