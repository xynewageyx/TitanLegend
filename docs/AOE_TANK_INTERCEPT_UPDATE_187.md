# Titan Legends – Update 187: Atomarer Flächenschutz im Bosskampf

## Problem
Bei `_damage_heroes()` wurde der lebende Tank **innerhalb** der Schleife über die Ziele eines Flächenangriffs erneut gesucht. Wenn der Tank früh in der Schleife getötet wurde, ging der aktive Gruppenabfang-Schutz für die weiteren Helden innerhalb *desselben* Angriffs verloren. Das Ergebnis konnte je nach Reihenfolge der Heldenplätze schwanken.

## Fix
- Der zu Beginn eines gleichzeitigen Schadensereignisses lebende Tank wird nur **einmal** bestimmt.
- Auch der Status von `tank_intercept_until` wird vor der Schaden-Schleife erfasst.
- Bei aktivem Abfangen werden alle betroffenen Verbündeten im **gleichen Flächenangriff** weiterhin mit 35 % Basisminderung behandelt, selbst wenn der Tank während des Angriffs fällt.
- Zusätzlicher individueller Talentschutz bleibt weiterhin multiplikativ.
- Bei späteren, *separaten* Angriffen muss ein Tank erneut lebend vorhanden sein; der Schutz wird nicht künstlich verlängert.
- Die vorbereiteten Heilungen werden weiterhin **erst nach** Abschluss des gesamten Schadensereignisses ausgelöst, sofern das Team überlebt; keine Wiederbelebung.

## Deterministischer Grenzfall zur Erläuterung
Ein aktiver Tank steht auf Slot 0, benutzt Gruppenabfangen und stirbt beim nächsten Flächenangriff. Sein Verbündeter auf Slot 1 erhält in demselben Angriff jetzt unverändert 35 % Basis-Schadensminderung. Vorher konnte er bei dieser Reihenfolge nur 5 % erhalten. Bei 100 eingehendem Basisschaden wären dies 65 statt 95 Schaden (vor Talentminderung und unter Vernachlässigung von Ausweichen). Dieser Fall ist eine **Berechnungsillustration**, kein ausgeführter Godot-Test.

## Beibehaltener Umfang
- 60-Sekunden-Limit für Bosse.
- Maximal ein aktiver Tank im Viererteam.
- Feste Skillfolge 1 → 2 → 3 → 4.
- Passive Pets, vier Bossarchetypen je Gebiet mit festem Gebietselement, Bossbegleiter ab Gebiet 5.

## Validierung
Nach Commit wurde der Quellcode geprüft; in `tests/test_core_import.py` wurde ein statischer Regressionstest ergänzt, der das Ermitteln des Tanks und des Schutzstatus **vor** der Zielschleife kontrolliert.

**Kein echter Godot-4.7-Laufzeittest, Android-Build oder neuer vollständiger 12-Gebiete-Balancing-Lauf.** Den Kampf müssen wir anschließend in Godot mit Tanktod im selben AoE-Hit testen.
