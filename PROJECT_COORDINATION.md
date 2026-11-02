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

## Aktuelle Chat-Zuordnung (2026-11-02)
- **Charakterdesign (neuer Chat):** übernimmt die bestehende Zuständigkeit für Charaktermodelle, Gesichter, Proportionen, Haare, Rigging und Basisanimationen.
- **Landschaft (neuer Chat):** übernimmt die bestehende Zuständigkeit für Gebiete, Terrain, Vegetation, Beleuchtung und Android-Performance.
- Beide ersetzen für die Koordination die bisherigen Chat-Zuordnungen ihrer Fachbereiche; es entstehen keine doppelten Entwicklungsaufträge.
- Skill-Animationen bleiben beim separaten Skills-und-Animationen-Chat. Schnittstellen zum Charakterdesign abstimmen.
- Alle Fach-Chats lesen PROJECT_LIVE_STATUS.md und dokumentieren Änderungen in GitHub. Ein automatischer Nachrichtenaustausch zwischen ChatGPT-Chats ist nicht verfügbar.

## Audio-Erstellung (2026-11-02)
- **Audio-Erstellung (neuer Fach-Chat):** Musik, Umgebungsgeräusche, Kampf-/Skill-SFX, UI-Sounds, Audio-Mixing und Godot-Audio-Integration; stimmt Skill-Sounds mit Skills-und-Animationen, Gebietsatmosphäre mit Landschaft und UI-Sounds mit UI ab. Nur eigene oder entsprechend lizenzierte Audio-Assets verwenden.

## Titan Chat / Moderation (2026-11-02)
- **Titan-Chat (neuer Fach-Chat):** Ingame-Chat, Chatkanäle, Nachrichtenübermittlung, Schimpfwortfilter, Verwarnungen, Moderationsprotokoll und Sperrverwaltung.
- **Moderationsregeln:** zunächst drei Systemverwarnungen; danach bei erneuten Verstößen abgestufte Sperren von 2 Stunden, 5 Stunden, 24 Stunden und 7 Tagen. Sperren bedürfen der Freigabe durch den Spielbetreiber; der Betreiber kann die Strafdauer ändern. Zur Prüfung muss ein zweckgebundener, zugriffsgeschützter Chatverlaufs-Auszug bereitstehen; Aufbewahrung und Zugriff datensparsam gestalten.
- **Schnittstellen:** Abstimmung mit UI für Chatoberfläche, mit Multiplayer/Backend für serverseitige Durchsetzung und mit Audio für Benachrichtigungstöne. Andere Fach-Chats sollen keine parallelen Chat- oder Moderationssysteme entwickeln.
