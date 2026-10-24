# Titan Legends – Update 195: Härtungsattribute auswählen und neuwürfeln

## Funktion
Jeder der vier Helden besitzt vier Härtungsfelder mit unabhängigem Rang und zugewiesenem Attribut. Die sechs verfügbaren Attribute sind **Angriff, Rüstung, HP, kritischer Schaden, Ausweichen und Aufspießen**.

- Ein Feld kann gezielt einem anderen der sechs Attribute zugewiesen oder zufällig neu gewürfelt werden.
- Beide Aktionen kosten Gold: `250 × (Härtungsrang + 1)`. Bei ungültiger Auswahl oder zu wenig Gold wird nichts verändert oder abgezogen.
- Der Zufallswurf liefert stets ein anderes Attribut als das aktuelle; keine kostenlose Ergebnisgarantie für eine bestimmte gewünschte Eigenschaft.
- Der Rang bleibt bei Attributwechsel erhalten. Die Härtungsverbesserung selbst kostet weiterhin `1000 × (Rang+1)` Gold und bleibt auf Charakterlevel gedeckelt.
- Pro Attribut summieren sich die Ränge aller vier Felder desselben Helden; der Bonus ist je Attribut auf maximal +20 % begrenzt.

## Kampfanbindung
- Angriff erhöht normale Treffer und Schaden offensiver Skills.
- Rüstung gewährt zusätzliche relative Schadensminderung.
- HP erhöhen die maximale Heldengesundheit bei nächster HP-Initialisierung.
- Kritischer Schaden erhöht den kritischen Multiplikator.
- Ausweichen erhöht die Basisausweichchance von 4 % bis insgesamt maximal 24 %.
- Aufspießen erhöht die passive Rüstungsdurchdringung gegen Bosswiderstände. Dabei bleibt die bestehende Kappung des effektiven Bosswiderstands in `damage_after_resistance()` maßgeblich.

## Kompatibilität und Android-Bedienung
Alte Spielstände ohne `hardening_attributes` behalten automatisch die ursprünglich zugewiesenen Attribute [Angriff, Rüstung, HP, Krit-Schaden] pro Held. Die vier vorhandenen Härtungsränge und Waffenstufen bleiben erhalten. Neue Auswahlwerte werden zusätzlich gespeichert.

Die vorhandene Juwelen-/Ausrüstungsansicht erhält Feldauswahl, Wahl des gewünschten Attributs, kostenpflichtige gezielte Umstellung und Zufallswurf. Wegen der zusätzlichen Schaltflächen ist das Fenster scrollbar gemacht.

## Grenzen
- Noch keine eigenen Gegenstandsdrops, Item-Seltenheiten, Härtungsgutscheine oder zufälligen Erfolgswahrscheinlichkeiten je Rang.
- Bosskampflimit bleibt bei 60 Sekunden.
- Quellcode und statische Testabdeckung wurden angepasst; **kein echter Godot-4.7-Laufzeittest oder Android-APK-Build**.
