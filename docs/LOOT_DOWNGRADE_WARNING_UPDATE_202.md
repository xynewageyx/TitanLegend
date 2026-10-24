# Titan Legends – Update 202: Warnung vor schwächerer Ausrüstung

Dieses Update erweitert nur **Vergleichen und sichere Ausrüstungswechsel**. Keine Zerlegung, keine neuen Upgrades.

## Vor unbeabsichtigten Nachteilen schützen
- Wenn der ausgewählte Helm, die Rüstung oder das Zubehör weniger Bonus als die aktuell vom Zielhelden getragene Ausrüstung bietet, erscheint vor dem Anlegen ein **Bestätigungsdialog**.
- Vergleichsgrundlage ist die bereits vorhandene zentrale Bonusformel; der Unterschied wird in Prozentpunkten angezeigt.
- Der Dialog speichert die unveränderliche Item-ID und die Zielheldennummer. Bestätigung prüft, ob das Item weiterhin verfügbar und nicht inzwischen anderswo getragen wird; Abbrechen verändert nichts.
- Bei einem Item, das **ein anderer Held trägt**, bleibt dessen bisheriger Übertragungsdialog erhalten. Er weist zusätzlich darauf hin, wenn der Zielheld ein schlechteres Item erhalten würde.
- Gleichwertige oder bessere, frei verfügbare Items können weiterhin direkt angelegt werden.
- Die mehrzeiligen Vergleichstexte und Bestätigungsdialoge nutzen nun echte GDScript-Zeilenumbrüche.

## Unverändert
Der Verkauf benötigt weiterhin eine Bestätigung und verbietet Verkäufe angelegter Items. Inventargröße, Boss-Drops, Goldwerte, Ausrüstungsslots, Speicherung und Kampf-Balancing wurden nicht verändert.

## Teststatus
Neuer statischer Regressionstest in `tests/test_core_import.py`, GitHub-Quellcode geprüft. **Noch kein tatsächlicher Godot-4.7-Laufzeittest oder Android-APK-Build.**
