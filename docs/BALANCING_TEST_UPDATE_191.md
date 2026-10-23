# Titan Legends – Update 191: Vergleich CC gegen reine Schadensskills nach Update 190

Datum: 23.10.2026.

## Tatsächlich durchgeführter Test
9.216 Bosskämpfe mit dem lokalen Python-Näherungsmodell `sim_update190.py`, basierend auf dem älteren Update-189-Modell, erweitert um den Boss-Verwundbarkeitsbonus nach erfolgreich abgeschlossenem CC. Getestet:
12 Gebiete × 4 Bossvarianten × 2 Bossstufen (normal/fusion) × 4 Heilklassen × 2 Begleiter-Affinitäten × 3 Leistungsprofile × 2 Skillbelegungen × 2 feste Zufallsseeds.

Profile:
- Schwach: 60 % angenommener Standardschaden, Talentrang 0, Juwelenlevel 1.
- Mittel: 60 % Standardschaden, Talentrang 50 je Baum, Juwelenlevel 300.
- Hoch: 100 % Standardschaden, Talentrang 50 je Baum, Juwelenlevel 300.

Vergleichsbelegungen:
- **Mit CC**: Die zwei DDs und der Heiler besitzen Skill 7 als vierten Skill. Für erfolgreich vollendete Unterbrechungen erhält der Boss vier gegnerische Ticks +15 % Schaden.
- **Ohne CC**: Die DDs verwenden stattdessen Bossbrecher (Skill 5), der Heiler den Angriff Elementarwelle (Skill 6). Diese Skillbelegung verursacht mehr Direktschaden und besitzt keine Unterbrechungen. **Diese Belegungsdifferenz ist Absicht, es ist kein isolierter Test eines einzigen Schadensmultiplikators.**

Das Modell berücksichtigt vorbereitete CC-Treffer, vorbereitete Heilungen, HoT, Tank-/Gruppenabfangen, vier Bossarchetypen, Elementwiderstand, einzelne HP-bezogene Boss-Flächenzauber sowie die 60-Sekunden-Grenze. Es bleibt ein **vereinfachtes Python-Modell, kein Godot-Laufzeittest**. Die Wiederholungszahl pro exakter Kombination beträgt nur 2 Seeds, also besteht beträchtliche statistische Unsicherheit.

## Siegquoten – mittlerer Fortschritt, 60 % Standardschaden

| Gebiet | Normaler Boss ohne CC | Normaler Boss mit CC | Fusionsboss ohne CC | Fusionsboss mit CC |
|---:|---:|---:|---:|---:|
| 1–10 | 100 % | 100 % | 100 % | 100 % |
| 11 | 100 % | 100 % | 87,5 % | 75,0 % |
| 12 | 100 % | 100 % | 43,8 % | 25,0 % |

Ergebnisse zeigen: Direktschadensbelegungen sind bei sehr robusten Endgame-Fusionsbossen weiterhin im Vorteil. Erfolgreiche Unterbrechungen können dennoch Boss-Spezialattacken verhindern und kurzzeitig den erlittenen Schaden erhöhen. Die errechneten Siegquoten dürfen **nicht** als verifizierte Spielbalance interpretiert werden.

## Gefundener und behobener Implementierungsfehler
In Update 190 stand für die Verwundbarkeitszeit `skill_tick <= boss_vulnerable_until_tick` bei `boss_vulnerable_until_tick = skill_tick + 4`. Einschließlich des Endticks konnte der Bonus fünf statt vier Ticks aktiv sein. Das wurde in `scripts/battle_manager.gd` auf `skill_tick < boss_vulnerable_until_tick` korrigiert und ein statischer Regressionstest ergänzt.

Das Python-Testmodell und die CSV wurden mit der korrigierten **exakt viertickigen** Bedingung neu ausgeführt.

## Entscheidung
Keine pauschale Änderung an Boss-HP, 60-Sekunden-Limit oder Damage-Multiplikatoren ohne Laufzeitprüfung. Ein sinnvoller Folgetest muss Fusionsboss-Gegner 10–12 mit realistischer Ausrüstung, Einzelziel-DD-Optimierung und Team-CC gegentesten. Die schwankenden Siegquoten der späten Gebiete allein rechtfertigen noch keine automatische Nerfung.

Lokale Artefakte im Chat: `sim_update190.py`, `balance_update190.csv`.
