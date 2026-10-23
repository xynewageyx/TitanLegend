# Titan Legends – Update 180: Realistische Fortschrittsprüfung

Datum: 23.10.2026. GitHub-Quellen: `battle_manager.gd`, `talent_system.gd`, `titan_combat_balance.gd`, `game_manager.gd`.

## Gefundene Probleme
- Pro Bossfortschritt steigt `GameManager.character_level` um eins; jeder Held erhält gemäß `points_available` drei Talentpunkte je Levelaufstieg. Konzentriert auf einen einzigen Baum konnte ein Krieger zuvor bereits um Stage 50 den Angriffsbonus von 75 % erreichen.
- Der alte Juwelenbonus `0.002 * (jewel_level-1)`, gedeckelt bei 20 %, war ab Juwelenlevel 101 vollständig ausgeschöpft, während die Goldkosten weiterstiegen.
- Talent-Anzeigewerte und verwendete individuelle Kampfformeln waren nicht identisch.

## Anpassungen
- Offensive Talentskalierung auf 25 % der klassenabhängigen bisherigen Rangsteigerung, defensive auf 10 %, Heilung auf 20 % gesetzt. Die bekannten Bonusobergrenzen und Talent-Meilensteine bleiben erhalten.
- Juwelen-Angriffsbonus nun `min(0.20, (jewel_level-1)*0.0001)`, also erst bei Level 2001 gedeckelt; Goldkosten `250*jewel_level` bleiben unverändert.
- Talent-Textanzeige zeigt die tatsächlich verwendeten Angriffs-, Schutz- und Heilstufen an.
- Die individuellen Boni gelten weiter pro Held, die passive Haustier-Elementdurchdringung bleibt unverändert.

## Deterministische Rechenprüfung
Die Zahlen sind analytische **Obergrenzen**, keine echten Playthrough- oder Godot-Tests.
Annahme: Level 1 zu Beginn, ein Charakterlevel nach jeder besiegten Stage; Talentpunkte vollständig in **einen** Baum investiert; Krieger-Offensivwert 0.006 je Rang vor Multiplikator, Krieger-Schutzwert 0.006; sämtliche erhaltenen Goldbelohnungen ohne sonstige Käufe in Juwelen investiert. Gesonderte Goldquellen und Ausgaben sind nicht berücksichtigt. Bei Stage 1 kann Startgold bereits für Juwelen ausgegeben werden.

| Stage | Talentpunkte pro Held | Max. Angriffsrang | Krieger Angriff+ | Krieger Schutz+ | Theoret. maximales Juwelenlevel (Gold nur Juwelen) | Juwelen Angriff+ |
|---:|---:|---:|---:|---:|---:|---:|
| 1 | 0 | 0 | 0.0 % | 0.0 % | 9 | 0.1 % |
| 50 | 147 | 147 | 28.1 % | 12.8 % | 87 | 0.9 % |
| 100 | 297 | 297 | 50.6 % | 21.8 % | 172 | 1.7 % |
| 200 | 597 | 500 | 75.0 % | 34.0 % | 342 | 3.4 % |
| 400 | 1197 | 500 | 75.0 % | 34.0 % | 682 | 6.8 % |
| 600 | 1797 | 500 | 75.0 % | 34.0 % | 1023 | 10.2 % |
| 800 | 2397 | 500 | 75.0 % | 34.0 % | 1363 | 13.6 % |
| 1000 | 2997 | 500 | 75.0 % | 34.0 % | 1704 | 17.0 % |
| 1200 | 3597 | 500 | 75.0 % | 34.0 % | 2045 | 20.0 % |

Zahlen sind gerundet; Talent-Meilensteine bei 10, 25, 50 und 100 eingerechnet. Der Talentbaum-Rang ist bei 500 gedeckelt, daher zeigt die Tabelle die maximal investierbaren Punkte in nur einem Baum. Der Juwelen-Stand ist ein unrealistisches Gold-Maximum, **keine** Spielerprognose.

## Bekannte Grenzen
1. Keine Godot-4.7-Laufzeitprüfung. Nur Quelltext-/Formelabgleich und Regressionstest-Ergänzung.
2. Noch kein valider 60-Sekunden-Kampftest nach der Talentkorrektur; die früheren 100-%-Siegquoten gelten hierfür nicht mehr.
3. Ausrüstung, Goldausgaben für andere Systeme, XP und Skill-Level sowie PvP müssen separat integriert bzw. geprüft werden.
4. Bonus von Juwelenleveln über 2001 wirkt noch nicht auf andere Stats; später ist eine maximale Juwelenstufe oder ein zusätzliches Statsystem vorzusehen.

Bosslimit bleibt fest 60 Sekunden, 12 Gebiete mit je 100 Stages, vier Bosse je Gebiet mit identischem Gebietselement und Bossbegleiter ab Stage 401.
