# Titan Legends – Android FPS-Messprotokoll

Stand: 2026-11-04. Zuständigkeit: Grafiktreiber / Rendering.

## Voraussetzung
- Nur einen **erfolgreich validierten integrierten Android-Build** testen. Ein erfolgreicher Export allein beweist keine Spielfunktion.
- Für sichtbare Messwerte den Workflow `.github/workflows/android-debug-apk.yml` manuell mit `developer_fps=true` starten. Normale Push-Builds zeigen keine Entwickler-FPS-Anzeige.
- Godot 4.7.2 / Android Hochformat; keine Änderungen an UI, Charakterformation oder Landschaft in diesem Messlauf.
- Der Wert **Soll-Skalierung** ist die angeforderte 3D-Skalierung. Die tatsächliche GPU-Renderauflösung ist beim Compatibility-Renderer damit **nicht** bestätigt.

## Vergleichbare Messung
1. Gerät und Android-Version notieren; Bildschirmhelligkeit möglichst gleich lassen; Energiesparmodus und Ladezustand dokumentieren.
2. Spiel neu starten; Grafikprofil, Ziel-FPS, Schatten, Effekte und automatische Optimierung dokumentieren.
3. Pro Szenario die FPS-Messung per **FPS Reset** zurücksetzen und mindestens 120 Sekunden beobachten; erste Lade-/Aufwärmphase getrennt erfassen.
4. Szenarien: (a) ruhiges Gebiet, (b) normale Mobwellen, (c) Bosskampf mit vier Helden und Skill-Effekten. Bosskämpfe dauern maximal 60 Sekunden; für 120 Sekunden ggf. mehrere getrennte Bossdurchläufe verwenden und **nicht** unbemerkt vermischen.
5. Wiederholung mit 30-FPS- und 60-FPS-Ziel; 120 FPS nur, wenn das Gerät dies unterstützt. Erst ein Basislauf mit automatischer Optimierung **aus**, danach ein zweiter Lauf **ein**.
6. Pro Durchlauf FPS-Minimum, -Maximum, Durchschnitt, Ziel-FPS, Prozent **Unter Ziel**, Soll-Skalierung, Laufzeit und einen Screenshot notieren. Bei FPS Pause bleiben die angezeigten Werte stehen.
7. Temperaturentwicklung, sichtbares Ruckeln, Ladepausen und Darstellungsfehler separat beschreiben. Keine FPS-Gewinne aus CI oder Soll-Skalierung ableiten.

## Messblatt

| Gerät / Android | Build-SHA | Szene | Profil | Auto | Ziel | Min | Avg | Max | Unter Ziel % | Soll-Skalierung % | Dauer |
|---|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|
| | | | | | | | | | | | |

## Auswertung und Übergabe
- Wiederholte Unterschreitungen: zuerst Szene und konkreten Effekt identifizieren, dann mit dem verantwortlichen Fach-Chat abstimmen.
- **Landschaft:** Vegetation, Lichtquellen, Terrain und Sichtweite. **Charakter/Gegner:** Skins, Rigs, Animationen und Materialanzahl. **Skills:** VFX, Partikel und Überlagerung. **UI:** nur HUD-Performance und Überlappungen im zuständigen UI-Chat. **APK/CI:** Export und Gerätekompatibilität.
- Globales Renderer-Verhalten, Shader oder Qualitätsprofile nur nach Vergleichsmessung verändern.
- Die Entwickleranzeige nimmt halbsekündliche FPS-Stichproben. **Unter Ziel** ist deren Anteil unter `Engine.max_fps`, kein exaktes Frametime-Perzentil.
