# Titan Legends — Vierer-Team: Waffen, Begleiter und echte Attack-Effekte (2026-11-10)

## Verifizierter Testlauf

[GitHub Actions: 42786662858](https://github.com/xynewageyx/TitanLegend/actions/runs/42786662858) — **success**, einschließlich des neuen Schritts `Audit four-hero camera, pet and attack-effect visibility`.

Artefakt: `TitanLegends-Rarity-Silhouette-V2-Visual-QA`, ID `13748174337`. Das heruntergeladene ZIP enthält **72 PNG-Bilder**, `manifest.json` und `formation_visibility_audit.json`. Der separate Prüfbericht meldet `valid: true`, `errors: []`.

## Gemessene Vierer-Formation

Krieger (Tank), Magier (DD), Todesritter (DD) und Druide (Heiler) stehen in ihrer festen 4er-Aufstellung. Jeder besitzt eine hochstufige (Seltenheit 5) Waffe, Brustschutz und einen passiven Begleiter. Aufnahmen mit Godot 4.7.2 auf Linux/Mesa OpenGL in 720×1280; **kein realer Android-Test**.

| Pose | Körper im Bild | Körper-AABB-Überlappung | Waffenfläche mit fremden Körper-AABBs | Begleiter mit fremden Körper-AABBs | Aktive Attack-FX | Höchste Attack-FX-Überlappung |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Idle | 4/4 | 0 % | 0 % | 0,6 % | 0 | 0 % |
| Walk | 4/4 | 0 % | 0 % | 0,6 % | 0 | 0 % |
| Attack | 4/4 | 0 % | 0 % | 0,6 % | 4 | **14,6 %** |
| Dodge | 4/4 | 0 % | 0 % | 0,6 % | 0 | 0 % |

Die projizierten Körper-AABBs haben **100 % Viewport-Flächenabdeckung**. Die Attack-FX-AABBs werden aus den **echten `HeroCombatMotion/AttackFlash`-Mesh-Knoten** gemessen, nicht aus statischen Beispielkreisen.

Die Überlappungen sind konservative projizierte Bounding-Box-Messungen. **14,6 % ist weder eine tatsächliche verdeckte Pixelmenge noch eine Mesh-Kollisionsrate.** Die reale GPU-Renderreihenfolge, Tiefentest, transparente Flächen, Texturen und Okklusion sind nicht durch diese Zahlen bestimmt.

## Neu implementierte Regression

- `tools/render_live_equipment_qa.gd` erfasst für jede Pose Körper, Waffen, Begleiter und separat aktive FX.
- Der Test aktiviert in Attack den vorhandenen spielinternen `HeroCombatMotion.play_attack()` für alle vier Helden; bei anderen Posen bleiben die Impulse aus.
- `tools/check_four_hero_visual_manifest.py` prüft vier Posen, vier Waffen, vier Körper, vier Begleiter, Portrait-Sichtbarkeit und genau vier Effekte im Angriffsbild.
- `tests/test_check_four_hero_visual_manifest.py` enthält fünf Regressionstests, darunter Fehlerfälle bei fehlenden Begleitern, fehlenden FX und aus dem Bild gerückten Körpern.
- Der GitHub-Actions-Workflow prüft die Daten und legt `formation_visibility_audit.json` beim Screenshot-Artefakt ab.

## Bewertung und Grenzen

Die höhere QA-Kamera zeigt alle vier Charaktere samt Ausrüstung. **Es besteht aktuell kein messbarer Grund, Waffen, Begleiter oder Effekte allein anhand dieser AABB-Werte zu verkleinern.** Die Attack-FX-Überlappung sollte im realen Gameplay bei tatsächlicher Kamerahöhe und mit transparenter Materialkomposition gesondert beurteilt werden.

Offen: Pixelgenaue Tiefen-/Silhouettenmasken, tatsächlich sichtbare Effektpixel, 3D-Mesh-Clipping, Gameplay-Kameradistanz, Android-APK-Performance und GPU-Auslastung.

Keine fremden Ulala-Modelle, Texturen oder Animationen wurden übertragen.
