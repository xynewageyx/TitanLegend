# Titan Legends – Gemeinsame Projektkoordination

Stand: 2026-11-01
Repository: xynewageyx/TitanLegend
Zweck: Verbindliche, von allen Entwicklungs-Chats lesbare Projektregeln. Diese Datei synchronisiert Chatverläufe nicht automatisch.

## Technische Basis
- Engine-Ziel laut Projektvorgabe: Godot 4.7.2 (vorhandene Projekt- und CI-Konfiguration vor Änderungen prüfen).
- Zielplattform: Android, Hochformat; Entwicklung und Tests müssen ohne lokalen PC möglich sein.
- Hauptbranch `main` ist Integrationsbasis. Änderungen vorzugsweise über eigene Branches und geprüfte Pull Requests.
- Keine Erfolgsmeldung ohne tatsächlich ausgeführte Prüfung bzw. GitHub-Actions-Ergebnis.

## Verbindliche Spielregeln
- Vier Helden pro Team, maximal ein aktiver Tank.
- Keine automatische Tank-Verdrängung und kein automatischer Rollenwechsel; die zuerst belegte Tank-Rolle bleibt besetzt, bis sie frei wird.
- Team-Bonus für 1 Tank, 2 Schadensklassen, 1 Heiler.
- Automatisches Kampfsystem, vier priorisierte Skills pro Held.
- 12 Gebiete mit je 100 Stages; normale Stages mit drei Wellen (2/5/7 Gegner), Boss alle zehn Stages.
- Bosskämpfe dauern maximal 60 Sekunden; keine Wiederbelebung im Bosskampf.
- Begleiter unterstützen passiv und werden visuell neben dem Charakter dargestellt.
- Offline-Farming bis acht Stunden; Bosskampf nicht automatisch starten.
- Reinkarnation ab Level 250 gemäß vorhandener Progressionsimplementierung prüfen.
- Gilden- und PvP-Systeme müssen auf bestehenden Regeln aufbauen.

## Gemeinsame Designrichtung
- Eigenständige, hochwertige, farbenfrohe, stilisierte 3D-Fantasy-Ästhetik, inspiriert vom allgemeinen Chibi-/Cartoon-RPG-Look.
- Einheitliche Proportionen, ausdrucksstarke Gesichter, individuelle Silhouetten, hochwertige Materialien und flüssige Animationen.
- Charaktere, Gegner, Bosse, Waffen, Rüstungen, UI und Landschaften müssen optisch zusammenpassen.
- Keine direkte Übernahme fremder geschützter Spiel-Assets ohne geklärte Nutzungsrechte.

## Zuständigkeiten nach Arbeitsbereich
- Charaktere: Modelle, Rigging, Animationen, Klassen-Silhouetten.
- Gegner/Bosse: Modelle, Bewegungen, Angriffs-Telegraphen, Effekte.
- Landschaften: Gebiete, Terrain, Vegetation, Beleuchtung, Performance.
- Ausrüstung: Waffen, Rüstungen, Seltenheitsstufen, visuelle Eskalation.
- UI: Android-Hochformat, Bedienbarkeit, HUD, Menüs.
- Gameplay: XP, Talentbäume, Teamrollen, Kampfregeln und Progression; Schnittstelle zur Skill-Ausführung.
- Skills und Skill-Animationen (eigener Fach-Chat): Klassenfähigkeiten, Skill-Eigenschaften, Unterbrechen, Zielauswahl, Flächenschaden, Heilungslogik sowie Skill-VFX und Animationen. Keine eigenständigen Änderungen an Teamrollen, XP oder Talentbaum ohne Abstimmung.
- Integration: Import, Ressourcenpfade, Godot-Validierung, Android-Build.

## Schnittstellen für den Skills-und-Animationen-Chat
- Jeder Klasse stehen unterbrechende Fähigkeiten zur Verfügung; eine Unterbrechung wird ausschließlich durch einen entsprechenden Skill ausgelöst.
- Die Eigenschaft des einzelnen Skills legt fest, ob er Einzelziel- oder Flächenschaden verursacht; keine Skill-Kombinationsmechanik.
- Der Spieler legt die Skills fest; die bestehende automatische Kampfsteuerung führt sie gemäß Priorität aus.
- Einzelziel-Heilung wählt automatisch den lebenden Verbündeten mit den niedrigsten aktuellen Lebenspunkten.
- Abstimmung mit Charakter-Chat (Rigging/Animation), Gegner-/Boss-Chat (Trefferreaktion/Unterbrechung), Gameplay-Chat (Kampf-API) und UI-Chat (Skill-Anzeigen).

## Ablauf für jede Änderung
1. Vor Beginn aktuellen Repository-Stand und relevante Dateien prüfen.
2. Bestehende Regeln und andere betroffene Systeme berücksichtigen.
3. Änderungen in klar abgegrenzten Dateien/Branches vorbereiten.
4. Konflikte, Importfehler und Ressourcenzuordnungen prüfen.
5. Godot-Validierung und Android-Build über GitHub Actions ausführen, sofern verfügbar.
6. Nur nach belegtem Erfolg als integriert melden; Fehler mit Logstellen dokumentieren.
7. Entscheidungen und offene Punkte in dieser Datei oder ergänzenden Projektdateien aktualisieren.

## Nächste gemeinsame Aufgaben
- Vorhandene GitHub-Actions-Workflows und Godot-Projektversion abgleichen.
- Asset-Qualität und einheitlichen Stil anhand echter Android-Screenshots prüfen.
- Defekte Import-/Terrain-/UI-Pfade anhand von Logs priorisieren.
- Fehlende Abhängigkeiten nur hinzufügen, wenn ein konkreter technischer Bedarf nachgewiesen ist.

## Ausrüstung / Frisuren – Entwicklungsstand 2026-11-01
- Arbeitsbranch: `feature/modular-hair-v3`; Draft-PR #10: https://github.com/xynewageyx/TitanLegend/pull/10
- Neue originale Frisuren: `scripts/equipment/procedural_hairstyle.gd`, Anbindung über `hero_equipment_sockets.gd::equip_hairstyle`.
- Überarbeitete prozedurale Rüstungsgeometrie: `scripts/equipment/chibi_armor_piece.gd`. Bestehende Slots und Kampfregeln bleiben erhalten.
- Tests: `tests/test_modular_hairstyle.py` und `tests/test_modular_armor_geometry.py`.
- GitHub Actions für Commit `6a6e865f`: Godot-Validierung und Core Regression erfolgreich; Android-Debug-APK abgebrochen (kein APK-Erfolg nachgewiesen).
- Noch offen: echte Android-Sichtprüfung, Charakter-Skelett-/Socket-Ausrichtung, hochwertige individuelle Meshes, LOD/Performance, Merge.
- WICHTIG: andere Chats bitte vor Arbeiten an den genannten Dateien PR #10 prüfen; keine parallele Überschreibung. Dieser Projektstatus ist eine gemeinsame Referenz, keine automatische Live-Chat-Synchronisation.
