# Titan Legends: echte Spielkamera und OpenGL-Vierer-Team-Referenz (2026-11-11)

## Code und Daten

Godot-Perspektivkamera aus **`scripts/camera_follow.gd`**, d.h. der tatsächliche normale Nicht-Boss-Kameracode des Spiels, nicht die orthografische Modell-Inspektionskamera.

- Kameraposition im isolierten Team-QA: `(0,12.1,13.5)`, `fov=56°`, `camera_offset=(0,10.5,17.5)`, `look_ahead=(0,1.6,-4)`.
- Vier importierte 3D-GLBs mit hochstufigen Waffen, Brustpanzer, vier passiven Begleitern und Angriffsblitzen: Krieger, Magier, Todesritter, Druide.
- OpenGL/Linux xvfb/Mesa, **720×1280**, kein Android-Gerät.
- Real gerenderte Standbilder: `formation_gameplay_camera_idle.png` und `formation_gameplay_camera_attack.png`.
- Korrigierter Workflow: [GitHub Actions #43076803728](https://github.com/xynewageyx/TitanLegend/actions/runs/43076803728), **success**. Das ZIP `TitanLegends-Rarity-Silhouette-V2-Visual-QA` enthält insgesamt 94 PNGs, `gameplay_camera_benchmark.json`, `manifest.json` und `formation_visibility_audit.json`.

## Kamerabild und tatsächliche Bewegung

Alle 4 Körper-Bounding-Boxen sind zu 100 % im 720×1280-Bild (Idle und Attack). **Dies beweist keine vollständige Bewegungs-/Effektlesbarkeit**, nur geometrisches Framing.

Ein erster Kamerarender-Test stellte sogar Idle und Attack pixelidentisch dar; dieser Fehler wurde gezielt behoben. Der korrigierte Test ruft die echte vorhandene kosmetische `HeroCombatMotion`-Angriffslogik in der Mitte des Angriffs auf, setzt die ausgewählte GLB-Animation ohne Crossfade und misst den Bildunterschied mit RGB8-Schwellwert 24/255.

**Nach der Korrektur:** 30.713 von 921.600 Bildpixeln (3,333 %) unterscheiden sich zwischen Idle und Attack. Diese Zahl misst einen **Bildunterschied**, keinen prozentualen Anteil bewegter Knochen oder verdeckter Körperpixel.

Im visuellen Vergleich dominieren in der aktuellen Nicht-Boss-Kamera die vier Helden die untere Bildhälfte, mit großzügigem Freiraum oberhalb für den vorausschauenden Blick auf das Schlachtfeld. Das ist kein getesteter Bossfall: Ein echter Boss und HUD-Overlays waren in dieser separaten QA-Szene nicht eingeblendet.

## 90-Frame-Software-OpenGL-Diagnose

Die Szene wird mit 20 Warm-up-Frames und 90 aufeinanderfolgenden `RenderingServer.frame_post_draw`-Samples vermessen. Mitten im Messfenster werden die bestehenden kosmetischen Angriffe für alle vier Helden wiederholt ausgelöst. Kein Screenshot-Readback findet während der Zeitmessung statt. Dies ist ein **Linux-CI-Renderloop-Vergleich**, keine echte Android- oder GPU-FPS-Messung.

| Kennzahl | Erster CI-Lauf | Korrigierter CI-Lauf |
| --- | ---: | ---: |
| Mittlere Zeit pro Frame | 68,423 ms | 85,535 ms |
| Median | 68,285 ms | 83,438 ms |
| 95. Perzentil | 70,302 ms | 98,630 ms |
| Rechnerische Bildrate | 14,61 | 11,69 |
| Plattform | Linux Mesa Software | Linux Mesa Software |

Der Unterschied der beiden Läufe zeigt, dass die Werte vom CI-Runner beziehungsweise Messablauf abhängen. **Nicht** als realistische Smartphone-Leistung, stabile Android-FPS oder direkter A/B-Optimierungserfolg interpretieren.

## Automatisierte Schutztests

- `tools/render_live_equipment_qa.gd` erzeugt reale Kamera-Screenshots, 90-Frame-Diagnose und Idle/Attack-Bilddifferenz.
- `tools/check_gameplay_camera_benchmark.py` verlangt den echten Kamerascriptpfad, 56° FOV, vollständige vier Charakterpositionen und valide Linux-Messangaben; es lehnt unzulässige Android-FPS-Behauptungen und identische Idle/Attack-Bilder ab.
- `tests/test_check_gameplay_camera_benchmark.py` enthält Regressionen für falsche Kamera, fehlende Posen, unzulässige Gerätebehauptung und fehlende Bewegungsdifferenz.
- Alle **sieben** GitHub-Workflows zum korrigierten Code-Commit `d9502d79435ff776ca2ede916daabb6e7a05384b` sind erfolgreich.

## Noch zu prüfen

1. Bosskameraframing mit echtem Bossmodell und HUD bei Bossbegegnungen.
2. Vier-Klassen-Performance auf physischem Android-Telefon: echtes GPU-Frameprofil (z. B. Godot-Monitor, Gerätetemperatur, niedrige/mittlere/hohe Qualitätsstufen).
3. Lesbarkeit der VFX mit Gegnern, Bosswarnung und Chat/HUD gleichzeitig.
4. Betrieb unter langen Kämpfen und mehr als 90 Frames, einschließlich Speicherverbrauch und thermischer Drosselung.

Keine Ulala-Assets oder proprietären Animationskurven übernommen.
