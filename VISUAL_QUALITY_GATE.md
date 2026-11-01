# Titan Legends – Visuelle Qualitätsprüfung

Stand: 2026-11-01
Status: Prüfplan; kein Nachweis für bereits erreichte Grafikqualität.
Referenz: PROJECT_COORDINATION.md

## Ziel
Eigenständige, hochwertige, farbenfrohe Cartoon-/Chibi-3D-Fantasy-Grafik. Nicht nur technisch ladende, sondern visuell überzeugende Modelle. Fremde Spielassets nicht ungeprüft übernehmen.

## Prüfkriterien
### Charaktere
- Deutlich unterscheidbare Silhouetten und Gesichter je Klasse.
- Ausdrucksstarke Augen, Haare mit Volumen, anatomisch konsistente stilisierte Proportionen.
- Rüstung sitzt auf dem Körper; keine schwebenden oder ineinander ragenden Teile.
- Idle, Laufen, Angriff, Treffer und Tod müssen flüssig und lesbar sein.

### Gegner und Bosse
- Unterschiedliche Körperformen und Bewegungsprofile statt bloßer Farbvarianten.
- Gesichtsausdruck, Materialwirkung, Konturen und Animationen auf gleicher Qualitätsstufe wie Helden.
- Boss-Angriffe mit klaren Warnsignalen; Trefferreaktionen sichtbar.
- Keine offensichtlichen Platzhalter oder primitive Mesh-Kombinationen als finales Design ausgeben.

### Ausrüstung
- Waffen und Rüstungen nach Seltenheit sichtbar aufwendiger; höchste Stufen dramatisch, aber gut lesbar.
- Ein gemeinsamer Farb-, Material- und Detailstandard über alle Klassen.
- Keine Clipping-Fehler bei Animationen.

### Landschaft
- Wiedererkennbare Gebiete mit Tiefenstaffelung, Variation, stimmiger Beleuchtung.
- Performance auf Android beachten; keine unkontrollierte Polygon- oder Materiallast.

### UI
- Hochformat 720×1280 als Referenz, zusätzlich kleinere Android-Displays prüfen.
- Lesbare Texte, klare Touch-Ziele, keine verdeckten Bedienelemente.
- HUD und Menüs müssen zum gleichen Cartoon-Fantasy-Artstyle passen.

## Validierungsverfahren
1. CI: Godot-Import, Skript-/Gameplay-Tests, Android-Export.
2. Gerät: echte Screenshots/Videos aus aktueller APK von Held, Gegner, Boss, Inventar, HUD und Landschaft sammeln.
3. Visuelle Prüfung: pro Bereich mit Pass / Nacharbeit / Blockiert bewerten; konkrete Bildstellen dokumentieren.
4. Änderungen nur dann als visuell erfolgreich kennzeichnen, wenn aktuelles Bildmaterial überprüft wurde.
5. Testergebnisse und zugehörige Commit-SHA dokumentieren. Alte Screenshots niemals als Nachweis neuer Änderungen verwenden.

## Aktuelle Priorität
1. Android-Build und Godot-Validierung auf demselben Commit abwarten.
2. Aktuelle Screenshots auf Android erstellen.
3. Charakter-/Gegnerqualität anhand der Screenshots korrigieren.
4. Anschließend Waffen/Rüstungen, Umgebung und UI gemeinsam abstimmen.
