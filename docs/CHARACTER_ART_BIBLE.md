# Titan Legends – Character Art Bible v1

## Ziel
Eigenständige, hochwertige stylisierte 3D-Fantasy-Helden mit charmanten Chibi-Proportionen; keine Übernahme fremder Meshes, Texturen oder geschützter Charakterdesigns. Android-Hochformat und Godot-GL-Compatibility bleiben verbindlich.

## Silhouette und Proportionen
- Grundfigur: ca. 2.5–3.2 Kopfhöhen als verbindlicher Chibi-Zielbereich; Tank 2.5–2.8, agile Klassen 2.8–3.2.
- Große lesbare Hände und Waffen, markante Schuhe, klare Farbflächen; Lesbarkeit bei 720x1280 prüfen.
- Klassen müssen ohne Texturen anhand der Silhouette erkennbar sein.
- Gesicht: getrennte Augenbrauen, Augenlider, Mundformen und Blickrichtung; mindestens neutral, froh, wütend, überrascht, getroffen.

## Visuelle Referenz: Ulala-artiger Cartoon-Look
- Große rundliche Köpfe, kurze Gliedmaßen, kompakte Körper, breite Hände und Füße.
- Dicke, in Volumen modellierte Haarsträhnen, runde Wangen, kleine Nase und sehr lesbare Augen.
- Weiche Farbverläufe und sanftes Toon-Shading; keine fotorealistischen PBR-Materialien oder scharfkantigen Low-Poly-Platzhalter.
- Federnde Bewegungen mit klaren Antizipations- und Nachschwungphasen; besonders Idle, Run, Attack und Hit.
- Rüstung und Waffen überzeichnet, aber eigenständig gestaltet; keine direkte Übernahme fremder Modelle, Texturen oder unverwechselbarer Designs.
- Freigabe eines Referenzcharakters anhand von Front-, Seiten-, Rückenansicht und Ingame-Screenshot vor Serienproduktion.

## 11 Klassen
| Klasse | Silhouette | Bewegung |
|---|---|---|
| Krieger | Breite Schultern, massive Stiefel | schwere Hiebe |
| Paladin | Schildform, aufrechte Haltung | kontrollierte Schläge |
| Druide | organische Stofflagen, Blattformen | fließende Gesten |
| Schamane | Totemdetails, asymmetrische Kleidung | rhythmische Zauber |
| Jäger | leichte Schulterpartie, Köcher | gespannte Bogenhaltung |
| Schurke | schmale Taille, leichte Rüstung | schnelle Ausweichschritte |
| Magier | hohe Kopfbedeckung oder Mantel | klare Zauberposen |
| Hexer | kantige Stofflagen, düstere Akzente | gewichtige Beschwörung |
| Beschwörer | Runensymbole, markante Ärmel | dirigierende Gesten |
| Priester | helle Stofflagen, ruhige Haltung | heilende Gesten |
| Raufbold | große Fäuste, kompakter Oberkörper | schnelle Schlagfolgen |

## Modularer Charakteraufbau
- Ein konsistentes humanoides Rig pro Körperbau; gemeinsame Bone-Namen und Retargeting.
- Steckplätze: hair, head, torso, gloves, legs, boots, main_hand, off_hand, back.
- Körper unter geschlossener Rüstung verdecken statt doppelte Oberflächen zu rendern.
- Haare, Kleidung und Waffen als eigene Meshes mit konsistenten Ankerpunkten.
- Keine Laufzeitabhängigkeit von Blender: Export als glTF 2.0 (.glb).

## Animationsbasis
idle, walk, run, attack_1, attack_2, cast, hit_front, dodge, victory, death; pro Klasse passende Varianten. Root-Motion zunächst deaktivieren, Fortbewegung über Spiellogik. Treffer- und Skill-Timing mit benannten Animationsevents koppeln.

## Qualitätskontrolle
1. Silhouette im Graumaterial bei kleiner Bildschirmdarstellung erkennbar.
2. Keine offenen Nähte, sichtbaren Clipping-Fehler oder invertierten Normalen.
3. Skelette und modulare Slots in Blender und Godot gleich ausgerichtet.
4. Idle/Run/Attack/Hit/Death im GLB vorhanden und in Godot abspielbar.
5. Performance mit vier Helden plus Begleitern und Gegnern auf Android messen.
6. Kein fremdes urheberrechtlich geschütztes Asset ungeprüft in das Spiel importieren.

## Nächste Umsetzung
Zuerst einen vollständig riggbaren Krieger als Referenzmodell bauen und validieren. Danach Rig, Material- und Animationsstandard auf weitere Klassen übertragen. Art-Bible ist Spezifikation, kein Nachweis fertig erstellter 3D-Modelle.
