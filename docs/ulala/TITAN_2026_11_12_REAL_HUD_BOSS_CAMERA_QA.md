# Bosskamera mit originalen UIManager-HUD-Widgets – 12. November 2026

## Umgesetzt

Die Bosskamera-Renderprüfung in PR #258 verwendet weiterhin `scripts/camera_follow.gd`, `scripts/boss_art.gd`, `scripts/boss_motion.gd` und die vier originalen GLB-Helden Krieger, Magier, Todesritter und Druide. Neu: Die zuvor frei nachgebildete Boss-Testanzeige wurde durch die **echten Widget-Erzeugungsfunktionen** des produktiven `scripts/ui_manager.gd` ersetzt.

`tools/boss_camera_real_hud_qa.gd` erweitert den produktiven UIManager und überschreibt ausschließlich dessen `_ready`-Initialisierung. Es ruft direkt `_make_hud()` auf und verwendet dadurch die realen Boss-HP-, Countdown-, Chat-, Ressourcen- und Navigationswidgets samt Styles. Die Werte werden in dieser isolierten QA-Szene ausdrücklich **manuell mit Testdaten** (`Boss-Zeit: 00:45`, HP 70 %, Castwarnung) gesetzt. Die produktive `_ready`-Verkabelung des echten BattleManager, das Adventure-Overlay, die laufende 60-Sekunden-Bossmechanik sowie ein physisches Android-Gerät werden **nicht** hier getestet.

## Technische Korrektur

Der erste GitHub-Lauf scheiterte, weil ein Top-Level-`preload` der UIManager-Subclass im standalone Godot-`--script`-Kontext den globalen `GameManager` beim GDScript-Kompilieren noch nicht auflösen konnte. Die Script-Subclass wird deshalb in `tools/render_boss_gameplay_camera_qa.gd` erst **zur Laufzeit nach dem SceneTree-Start** per `load()` geladen. Die Quelle `scripts/ui_manager.gd` wird nicht geändert.

Der korrigierte [OpenGL-CI-Lauf 43278217066](https://github.com/xynewageyx/TitanLegend/actions/runs/43278217066) war erfolgreich und stellte die vier Bosskamera-Bilder aus echten UIManager-Widgets dar.

## Verifizierte 720×1280-Bildgeometrie

| Merkmal | Feuerboss | Erd-Fusionsboss |
| --- | ---: | ---: |
| Bosskörper-Rechteck | (302.0, 420.1, 116.1, 178.3) | (272.3, 417.8, 175.5, 180.3) |
| Bossleben-/Countdown-Panel | (216, 240, 485, 145) | (216, 240, 485, 145) |
| Chatpanel | (12, 1071, 696, 72) | (12, 1071, 696, 72) |
| Mindestens sichtbare Helden | 4 / 4 | 4 / 4 |
| Realer, vom HUD-Text unabhängiger Boss-Windup-Bildunterschied | 7.908 Pixel | 6.180 Pixel |
| Abstand unter Boss-HUD zur Bosskörper-Silhouette | ca. 35 px | ca. 33 px |
| Abstand der unteren Körper-Silhouetten zum Chat | ca. 27 px | ca. 28 px |

Alle vier Helden und der Boss liegen in beiden Szenarien vollständig im Bild. Der Screenshot zeigt dieselbe 56°-Perspektivkamera aus der Produktion. Die Abstandsmessungen verwenden projizierte Mesh-AABBs und tatsächliche UIManager-Control-Rechtecke, nicht reale Pixel-Okklusionsmasken.

## Neue verpflichtende Regressionen

- `tools/check_boss_gameplay_camera_report.py`: echte UIManager-Quellkennung, sichtbarer Boss-Lebensbalken, Countdown und Chat; Cast-Warntext; Controls vollständig im 720×1280-Viewport; mindestens 15 px Abstand HUD ↔ Boss und Chat ↔ untere Charakterkörper.
- `tests/test_check_boss_gameplay_camera_report.py`: Fehlerfälle für fehlendes produktives HUD, fehlenden Timer, unsichtbare Warnung, abgeschnittenen Chat sowie Boss- und Teamüberlagerungen.
- [OpenGL-Grafiktest 43278930970](https://github.com/xynewageyx/TitanLegend/actions/runs/43278930970) einschließlich dieser Abstandsprüfungen: **success**.

## Noch offen

Die hier gerenderten Widgets stammen nachweislich aus dem produktiven `UIManager._make_hud`, werden aber mit **QA-Daten** gespeist; dieser Test ist daher *keine* End-to-End-Abnahme des tatsächlichen HUD-Spielverlaufs, der Adventure-Overlay-Schichten oder der 60-Sekunden-Bossmechanik. Dafür sind ein echter `BattleManager`/SaveManager-gekoppelter Ingame-Test, HUD-Überlagerungsprüfung und ein Test auf Android-Hardware erforderlich.

Kein originales Ulala-Material wurde in das Spiel kopiert.
