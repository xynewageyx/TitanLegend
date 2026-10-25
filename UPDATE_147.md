# Titan Legends – Update 147: Android-Kampfanzeigen

- Schadens- und Heilungszahlen deutlich verkleinert (Schrift, Outline, Pixelgröße).
- Kritische Treffer bleiben größer als normale Treffer.
- Geringere seitliche und vertikale Streuung, kürzere Aufstiegsanimation.
- Maximal fünf gleichzeitige Schadens-/Heilungsanzeigen nahe einem Helden; HP-Berechnung bleibt unverändert.
- Unbenutzte Variable `final_color` entfernt.
- Ganzzahldivisionswarnung in `floating_text.gd` durch `float(lane_index) / 5.0` behoben.

Hinweis: Hardware-Warnungen zur RGBAFloat-Konvertierung sind geräte-/rendererabhängig und wurden nicht als behoben markiert. Godot-Android-Laufzeittest noch ausstehend.
