# Titan Legends – Update 198: Nur Verkaufen und Vergleichen

## Umfang
Auf Wunsch wurden **ausschließlich** zwei Inventarfunktionen ergänzt: Verkaufen und Vergleich. Kein Zerlegen, kein Aufwerten gedroppter Gegenstände, keine weiteren Systeme.

## Verkaufen
- Verkaufswert eines Gegenstands: **Itemstufe × (20 + 10 × Qualitätsindex)** Gold; Qualitätsindex Weiß = 0 bis Lila = 5.
- Nur **nicht angelegte** Gegenstände können verkauft werden; dies wird sowohl im Code als auch über einen deaktivierten Android-Verkaufsbutton abgesichert.
- Beim Verkauf wird die eindeutige Gegenstands-ID aus dem Inventar entfernt, Gold gutgeschrieben und gespeichert.
- Nach dem Verkauf bleibt die Inventarauswahl innerhalb des gültigen Bereichs.
- Angelegte Gegenstände können zuerst durch Ausrüsten eines anderen Gegenstands im selben Slot frei gemacht werden.

## Gegenstandsvergleich
Im scrollbaren Ausrüstungsfenster wird der ausgewählte Gegenstand für den ausgewählten Helden dem **bereits ausgerüsteten Gegenstand desselben Platzes** gegenübergestellt. Sichtbar sind Gegenstandsname, aktueller Bonus, neuer Bonus und Differenz in Prozentpunkten.
- Helm: maximale HP
- Rüstung: Schadensminderung
- Zubehör: Angriff
Die Werte verwenden dieselbe Formel wie der bestehende tatsächliche Kampfbonus: Seltenheit und Stufe bis maximal +12 %.

## Sicherheit und Verifikation
Bestehende Spielstände werden nicht migriert oder verändert, bis der Spieler einen Gegenstand verkauft. Die vorhandene SaveManager-Speicherung wird wiederverwendet.

Static Regression Assertions: `tests/test_core_import.py` – Verkaufssperre bei angelegten Items, Goldgutschrift, Speicherung, Vergleich desselben Slots und neue Bedienelemente. **Kein ausgeführter Godot-4.7-Laufzeittest/Android-Build.**
