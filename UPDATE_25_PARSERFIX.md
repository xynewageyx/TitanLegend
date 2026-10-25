Titan Legends Update 25 - Parserfix

In scripts/talent_system.gd und scripts/talent_menu.gd wurde der unzulaessige Bezeichner class_name (reserviertes GDScript-Schluesselwort) durch class_label ersetzt.

Die Meldung in save_manager.gd Zeile 108 ist ein Folgefehler, wenn TitanTalentSystem nicht geparst werden kann.

Hinweis: ZIP-Inhalt und Scriptstellen geprueft; kein Godot-Laufzeittest verfuegbar.

