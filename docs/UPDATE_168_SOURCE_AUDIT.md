# Update 168 – geprüfter Originalabgleich (25.10.2026)

Quelle: `Titan_Legends_Update_168_Gegner_KI_Tank_Fix.zip`, Verzeichnis `Titan_Legends_Complete_Android_Godot/scripts/`.

- Originalarchiv: **213 Archiv-Einträge**, darunter **46 GDScript-Dateien**.
- GitHub `main`, geprüfte Dateien: **46 von 46 vorhanden**.
- **33 Dateien** haben einen identischen Git-Blob-SHA-1 wie das Original, nach Vereinheitlichung von CRLF auf LF.
- **13 Dateien** unterscheiden sich vom Original. Das bedeutet nicht automatisch, dass der GitHub-Code schlechter ist: Einige Dateien wurden nach Update 168 weiterentwickelt.
- **Keine** der 46 Skriptdateien fehlt. Der Abgleich **aller 213 Archiv-Einträge einschließlich Szenen und Assets ist noch offen**.

## Unveränderte Originalskripte (33)

- `scripts/class_visuals.gd`
- `scripts/boss_arena.gd`
- `scripts/world_transition.gd`
- `scripts/talent_menu.gd`
- `scripts/visual_factory.gd`
- `scripts/skill_fx.gd`
- `scripts/hero_body_profiles_126.gd`
- `scripts/mob_details.gd`
- `scripts/class_menu.gd`
- `scripts/ad_manager.gd`
- `scripts/hero_faces_hands_70.gd`
- `scripts/element_status_fx.gd`
- `scripts/camera_follow.gd`
- `scripts/hero_class_silhouettes_64.gd`
- `scripts/boss_art.gd`
- `scripts/boss_motion.gd`
- `scripts/nature_art.gd`
- `scripts/talent_path_diagram.gd`
- `scripts/boss_abilities.gd`
- `scripts/crowd_control.gd`
- `scripts/hero_polish.gd`
- `scripts/element_debuffs.gd`
- `scripts/boss_phase_fx.gd`
- `scripts/boss_intro.gd`
- `scripts/talent_visual_fx.gd`
- `scripts/element_impact_fx.gd`
- `scripts/talent_abilities.gd`
- `scripts/hero_class_identity_125.gd`
- `scripts/shop_manager.gd`
- `scripts/design_details.gd`
- `scripts/audio_manager.gd`
- `scripts/boss_aura.gd`
- `scripts/hero_weapons_47.gd`

## Abweichende Originalskripte (13; erst vergleichen, nicht blind ersetzen)

- `scripts/floating_text.gd`
- `scripts/skill_system.gd`
- `scripts/save_manager.gd`
- `scripts/battle_manager.gd`
- `scripts/hero_detail_44.gd`
- `scripts/game_manager.gd`
- `scripts/biome_manager.gd`
- `scripts/skill_menu.gd`
- `scripts/hero_combat_motion.gd`
- `scripts/team_formation.gd`
- `scripts/skin_shop_menu.gd`
- `scripts/talent_system.gd`
- `scripts/ui_manager.gd`

## Was der Abgleich noch nicht bestätigt

- Der derzeitige `battle_manager.gd` ist weiterhin als temporäre Kompatibilitätsimplementierung gekennzeichnet, obwohl er zwischenzeitliche Fehlerkorrekturen enthält.
- Ebenso enthält `team_formation.gd` einen Ersatzcode mit Weiterentwicklungen.
- Identische Dateinamen allein belegen keine Funktionsgleichheit.
- Die GitHub-Actions-Validierung hat den Godot-Headless-Projektimport, Speicher-, Offline- und AFK-Tests sowie einen Start-Smoke-Test für Commit `885c577f` erfolgreich abgeschlossen (Lauf `40195099387`). Das ist noch kein Test auf einem Android-Gerät. Ein erfolgreicher Android-APK-Export für diesen Stand ist weiterhin nicht nachgewiesen.

## Sichere Reihenfolge

1. Für alle 13 abweichenden Skripte fachliche Diffs gegen die Originale erstellen und nach Update 168 ergänzte Änderungen erhalten.
2. Die restlichen 167 Archiv-Einträge (nicht-GDScript, Verzeichnisse eingeschlossen) und deren tatsächlich benötigte Projektdateien gesondert prüfen.
3. Godot-Validierung, Regressionstests und APK-Export in GitHub Actions durchführen.

Die Prüfmethode verwendet den Git-Blob-SHA-1 (`SHA1("blob <bytes>\\0" + normalized_file_bytes)`); bei GitHub wurde der Blob-SHA jedes vorhandenen Skripts abgefragt.

## Nachtrag – Bossanimationen und Originalarchiv

- Vollständiger originaler `scripts/boss_motion.gd` mit **21.092 Bytes** statt des früheren **5.280-Byte**-Ersatzskripts übernommen.
- Git-Blob-SHA-1 der aktiven Datei: `36846e8a233c5e66920edead2659c11291290b0f`, identisch mit Update 168.
- Die Originalfassungen von `team_formation.gd`, `battle_manager.gd`, `ui_manager.gd` und `boss_motion.gd` sind außerdem getrennt unter `original_update168/scripts/` gesichert, damit spätere Spielfunktionen erhalten bleiben.
- Regressionstest: `tests/test_update168_boss_motion.py`.
