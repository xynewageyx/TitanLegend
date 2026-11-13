# Tiefengeprüfte Charakter-Silhouetten – 4er-Team, Godot 4.7.2

Stand: 2026-11-10. **Erfolgreicher Masken-Renderlauf:** [GitHub Actions 42902300703](https://github.com/xynewageyx/TitanLegend/actions/runs/42902300703).

## Methode

Für Krieger, Magier, Todesritter und Druide wurden jeweils vier 720×1280-PNG-Masken erstellt: Körper ohne zusätzliche Vordergrundobjekte, sowie Körper mit Waffen, passiven Begleitern oder echten `HeroCombatMotion/AttackFlash`-Effekten als **deckend schwarze, tiefengeprüfte Occluder**. Der importierte Körper wird weiß mit unbeleuchtetem Material gezeichnet. Die perspektivisch korrekte Tiefenprüfung des Godot-OpenGL-Renderers bestimmt, welche weißen Körperpixel durch schwarze Objekte verdrängt werden.

Diese Methode unterscheidet sich von den früheren veränderten RGB-Pixeln bei normaler Transparenz: **Schwarze Tiefenmaske misst eine geometrische mögliche Verdeckung unter angenommener Undurchsichtigkeit.** Sie berücksichtigt keine originalen transparenten VFX-Alpha-Werte, keine Farbkontraste, kein tatsächliches HUD und keine Android-GPU.

Die 16 erzeugten Masken heißen `formation_mask_<slot>_<baseline|weapon|pet|effect>.png`. Der `formation_visibility_audit.json`-Bericht sowie das Original-`manifest.json` sind im ZIP-Artefakt `TitanLegends-Rarity-Silhouette-V2-Visual-QA` (ID `13801944784`) enthalten.

## Gemessene Angriffs-Silhouetten

| Held | Baseline sichtbare Körperpixel | Durch Waffen verdeckt | Durch Begleiter verdeckt | Potenziell durch deckende Attack-FX verdeckt |
| --- | ---: | ---: | ---: | ---: |
| Krieger | 33.471 | 0 (0 %) | 0 (0 %) | 7.144 (**21,34 %**) |
| Magier | 26.766 | 0 (0 %) | 0 (0 %) | 6.537 (**24,42 %**) |
| Todesritter | 31.349 | 0 (0 %) | 70 (**0,22 %**) | 6.638 (**21,18 %**) |
| Druide | 27.396 | 0 (0 %) | 0 (0 %) | 6.237 (**22,77 %**) |

**Wichtig:** Die 21–24 % Attack-FX-Werte entsprechen absichtlich *deckender* Silhouettenabdeckung in diesem eingefrorenen Attack-Sample. Tatsächliche transparente Zaubereffekte machen nicht automatisch ebenso viele Charakterpixel unsichtbar. Das ist ein konservativer Bereich möglicher Verdeckung, nicht eine visuelle Qualitätsbewertung.

Das Ergebnis zeigt, dass für diesen Bildausschnitt die **Effekte** wichtiger als Waffengröße oder Begleiterposition als potenzielle Verdeckungsquelle sind. Es gibt keinen durch den Maskenvergleich belegten Grund, die hochwertigen Waffen generell kleiner zu machen.

## Automatische Regression

- `tools/render_live_equipment_qa.gd` erzeugt 16 zusätzliche Tiefenmasken plus die bestehenden 75 Screenshots, insgesamt **91 PNGs** und zwei Berichte.
- `tools/check_four_hero_visual_manifest.py` prüft die vollständige Maske je Klasse, Plausibilität der Pixelzahlen und eine konservative obere Abdeckungsgrenze von **35 % für deckend projizierte Attack-FX**.
- `tests/test_check_four_hero_visual_manifest.py` enthält Regressionen für fehlende oder ungültige Masken und übergroße FX.
- GitHub-Actions-Schritte prüfen das Maskenmanifest und den Bildbestand.

## Offene Punkte

- Für die exakte *sichtbare Transparenzwirkung* müssen die realen Alpha-Blends oder gerenderte farbige Effektmasken bei der Gameplay-Kamera analysiert werden.
- Die QA verwendet eine erhöhte, für 4 Helden geeignete Kamera; eine 1:1-Live-Spielkamera und Android-Geräte-FPS sind nicht bestätigt.
- Die parallelen GitHub-Import/Android-Jobs haben gelegentlich sporadische `double free or corruption`-Abstürze gezeigt; die Masken-CI selbst war erfolgreich. Solche Importfehler müssen eigenständig weiter beobachtet werden.

Diese Prüfung verwendet ausschließlich originale Godot-/Titan-Legends-Daten. Es wurden keine Ulala-Meshes, Clips oder Bindpose-Daten kopiert.
