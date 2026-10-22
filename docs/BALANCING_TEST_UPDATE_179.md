# Titan Legends – Update 179: Talent- und Juwelen-Balancing-Test

Datum: 22.10.2026.

## Testumfang
**18.432 simulierte Bosskämpfe** in einer externen, vereinfachten Python-Simulation, kein Godot-4.7-Laufzeittest:
12 Gebiete × 4 Bossvarianten × 4 Heilklassen × 2 Begleiter-Affinitäten × 4 Fortschrittsprofile × 12 reproduzierbare Zufallsseeds.

Es gelten 60 Sekunden Bosslimit, 100 Stages pro Gebiet, wiederkehrende Elemente und Bosse sowie Midgame-Bossbegleiter ab Stage 401.

## Neu simuliert: Upgrade 179
Die individuellen Talentboni für Angriff, Verteidigung und Heilung und der Juwelen-Angriffsbonus sind im Modell berücksichtigt. Profile: kein Upgrade (Rang 0/Juwel 1); leicht (Rang 10/Juwel 10); mittel (Rang 25/Juwel 30); hoch (Rang 50/Juwel 70). In diesem *isolierten Vergleich* besitzt jeder der drei Talentbäume eines Helden den angegebenen Rang. Das ist **kein Nachweis**, dass diese Verteilung auf der jeweiligen Stage tatsächlich freigeschaltet oder finanzierbar wäre.

## Ergebnisse

| Gebiet | Median ohne Upgrade | Median leicht | Median mittel | Median hoch |
|---:|---:|---:|---:|---:|
| 1 | 16,9 s | 15,4 s | 13,2 s | 11,7 s |
| 2 | 19,9 s | 17,6 s | 16,1 s | 12,8 s |
| 3 | 20,6 s | 19,1 s | 16,9 s | 13,7 s |
| 4 | 21,4 s | 19,9 s | 17,3 s | 14,7 s |
| 5 | 29,6 s | 26,6 s | 23,6 s | 19,9 s |
| 6 | 31,1 s | 28,1 s | 25,1 s | 21,2 s |
| 7 | 33,0 s | 30,2 s | 26,6 s | 21,5 s |
| 8 | 35,9 s | 31,9 s | 27,8 s | 22,9 s |
| 9 | 36,7 s | 34,3 s | 29,6 s | 24,8 s |
| 10 | 39,9 s | 36,7 s | 31,5 s | 26,6 s |
| 11 | 42,3 s | 38,3 s | 33,5 s | 27,4 s |
| 12 | 44,7 s | 41,0 s | 36,4 s | 29,6 s |

Alle Profile hatten 100 % Siegquote bei angenommener Standard-Ausrüstung und Schadensleistung. Das legt nahe, dass die **unmodifizierte Standardgruppe im Näherungsmodell zu stark** ist; es zeigt nicht, dass alle echten Spieler das Endgame meistern.

## Grenzen und Bewertung
- Die Simulation basiert auf `sim_update178.py`, erweitert um Angriffs-, Verteidigungs-, Heiler- und Juwelenfortschritt nach `TitanCombatBalance.hero_progression`. Sie ist kein Abbild des kompletten Godot-Combat-Loops.
- Reale Ausrüstungswerte, Kosten, freigeschaltete Talentpunkte und Charakter-Level je Gebiet wurden nicht hergeleitet; alle Profile nutzen ansonsten die gleiche angenommene Standardausrüstung.
- CC-Timing und Bossinterrupts sind nicht vollständig abgebildet.
- Keine neuen Boss-HP- oder Schadensmultiplikatoren aufgrund dieses Tests geändert. Erst nach Laufzeittest und einer realistischen Progressionsprüfung nachjustieren.
- Bosszeitlimit bleibt genau 60 Sekunden.

Rohdaten und Simulationsskript stehen im zugehörigen Chat als CSV/Python-Datei.
