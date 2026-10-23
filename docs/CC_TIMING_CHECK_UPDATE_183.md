# Titan Legends – Update 183: Vorbereitete Boss-Unterbrechungen

## Problem und Korrektur
Mit der strikten Skillfolge 1→2→3→4 können Unterbrechungen erst nach mehreren normalen Angriffen verwendet werden. Eine ausschließlich während eines Boss-Casts nutzbare CC-Fähigkeit blockierte zuvor die Rotation; nach Update 182 lief sie außerhalb des Casts ohne CC-Effekt weiter. Dadurch war ein frühes Zeitfenster von 1–3 verlangten CC-Treffern schwer zuverlässig zu treffen.

Der Skill auf Platz 4 legt nun bei Ausführung außerhalb eines unterbrechbaren Bosszaubers **einen vorbereiteten CC-Treffer pro Held** ab. Dieser wird beim nächsten unterbrechbaren Cast automatisch angerechnet:
- Die vorbereitende Aktion verbraucht die normalen Treffer der regulären Slot-4-Position und rückt erst danach zu Slot 1 weiter.
- Je Held ist höchstens ein Treffer gespeichert, kein kostenloses CC-Stapeln.
- Gefallene Helden liefern keine vorbereiteten Treffer.
- Ein aktiv ausgeführter Unterbrechungsskill während eines Casts zählt direkt, wie bisher.
- Nach ausreichend CC-Treffern wird der Bosszauber sicher beendet und die CC-Anzeige zurückgesetzt.
- Boss-Zeitlimit **unverändert 60 Sekunden**. Castfenster: 1 CC = 3 gegnerische Ticks, 2 CC = 5, 3 CC = 7; gegnerischer Tick ungefähr 2,2 s.

## Zeitlicher Plausibilitätstest (vereinfachte Modellrechnung)
Ein separates deterministisches Python-Timingmodell berechnet 60 Sekunden, Helden-Angriffsintervalle [1,25; 0,75; 0,75; 1,50] Sekunden, Aufladekosten [2,3,4,4] Treffer und Boss-Zauberbeginn nach vier gegnerischen Ticks sowie bei späteren Zaubern etwa neun Ticks nach Start. Bei einem voll lebenden Standardteam und **durchgehend nutzbaren Slots 1–3** erfüllt der Modelllauf die Fälle 1, 2 und 3 benötigte CC-Treffer jeweils in drei gestarteten Zeitfenstern (~8,8 s / 28,6 s / 48,4 s).

Dies ist **kein Godot-Laufzeittest und keine gemessene Unterbrechungsquote**. Die vereinfachte Rechnung modelliert keine HP-Abfälle, nicht nutzbare Heilskills, Wechsel der CC-Anforderung je Bosszauber, Zielwahl, Gold, UI, tatsächliche Frametimings oder Tod eines Helden. Insbesondere können reine Heilslots bei voller Gesundheit in der echten Spiellogik weiterhin die Rotation bis zum nächsten verletzten Helden aufhalten.

## Regressionsabdeckung
Im statischen Test `tests/test_core_import.py` ist geprüft:
- Vorbereiteter CC-Speicher existiert und wird beim Team-Reset geleert.
- Gespeicherte Treffer werden nur lebenden Helden zugerechnet und einmalig abgezogen.
- Unterbrechungsfunktion setzt Caststatus zurück und beendet ihn nach ausreichenden Treffern.
- Das 60-Sekunden-Boss-Zeitlimit wird nicht verändert.

Noch offen: Echte Godot-4.7-Testläufe samt UI, sowie Grenzfälle bei wenig Heiler-Treffern, Tod eines Helden oder unbenutzbarem Heilslot.
