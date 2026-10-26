# Titan Legends – Idle RPG (Godot 4.2+)

**Android-friendly playable prototype**, not a finished commercial game.

## Import on Android
1. Extract the ZIP using your phone's file manager.
2. Open the Godot Android editor, choose **Import**, select the extracted `project.godot`.
3. Open the project and press **Play**. First import may take some time.
4. The main scene is `res://scenes/main.tscn`.

## Included
- Procedural low-poly 3D environment: six biomes, changing every 100 stages (starts in Nature).
- Four heroes in fixed formation, one passive pet each, walk before each encounter.
- Automatic attacks, damage popups, nine mob waves then a boss wave.
- Gold rewards, jewel upgrades, R0–R5 reincarnation with rising ticket costs and titan scaling.
- Tabs for Combat / Jewels / Reincarnation / Shop.
- Local JSON save on startup, every minute, on pause/close, and after upgrades/waves.
- AudioManager ready for sound assets (no copyrighted audio bundled).
- AdManager **stub only**. No ads shown and no reward without a real SDK.

## Limitations
- Character and enemy meshes are procedural placeholders; no rigged animations or imported art.
- No real AdMob SDK, no in-app billing, no network features or published APK.
- Damage loop is a demonstration, not a full combat simulation; heroes do not take damage yet.
- Progress saving uses one local JSON file; no cloud backup or anti-cheat.
- Test in Godot 4.2+ before release; a Godot executable is not available in this environment.

## Scripts
`game_manager.gd`, `save_manager.gd`, `ad_manager.gd`, `audio_manager.gd`, `biome_manager.gd`, `team_formation.gd`, `battle_manager.gd`, `floating_text.gd`, `visual_factory.gd`, `ui_manager.gd`.

The code is original and provided for continued editing. For monetization, integrate a Godot-4.2-compatible AdMob plugin and a compliant purchase SDK, then use real ad unit IDs only after testing.


## Update: Kamera und mobile UI (20.10.2026)
- Camera3D folgt jetzt dem Team und blickt auf die Gegnerzone.
- HUD-Schriftgroesse und Touch-Flaechen wurden fuer Android vergroessert.
- Referenzaufloesung auf 720 x 1280 angepasst.
- Die Landschaft und Helden werden zur Laufzeit erzeugt; die lokale 3D-Editoransicht kann deshalb leer wirken.
- Godot-Projekt konnte in dieser Umgebung nicht in der Engine ausgefuehrt werden.


## Update 28 – Chat / Hochformat
- Tab-Schaltflächen mit abgeschnittenem Überlauf statt breitem HUD.
- Chat einklappbar, Knopf wechselt zwischen + und −.
- Systemmeldungen für Fähigkeiten auf maximal eine pro acht Sekunden je gleichbleibender Fähigkeit begrenzt.
- Menüdialoge verwenden 84 % der Bildschirmbreite statt einer festen Breite.
- Nachrichten in Welt, Team und Gilde sind noch kein echter Online-Chat; keine Netzwerkverbindung vorhanden.
