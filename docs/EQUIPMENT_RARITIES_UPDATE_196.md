# Titan Legends – Update 196: Sechs Waffen-Seltenheitsstufen

## Implementierte Waffenqualitäten
Die bereits gespeicherten Waffenlevel 0–300 bleiben erhalten. Neu hinzugekommen ist eine separat gespeicherte Qualitätsstufe je Held. Qualität wird **nicht** automatisch beim Levelaufstieg verteilt; der Spieler kauft eine Qualitätsverbesserung mit Gold, sobald die Waffenlevel-Voraussetzung erfüllt ist.

| Qualität | Erforderliches Waffenlevel | Einmalige Kosten zum Erreichen | Zusätzlicher Angriff durch Qualität |
|---|---:|---:|---:|
| Weiß | 0 | Standard | 0 % |
| Grün | 20 | 10.000 Gold | +1 % |
| Blau | 50 | 50.000 Gold | +2,5 % |
| Gelb | 100 | 200.000 Gold | +4,5 % |
| Gold | 180 | 800.000 Gold | +7 % |
| Lila | 260 | 2.000.000 Gold | +10 % |

Gesamte Qualitätskosten von Weiß bis Lila: **3.060.000 Gold je Held** (zusätzlich zu den bereits vorhandenen Waffenlevel-Kosten). Der Qualitätsbonus addiert sich zum bis zu +15 % hohen Levelbonus: maximal **+25 % Waffen-Angriff** bei Level 300, Lila. Die übrigen Talente und Härtungswerte wirken wie zuvor.

## Umsetzung
- `scripts/game_manager.gd`: sechs Qualitätsstufen, Voraussetzungen, Goldkosten und Kaufabwicklung.
- `scripts/save_manager.gd`: getrennte Qualität für alle vier Helden, Altspielstände beginnen mit Weiß. Daten werden validiert und auf eine zum gespeicherten Waffenlevel passende Qualität begrenzt.
- `scripts/ui_manager.gd`: Kaufbutton im vorhandenen scrollbaren Ausrüstungs-/Juwelenmenü.
- `tests/test_core_import.py`: zusätzlicher statischer Regressionstest.

## Abgrenzung
Dieses Update fügt die sechs Qualitäten für die **bestehenden Waffen** hinzu, nicht für zufällige Lootgegenstände. Ausrüstungsdrops, Inventar, individuell ausrüstbare Helme/Rüstung, Setboni und zufällige Seltenheits-Drops sind noch nicht umgesetzt. Das Bosszeitlimit bleibt **60 Sekunden**.

## Teststatus
Quellcode- und Commitprüfung: durchgeführt. **Kein Godot-4.7-Laufzeittest und kein Android-APK-Build ausgeführt.** Der erste Kauf von Grün und das Wiederherstellen der Qualitätswerte sollten auf Android getestet werden, bevor zufälliger Ausrüstungsloot hinzukommt.
