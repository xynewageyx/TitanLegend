# Titan Legends – Stylized Enemy Art Bible v1

## Ziel
Eigenständiger, farbenfroher 3D-Cartoon-Look mit ähnlicher Lesbarkeit und verspielten Proportionen wie Ulala: Idle Adventure. Keine Übernahme fremder Charaktermodelle, Texturen oder Silhouetten.

## Technik
- Godot 4, Android Hochformat, GL Compatibility
- Blender Headless über GitHub Actions; glTF 2.0 / GLB
- Kleine Gegner: ca. 800–2500 Dreiecke; Elite: 2500–5000; Boss: 5000–10000 (vorläufige Zielbudgets, durch Gerätetests validieren)
- 1–2 Materialien pro normalem Gegner; wenige transparente Partikel; gemeinsame Texturatlanten
- Animationen: idle, move, attack, hit, death; Boss zusätzlich telegraph, special, enrage
- Silhouetten, Angriffs-Telegraphen und Trefferboxen im 720x1280-Hochformat testen

## Feuergebiet: acht Gegnertypen
| ID | Name | Silhouette | Bewegung | Elementangriff |
|---|---|---|---|---|
| fire_01 | Glutknirps | Rundkopf, große Ohren, kurze Arme | Hüpfen | Glutfunken |
| fire_02 | Lavahüpfer | Breiter Froschkörper, kurze Beine | Springen | Lavapfütze |
| fire_03 | Aschepanzer | Ovaler Käfer, hoher Rückenpanzer | Krabbeln | Aschestoß |
| fire_04 | Funkenflitzer | Kleiner Fuchs, großer Schweif | Sprinten | Funkenstoß |
| fire_05 | Magmahorn | Breiter Saurier, übergroßes Horn | Stampfen | Bodenschlag |
| fire_06 | Schlackenschleuder | Vulkanpflanze mit Kelchkopf | Schwingen | Glutgeschoss |
| fire_elite_01 | Glutwächter | Breiter Krieger, übergroße Fäuste | Schwere Schritte | Flammenhieb |
| fire_elite_02 | Lavabestie | Vierbeiner, massiver Kopf | Anstürmen | Magmaansturm |

## Boss: Ignarox – Vulkanverschlinger
- Eigenständiger, rundlicher Vulkan-Saurier, kurzer Hals, mächtiger Kiefer, vier breite Beine, obsidianschwarze Schuppen, orange Magmarisse
- Phase 1: Biss, Bodenschlag, Glutspucken
- Phase 2 (z.B. ab 50 % HP): Panzersegmente öffnen sich, glühende Rückenplatten, schnellere Bewegungen; tatsächliche Phasenlogik mit bestehendem Battle-System abstimmen
- 60-Sekunden-Boss-Timer und vorhandene Enrage-Regeln nicht verändern
- Bosskampf-UI nicht überladen; Angriffe durch eindeutige Bodenwarnungen anzeigen

## Mobwellen
- Welle 1: 2 Gegner
- Welle 2: 5 Gegner
- Welle 3: 7 Gegner
- Boss alle 10 Stages; tatsächliche Spawner-Integration erst nach Codeprüfung

## Asset-Pipeline
1. Parametrische Blender-Meshes je Silhouette (nicht nur Farbvarianten)
2. Materialien, Augen und Gesichtsausdrücke pro Typ
3. Rigging / prozedurale Grundanimationen
4. GLB-Export mit benannten Animationen
5. Godot-Import- und Performance-Tests in GitHub Actions
6. Android-Sichtprüfung und Optimierung

## Qualitätskriterien
- Acht erkennbare Silhouetten ohne Farben
- Kein fehlendes GLB, keine kaputten Animationen
- Lesbare Angriffs-Telegraphen auf 720x1280
- Keine ungeprüften Drittanbieter-Assets oder Lizenzen
- Animationen und tatsächliche Gameplay-Integration separat verifizieren

## Nächste Implementierung
Blender-Generator für fire_01 und fire_02, Export-Workflow, Godot-Testszene, danach sechs weitere Gegnertypen und Boss.
