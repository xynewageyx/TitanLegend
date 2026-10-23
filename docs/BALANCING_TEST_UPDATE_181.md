# Titan Legends – Update 181: Kampf-Balancing mit korrigiertem Fortschritt

Datum: 23.10.2026. Basis: Formeln aus Update 180.

## Umfang
9.216 Kämpfe im **externen Python-Näherungsmodell**:
12 Gebiete × 4 wiederkehrende Bossvarianten × 4 Heiler (Paladin, Druide, Schamane, Priester) × 2 Begleiter-Affinitäten × 3 Fortschrittsprofile × 2 Grund-Schadensstärken (60 %, 100 %) × 4 Seeds.

**Kein Godot-4.7-Laufzeittest**: keine echte GDScript-Ausführung; insbesondere CC-Slots, Ausrüstung und vollständige Skill-Rotation müssen separat im laufenden Spiel validiert werden. Die früheren Python-Modelle sind keine identische Godot-Engine.

## Verwendete Fortschrittsprofile
- Ohne Verbesserungen: Talent-Rang 0 je Baum, Juwelenlevel 1.
- Mittlerer Fortschritt: Rang 50 **je Baum**, Juwelenlevel 300.
- Hoher Fortschritt: Rang 150 **je Baum**, Juwelenlevel 1000.

Die Vergleichsprofile werden in **jedem** Gebiet fix eingesetzt; sie sind keine Aussage über Erreichbarkeit oder Goldkosten. Drei Bäume à Rang 150 erfordern 450 Talentpunkte pro Held und damit mindestens Charakterlevel 151 (3 Punkte pro Level ab Level 2). Die vier untersuchten Heilerklassen und Elementaffinitäten wurden gleich gewichtet.

## Siegquoten bei 60 % angenommener Standardschadensleistung

| Gebiet | Keine Upgrades | Mittlerer Fortschritt | Hoher Fortschritt |
|---:|---:|---:|---:|
| 1 | 100,0 % | 100,0 % | 100,0 % |
| 2 | 100,0 % | 100,0 % | 100,0 % |
| 3 | 100,0 % | 100,0 % | 100,0 % |
| 4 | 100,0 % | 100,0 % | 100,0 % |
| 5 | 100,0 % | 100,0 % | 100,0 % |
| 6 | 100,0 % | 100,0 % | 100,0 % |
| 7 | 96,9 % | 100,0 % | 100,0 % |
| 8 | 56,2 % | 100,0 % | 100,0 % |
| 9 | 12,5 % | 100,0 % | 100,0 % |
| 10 | 0,0 % | 68,8 % | 100,0 % |
| 11 | 0,0 % | 37,5 % | 100,0 % |
| 12 | 0,0 % | 0,0 % | 100,0 % |

Das Vergleichsteam mit 100 % angenommener Schadensleistung gewann in allen Profilen 100 % der simulierten Kämpfe. Mediane Kampfzeit in Gebiet 12: 44,7 s (ohne), 38,3 s (mittel) und 31,3 s (hoch).

## Methodik und Grenzen
Die Simulation wurde von `sim_update179.py` abgeleitet und die Talentfaktoren auf Update 180 korrigiert:
- Angriffstalent-Rangskalierung ×0,25
- Verteidigungstalent-Rangskalierung ×0,10
- Heiltalent-Rangskalierung ×0,20
- Juwelen-Angriff: +0,0001 je Juwelenstufe ab Level 1, maximal 20 %
- Boss-Gebietsskalierung unverändert und exakt 60 Sekunden Kampfgrenze

Kampftick, zufällige kritische Treffer, Zielwahl, Bossbegleiter und Heiler sind **vereinfacht** nachgebildet. Skill-CC wird nicht vollständig ausgewertet. Der Test ersetzt weder eine reale Godot-Spielrunde noch eine Wirtschaftssimulation mit Gold, Ausrüstung und tatsächlicher Levelkurve.

## Entscheidung
Keine pauschale Erhöhung der Boss-HP: Die Endgame-Lücke hängt stark von der Ausrüstung und dem tatsächlichen Fortschritt ab. Vor weiteren HP-Änderungen sind die GDScript-Kampfschleife, Stun-Unterbrechungen und die Gold-/XP-Progression in einem echten Godot-Test zu prüfen.

Rohdaten: `balance_update180.csv` im aktuellen Chat; Simulationsstarter: `run_update180.py`.
