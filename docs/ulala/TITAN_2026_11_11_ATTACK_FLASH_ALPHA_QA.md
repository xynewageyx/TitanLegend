# Titan Legends – 55 % Transparenz für kosmetische Angriffsblitze

Stand: 2026-11-11. Geprüft in [GitHub Actions 43074302659](https://github.com/xynewageyx/TitanLegend/actions/runs/43074302659), **success**.

## Änderung

In `scripts/hero_combat_motion.gd` verwendet nur `magic_flash` (die kleine, farbige AttackFlash-Kugel) nun ein **instanzlokales, unbeleuchtetes, alpha-transparentes Material** mit `ATTACK_FLASH_ALPHA = 0.55` statt der vorherigen deckenden Variante. Schadenswerte, Angriffsdauer, Treffer, ursprüngliche GLB-Animationen, Waffen, Begleiter und die übrigen Spezialeffekte sind unverändert. Der Materialeffekt bleibt kosmetisch.

## Reproduzierbarer A/B-Vergleich

Die Godot-4.7.2-Mesa-OpenGL-Pipeline rendert denselben eingefrorenen vierköpfigen Attack-Frame mit:
- `formation_mythic_attack_opaque_reference.png` — derselbe Effekt mit Alpha 1.00.
- `formation_mythic_attack.png` — tatsächliche neue Produktionseinstellung Alpha 0.55.

Die Kamera, die vier Helden und ihre Angriffspositionen sind identisch. Das Bild besteht aus 720×1280 Pixeln. Bei einem RGB-Kanalunterschied von mehr als 24 von 255 wurden **13.405 veränderte Pixel** gemessen, **1,455 % der gesamten Bildfläche**.

| Körper-Bounding-Box-Slot | Unterschiedliche Pixel | Anteil innerhalb des projizierten Rechtecks |
| --- | ---: | ---: |
| Krieger | 4.191 | 7,017 % |
| Magier | 3.437 | 7,999 % |
| Todesritter | 3.834 | 6,780 % |
| Druide | 1.943 | 3,704 % |

Die Bilddifferenz belegt, dass das Alpha der Angriffskugel im Renderer tatsächlich die Darstellung verändert; sie ist keine mathematische Messung der verbesserten Lesbarkeit oder der durchsichtigen Effektfläche.

Die bisherigen **16 deckenden Tiefenmasken** bleiben als konservative geometrische Verdeckungsmessung bestehen. Die Transparenzeinstellung ändert diese geometrische Maske nicht.

## Regression und Ergebnisse

- `tools/render_live_equipment_qa.gd` verlangt Alpha 0.55 und rendert eine passende opaque A/B-Referenz.
- `tools/check_four_hero_visual_manifest.py` prüft beide Varianten und fordert sichtbare veränderte Pixel.
- `tests/test_check_four_hero_visual_manifest.py` enthält Fehlerfälle für alpha 1.0 und null Pixelunterschied.
- Der OpenGL-CI-Test rendert **92 PNGs** (inklusive 16 Tiefenmasken, 3 Kategorie-Gegenproben, 4 Übersichtsblättern und A/B-Effektbild) und exportiert die beiden JSON-Berichte.
- Alle sieben Workflows auf Commit `8e04b1d744934cd05acc740ac00a838ad7463c4d` waren erfolgreich.

## Einschränkungen

Diese Renderbilder wurden auf Linux/Mesa und einer erhöhten **QA-Kamera** erzeugt, nicht auf einem echten Android-Gerät oder mit exakt der aktuellen Gameplay-Kamera. Die A/B-Aufnahmen zeigen eine geringere optische Deckkraft, sind aber kein vollständiger Leistungstest und keine pixelgenaue Spieler-Lesbarkeitsmessung im realen Kampf.

Es wurden keine externen Ulala-Assets übernommen.
