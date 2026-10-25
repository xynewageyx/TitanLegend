# Update 41 – Boss-Wutphase: bessere visuelle Signale

- Alle zehn Boss-Elemente erhalten ihre eigene Farbe für den Wutphasen-Energiering.
- Ab weniger als 35 % Boss-LP erscheinen zwei gegenläufig rotierende Energieringe und ein leuchtender Kern.
- Fusionstitanen erhalten größere Ringe und schnellere Drehungen.
- Bei Boss-Spezialangriffen leuchtet ein kurzlebiger Warnring am Boden.
- Die bisherigen Kampfwerte, Cooldowns, Talentbäume, passiven Begleiter und Hochformat-HUD bleiben unverändert.
- Die Effekte werden ohne externe Assets direkt als Godot-3D-Geometrie erzeugt.

## Test
1. `project.godot` in Godot 4.7.2 importieren.
2. Bis Welle 10 spielen.
3. Den Boss auf unter 35 % Lebenspunkte bringen und die Wutphase beobachten.
4. Prüfen, ob der Angriffswarnring vor Boss-Spezialangriffen erscheint.

ZIP-Inhalt und Scriptintegration geprüft; kein vollständiger Godot-Android-Laufzeittest durchgeführt.
