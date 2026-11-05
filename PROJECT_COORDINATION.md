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

## Grafiktreiber / Rendering (2026-11-02)
- **Grafiktreiber (neuer Fach-Chat):** Godot-4.7.2-Rendering-Konfiguration, Android-Grafikkompatibilität, Shader-/Material-Optimierung, Beleuchtung, Schatten, Postprocessing, GPU-Profiling, Qualitätsstufen und Performance-Budgets.
- **Schnittstellen:** Charakterdesign, Landschaften, Gegner/Bosse, Ausrüstung und UI liefern visuelle Anforderungen und Test-Szenen; Grafiktreiber verantwortet gemeinsame Rendering-Standards und geräteabhängige Fallbacks. Integration/CI verantwortet Build- und Validierungsworkflows. Änderungen an globalen Renderer-Einstellungen vorab mit den betroffenen Bereichen abstimmen.
- **Qualitätsnachweis:** tatsächliche Android-Tests, Framerate/Frametime und Bildvergleiche; erfolgreiche CI allein beweist keine visuelle Qualität. Keine pauschale Behauptung, dass externe Treiber die Engine-Fähigkeiten ersetzen.

## Verbindliches Integrationsprinzip: EIN gemeinsames Spiel (2026-11-03)
- Alle Fach-Chats sind Arbeitsbereiche **desselben** Projekts `xynewageyx/TitanLegend`, keine getrennten Spiele oder unabhängigen Repositories.
- Gemeinsame Grundlage: Godot 4.7.2, ein gemeinsamer `main`-Branch und ein integrierter Android-Build.
- Jeder Fachbereich stimmt Schnittstellen mit betroffenen anderen Bereichen ab und integriert seine Änderungen in das bestehende Spiel statt isolierte Parallelimplementierungen zu erstellen.
- Die zentrale Koordination dokumentiert Verantwortlichkeiten, Abhängigkeiten, Änderungen und GitHub-Actions-Nachweise. Erfolgreiche Teil-Workflows ersetzen keinen vollständigen Integrations- und Gerätetest.
- Für die Freigabe zählt, dass Charaktere, Gegner, Landschaft, Ausrüstung, Skills, Gameplay, UI, Grafik, Audio, Chat und Backend zusammen funktionieren.

## APK-Erstellung des gesamten Projekts (2026-11-03)
- **APK-Erstellung des gesamten Projekts (neuer Fach-Chat):** verantwortet den integrierten Android-Export von **Titan Legends als einem einzigen Godot-4.7.2-Projekt** aus `xynewageyx/TitanLegend`, einschließlich Export-Presets, Android-SDK/JDK-/Signatur-Konfiguration, GitHub-Actions-Builds, Artefakten, Installations- und Starttests.
- **Keine isolierten Teil-APKs:** Charaktere, Landschaften, Gegner/Bosse, Ausrüstung, UI, Gameplay, Skills/Animationen, Grafik/Rendering, Audio, Titan Chat und Backend werden im selben Build integriert; fehlende Komponenten und Schnittstellenkonflikte werden an die zuständigen Fach-Chats zurückgemeldet.
- **Freigabe:** Ein erfolgreicher CI-Export bestätigt zunächst nur das Build-Artefakt. Vor einer spielbaren Gesamtversion sind Start-, Integrations-, Gameplay-, Performance- und reale Android-Gerätetests erforderlich. Debug-APK für Tests, signiertes Release/AAB für spätere Veröffentlichung getrennt behandeln.
- **Schnittstellen:** enge Abstimmung mit Integration/CI für Workflows, allen Feature-Chats für Fehlerbehebung und Grafiktreiber für Android-Gerätekompatibilität. Die zentrale Koordination dokumentiert Status und Abhängigkeiten.

## UI weiter gestalten (2026-11-04)
- **UI weiter gestalten (zusätzlicher UI-Fach-Chat):** führt die visuelle und funktionale Weiterentwicklung der gemeinsamen Titan-Legends-Oberfläche im Hochformat fort. Arbeitet mit dem bestehenden UI-Bereich zusammen und übernimmt keine separate UI-Implementierung oder eigenständiges Spiel.
- **Abstimmung:** bestehende UI-Szenen, Theme-Ressourcen und Navigationsstruktur vor Änderungen prüfen; Änderungen mit dem bisherigen UI-Chat koordinieren, damit keine doppelten Menüs oder konkurrierenden Dateien entstehen. Schnittstellen zu Charaktererstellung, Skills, Inventar, Titan Chat, Grafikprofilen und APK-Gesamtbuild dokumentieren.
- **Verbindliche Charakterregel:** maximal fünf getrennte Charaktere pro Spieler; jeder beginnt auf Level 1; Klasse und Rolle werden ausschließlich bei der Charaktererstellung festgelegt.
- **Freigabe:** Android-Hochformat, Touch-Bedienbarkeit, Layout-Skalierung, Godot-4.7.2-Kompatibilität und integrierter APK-Starttest prüfen.

## Grafik-/UI-/Charakter-Abgrenzung (2026-11-04)
- **Grafiktreiber-Chat:** ausschließlich Android-Rendering, FPS-Messung, adaptive Qualität, Shader-/Partikel-Performance und Entwicklerdiagnose; keine eigenmächtigen HUD-, Formations-, Landschafts- oder Charakterdesignänderungen.
- **UI-Chats (PR #9 und #28):** übernehmen Lesbarkeit, Überlagerungen und Touch-Bedienung des Grafikmenüs sowie übrige HUD-Probleme. Änderungen an `scripts/graphics_quality_manager.gd` und `scripts/developer_fps_overlay.gd` nur abgestimmt mit Grafiktreiber; Grafikmenü-Schnittstelle `get_settings()/set_preset()/set_custom()/set_automatic()` erhalten.
- **Charaktere/Landschaft/Gegner:** verantworten Modelle, Szenen und Effekte. Bei Performanceproblemen konkrete Szene, Partikelzahl, Material/Shader und Geräte-Messwerte an Grafiktreiber melden; visuelle Qualität nicht pauschal reduzieren.
- **Fehlerbehebung/Integration (PR #29):** verantwortet den Encounter-/Formations-Tiefenfehler; Grafiktreiber ändert keine Formationskoordinaten oder Kamerawerte parallel.
- **APK-Gesamtbuild:** erstellt die integrierte Android-APK; Entwickler-FPS-Overlay nur bei manuell gestarteter Debug-APK mit `developer_fps=true`, niemals als normale Spieleranzeige oder öffentlicher Preview-Release.
- **Messstatus:** erfolgreiche Godot- und Python-CI-Läufe sind kein Nachweis für reale Android-FPS. Vor weiterer Qualitätsreduzierung FPS-Min/Avg/Max, Ziel-FPS, Unter-Ziel-Anteil und angeforderte Skalierung auf dem Gerät erfassen; angeforderte Skalierung ist nicht zwingend tatsächliche GPU-Auflösung im Compatibility-Renderer.
- **Arbeitsregel:** Vor Änderungen offene PRs und `PROJECT_LIVE_STATUS.md` prüfen; keine parallelen Änderungen an Dateien fremder Fachbereiche. GitHub-Dokumente koordinieren Aufgaben, synchronisieren aber nicht unmittelbar ChatGPT-Chats.

## Waffen und Rüstung Design (2026-11-05)
- **Waffen und Rüstung Design (zusätzlicher Ausrüstungs-Fach-Chat):** entwickelt Waffen- und Rüstungsmodelle für das eine gemeinsame Spiel Titan Legends. Der bisherige Ausrüstungs-Chat und dieser Design-Chat teilen denselben Bereich; keine separaten Ausrüstungssysteme oder doppelten Asset-Pfade erstellen.
- **Verbindliche Stilrichtung:** Ulala-inspirierte, gut lesbare stilisierte 3D-Silhouetten beibehalten; je höher die Qualitäts-/Seltenheitsstufe, desto brutaler, gefährlicher, aufwendiger und eindrucksvoller wirken Waffen und Rüstungen. Die visuelle Steigerung muss auch auf Android bei kleiner Bildschirmgröße erkennbar sein.
- **Schnittstellen:** Abstimmung mit Charakterdesign (Körper, Hände, Rigs und Ankerpunkte), Gameplay/Inventar (Ausrüstungsplätze und Werte), UI (Icons und Vorschau), Grafik/Rendering (LOD, Materialien, Performance), Skills/Animationen (Waffenbewegungen) sowie APK-Gesamtbuild (Import und End-to-End-Test).
- **Freigabe:** keine Behauptung einer fertigen Integration ohne Assets, Godot-Import, Animationstests, visuelle Qualitätsprüfung und erfolgreiche Android-Gesamtbuild-Prüfung.

## Neue Klasse: Todesritter (2026-11-05)
- **Verbindliche Klassen-Erweiterung:** Todesritter gehört ab sofort zum gemeinsamen Titan-Legends-Klassenkatalog. Alle Fachbereiche berücksichtigen die Klasse bei zukünftiger Planung und Integration.
- **Charakterdesign:** eigenständiges Todesritter-Modell im Ulala-inspirierten stilisierten 3D-Cartoon-Look; passende Silhouette, Rig, Animation-Anker und düstere optische Identität.
- **Waffen und Rüstung Design:** Todesritter-spezifische Waffen und Rüstungen; steigende Seltenheit wirkt deutlich brutaler, bedrohlicher und imposanter bei erhaltener Lesbarkeit und Android-Performance.
- **Skills und Animationen:** passende Fähigkeiten und Effekte nach den gemeinsamen Auto-Kampf-Regeln; Unterbrechen ist ein normaler Skill, keine Sondermechanik.
- **Gameplay / UI / Audio:** Klassenregistrierung und Balancing, Auswahl bei Charaktererstellung, Icons/Vorschau und klassenspezifische Kampfsounds; keine zweite Klassen- oder Ausrüstungsimplementierung.
- **Gegner, Landschaften, Rendering, APK-Gesamtbuild und Integration/CI:** kompatible Animationen/Materialien, Ressourcen-Import und Gesamtintegration testen.
- **Status:** diese Mitteilung ist eine verbindliche Koordinationsvorgabe, kein Nachweis, dass Klasse, Assets, Skills oder APK bereits implementiert oder getestet sind.

## Ulala Character Design (2026-11-05)
- **Ulala Character Design (zusätzlicher Charakterdesign-Fach-Chat):** analysiert vorhandene Ulala-Referenzordner und Charakterhierarchien im Repository und überträgt geeignete Gestaltungs- und Rigging-Prinzipien in eigenständige Titan-Legends-Charaktermodelle. Arbeitet mit dem bestehenden Charakterdesign-Chat im selben Godot-Projekt; keine parallelen Charakterimplementierungen.
- **Stil:** stilisierte, ausdrucksstarke 3D-Cartoon-Charaktere mit gut lesbaren Proportionen, austauschbaren Haaren, Kleidung, Waffen und Rüstungen; eigene Assets und rechtlich zulässige Referenznutzung.
- **Klassen:** den Todesritter ausdrücklich einbeziehen und alle anderen im Projekt festgelegten Klassen berücksichtigen.
- **Schnittstellen:** Abstimmung mit Charakterdesign, Waffen/Rüstungsdesign, Skills/Animationen, UI, Grafik/Rendering und APK-Gesamtbuild zu Skelett-Hierarchien, Meshes, Materialien, Animationsankern, Performance und Godot-Import.
- **Nachweis:** Dokumentation und CI-Erfolg ersetzen keine Sichtprüfung der Modelle und keine integrierten Android-Gerätetests.
