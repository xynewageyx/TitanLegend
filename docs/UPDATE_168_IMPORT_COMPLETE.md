# Titan Legends – vollständiger Update-168-Import (25.10.2026)

## Verifizierter Stand

Quelle: `Titan_Legends_Update_168_Gegner_KI_Tank_Fix.zip`, ZIP-SHA256: `6a756b5c7f5d6bbf4c569632f932ac134fc6c35fa094d5dd71ab465618390072`.

- **213 von 213 Originaldateipfaden auf GitHub vorhanden**, 371.692 Byte unkomprimierter Quellinhalt.
- **196 Dateien** stimmen nach Git-Blob-SHA-1 exakt mit dem Update-168-Archiv überein.
- **17 Dateien** sind gegenüber Update 168 verändert und bleiben absichtlich unangetastet, um die jüngeren Spiel- und Fehlerkorrekturen zu bewahren.
- Aufteilung: **46 Skripte**, **2 Szenen**, **1 project.godot**, **164 weitere Root-Dateien (Dokumentation und historischer Quelltext)**.
- Die vier ausgewählten Original-Kernskripte sind unter `original_update168/scripts/` zusätzlich geschützt.
- Das vollständige SHA-1-/SHA-256-Verzeichnis der Originaldateien liegt unter `docs/update_168_import_manifest.json` und wird in CI überprüft.
- **Keine ZIP-Datei neu erstellt.** GitHub enthält die Originaldateien, nicht nur einen externen Download.

## 17 aktiv weiterentwickelte oder sonst abweichende Dateien

```text
README.md
UPDATE_23.md
UPDATE_25_PARSERFIX.md
project.godot
scripts/battle_manager.gd
scripts/biome_manager.gd
scripts/floating_text.gd
scripts/game_manager.gd
scripts/hero_combat_motion.gd
scripts/hero_detail_44.gd
scripts/save_manager.gd
scripts/skill_menu.gd
scripts/skill_system.gd
scripts/skin_shop_menu.gd
scripts/talent_system.gd
scripts/team_formation.gd
scripts/ui_manager.gd
```

Bei diesen 17 Dateien bedeutet **abweichend nicht fehlend**. Keine wurde beim Dokumentationsimport ersetzt.

## Nächster technischer Schritt

Das Quellarchiv ist damit strukturell vollständig übertragen. Am 25.10.2026 liefen Godot-Validierung, Kern-Regressionstests und Android-Debug-APK-Export für Commit `4c0d7d4b948623628ccd2ec36fb87da40a1862fd` erfolgreich durch. Die APK ist unter `https://github.com/xynewageyx/TitanLegend/releases/download/android-preview/TitanLegends-debug.apk` verfügbar. Vor einem als spielbar bestätigten Android-Release fehlen weiterhin der Funktionsabgleich der weiterentwickelten Kampf-/UI-Skripte und ein tatsächlicher Gerätetest. Historische Update-Notizen sind keine Laufzeittests.
