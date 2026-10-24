# Titan Legends – Offline-Farming (Update 199)

## Spielerregel

Titan Legends speichert den Spielstand automatisch. Nach mindestens fünf Minuten Abwesenheit werden beim nächsten Start bzw. beim Fortsetzen der App passive **Gold- und XP-Erträge aus normalen Mobwellen** ausgezahlt.

- **Obergrenze:** Acht Stunden Offline-Zeit pro Abwesenheitsperiode; darüber hinaus entsteht kein zusätzlicher Ertrag.
- **Mindestzeit:** Fünf Minuten. Kürzere Pausen erzeugen keinen Ertrag.
- **Balancing:** Eine normale Mobwelle pro 60 Sekunden; jede Welle bringt `50 × aktuelle Stage` Gold und `10 × aktuelle Stage` XP. Die zugrunde gelegte Stage ist auf 1–1200 begrenzt.
- **Stage-Fortschritt:** unverändert; die Figur startet auf genau derselben Stage und Welle wie vor der Pause.
- **Bosskämpfe und Loot:** Es werden offline **keine** Bosse besiegt, keine neuen Gebiete freigeschaltet und **keine** Boss-Gegenstände vergeben.
- **Erfahrung:** Normale Mobwellen bringen online wie offline XP. XP erhöht nach wachsendem Schwellenwert das Charakterlevel (anfangs `5.000 + 1.000 × aktuelles Level` XP). Die bisherigen direkten Charakterlevel nach Boss-Siegen bleiben zusätzlich bestehen. Die 3 Talentpunkte pro Level folgen automatisch aus dem bestehenden Talentsystem.
- **Team-Rollen:** Die bestehende Ein-Tank-Regel und das Kampfsystem bleiben unberührt.

Beispiel: Bei Stage 10 entsprechen genau fünf Minuten Offline-Zeit fünf normalen Wellen und **2.500 Gold und 500 XP**. Nach acht Stunden ergibt das für Stage 10 maximal **240.000 Gold und 48.000 XP**.

## Umsetzung

- `scripts/experience_system.gd` berechnet Mob-XP, steigende Levelschwellen und XP-Überträge über Levelaufstiege hinweg; dieselbe Routine wird auch im Online-Kampf verwendet.
- `scripts/offline_rewards.gd` enthält eine pure, geprüfte Gold-/XP-Berechnungsroutine mit Zeitlimit und Obergrenze.
- `scripts/save_manager.gd` speichert `last_active_unix` bei jedem automatischen Save, nach 30 Sekunden und auf Android beim Pausieren.
- Während die App pausiert ist, stoppt der periodische Speicher-Timer. Bei Fortsetzung wird der Offline-Ertrag berechnet und automatisch angewendet.
- Der neue Goldstand, die XP, das Charakterlevel und der fortgeschriebene Zeitstempel werden vor der Auszahlung **zusammen atomisch** in `user://save_data.json` gesichert. Eine unveränderte gespeicherte Periode kann nicht erneut beansprucht werden.
- Ältere Spielstände ohne `last_active_unix` bleiben kompatibel. Für Zeiten vor dem ersten aktualisierten Speichern wird keine erfundene Offline-Belohnung rückwirkend erzeugt.
- Das HUD zeigt die erfolgreiche Gold-/XP-Zahlung kurz an und protokolliert sie im lokalen System-Chat.

## Tests

- Godot: `godot --headless --path . --script res://tests/test_offline_rewards.gd`.
- GitHub Actions: [Godot project validation](https://github.com/xynewageyx/TitanLegend/actions/workflows/godot-validate.yml) führt den Test zusätzlich zu den Speicherintegritäts- und Spiel-Smoke-Tests aus.
- Testfälle: Grenze fünf Minuten; maximal acht Stunden; Stages 1–1200; manipulierte Rückwärts-Uhrzeit; bestehende Spielstände; gleiche Abwesenheit nur einmal; XP-Levelaufstiege und Rest-XP; unveränderte Stage/Boss-/Loot-/Talentwerte.

## Grenzen

Offline-Zeit wird anhand der **lokalen Geräteuhr** ermittelt. Ohne Server kann eine manipulierte Uhrzeit nicht zuverlässig erkannt werden; die Acht-Stunden-Obergrenze begrenzt den Schaden. Ein volles Speichermedium kann die Auszahlung verhindern; dann wird kein nicht gespeicherter Goldbonus im Spiel angezeigt. Die Sicherung bleibt lokal auf dem Handy, nicht in einer Cloud. Beim Löschen der App-Daten gehen lokale Spielstände verloren.

Die beiden automatischen Godot- und Python-Testläufe müssen für jeden neuen Commit separat erfolgreich sein. Die eigentliche Bedienung nach dem Installieren auf Android muss noch praktisch getestet werden.
