# Titan Legends – Update 178: AoE-Korrektur und Balancing erneut getestet

Datum: 22.10.2026.

## Änderungen im Kampfcode

- `TitanSkillSystem.damage_for_skill` liefert nun **Schaden pro Ziel**, unabhängig von der Zielzahl. Der `battle_manager.gd` verteilt AoE auf Ziele.
- Normale Gegnerwellen besitzen derzeit einen gemeinsamen HP-Pool; dort wird AoE genau einmal mit der begrenzten Zahl verbleibender Ziele multipliziert.
- Bei Bosskämpfen wird AoE jeweils auf die lebenden Bossbegleiter und einmal auf den Boss angewendet. Die frühere doppelte AoE-Skalierung wurde beseitigt.
- Kampfende/Niederlage wird in der Hauptschleife und nach Bossfähigkeiten abgefangen, um Folgeaktionen im selben Frame zu verhindern.
- Das Bosslimit bleibt **60 Sekunden**. Die Schwierigkeit steigt ab Gebiet 2; kein pauschaler HP-Rabatt.

## Simulation

Externe Python-Näherung der Kampfformeln von Update 177 mit korrigierter AoE-Verteilung, **kein** ausgeführter Godot-4.7-Lauf. 11.520 Kämpfe: 12 Gebiete × 4 Bossvarianten × 4 Heiler × 2 Pet-Elementaffinitäten × 3 Teamstärken × 10 Seeds.

Achtung: Die Simulation ist weiterhin ein Näherungsmodell. Sie simuliert Teamstärke als Faktor der Schadensleistung, keine vollständigen Ausrüstungs-/Talentbäume. Besonders das Zusammenspiel unterschiedlicher CC-Skills mit Boss-Casts sowie die Einschränkungen durch feste Skillfolge sind nicht hinreichend geprüft. Es handelt sich weder um echte Nutzertelemetrie noch um eine Bestätigung der Spielbarkeit aller Stages.

| Gebiet | Siegquote Standardteam | Siegquote 60 %-Team | Siegquote 40 %-Team | Median Standard-Kampfzeit |
|---:|---:|---:|---:|---:|
| 1 | 100 % | 100 % | 100 % | 16,9 s |
| 2 | 100 % | 100 % | 100 % | 19,9 s |
| 3 | 100 % | 100 % | 100 % | 21,0 s |
| 4 | 100 % | 100 % | 88,8 % | 21,6 s |
| 5 | 100 % | 100 % | 0 % | 29,6 s |
| 6 | 100 % | 100 % | 0 % | 31,1 s |
| 7 | 100 % | 98,8 % | 0 % | 33,1 s |
| 8 | 100 % | 55,0 % | 0 % | 35,5 s |
| 9 | 100 % | 11,2 % | 0 % | 37,3 s |
| 10 | 100 % | 0 % | 0 % | 39,8 s |
| 11 | 100 % | 0 % | 0 % | 41,5 s |
| 12 | 100 % | 0 % | 0 % | 44,7 s |

## Bewertung

Standardteams besiegen Bossgegner weiterhin innerhalb des 60-Sekunden-Limits, während schwächere Teams besonders ab Gebiet 8 an der Schadensschwelle scheitern. Hieraus folgt noch **keine** belastbare Aussage über reales Balancing: Vor weiteren Anpassungen an Boss-HP benötigen wir Laufzeittests, korrekte Level-/Equipmentfortschritte und glaubwürdige CC-Koordination.

## Testartefakte

Lokales Skript: `sim_update178.py` (aus dem vorherigen Python-Näherungsmodell nach Anpassung der AoE-Schadensformel).
CSV: `balance_update178.csv` (11.520 simulierte Kämpfe, aggregiert nach Gruppen). Diese Dateien sind im Chat als Download vorhanden und nicht Teil dieses GitHub-Dokuments.

Quellcode-Regressionstests: `tests/test_core_import.py`; noch nicht in einem vollständigen Godot-4.7-Build validiert.
