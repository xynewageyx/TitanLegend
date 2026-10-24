# Titan Legends – Update 197: Boss-Loot, Inventar und drei zusätzliche Ausrüstungsplätze

## Neuer Spielfluss
Nach einem erfolgreich besiegten **Welt-Boss** wird unabhängig vom Gold ein zufälliger Ausrüstungsdrop geprüft. Normale Bosskämpfe haben 55 % Dropchance, Fusionsbosse 85 %. Astral-Bosse erhalten in dieser Version keine Inventardrops. Normale Mobwellen haben weiterhin keine Ausrüstungsdrops.

## Itemtypen und Seltenheit
Die drei Itemtypen sind **Helm, Rüstung und Zubehör**. Für den Drop wird zufällig einer der Typen gewählt; die Seltenheit wird gewichtet von Weiß über Grün, Blau, Gelb und Gold bis Lila ermittelt. Höhere Stages steigern die Chance auf seltenere Qualitäten geringfügig. Jedes Item enthält eine eindeutige ID, Typ, Qualitätsrang und Stufe (1–1200).

## Ausrüstung und Wirkung
Jeder der vier Helden kann **je ein Item jedes Typs** ausrüsten. Die Gegenstände liegen in einem globalen Inventar, maximal 60. Ein und dieselbe Item-ID darf nur bei einem Helden ausgerüstet sein; erneutes Anlegen versetzt sie automatisch. Ein freier Platz gewährt keinen Bonus.

- **Helm:** Erhöht die maximalen HP des Helden bei der nächsten HP-Initialisierung.
- **Rüstung:** Reduziert eingehenden Schaden für diesen Helden zusätzlich und multiplikativ.
- **Zubehör:** Erhöht den Schaden der normalen und offensiven Skill-Angriffe.
- Pro Gegenstand beträgt der Bonus maximal 12 %, abhängig von Itemqualität und Itemstufe, ohne unbegrenzte Stapelung.

## Android und Spielstände
Im scrollbaren Juwelen-/Ausrüstungsfenster kann das Inventar durchgeschaltet und der angezeigte Gegenstand dem gewählten Helden angelegt werden. Waffenlevel, Waffenqualität und die vier Härtungsfelder bleiben unverändert.

Im Savefile werden Inventar, belegte Item-IDs und die nächste Item-ID gespeichert. Beim Laden werden doppelte und ungültige IDs sowie falsche Gegenstandstypen verworfen. Alte Savefiles enthalten zunächst ein leeres Inventar.

Bei vollem Inventar werden keine neuen Drops verliehen; automatische Verkäufe und Zerlegen sind noch **nicht** enthalten. Itemtausch, Verkauf, detaillierte Inventarliste und Drops für andere Spielmodi folgen.

## Verifikation
Statische Prüfungen in `tests/test_core_import.py` ergänzt und Quellcodeverknüpfungen geprüft. Die Tests sind keine ausgeführte Godot-Engine-Simulation.

**Kein Godot-4.7-Laufzeittest oder Android-APK-Build.** Insbesondere Save/Load, Touchscrolling, die 60-Gegenstände-Grenze und die Dropchancen müssen noch im echten Spiel getestet werden. Bosskampfzeit bleibt **60 Sekunden**.
