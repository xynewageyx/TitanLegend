# Titan Legends – Update 188: Boss-Flächenschaden pro Held

## Befund
In `_resolve_boss_cast()` bezog sich der gesamte Zauber-Flächenschaden auf `hero_max_hp[0]`. Dies war auch dann der Fall, wenn Held 1 bereits gestorben war oder andere Helden durch Begleiterboni abweichende maximale HP hatten. Der Boss traf alle Ziele mit demselben Rohwert, obwohl die restliche Schadensberechnung bei anderen Fähigkeiten auf den aktuellen Ziel-HP-Wert skaliert.

## Änderung
- `_damage_heroes()` akzeptiert optional einen HP-Anteil für jeden betroffenen Helden. Der Rohschaden verwendet in diesem Fall `hero_max_hp[index]` für **jedes** Ziel, zusammen mit der bestehenden Gebietsschadensskala.
- Boss-Spezialzauber mit Flächenschaden verwenden 10 % der jeweiligen maximalen HP, bei Fusionsbossen 13 %.
- Für andere Schadensereignisse wird weiterhin der bisherige absolute Rohwert übergeben; dies ändert normale Gegnerangriffe und Boss-Minion-Schäden nicht.
- Tank-Snapshot und aktives Gruppenabfangen werden weiterhin **vor** der Zielschleife ausgewertet. Talentschutz bleibt multiplikativ.
- Vorbereitete Heilungen werden erst nach Abschluss des Schadensereignisses ausgelöst. Kein Wiederbeleben gefallener Helden.
- Boss-Zeitlimit weiterhin **60 Sekunden**.

## Ausgeführter isolierter Formeltest
Vier deterministische Fälle mit einem unabhängigen Python-Prüfskript getestet (**kein Godot-Laufzeittest**):
1. Lebende Helden mit [300,330,420,260] Max-HP, 10 % Boss-AoE, Gebietsskala 1.0 → effektiver Schaden [21,31,40,25] bei Tankschutz 30 % und 5 % Basisabwehr der übrigen Helden.
2. Erstes Teammitglied tot, restliche Helden wie oben → [0,31,40,25]; kein Bezug auf dessen Max-HP für die anderen Schadenswerte.
3. Tank lebt zu Angriffsbeginn nur mit 10 HP und hat Gruppenschutz aktiv → [21,20,20,20]; alle Verbündeten erhalten den aktiven 35-%-Schutz für dieses Ereignis.
4. Fusions-AoE mit 13 % und Beispiel-Gebietsfaktor 1.86 auf verschiedene HP-Größen → [51,76,97,60] nach Schutzwerten.

**Alle vier unabhängigen Formel-Fälle bestanden.** Die Tests sind einfache Rechen-Nachbildungen der angepassten Schadensgleichungen, keine Engine-Ausführung.

## GitHub-Abdeckung
Zusätzlich wurde `tests/test_core_import.py` um einen statischen Regressionstest erweitert. Dieser prüft, dass der Boss-AoE-Zweig nicht auf `hero_max_hp[0]` zugreift, sondern den individuellen Zielwert nutzt.

## Grenzen
Kein Godot-4.7- oder Android-Runtime-Test ausgeführt. Keine neue 12-Gebiete-Siegquote, weil die vollständigen Kampf-, XP-, Ausrüstungs- und CC-Abläufe hier nicht live reproduziert wurden.
