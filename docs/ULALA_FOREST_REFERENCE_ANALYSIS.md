# Ulala-Backup: Referenzanalyse für Titan Legends Waldgegner

Stand: 2026-11-04. **Referenzdaten, keine zu importierenden Fremdassets.**

## Datenquelle und Verifikationsstatus
- Google Drive: https://drive.google.com/drive/folders/1exzf9zslKN4U0jPu41Ay-gwkcSBTP0oo
- Neun Teile `ulala_backup.7z.001` bis `.009` sind im Ordner gelistet und über den Drive-Connector abrufbar.
- Eine belastbare Analyse der *inneren* Unity-Bundle-Meshes, Skeletons, Animationen und Materialien liegt in diesem Dokument **noch nicht vor**. Dateinamen und Dateitypen sind kein Nachweis für tatsächliche Rig-/Clip-Eigenschaften.
- Keine Ulala-Modelle, -Texturen, -Animationen oder geschützten Silhouetten in das Spiel übernehmen.

## Abgleich mit den eigenen Gegnern
| Titan-ID | Name | Zu untersuchende Referenzeigenschaft | Eigene Animationsbasis |
|---|---|---|---|
| forest_01 | Mooshüpfer | Hüpfrhythmus, Squash/Stretch, Augenfokus | idle/attack/hit/death |
| forest_02 | Pilzling | Kappenbewegung, Vorwarnung vor Angriff | idle/attack/hit/death |
| forest_03 | Wurzelkrabbler | Beinversatz und Bodenkontakt | idle/attack/hit/death |
| forest_04 | Blattfuchs | Vierbeiner-Gang, Schweif-Überlappung | idle/attack/hit/death |
| forest_05 | Dorneneber | Gewicht, Ansturm-Antizipation | idle/attack/hit/death |
| forest_06 | Rankenwerfer | Fernangriffs-Telegraph, Ranken-Nachlauf | idle/attack/hit/death |
| forest_elite_01 | Rindenwächter | Schwere Armbewegung, Trefferlesbarkeit | idle/attack/hit/death |
| forest_elite_02 | Moosbestie | Vierbeiner-Gewichtsverlagerung | idle/attack/hit/death |
| forest_boss_01 | Wurzelkönig | Boss-Telegraph, Phasenwechsel, Timing | idle/attack/hit/death |

## Nächste technisch nachweisbare Schritte
1. Vollständige mehrteilige 7z-Datei in einer Arbeitsumgebung zusammensetzen; CRC/Archivtest durchführen.
2. Nur Dateiverzeichnis und gezielte Monster-/Animations-Bundles extrahieren, statt pauschal alle Ressourcen ins GitHub-Repo zu kopieren.
3. UnityFS-Metadaten mit einem passenden Parser lesen; Typen `GameObject`, `Mesh`, `Animator`, `AnimationClip`, `SkinnedMeshRenderer` erfassen.
4. Je Referenz **abstrakte** Werte protokollieren: Knochenanzahl, Clipnamen/-längen, Silhouettenverhältnisse, Materialanzahl, Bewegungsphasen. Keine geschützten Inhalte exportieren.
5. Eigene Blender-Generatoren und Godot-Tests anpassen; Android-Sichttest separat durchführen.

## Unveränderliche Spielregeln
Wald ist Gebiet 1, 100 Stages; normale Stages mit 2/5/7 Gegnern und Boss alle zehn Stages. Kampfsystem und Skill-Auswahl bleiben unberührt. Die bestehenden neun Waldgegner besitzen vier Grundclips; weitere Clips erst nach Implementierung und CI-Test als fertig markieren.

Siehe `docs/ENEMY_ART_BIBLE_FOREST_START_V1.md` und `docs/ENEMY_ART_BIBLE_STYLIZED_V1.md`.
