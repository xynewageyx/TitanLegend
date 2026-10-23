# Titan Legends – Update 194: Erste Ausrüstungshärtung

## Implementiert
Vier unabhängige Härtungsfelder **pro Held**, zusätzlich zu dessen Waffenlevel:
1. Angriff: +0,02 % Angriffsschaden je Rang (Normalangriff und offensive Skills)
2. Rüstung: +0,02 % zusätzliche relative Schadensminderung je Rang
3. HP: +0,02 % maximale HP je Rang (bei nächster Team-HP-Initialisierung)
4. Kritischer Schaden: +0,02 Prozentpunkte kritischer Treffer-Multiplikator je Rang

Jeder Bereich wird bei +20 % gedeckelt. Die vier Felder sind in dieser **ersten Version fest vorbelegt**, nicht frei auswählbar. Weitere Härtungsattribute (Ausweichen, Aufspießen), zufällige Attributwahl, Neuwürfeln und gesonderte Härtungsgutscheine sind **noch nicht** implementiert.

## Kosten und Grenzen
Eine Verbesserung von Rang R nach R+1 kostet `1.000 × (R+1)` Gold. Der Rang darf das aktuelle Charakterlevel nicht überschreiten. Kosten je Feld von Rang 0 auf 10: 55.000 Gold; auf 100: 5.050.000 Gold. Beim gleichen Rang über alle vier Felder eines Helden vervierfacht sich der Gesamtbetrag. Die bisherigen Waffen- und Juwelen-Upgrades bleiben getrennte Goldsenken.

## Spielerbedienung und Speicherstand
Im bestehenden Juwelenfenster gibt es zusätzliche Buttons zum Wechseln des Härtungsfeldes und zum Kauf einer Härtungsstufe; dieselbe Held-Auswahl wie für Waffen wird verwendet. Alle 4×4 Härtungsränge werden gespeichert; alte Spielstände ohne den neuen Eintrag beginnen bei Rang 0. Ungültige IDs, Goldmangel und Levelgrenzen führen nicht zur Goldabbuchung.

## Kampfmechanik
- Angriffshärtung wird zu persönlichem Talent- und Waffenbonus addiert.
- Rüstungshärtung reduziert Schaden **multiplikativ nach** Tankschutz und Talentverteidigung.
- HP-Härtung wirkt bei der Initialisierung der Helden-HP. Im laufenden Kampf erfordert sie keine plötzliche HP-Heilung.
- Kritischer Schaden steigert den kritischen Multiplikator ausgehend von 1,6.
- Das 60-Sekunden-Limit für Bosse bleibt unverändert.

## Verifikation und Folgeschritte
Quellcodeänderungen in `game_manager.gd`, `save_manager.gd`, `battle_manager.gd`, `ui_manager.gd`, neuer statischer Test in `tests/test_core_import.py`. **Kein Godot-4.7-Laufzeittest, APK-Build oder vollständiger 12-Gebiete-Balancing-Test durchgeführt.** Das zusätzliche Layout im hochkantigen Android-Fenster muss noch visuell geprüft werden. Weiterer Ausbau: auswählbare sechs Attribute, Gold-Neuwürfeln, Härtungsgutscheine, UI mit vier klar unterscheidbaren Feldern.
