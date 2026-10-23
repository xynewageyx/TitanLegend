# Update 192 – Endgame mit erreichbarem Talent- und Juwelenfortschritt

## Anlass
Update 191 verglich Fusionsbosse der Gebiete 10–12 mit festen 50 Talenträngen und Juwelenlevel 300. Das ist kein belastbarer Endgame-Standardwert: Im aktuellen Code gibt jeder besiegte Stage-Boss **ein Charakterlevel**, jedes Level gibt **drei Talentpunkte pro Held**, und jeder Talentbaum ist bis Rang 500 ausbaubar.

## Quellcodegrundlagen
- `battle_manager.gd/finish_wave()`: neun normale Wellen pro Stage plus Boss; Gold pro gewöhnlicher Welle = `50 × stage`, pro Standardboss = `250 × stage`, pro Fusionsboss (jede 10. Stage) = `500 × stage`. Der +5%-Formationsbonus wurde aus Vorsicht nicht mitgerechnet.
- `GameManager.current_gold` beginnt bei 10.000; `upgrade_jewel()` verlangt für den Schritt von Level L auf L+1 `250 × L` Gold.
- `TitanTalentSystem.points_available(level)` = `3 × (level - 1)`; bis Rang 500 pro Baum.
- `titan_combat_balance.gd/hero_progression()`: individuelle Talent- und Juwelenboni, keine vierfach aufaddierten Talenteffekte.
- Für die Modellfälle wurde die Talentverteilung über alle drei Bäume pro Held ausgeglichen (`rank = min(500, stage-1)`); das sind bei Stage 501 alle drei Talentbäume auf Rang 500, weil jeder Held 3 Punkte je Level erhält.

## Fortschrittsbudget ohne andere Ausgaben
Die Summe vor dem Start einer Stage berücksichtigt **nur** die Goldbelohnungen erfolgreich abgeschlossener Vorgängerstages einschließlich neun Wellen und Boss. Alternativ wurden 0% oder 25% dieses verfügbaren Goldes hypothetisch für Juwelen verwendet; das heißt nicht, dass Spieler zwangsläufig dieses Budget erreichen oder vollständig auf Juwelen konzentrieren.

| Vor Stage | Verdientes Gold inkl. Anfangsgold | Talentrang je Baum im Modell | Juwelenlevel bei 25%-Budget |
|---|---:|---:|---:|
| 101 | 3.682.500 | 100 | 86 |
| 401 | 58.200.000 | 400 | 341 |
| 801 | 232.390.000 | 500 | 682 |
| 1001 | 362.985.000 | 500 | 852 |
| 1200 | 521.440.000 | 500 | 1021 |

Wichtig: Zusätzlich mögliche Ausgaben für Ausrüstung, andere Upgrades, Spielmechaniken und Rücksetzungen sind **nicht** eingerechnet. Auch die manuelle Verteilung aller Punkte wurde angenommen, nicht beobachtet.

## Simulationslauf
**12.288 Kämpfe**, unabhängiges Python-Kampfmodell aus Update 190 mit dem neuen 15%-CC-Bonus, vier Bossvarianten, Standard- und Fusionsbossen, vier Heilern, Elementaffinität ja/nein, 60%- bzw. 100%-Team-Schadensleistung, mit/ohne CC, 0% bzw. 25% Gold-Juwelenbudget und zwei reproduzierbaren Seeds.

### Resultat
Für Fusionsbosse in Gebieten **9–12** beträgt die Siegquote bei ausgeglichener, verfügbarer Talentinvestition bereits **100%**, sowohl mit als auch ohne CC, einschließlich des Szenarios *ohne Goldinvestition in Juwelen*. Auch die normalen Bosse zeigen im vereinfachten Modell keine Endgame-Blockade.

Dieses **Deckenergebnis** erlaubt keinen Schluss, dass CC überflüssig ist. Wenn beide Strategien alle Kämpfe gewinnen, muss man stattdessen Kampfzeit und Rest-HP bei realistischen Zwischenständen untersuchen. Das ältere Szenario mit starr auf 50 fixierten Talenträngen darf nicht als regulärer Endgame-Fortschritt interpretiert werden.

## Grenzen und Entscheidung
- Python-Modell, **kein Godot-4.7-Laufzeittest** oder Android-Test.
- Für bereits erfolgreich abgeschlossene Vorgängerstages wird voller Belohnungsertrag angenommen; Kosten für anderes Equipment fehlen.
- Die angenommene Team-Schadensleistung von 60% bzw. 100% ist ein Sensitivitätsparameter, kein aus Godot ausgelesener Ausrüstungswert.
- Die Simulation bildet nicht sämtliche Talentzweige, Fertigkeiten, UI- und Zeitabläufe der Engine exakt ab.

**Keine Boss-HP- oder Schadensänderungen in Update 192.** Vor Änderungen ist ein Abgleich der Gold-Senken, der Ausrüstung und der tatsächlich erreichbaren Heldenwerte erforderlich. Für präzisere Balance-Simulation sollten mittlere Investmentprofile (z. B. 15–50 Ränge je Baum, niedrige Juwelenwerte und reduzierte Schadensleistung) ergänzend geprüft werden.
