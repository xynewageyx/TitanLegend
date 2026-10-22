# Titan Legends – Kampf-Balancing-Test (Update 176)

Datum: 2026-10-22. Grundlage: die aktuellen Formeln in `battle_manager.gd`, `skill_system.gd` und `titan_combat_balance.gd`.

## Methode und Grenzen
- Externe Python-Monte-Carlo-Näherung der vorhandenen Kampfformeln, **kein** ausgeführter Godot-4.7-Spieltest.
- 7.680 simulierte Kämpfe: 8 Stages × 4 Heilerklassen × 2 Element-Affinitäten × 120 Seeds.
- Zusätzliche Belastungsproben mit 40 % des simulierten Teamschadens an den vier Bossvarianten.
- Team: 1 Tank, 2 DD, 1 Heiler; automatische normale Treffer und aufladbare Skills; 60-Sekunden-Bosslimit, Bossbegleiter, Angriffsmuster, Heiler-Heilung und HoT.
- CC-Interaktion ist nicht vollständig modelliert, daher ersetzen die Ergebnisse keinen späteren spielbaren Vier-Spieler-Test. Gegnerzielwahl und Rundung sind Näherungen.

## Ergebnisse
Das angenommene Standardteam gewann **100 %** der 7.680 simulierten Kämpfe. Die Überlebenswerte blieben oft hoch, während schwächere Teams überwiegend am Boss-Zeitlimit scheiterten.

| Stage | Bossvariante | Standardteam: mediane Kampfzeit | Team mit 40 % Schaden: Siege/120 | Begleiter |
|---|---|---:|---:|---|
| 10 | Wächter | 15,4 s | 120 | Nein |
| 20 | Sturmrufer | 14,0 s | 120 | Nein |
| 30 | Runenhüter | 15,2 s | 120 | Nein |
| 40 | Urtitan | 16,9 s | 120 | Nein |
| 410 | Wächter | 21,4 s | 120 | Ja |
| 420 | Sturmrufer | 21,4 s | 120 | Ja |
| 430 | Runenhüter | 20,6 s | 120 | Ja |
| 440 | Urtitan | 22,1 s | 119 | Ja |
| 1200 | Sturmrufer | 21,4 s | 120 | Ja |

Anmerkung: Das 40-%-Team hatte ein nicht passendes Begleiter-Element, die Standardzeiten gelten für einen passenden Begleiter und die Heilerrolle Priester. Es handelt sich um simulierte Stichproben, nicht um gemessene Android-Spielzeiten.

## Änderung
Boss-HP-Multiplikatoren von `[1.08, 0.96, 1.0, 1.12]` auf `[1.08, 0.96, 0.94, 1.05]` angepasst. Damit sind Runenhüter (mit Selbstheilung) und Urtitan (mit breitem Angriffsmuster) weniger übergewichtet. Die anderen zwei Varianten sind unverändert. Ein statischer Regressionstest schützt die Werte.

## Offene Balancing-Aufgaben
1. Tatsächliche Godot-Kämpfe mit allen vier Heilerklassen und mehrfachen CC-Auslösungen testen.
2. Schwächere / unvollständige Teams und Ausrüstungsstufen separat simulieren.
3. Boss-Zeitlimit gegen Heiler-DPS und Minion-HP anhand von realen Telemetriedaten prüfen.
4. Variation der späteren Gebiete bewerten; lineare Skalierung sorgt derzeit für ähnliche Kampfzeiten über viele Stages.
5. Nach Umsetzung von echten PvP- und Gilden-Boss-Mechaniken diese getrennt balancieren.

Die Testergebnisse sind keine Aussage darüber, dass Titan Legends bereits voll ausbalanciert oder fehlerfrei ist.
