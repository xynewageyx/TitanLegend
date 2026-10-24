# Titan Legends – In-App AFK-Farming (Update 200)

## Unterschied zwischen AFK und Offline

- **Offline-Farming:** Spiel verlassen bzw. pausiert, nach mindestens 5 Minuten Abwesenheit maximal 8 Stunden **Gold + XP**, mit Zeitstempel im Spielstand. Keine Bosse, kein Stage-Wechsel.
- **In-App AFK-Farming:** Spiel bleibt offen und wird **5 Minuten nicht bedient**. Der automatische Kampf wechselt auf wiederkehrende **normale Mobwellen derselben Stage**. Keine Bosse oder neue Stages. Auszahlungen erfolgen **höchstens einmal je 60 Sekunden**, jeweils nach besiegter AFK-Mobwelle, und werden sofort gespeichert.
- **Aktives Spielen:** Auf eine Touch-, Maus- oder Tastatureingabe endet der AFK-Modus; der normale Kampffluss auf dem gespeicherten Stage-/Wellencheckpoint wird wieder aufgenommen.

## Regeln

1. Timer läuft mit `Time.get_ticks_msec()` (monotone Zeit, nicht manipulierbare Systemuhr).
2. Der Fünf-Minuten-Trigger ist nur im Weltkampf verfügbar, **nicht** in der Astralprüfung und **nicht** während Android pausiert ist.
3. Beim Wechsel zu AFK wird ein laufender Bosskampf **abgebrochen**, nicht gewonnen, und durch reguläre Mobs ersetzt. Der Bosscheckpoint (z. B. Stage 10, Welle 10) bleibt gespeichert.
4. Die XP-Berechnung nutzt dieselbe `experience_system.gd`-Funktion wie normale aktive Mobwellen. Die Goldbelohnung beträgt **50 × aktuelle Stage**. Die Berechnung wird maximal auf Stage 1200 begrenzt.
5. Ist der AFK-Gegner besiegt, wird bis zum 60-Sekunden-Auszahlungstakt gewartet. Ohne besiegte Mobwelle gibt es keine Belohnung.
6. Die drei Talentpunkte pro zusätzlichem Charakterlevel werden weiterhin indirekt über `TitanTalentSystem.points_available(character_level)` bereitgestellt.
7. Im HUD erscheint ein **AFK-FARMING**-Hinweis; Gold und XP werden im lokalen System-Chat protokolliert.
8. Bei Rückkehr per Touch/Maus/Tastatur und nach dem Fortsetzen aus dem Android-Hintergrundmodus endet das AFK-Farming. Der nächste reguläre Encounter darf wieder ein Boss sein.

## Grenzen und Spielstand

AFK-Auszahlungen werden mit `SaveManager.save_game()` atomisch lokal gesichert. Die bereits vorhandenen lokalen Spielstand-Backups bleiben erhalten. Das AFK-System vergibt keine Boss-Drops, Reinkarnationspunkte, Stages oder Astralmarken. Es ersetzt kein echtes cloudbasiertes AFK-Farming nach einer Deinstallation.

**Test:** `godot --headless --path . --script res://tests/test_afk_farming.gd` prüft 5-Minuten-Schwelle, 60-Sekunden-Limit, Boss-Ausnahme, Gold/XP und Rückkehr zum Bosscheckpoint. CI-Workflow: [Godot validation](https://github.com/xynewageyx/TitanLegend/actions/workflows/godot-validate.yml).
