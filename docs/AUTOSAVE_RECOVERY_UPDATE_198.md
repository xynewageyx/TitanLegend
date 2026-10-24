# Titan Legends – Automatische Spielstand-Sicherung (Update 198)

## Verhalten für Spieler

**Keine Speichern-Schaltfläche notwendig.** Titan Legends schreibt den Fortschritt selbstständig:

- Alle **30 Sekunden**, solange das Spiel läuft (zuvor 60 Sekunden).
- Unmittelbar nach abgeschlossenen Kampfwellen bzw. neuen Stages, einschließlich Bossfortschritt.
- Nach wichtigen Änderungen an Ausrüstung, Härtung, Skills, Shopwährung und freigeschalteten Gegenständen (bestehende Gameplay-Aufrufe).
- Beim regulären Pausieren oder Schließen der App, soweit Android die Benachrichtigung rechtzeitig ausliefert.

Der Spielstand enthält unter anderem Stage/Welle, Gold, Tickets, Charakter- und Juwelenstufen, Waffenausbauten, Qualitätsstufen, Härtung, Loot-Inventar/-Ausrüstung, Fähigkeiten, Talente und ausgewählte Kosmetikdaten.

## Schutz vor beschädigten Dateien

Der Speicherort bleibt **`user://save_data.json`**. Bestehende v1-Spielstände bleiben damit lesbar.

1. Der neue Spielstand wird vollständig in `user://save_data.json.tmp` geschrieben und vor der Übernahme validiert.
2. Nur wenn die bisherige Hauptdatei gültig ist, wird sie als Sicherung `user://save_data.json.bak` abgelegt.
3. Erst danach ersetzt die fertig geschriebene temporäre Datei den Hauptspielstand per Dateiumbenennung.
4. Ist die Hauptdatei beim Start unlesbar, wird automatisch die letzte gültige Sicherung geladen.
5. Eine beschädigte Hauptdatei darf **niemals** die bereits gültige Sicherung überschreiben.
6. Alle Auslesefunktionen für Stage, Welle, Skills, Talente und Astral-Fortschritt verwenden dieselbe Backup-Wiederherstellung.

**Grenzen:** Ein Abschalten während des Schreibens, voller Speicherplatz oder ein Geräte-/Dateisystemausfall kann weiterhin Daten kosten. Eine Sicherung auf demselben Handy schützt **nicht** vor einer Deinstallation, dem Löschen von App-Daten oder dem Verlust des Geräts. Es gibt noch **keine kontogebundene Cloud-Synchronisierung**.

## Tests

- Godot 4.6: `godot --headless --path . --script res://tests/test_save_integrity.gd`
- GitHub Actions: [Godot project validation](https://github.com/xynewageyx/TitanLegend/actions/workflows/godot-validate.yml) enthält diesen Test.
- Der Test prüft die neue Hauptdatei, das Rotieren der Sicherung, das Ablehnen ungültiger Daten, die Wiederherstellung nach einer simulierten Beschädigung und das Bewahren der guten Sicherung.

Die bestehenden Kampfsystem- und Balancingregeln bleiben davon unberührt.
