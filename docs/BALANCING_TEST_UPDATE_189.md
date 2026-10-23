# Titan Legends – Update 189: Normale Bosse und Fusionsbosse getrennt getestet

Datum: 23.10.2026.

## Testumfang

**6.912 tatsächliche Python-Modellläufe**, keine Godot-4.7-Ausführung. 12 Gebiete × 4 Bossarchetypen × 2 Bossarten (normale Stages 5/15/25/35 und Fusions-Stages 10/20/30/40 pro Gebiet) × 4 Heilerklassen × 2 Elementaffinitäten × 3 Teamprofile × 3 Seeds. Das 60-Sekunden-Zeitlimit wurde stets verwendet.

Vergleichsprofile:
- Schwach, ungelevelt: 60 % Basisschaden, Talent-Rang 0, Juwelenlevel 1.
- Schwach, entwickelt: 60 % Basisschaden, Talent-Rang 50 **in jedem Baum**, Juwelenlevel 300.
- Standard entwickelt: 100 % Basisschaden, Talent-Rang 50 in jedem Baum, Juwelenlevel 300.

Die Profile sind als isolierter Vergleich auf jeder Stage fixiert, nicht als realistische Level-/Goldkostenprognose.

## Siegquoten

Je Gebiet/Bossart/Profil: 96 Kämpfe. **N** = normaler Boss, **F** = Fusionsboss.

| Gebiet | N 60 %, ohne | N 60 %, entwickelt | N 100 %, entwickelt | F 60 %, ohne | F 60 %, entwickelt | F 100 %, entwickelt |
|---:|---:|---:|---:|---:|---:|---:|
| 1 | 100 % | 100 % | 100 % | 100 % | 100 % | 100 % |
| 2 | 100 % | 100 % | 100 % | 100 % | 100 % | 100 % |
| 3 | 100 % | 100 % | 100 % | 100 % | 100 % | 100 % |
| 4 | 100 % | 100 % | 100 % | 100 % | 100 % | 100 % |
| 5 | 100 % | 100 % | 100 % | 100 % | 100 % | 100 % |
| 6 | 100 % | 100 % | 100 % | 100 % | 100 % | 100 % |
| 7 | 100 % | 100 % | 100 % | 100 % | 100 % | 100 % |
| 8 | 100 % | 100 % | 100 % | 66,7 % | 100 % | 100 % |
| 9 | 100 % | 100 % | 100 % | 16,7 % | 100 % | 100 % |
| 10 | 100 % | 100 % | 100 % | 0 % | 83,3 % | 100 % |
| 11 | 100 % | 100 % | 100 % | 0 % | 45,8 % | 100 % |
| 12 | 100 % | 100 % | 100 % | 0 % | 12,5 % | 100 % |

Median Fusions-Bosskampfzeit in Gebiet 12: 60,0 s (60 % ungelevelt), 60,0 s (60 % entwickelt), 39,0 s (100 % entwickelt). Normaler Boss Gebiet 12: 40,9 s, 35,6 s, 21,0 s.

## Berücksichtigte Regeln

- Boss HP, Schaden und Resistenzen samt Gebietsskalierung ab Stage 101.
- Vier Bossarchetypen, zwei angreifbare Adds ab Stage 401 bei entsprechenden Bossen.
- Vier feste Heldenslots und Angriffstakte [1,25; 0,75; 0,75; 1,5] Sekunden.
- Feste Skillfolgen, Angriffschargen, Tank-Spott und aktiver Gruppenschutz.
- Pro-Held-Talentwerte und Juwelenkoeffizienten gemäß Update 180.
- Vorbereitete CC-Treffer, maximal einer je Held, 1–3 verlangte Treffer und erweiterte Zauberfenster.
- Vorbereitete Heilung, direkte Heilung, Heilung über Zeit und Erhalt stärkerer HoTs.
- Zielbezogener AoE-Bossschaden und Tank-Snapshot.
- Vollständiger Team-Wipe ohne Wiederbelebung.

## Modellgrenzen und Auffälligkeit

1. **Alle angefangenen unterbrechbaren Bosszauber konnten in diesem Modell verhindert werden** (7.964 erfolgreiche Unterbrechungen, 0 verfehlte). Das ist eine Auffälligkeit: Die gewählten Loadouts mit zwei DD-CCs plus Heiler-CC sowie die Vorbereitung können Bossfähigkeiten übermäßig zuverlässig neutralisieren. Diese Quote ist **keine verifizierte Godot-Quote**.
2. Vereinfachter Kampfloop (Zeitschritt 0,05 s), keine Animationstaktung, UI, komplette reale Skillwahl, wirtschaftliche Progression, XP oder Equipment.
3. Alle Bossproben simulieren frische Helden-HP bei Kampfbeginn, nicht mehrere zuvor gespielte Wellen ohne Reset.
4. Feste Stärke 60 % ist ein synthetisches Schwächeprofil. Rang 50 in drei Talentbäumen ist je Held frühestens ab Charakterlevel 51 möglich, die Juwelenkosten und das tatsächliche Goldtempo sind nicht integriert.
5. Eine weitere unabhängige Godot-Laufzeitprüfung ist erforderlich, bevor Boss-Schaden oder HP angepasst werden.

## Empfehlung

**Keine pauschale Boss-HP-Erhöhung** auf Grundlage dieser Simulation. Der wichtigste nächste Balancepunkt ist ein Test *mit und ohne Unterbrechungsfertigkeiten* sowie mit realistischer Boss-HP-/Mana-/Ausrüstungsprogression; andernfalls verdeckt nahezu perfekte CC-Abdeckung den realen Druck von Boss-Zaubern.

Die Rohdaten `balance_update189.csv` und das ausführbare Python-Modell `sim_update189.py` wurden im zugehörigen Chat als Dateien bereitgestellt.
