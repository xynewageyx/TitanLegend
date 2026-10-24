# Titan Legends – Update 201: Geschützter Wechsel der Ausrüstung zwischen Helden

Die Inventararbeiten bleiben wie gewünscht auf **Vergleichen und Verkaufssicherheit** beschränkt. Keine Zerlegung, neuen Gegenstandsverbesserungen oder Lootänderungen.

## Fehlervermeidung
Bisher führte der Knopf „Ausrüsten“ bei einem von einem anderen Helden getragenen Gegenstand sofort zu dessen Abnahme. Jetzt wird bei einer solchen Übertragung vorab ein Bestätigungsdialog angezeigt.

- Die Vergleichsanzeige nennt den Helden, der den ausgewählten Gegenstand bereits trägt.
- Sie warnt ausdrücklich, dass dieser Held den Gegenstand verliert.
- Der Dialog zeigt Gegenstandsname, alten und neuen Helden.
- Während des Dialogs werden **die eindeutige Item-ID und die ID des Zielhelden** festgehalten, nicht der aktuelle Inventarindex.
- Bei Bestätigung wird geprüft, ob das Item noch vorhanden ist und tatsächlich noch von einem anderen Helden getragen wird. Nur dann wird es übertragen.
- Abbrechen verändert weder Inventar noch Ausrüstung.
- Frei verfügbare Gegenstände werden weiterhin direkt angelegt. Der Verkauf bleibt durch die bereits vorhandene Bestätigungsabfrage gesichert.

## Verifikation
Änderungen im `scripts/ui_manager.gd`, Regressionstest in `tests/test_core_import.py`. Die geänderten Codepfade sind statisch überprüfbar. Ein Godot-4.7-Laufzeittest bzw. Android-APK-Test wurde noch nicht durchgeführt.
