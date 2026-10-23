# Titan Legends – Update 182: Vierer-Skillrotation und Boss-CC

## Behobener Fehler
Die feste automatische Skillreihenfolge 1 → 2 → 3 → 4 → 1 wurde durch Unterbrechungsskill Nr. 7 blockiert: Er durfte zuvor **nur** während eines unterbrechbaren Bosszaubers verwendet werden. Sobald er auf Slot 4 stand, konnten normale Mobwellen und ruhige Bossphasen die übrigen drei Skills nicht mehr erreichen. Da die gespeicherte Standardbelegung `[0,1,2,7]` ist, betraf das besonders neue Teams.

### Neue Regeln
- Die Skillreihenfolge bleibt strikt; Slots werden weder übersprungen noch vertauscht.
- Ist Slot 4 mit Unterbrechung belegt, läuft er außerhalb eines unterbrechbaren Bosszaubers als **„Kontrolle vorbereitet“** durch. Er verursacht dabei keinen Schaden und zählt nicht als CC. Die Rotation geht anschließend wieder bei Slot 1 los.
- Während eines unterbrechbaren Bosszaubers zählt derselbe Skill als ein CC-Treffer.
- Nach genügend CC-Treffern endet der Cast sofort, und sein CC-Fortschritt wird vollständig zurückgesetzt.
- Der Boss darf bei einem unterbrochenen Cast nicht zusätzlich die ursprünglich angekündigte Spezialfähigkeit ausführen.

## Castfenster
Die Zeit zum Unterbrechen hängt von der geforderten Anzahl an CC-Treffern ab. Die bestehende gegnerische Angriffsperiode beträgt ungefähr 2,2 Sekunden.

| Benötigte CC-Treffer | Castfenster (gegnerische Ticks) | Ungefährer Zeitraum |
|---:|---:|---:|
| 0 (nicht unterbrechbar) | 3 | 6,6 Sekunden |
| 1 | 3 | 6,6 Sekunden |
| 2 | 5 | 11,0 Sekunden |
| 3 | 7 | 15,4 Sekunden |

Das **Bosslimit bleibt 60 Sekunden**, der Cast dauert nur gegebenenfalls etwas länger. Die Helden müssen weiterhin genug normale Angriffe durchführen, um ihre Skills aufzuladen.

## Validierung
- Quellcode- und Commit-Prüfung der neuen CC-Verzweigungen.
- Statische Regressionstests in `tests/test_core_import.py` ergänzt.
- Noch **kein Godot-4.7-Laufzeittest** oder vollständige Monte-Carlo-Simulation der kombinierten vier Skillrotationszustände.
- Insbesondere bei drei benötigten CC-Treffern ist der Erfolg abhängig von Skillbelegung, Angriffstempo und Castzeitpunkt. Das Castfenster garantiert **keine** Unterbrechung.

## Weitere Aufgaben
Prüfung mit laufendem Godot: 60-Sekunden-Bosslimit, Unterbrechungsfolge bei zwei bis drei Helden, Anzeige des Castfortschritts sowie Bossfähigkeit bei verpasstem CC.
