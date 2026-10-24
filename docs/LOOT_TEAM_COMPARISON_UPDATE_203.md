# Titan Legends – Update 203: Zwei-Helden-Vergleich bei Ausrüstungsübertragung

Nur **Verkaufen und Vergleichen**; keine Zerlegung, keine Gegenstandsverbesserung.

## Vergleich bei Übertragungen
Wenn ein Inventargegenstand bereits bei einem anderen Helden getragen wird, werden künftig im Ausrüstungsfenster und im Übertragungsdialog drei Werte angezeigt:

- **Verlust des bisherigen Trägers:** Der Bonus des abgelegten Gegenstands (in Prozentpunkten).
- **Gewinn/Verlust des Zielhelden:** Differenz zwischen dem Kandidaten und dem bisher ausgerüsteten Gegenstand desselben Ausrüstungsplatzes.
- **Nettoveränderung für beide Helden:** Wert des Zielhelden minus wegfallender Bonus des bisherigen Trägers.

Beispiel: Held 2 verliert einen Helm mit +8 % HP, Held 1 gewinnt +3 Prozentpunkte gegenüber seinem aktuellen Helm. Netto verändern sich die zusammengezählten Bonus-Prozentpunkte um −5 Prozentpunkte. Das ist **keine Simulation der vollständigen Teamkampfstärke**, weil verschiedene Helden unterschiedliche Rollen haben.

Diese Berechnung wird nur angezeigt, wenn das Item tatsächlich von einem *anderen* Helden getragen wird. Frei verfügbare Items bleiben beim üblichen direkten Vergleich. Der Verkaufs- und Übertragungsschutz samt Bestätigungsfenstern bleibt erhalten.

## Technik
Neue `GameManager.compare_loot_transfer(hero, item_id)` berechnet `source_loss`, `target_gain` und `net_change` anhand der vorhandenen `loot_item_bonus`/ `compare_loot`-Funktionen. UI zeigt die Werte im Vergleich und im Dialog. Neuer statischer Regressionstest in `tests/test_core_import.py`.

**Kein ausgeführter Godot-4.7- oder Android-Laufzeittest.** Quellcodeverknüpfungen können statisch geprüft werden.
