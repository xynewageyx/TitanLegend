# Titan Legends – Update 42: Bossbewegungen

- Neuer BossMotion-Controller für schwebende, pulsierende Körperteile der zehn Elementartitanen.
- Angriffs-Vorbereitungsanimation mit kurzem Aufladen vor der Spezialattacke.
- Intensivere Bewegungen unter 35 % Boss-LP und bei Fusionstitanen.
- Bestehende Boss-Wutphase, Boss-FX, Kampfwerte, Fähigkeiten und HUD bleiben erhalten.
- Korrigierte Tween-Aufrufe in boss_abilities.gd: MeshInstance3D hat keine `transparency`-Eigenschaft; stattdessen wird die Skalierung animiert.
- Animationen verwenden nur einfache 3D-Meshes ohne externe Assets.

Prüfung: ZIP-Integrität und Script-Verknüpfungen geprüft. Nicht in Godot auf Android ausgeführt.
