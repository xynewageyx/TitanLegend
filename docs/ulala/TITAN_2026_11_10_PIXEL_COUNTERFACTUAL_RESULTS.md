# Pixelgenaue Vierer-Team-Gegenproben – bestätigte OpenGL-Ergebnisse

Stand: 2026-11-10. Validiert mit [GitHub Actions 42852858921](https://github.com/xynewageyx/TitanLegend/actions/runs/42852858921).

## Beweisdaten

- GitHub-Artefakt: `TitanLegends-Rarity-Silhouette-V2-Visual-QA`, ID `13780394199`.
- Tatsächlich heruntergeladen: **75 PNGs**, `manifest.json` und `formation_visibility_audit.json`.
- `formation_visibility_audit.json`: `valid: true`, `errors: []`.
- Realer Godot-4.7.2-OpenGL-Render mit Linux xvfb/Mesa, 720×1280. **Kein physischer Android-Test.**
- Der Attack-Frame ist Ausgangspunkt für drei Gegenproben, die jeweils alle vier Waffen, passiven Begleiter oder kosmetischen `AttackFlash`-Knoten ausblenden.

## Messverfahren

Für jedes RGB8-Pixel der Referenz und der Gegenprobe wird der maximale Unterschied eines Farbkanals bestimmt. Bei einem Unterschied **größer als 24/255** gilt das Pixel als verändert. Alle Gegenproben verwenden dieselbe Kamera und dieselben eingefrorenen Animationsposen.

| Gegenprobe | Veränderte Pixel | Anteil der ganzen 720×1280-Aufnahme |
| --- | ---: | ---: |
| Ohne vier Waffen | 16.642 | **1,806 %** |
| Ohne vier Begleiter | 44.032 | **4,778 %** |
| Ohne vier Angriffsblitze | 13.932 | **1,512 %** |

Die Werte wurden sowohl im Godot-Audit als auch unabhängig über einen Python-Bildvergleich mit demselben 24/255-Schwellwert bestätigt.

### Veränderte Pixel in den projizierten Charakterkörper-Rechtecken

Diese vier Rechtecke sind **keine pixelgenauen Figurensilhouetten**. Ein Bildpunkt in einem Körper-Rechteck kann Hintergrund, Ausrüstung, Begleiter oder eine andere sichtbare Fläche enthalten.

| Klasse / Platz | Ohne Waffen | Ohne Begleiter | Ohne Angriffsblitze |
| --- | ---: | ---: | ---: |
| Krieger (0) | 5.712 (9,564 % des Rechtecks) | 0 (0 %) | 4.326 (7,243 %) |
| Magier (1) | 2.368 (5,511 %) | 124 (0,289 %) | 3.536 (8,230 %) |
| Todesritter (2) | 5.235 (9,258 %) | 3.861 (6,828 %) | 4.002 (7,077 %) |
| Druide (3) | 3.327 (6,343 %) | 1.501 (2,862 %) | 2.068 (3,943 %) |

Die Gesamtsumme der vier Körper-Rechtecke sollte nicht als Summe der unabhängigen Gesamtbild-Pixel interpretiert werden: Rechtecke können sich überschneiden, auch wenn die AABB-Diagnose der einzelnen importierten Körper in dieser Kamera keine paarweise Überlappung meldet.

## Qualitativer Sichtvergleich

In den vier nebeneinandergelegten Bildern sind Unterschiede unmittelbar sichtbar:
- **Ohne Begleiter** verschwinden vier große, farbige Figuren neben den Charakteren; dies erzeugt den größten Bildunterschied.
- **Ohne Waffen** verschwinden Ausrüstungsteile, insbesondere farbige runde Vordergrundelemente.
- **Ohne Effekte** verschwinden die sichtbaren Angriffsblitze; die Figuren bleiben größtenteils erkennbar.

Das ist noch keine *verdeckte Körperpixelmaske*: Ein verschwundener Begleiter verändert auch Hintergrundpixel und erzeugt eine große Differenz, ohne zwangsläufig Teile einer Figur verdeckt zu haben. Ebenso zeigen die alten AABB-14,6 % bei Effekten nur geometrische Rechtecküberschneidung.

## Implementierte Regression

- `tools/render_live_equipment_qa.gd`: drei zusätzliche Attack-PNGs und Messungen direkt aus dem gerenderten Framebuffer.
- `tools/check_four_hero_visual_manifest.py`: validiert die drei Gegenproben und vier Körperregionen.
- `tests/test_check_four_hero_visual_manifest.py`: sieben synthetische Regressionstests für Pflichtdaten und Fehlerfälle.
- `.github/workflows/animated-equipment-visual-qa.yml`: fordert 75 PNG-Dateien und einen validierten `formation_visibility_audit.json`-Bericht.

## Noch nicht gelöst

Für die tatsächliche prozentuale **Abdeckung von Körperpixeln** sind separate, tiefengetestete Charakter-Objekt-ID-/Silhouettenmasken nötig. Die bisherige Methode misst den Pixelbeitrag der sichtbaren Komponenten bei fester Kamera, nicht die exakte Verdeckung ihrer Nachbarn. Eine Prüfung der echten Android-GPU-Leistung und des normalen Gameplay-Kameraabstands steht ebenfalls aus.

Es wurden nur originale Titan-Legends-Modelle und prozedurale Waffen verwendet, keine fremden Unity-/Ulala-Assets.
