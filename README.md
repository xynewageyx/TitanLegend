# Titan Legends – Idle RPG

Godot-4-Projekt fuer Android (Hochformat). Die Entwicklung erfolgt direkt auf GitHub, ohne neue ZIP-Uebergaben.

## Update 168 – Originalimport

**213 von 213 Originaldateipfaden sind im Repository vorhanden.**
Die Quelle ist `Titan_Legends_Update_168_Gegner_KI_Tank_Fix.zip`
(SHA-256: `6a756b5c7f5d6bbf4c569632f932ac134fc6c35fa094d5dd71ab465618390072`).

- 198 Dateien sind exakt byteidentisch mit dem Original (Git-Blob-SHA).
- 15 aktive oder historisch aktualisierte Dateien weichen ab und wurden zum Schutz neuerer Korrekturen nicht blind ersetzt.
- Vier Original-Kernskripte sind separat unter `original_update168/scripts/` gesichert: `team_formation.gd`, `battle_manager.gd`, `ui_manager.gd` und `boss_motion.gd`.
- Der Originalbestand wird in `docs/update_168_import_manifest.json` mit Dateilaenge, Git-Blob-SHA und SHA-256 dokumentiert. Die Tests pruefen alle Pfade und die vier gesicherten Originalskripte.

Details: [Importbericht](docs/UPDATE_168_IMPORT_COMPLETE.md) und [Quellcode-Abgleich](docs/UPDATE_168_SOURCE_AUDIT.md).

## Build und Spielbarkeit

Die drei GitHub-Actions-Workflows haben am **25.10.2026** fuer Commit `4c0d7d4b948623628ccd2ec36fb87da40a1862fd` erfolgreich abgeschlossen:

- [Godot-Validierung](https://github.com/xynewageyx/TitanLegend/actions/runs/40198094986)
- [Python-Regressionstests](https://github.com/xynewageyx/TitanLegend/actions/runs/40198094967)
- [Android-Debug-Export](https://github.com/xynewageyx/TitanLegend/actions/runs/40198094998)

**[Android-Debug-APK direkt laden](https://github.com/xynewageyx/TitanLegend/releases/download/android-preview/TitanLegends-debug.apk)**

Dies ist eine **Entwicklungsfassung**. Ein erfolgreicher Godot-CI-Start und APK-Build ersetzen keinen Test der Touch-Bedienung, Darstellung, Performance und Spiellogik auf einem Android-Geraet. Spaetere Commits benoetigen jeweils erneut erfolgreiche CI-Laeufe; der Download verweist auf die letzte veroeffentlichte Preview.

## Verbindliche Spielregeln

- Vier Helden pro Team, hoechstens ein aktiver Tank; die zuerst belegte Tankrolle bleibt belegt.
- Kein automatischer Tankrollen-Tausch. Ein weiterer Held kann erst Tank werden, wenn die Rolle frei ist.
- Formation: Tanks und Nahkampf-DDs vorn, Fernkampf-DDs und Heiler hinten; passive Begleiter bleiben direkt beim zugehoerigen Helden.
- Team-Bonus bei genau einem Tank, zwei DDs und einem Heiler.
- Tanks koennen spotten und Gruppenschaden abfangen. Keine Tank-HP-Regeneration und keine Wiederbelebung.
- Automatische Kaempfe; Boss-Zeitlimit 60 Sekunden; pro Levelaufstieg drei Talentpunkte.

## Entwicklung und Tests

Python-Regressionstests:
```sh
python -m unittest discover -s tests -v
```

Godot-Projektvalidierung:
```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --quit-after 120
```

Details der automatischen Pruefungen stehen in `.github/workflows/`.

Aeltere, lokal vorhandene Archive koennen mit `tools/import_update168.py` auf fehlende bzw. veraenderte Dateien geprueft werden. Das Werkzeug ueberschreibt bestehende Dateien standardmaessig nicht. Die Importarbeit am Originalarchiv ist strukturell abgeschlossen; die Funktionsabnahme der spaeteren Erweiterungen ist eine gesonderte Aufgabe.
