# Titan Legends – Update 183: CC-Timing-Belastungstest

## Ausgangslage
- 60 Sekunden Bosslimit: **unverändert**.
- Automatische Reihenfolge der vier Skills: 1 → 2 → 3 → 4.
- Ein Skill muss durch normale Treffer aufgeladen werden (Slotkosten: 2, 3, 4, 4 bei Standardbelegung).
- Angriffstempo: Tank 1,25 s, DD jeweils 0,75 s, Heiler 1,5 s.
- Cast-Abstände: ein gegnerischer Kampftick ca. 2,2 s.
- Unterbrechungsfenster bei 1/2/3 nötigen CC: 3/5/7 Ticks.

## Deterministische Stichprobe
18 verschiedene Cast-Startphasen; vier Helden mit Standard-Fertigkeiten, wobei die angegebene Zahl an Helden CC auf Platz 4 ausgerüstet hat. Die übrigen nutzen einen normalen Angriff auf Platz 4.

| CC-ausgerüstete Helden | 1 CC erforderlich | 2 CC erforderlich | 3 CC erforderlich |
|---:|---:|---:|---:|
| 1 | 6/18 | 0/18 | 0/18 |
| 2 | 14/18 | 12/18 | 10/18 |
| 3 | 14/18 | 18/18 | 17/18 |
| 4 | 14/18 | 18/18 | 18/18 |

## Interpretation
- Ein einzelner CC-Held kann in dieser Stichprobe keine mehrfachen CC-Anforderungen erfüllen.
- Mit zwei CC-Helden hängt der Erfolg stark von der Phase ab, in der der Boss den Zauber beginnt.
- Mit drei oder vier CC-Helden sind Drei-CC-Zauber in der Stichprobe zuverlässig, aber nicht uneingeschränkt garantiert.
- Selbst bei einem benötigten CC kann die Unterbrechung misslingen, wenn der entsprechende Skill gerade nicht aufgeladen ist.
- Die 60 Sekunden werden nicht verlängert; nur das Zeitfenster für den *einzelnen* Cast hängt von der CC-Anforderung ab.

## Reproduzierbarkeit und Einschränkungen
Das Modell ist in `tests/test_cc_timing.py` hinterlegt, ausführbar mit:
`python -m unittest discover -s tests -p 'test_cc_timing.py' -v`.

Die Zeitdiskretisierung beträgt 0,05 s. Es handelt sich um eine gezielte **Skill-/Cast-Timing-Näherung**, **keinen vollständigen Godot-Bosskampf**. Sie ignoriert Ausweichmanöver, tatsächliche Boss-HP, Skillbedingungen für Heiler, Unterbrechungen durch Teamtod, zufällige Ereignisse und Framerates. Die Resultate dürfen nicht als echte CC-Erfolgsquote im Spiel interpretiert werden. Im Repository wurde für diesen Test die Castzeit nicht weiter verändert.

## Nächster Schritt
Test im Godot-4.7-Lauf mit echter Vierer-Skillrotation und Anzeige des CC-Castfensters. Insbesondere überprüfen, wie Heiler-Fähigkeiten die feste Rotation verzögern können.
