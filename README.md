# Titan Legend

Godot 4 Android game project. The complete game source from Update 168 has not yet been uploaded.

## Established rules
- Four heroes per team; maximum one active tank.
- First tank selection retains the slot until the player changes role or leaves.
- No automatic tank replacement or role displacement.
- Composition bonus only for one tank, two damage dealers and one healer.
- Only the active living tank may use taunt and group damage interception.
- No tank HP regeneration or resurrection.

All future development should use GitHub commits instead of ZIP archives.


## Original Update 168: sichere Importprüfung

Die vorhandenen GitHub-Dateien enthalten zum Teil neuere Korrekturen und
vorläufige Ersatzimplementierungen. **Nicht blind mit der alten ZIP überschreiben.**

Das neue Werkzeug `tools/import_update168.py` zeigt, welche Originaldateien
im lokalen Checkout fehlen, identisch oder verändert sind:

```sh
python tools/import_update168.py /pfad/zur/Titan_Legends_Update_168_Gegner_KI_Tank_Fix.zip
```

Mit `--import-missing` werden ausschließlich noch fehlende Dateien aus
dem Originalarchiv in den lokalen Checkout übernommen und verifiziert.
Bestehende Dateien bleiben unangetastet. Das Werkzeug lädt **nicht**
selbstständig nach GitHub hoch und erstellt **keine ZIP-Dateien**.

Die Prüfdatei `tests/test_update168_import_tool.py` kontrolliert unter
anderem Pfadsicherheit und den Schutz bestehender Verbesserungen.

Vollständiger Originalabgleich, Godot-Testlauf und Android-Build sind weiterhin
offen. Ein Dateiname auf GitHub beweist keine Originalgleichheit.
