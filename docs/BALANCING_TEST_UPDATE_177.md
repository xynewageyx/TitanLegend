# Titan Legends – Balancing-Test nach Gebietsskalierung (Update 177)

Datum: 2026-10-22

## Vorgaben
- 1.200 Stages, 12 Gebiete mit je 100 Stages, Elemente dürfen sich wiederholen.
- Vier wiederkehrende Bossvarianten pro Gebiet; alle Bosse des Gebiets haben dasselbe Element.
- Bosszeitlimit **unverändert 60 Sekunden**.
- Schwierigkeit steigt ab Gebiet 2 (Stage 101); ausgewählte Bosskämpfe ab Stage 401 haben zwei angreifbare Bossbegleiter.

## Methode
Externe, vereinfachte Python-Monte-Carlo-Simulation der aktuellen Godot-Kampfformeln; kein Godot-4.7-Laufzeittest. 13.824 Kämpfe: 12 Gebiete x 4 Bossvarianten x 4 Heilerklassen x 2 Element-Affinitäten x 3 Teamstärken (100/60/40 %) x 12 Seeds. Simuliert wurden Skill-Trefferaufladung, Schadensrollen, Passivelement-Durchbruch, Bosswiderstand, Minions, HoT, Routineticks und grobe Castmechanik. **Die Simulation bildet CC-Auslösungen nicht vollständig ab** und ist deshalb keine exakte Spieltelemetrie. Prozentangaben sind gerundete Stichprobenwerte.

## Ergebnisse nach Gebiet

| Gebiet | Standardteam: Siege | Median Kampfzeit (s) | 60-%-Team: Siege | 40-%-Team: Siege |
|---:|---:|---:|---:|---:|
| 1 | 100 % | 16,4 | 100 % | 100 % |
| 2 | 100 % | 19,1 | 100 % | 100 % |
| 3 | 100 % | 19,9 | 100 % | 100 % |
| 4 | 100 % | 20,6 | 100 % | 100 % |
| 5 | 100 % | 27,0 | 100 % | 0 % |
| 6 | 100 % | 29,2 | 100 % | 0 % |
| 7 | 100 % | 30,4 | 100 % | 0 % |
| 8 | 100 % | 32,3 | 100 % | 0 % |
| 9 | 100 % | 34,8 | 75 % | 0 % |
| 10 | 100 % | 36,7 | 43,8 % | 0 % |
| 11 | 100 % | 39,5 | 0 % | 0 % |
| 12 | 100 % | 41,4 | 0 % | 0 % |

Anmerkung: Die Kampfzeit ist die mediane verstrichene Zeit aller simulierten Kämpfe, bei Zeitüberschreitungen auf 60 Sekunden begrenzt. Prozentwerte je Gebiet sind über Bossvarianten, Heiler und Element-Affinitäten gemittelt.

## Bewertung
- Die neue Gebietskurve sorgt bei identischer angenommener Teamstärke für längere Kämpfe bis Gebiet 12.
- Ab Gebiet 5 machen Bossbegleiter und zusätzliche HP vor allem schwachen Teams zu schaffen.
- Die Endgame-Schwelle setzt stärkere Ausrüstung/Skills voraus; für das 60-%-Team ist Gebiet 11–12 mit der derzeitigen Modellannahme nicht gewinnbar.
- Das Standardteam gewann alle simulierten Kämpfe: Der Test belegt **nicht**, dass Kämpfe herausfordernd genug sind.
- Um das 60-Sekunden-Limit nicht zu umgehen, wurde **keine automatische Zeitverlängerung** implementiert.
- Für diesen Test wurden **keine weiteren Schadens- oder HP-Änderungen vorgenommen**. Erst nach Godot-Laufzeittests und Prüfungen der tatsächlichen Charakterprogression sollten Werte neu festgesetzt werden.

## Bekannte Modellgrenzen / nächste Prüfungen
1. Godot-4.7-Headless-Lauf oder Android-Gameplay-Test inklusive Parsing aller GDScript-Dateien.
2. Tatsächliche CC-Interaktion mehrerer Spieler, Boss-Casts und feste Skillfolge 1→2→3→4.
3. Realistische Ausrüstungs-, Talent- und Levelwerte pro Gebiet statt konstanter relativer Teamstärken.
4. Siegquoten pro Bossvariante/Heiler/Pet-Affinität separat auswerten.
5. Eventuelle Rundungs- und Targetingabweichungen zwischen Python-Näherung und Godot verifizieren.

Quelle der Difficulty-Kurve: `scripts/titan_combat_balance.gd` mit area_number, enemy_hp_scale und enemy_damage_scale.
