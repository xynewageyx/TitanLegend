# Titan Legends – Update 199: Sicherer Verkauf und Vergleich

## Änderung
Das Loot-Inventar bleibt auf **Verkaufen und Vergleichen** beschränkt. Keine Zerlegung, keine weiteren Verbesserungen.

### Zweistufiger Verkauf
1. Der Spieler wählt einen nicht ausgerüsteten Gegenstand.
2. Das Bestätigungsfenster zeigt **Name und Verkaufspreis** an.
3. Erst nach Bestätigung wird die **eindeutige Item-ID** erneut im Inventar gesucht und geprüft.
4. Ist das Item inzwischen nicht mehr vorhanden oder wurde es ausgerüstet, wird der Verkauf abgebrochen.
5. Bei Erfolg: Item entfernen, Gold gutschreiben, Spielstand speichern.
6. Abbrechen verwirft die vorgemerkte ID ohne Änderung des Inventars.

Der Verkaufsknopf ruft nicht mehr direkt den Löschvorgang auf. Der bisherige Verkaufsschutz im GameManager bleibt erhalten.

### Vergleich
Die vorhandene Gegenüberstellung von Helm, Rüstung oder Zubehör zum belegten Platz des ausgewählten Helden bleibt unverändert. Sie zeigt weiterhin den ausgerüsteten Bonus, den Kandidatenbonus und die Differenz.

### Qualitätssicherung
- Statische Quellcodeprüfungen für Verknüpfung des Dialogs, ID-Bindung, Verkaufsverbot für angelegte Items und doppelte Sicherheitsprüfung durchgeführt.
- In `tests/test_core_import.py` ist der bisher fehlerhafte Abschnittstrenner für die Auslese der GDScript-Funktionen repariert.
- Neuer Regressionstest für die Bestätigungsstrecke hinzugefügt.
- **Kein echter Godot-4.7-Laufzeittest oder Android-APK-Test durchgeführt.** Der Bestätigungsdialog und Touchbedienung sind auf Android noch visuell zu prüfen.
