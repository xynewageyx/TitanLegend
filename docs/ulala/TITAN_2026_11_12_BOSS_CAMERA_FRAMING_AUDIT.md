# Titan Legends – Bosskamera mit vier Helden, 12. November 2026

## Geprüfte Originalquellen

- Kamera: `scripts/camera_follow.gd` mit 56° Sichtfeld und aktivem Boss-Framing-Zweig
- Bossgeometrie: `scripts/boss_art.gd`, Bosswarnung: `scripts/boss_motion.gd`
- Charaktere: Krieger, Magier, Todesritter, Druide mit ihren importierten Chibi-GLBs und Seltenheit-5-Ausrüstung
- Szenenpositionen entsprechen dem Hauptspiel: Team `(0,0,3)`, Gegner `(0,0,-8)`
- Die eingeblendete Lebens-/Zeit-/Warnungsanzeige ist eine **QA-Demonstration**, nicht das Produktions-HUD aus `scripts/ui_manager.gd`.

## Gemessene Ergebnisse

Der frühere erfolgreich verifizierte Godot-4.7.2-OpenGL-Lauf [43248577111](https://github.com/xynewageyx/TitanLegend/actions/runs/43248577111) erzeugte vier Bildschirmbilder: Feuerboss Idle/Windup und Erd-Fusionsboss Idle/Windup bei 720×1280.

| Kennzahl | Feuerboss | Erd-Fusionsboss |
| --- | ---: | ---: |
| Boss-Silhouette im sichtbaren Bild (projizierter AABB) | 100 % | 100 % |
| Boss-Warnung im sichtbaren Bild (projizierter AABB) | 100 % | 100 % |
| Alle vier Charakterkörper im Bild | 4/4, je 100 % | 4/4, je 100 % |
| Veränderte Renderpixel bei realem Boss-Windup, **ohne Textänderung** | 7.797 | 6.149 |
| Boss-Warnung bis zur vorderen Heldenreihe | ca. 66 px | ca. 66 px |
| Kamera-FOV | 56° | 56° |
| Kameraposition | `(0,14.7,16.5)` | `(0,14.7,16.5)` |

Diese Werte sind aus dem originalen `boss_camera_report.json` des heruntergeladenen Artefakts, keine Android-Messungen.

## Verschärfte Regression in PR #258

- `tools/check_boss_gameplay_camera_report.py` verlangt jetzt mindestens 98 % projizierte Sichtbarkeit von Boss und allen vier Charakteren, keine projizierten Boss-Eckpunkte hinter der Kamera und mindestens 20 px Abstand zwischen der Boss-Warnsilhouette und der nächsten Teamreihe.
- Ein Boss darf außerdem nicht in die obere Sicherheitszone der diagnostischen Bossanzeige ragen (180 px).
- `tests/test_check_boss_gameplay_camera_report.py` ergänzt vier Fehlerfälle: zugeschnittener Boss, Warnobjekt hinter der Kamera, HUD-Zonenüberlappung und Warnung mit Teamreihen-Überlappung.
- Der strengere OpenGL-Test bestand in [GitHub Actions 43275726886](https://github.com/xynewageyx/TitanLegend/actions/runs/43275726886). Alle sieben Workflows zum Code-Commit `f623a68b7d8fc0a59da9b7199c036ea0a2b88059` waren erfolgreich.

## Noch offen

- Echte Instanz des produktiven `UIManager` einschließlich Boss-Lebensanzeige, Zeit und Chat im gleichen Bildschirm und mit korrekt verkabeltem `BattleManager`.
- Realer 60-Sekunden-Bosskampf mit Cast-Unterbrechungen, Team-/Begleiter-Effekten und weiteren Bossvarianten.
- Android-Geräte-FPS, GPU, Wärmeentwicklung und Belastung über längere Laufzeiten.

Diese Diagnose verwendet originale Titan-Legends-Modelle; keine proprietären Ulala-Assets.
