# Titan Legends – Update 204: Keine veralteten Ausrüstungsvergleiche bestätigen

Dieses Update bleibt bei **Verkaufen und Vergleichen**. Kein Zerlegen, keine neuen Upgrades.

## Problem
Zwischen dem Öffnen eines Bestätigungsdialogs und der tatsächlichen Bestätigung kann sich die Ausrüstung ändern. Ein zuvor angezeigter Vergleich könnte dann nicht mehr stimmen.

## Lösung
- Beim Übertragen eines Gegenstands von einem anderen Helden werden vier unveränderliche Referenzen festgehalten: Item-ID, bisheriger Träger, Zielheld und Item-ID des vorherigen Gegenstands im Zielslot.
- Vor der Übertragung wird geprüft, ob der Gegenstand noch existiert, der bisherige Träger unverändert ist und der Zielslot noch denselben Gegenstand enthält.
- Vor dem bewussten Anlegen schwächerer Ausrüstung wird ebenfalls die Item-ID des vorherigen Zielgegenstands festgehalten und beim Bestätigen verglichen.
- Ändert sich einer dieser Zustände, erfolgt **keine Ausrüstungsänderung**; der Spieler kann den aktualisierten Vergleich erneut aufrufen.
- Abbrechen löscht die vorgemerkten Referenzen. Die Verkaufssperre für angelegte Items und die separate Verkaufsbestätigung bleiben erhalten.

## Technischer Status
Implementiert in `scripts/ui_manager.gd`; der bestehende Test der Übertragungsprüfung wurde angepasst und ein statischer Regressionstest für beide veralteten Vergleichszustände in `tests/test_core_import.py` ergänzt.

**Godot 4.7 ist in der verfügbaren lokalen CLI-Umgebung nicht installiert.** Daher kein tatsächlicher Laufzeittest und kein Android-Build. Quelltextprüfung ist kein Ersatz dafür.
