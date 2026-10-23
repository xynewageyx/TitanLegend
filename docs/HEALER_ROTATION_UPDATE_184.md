# Titan Legends – Update 184: Heiler-Rotation ohne Leerlaufblockade

## Befund
Bislang lehnte `_skill_is_usable` heilende Skills bei voller Teamgesundheit ab. In einer festen Rotation 1→2→3→4 führte dies dazu, dass Heiler an ihrem jeweiligen Heilslot hängen blieben und einen späteren Unterbrechungsskill nicht erreichen konnten. Besonders betroffen waren die vier Standardslots [0,1,2,7].

## Änderung
- Jeder regulär geladene Heilerskill kann seinen Platz in der strikten Reihenfolge benutzen.
- Fehlen verletzte, lebende Ziele, wird **nur die Heilkomponente** des Skills vorbereitet (maximal ein vorgemerkter Heilskill je Heldenplatz), statt auf volle HP zu heilen.
- Offensive Skillkomponenten werden wie gewohnt sofort ausgeführt.
- Beim nächsten erlittenen Schaden werden vorbereitete Heilungen auf lebende, verletzte Helden angewandt und aus dem Speicher entfernt. Vorbereitete HoTs laufen entsprechend der bestehenden Tick-Mechanik an.
- Ein gefallener Heiler kann seine vorgemerkte Heilung nicht auslösen; tote Ziele werden nicht wiederbelebt.
- Reset/Neustart des Teams löscht alle vorgemerkten Heilungen.
- Gleichzeitige vorbereitete Heilungen werden in Reihenfolge der Heldenplätze aufgelöst, sofern weiter verwundete Ziele existieren. Im Gegensatz zu unbegrenztem Stapeln speichert jeder Held nur einen vorbereiteten Skill.

## Unveränderte Regeln
- **60 Sekunden** festes Bosskampf-Limit.
- Kein Skill wird übersprungen: 1→2→3→4.
- Boss-CC-Treffer und ihre Vorbereitungen bleiben unabhängig.
- Keine automatische Wiederbelebung.

## Prüfung und Einschränkungen
Die aktualisierte Code-Verdrahtung wurde geprüft und statische Regressionstests in `tests/test_core_import.py` ergänzt. **Kein tatsächlicher Godot-4.7-Laufzeittest**. Offen sind echte Android-Tests für die genaue Reihenfolge von Schaden/Heilung im gleichen Tick, mehrere vorbereitete HoTs, kritische Team-Niederlagen und Boss-Casts.
