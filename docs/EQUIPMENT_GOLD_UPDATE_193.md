# Titan Legends – Update 193: Goldfinanzierte Waffenverbesserungen

## Befund bei der Progressionsprüfung
Im bisherigen GitHub-Kampfcode wirkte ausschließlich Talent- und Juwelenfortschritt auf die Angriffswerte; ein echtes Waffenlevel für die vier Teamhelden existierte noch nicht. Der Shop enthält derzeit hauptsächlich Skins. Deshalb waren die bisherigen „Ausrüstungskosten“ **nicht als reale Goldsenke** in den Simulationsmodellen belegbar.

## Neu implementierter erster Ausrüstungsschritt
- Jeder Held besitzt ein separat gespeichertes **Waffenlevel 0–300** (`GameManager.weapon_levels`).
- Eine Aufwertung von Level `L` auf `L+1` kostet `500 × (L + 1)` Gold.
- Pro Waffenstufe erhält nur dieser Held **+0,05 % Angriffsschaden**; bei Stufe 300 maximal **+15 %**.
- Bonus greift bei regulären Attacken **und** bei aktiven offensiven Skills, nicht bei Heilungen oder passiven Pets.
- Upgrades schlagen bei ungenügend Gold oder Level 300 fehl, ohne Gold abzuziehen.
- Die vier Levels werden im normalen Spielstand gespeichert und mit sicheren Default-Werten alter Spielstände geladen.
- Im bestehenden Juwelenfenster gibt es jetzt „Waffe Held X / 4 wechseln“ und einen eigenen Upgrade-Button. Das 4×2-Menüraster auf Android bleibt unverändert.

## Ausrüstungs-Goldbedarf
Gesamtkosten bis Waffenstufe `N`: `500 × N × (N+1) / 2`.

| Waffenstufe je Held | Goldkosten pro Held | Goldkosten für alle vier | Zusatzangriff je Held |
|---:|---:|---:|---:|
| 10 | 27.500 | 110.000 | 0,5 % |
| 50 | 637.500 | 2.550.000 | 2,5 % |
| 100 | 2.525.000 | 10.100.000 | 5,0 % |
| 200 | 10.050.000 | 40.200.000 | 10,0 % |
| 300 | 22.575.000 | 90.300.000 | 15,0 % |

Der verfügbare Goldvorrat muss auch Juwelen und mögliche Talent-Resets finanzieren. Diese Goldsenke sollte im nächsten realistischeren Balancing-Test berücksichtigt werden; sie **war in Update 192 noch nicht enthalten**.

## Abgrenzung
Dies ist eine **erste spielbare Waffenverbesserung**, kein vollständiges Ausrüstungsinventar. Es sind noch keine Gegenstandsdrops, Seltenheiten, vier Härtungsfelder oder mehrteiligen Rüstungssysteme umgesetzt.

## Verifikation
- Codeänderungen: `scripts/game_manager.gd`, `scripts/save_manager.gd`, `scripts/battle_manager.gd`, `scripts/ui_manager.gd`.
- Statischer Regressionstest in `tests/test_core_import.py`.
- **Kein echter Godot-4.7-Laufzeittest, kein Android-APK-Build.** UI und Speichern auf dem Smartphone müssen noch real geprüft werden.
- Das Bosszeitlimit bleibt bei **60 Sekunden**; bestehende Bosswerte wurden nicht verändert.
