# Titan Legends – Update 200: Präziser Gegenstandsvergleich

Umfang bleibt ausschließlich **Verkaufen und Vergleichen**. Weder Zerlegen noch zusätzliche Item-Upgrades wurden ergänzt.

## Verbesserter Vergleich
- Vergleich zeigt jetzt klar **BESSER / SCHWAECHER / GLEICH STARK** anhand des tatsächlichen Bonusunterschieds. Gleichstand bei Differenzen unter 0,000001.
- Kompakter mehrzeiliger Android-Text statt einer sehr langen Zeile mit Itemtyp, aktueller Ausrüstung und Kandidatenbonus.
- Zusätzlich wird ausgewiesen, wenn das ausgewählte Item bereits bei einem anderen Helden getragen wird.
- Werte werden weiter als **Prozentpunkte** verglichen, nicht als prozentuale Änderung relativ zum Ausgangswert.

## Konsistenz
`loot_bonus()` für den echten Kampf verwendet ab sofort unmittelbar `loot_item_bonus()`, dieselbe zentrale Berechnung, die auch im Vergleich genutzt wird. Damit können die beiden Formeln nicht auseinanderlaufen.

## Unverändert
- Nur nicht angelegte Items dürfen verkauft werden.
- Beim Verkauf bleibt der Sicherheitsdialog mit erneuter Prüfung der stabilen Item-ID erhalten.
- Inventar, Savegames, Dropchancen, Boss-Balancing und 60-Sekunden-Zeitlimit bleiben unverändert.

## Prüfung
Codeverknüpfungen erneut aus GitHub abgerufen und ein zusätzlicher statischer Regressionstest in `tests/test_core_import.py` ergänzt. **Kein Godot-4.7-Laufzeittest oder Android-APK-Test.**
