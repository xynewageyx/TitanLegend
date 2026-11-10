# Pixelbasierte Gegenproben für die Vierer-Formation

Stand: 2026-11-10. **Testlauf für diese neue Funktion noch nicht bestätigt**; die bisherigen OpenGL-Tests betreffen die vorherige Bounding-Box-Variante.

## Ziel

Die bestehende Analyse der projizierten 3D-Begrenzungsrahmen sagt nicht, welche Pixel durch Waffen, Begleiter oder Effekte tatsächlich verändert werden. Deshalb erzeugt `tools/render_live_equipment_qa.gd` im originalen vierköpfigen Godot-Team während eines eingefrorenen Attack-Frames zusätzlich drei Gegenproben:

1. `formation_mythic_attack_without_weapon.png`: alle vier Hauptwaffen ausgeblendet.
2. `formation_mythic_attack_without_pet.png`: alle vier passiven Begleiter ausgeblendet.
3. `formation_mythic_attack_without_effect.png`: alle vier echten `HeroCombatMotion/AttackFlash`-Knoten ausgeblendet.

Die Referenz bleibt `formation_mythic_attack.png`. Alle Aufnahmen verwenden dieselbe orthografische Kamera. Vor den Gegenproben werden die prozeduralen Kampfbewegungs- und Begleiter-Updates in dieser **isolierten QA-Szene** angehalten. Im normalen Spiel bleiben sie aktiv.

## Auswertung

Die Godot-RGB8-Framebufferdaten werden pro Pixel verglichen. Ein Pixel gilt als verändert, wenn mindestens ein Farbkanal um mehr als **24 von 255** abweicht. Für jede der drei Kategorien enthält das `manifest.json`:

- Anzahl und Anteil veränderter Pixel im 720×1280-Gesamtbild.
- Veränderte Pixel innerhalb der vier projizierten Charakterkörper-Rechtecke, einzeln nach Charakter-Slot.
- Den Namen des jeweiligen Gegenproben-PNG.
- Weiterhin den separaten, konservativen AABB-Vergleich.

Der Audit `tools/check_four_hero_visual_manifest.py` prüft, ob für Waffen, Begleiter und Effekte alle drei Datensätze, korrekten Gegenprobenamen, gültigen Pixelzahlen und vier Einzelregionen vorliegen. Bei fehlenden Daten schlägt CI fehl.

**Wichtig:** Dieser Wert ist ein *gerenderter Pixelunterschied*, **kein** direkter Anteil verdeckter Körperpixel und keine 3D-Kollisionserkennung. Unterschiedliche Farben, Transparenz, freigelegte Hintergrundbereiche oder Reflexionen können den Unterschied erzeugen. Auch wenn eine Waffe nur den Hintergrund überdeckt, kann sie viele veränderte Pixel verursachen.

## Nächste unabhängige Prüfungen

- GitHub Actions muss zunächst 75 PNG-Dateien (71 Einzelaufnahmen einschließlich drei Gegenproben plus vier Übersichten) erzeugen und die 7 Python-Manifest-Regressionstests bestehen.
- Danach die tatsächlichen Pixelanteile aus dem Artefakt übernehmen.
- Für *echte* Körperpixel-Verdeckung wären zusätzlich pro Charakter segmentierte Silhouetten-/Objekt-ID-Masken mit und ohne die jeweilige Vordergrundkategorie erforderlich.
- Eine Prüfung auf physischem Android und bei der normalen Gameplay-Kameraperspektive bleibt offen.

Die Methode verwendet ausschließlich original erstellte Titan-Legends-Modelle und Assets.
