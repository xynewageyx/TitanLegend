# Waldkulisse: eigener Low-Poly-Horizont (2026-11-10)

Erweiterung für Gebiet 1 (NATURE) in Titan Legends, Godot 4.7.2.

- **Implementierung:** `scripts/forest_horizon_ridges.gd`, nur im Nature-Zweig von `biome_manager.gd`.
- **Geometrie:** zwei entfernte, unterschiedlich hohe Geländerücken aus **einem** vertexgefärbten `SurfaceTool`-Mesh; 32 Segmente pro Seite, 2 Quads pro Segment = rechnerisch 256 Dreiecke.
- **Platzierung:** x beginnt bei ±11,8 und endet bei ±23,5; z von −111 bis +32. Kampfweg und Teamformation bleiben frei.
- **Performance:** kein Mesh-Import, keine Textur, keine Kollision, kein Animations- oder Partikelsystem; ein `MeshInstance3D`.
- **Wiederholbarkeit:** fester Seed 20261110.
- **Grenzen:** Quelltexttests kontrollieren Einbindung und Budgets, ersetzen aber noch keinen echten Android-Godot-Render-/FPS-Test.

## Herkunft und Referenzstatus

Das im Google Drive bereitgestellte neungeteilte Ulala-Archiv dient ausschließlich als visuelle/technische Referenz. Die existierenden Metadateninventare belegen **keine** vollständige Dekodierung von Ulala-Landschafts-Vertex- und Indexdaten. Die hier erzeugten Hügel sind eigenständige prozedurale Spielgeometrie; keine fremden Meshes, Materialien oder Texturen wurden übernommen.

## Prüfung

`python -m unittest tests.test_forest_horizon_ridges`

Manueller nächster Schritt: Godot 4.7.2 auf Android starten und Blickwinkel, Z-Fighting, Clipping, Draw Calls sowie FPS bei Niedrig/Mittel/Hoch vergleichen.
