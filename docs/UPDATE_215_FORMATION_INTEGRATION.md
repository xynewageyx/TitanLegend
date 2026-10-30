# Update 215 – Integration der GLB-Modelle

Die Teamformation ruft den optionalen Loader nach der bisherigen prozeduralen Erzeugung auf.

## Modellpfade

- Helden: `res://assets/models/heroes/class_0.glb` bis `class_10.glb`
- Begleiter: `res://assets/models/pets/element_0.glb` usw., entsprechend der vorhandenen Element-IDs

Fehlt eine Datei, bleiben alle bisherigen Meshes sichtbar. Wird ein Modell erfolgreich geladen, werden nur die direkten prozeduralen MeshInstance3D-Kinder des jeweiligen Hero-/Pet-Roots ausgeblendet. Healthbars, Gameplay, passive Pet-Boni und Motion-Nodes werden nicht gelöscht.

## Noch zu prüfen

- GLB-Import in Godot und sichtbare Modellskalierung
- Vorhandene Animationen müssen an `TitanModelLoader.play_animation` angebunden werden
- Bestehende Animationen könnten noch ausgeblendete prozedurale Meshes bewegen
- Mobile FPS und Speicherverbrauch
- Automatische Godot-Validierung und Android-APK-Build

**Status:** GitHub-Codeintegration vorhanden, aber nicht getestet. Noch keine GLB-Assets hinzugefügt.
