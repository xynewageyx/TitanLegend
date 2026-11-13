# Titan Legends — Originale Bosskamera, Vierer-Team und echte Boss-Warnanimation

Datum: 2026-11-12. **Erfolgreicher CI-Lauf:** https://github.com/xynewageyx/TitanLegend/actions/runs/43248060128

## Umfang und Grenzen

- Der QA-Renderer `tools/render_boss_gameplay_camera_qa.gd` verwendet tatsächlich `scripts/camera_follow.gd` mit **aktivem Bosszweig**, vier originale GLB-Helden, die gleichen Team- und EnemySpawn-Positionen wie `scenes/main.tscn`, Seltenheit-5-Waffen und Brustpanzer, sowie `scripts/boss_art.gd` und `scripts/boss_motion.gd`.
- Zwei Original-Bossvarianten: Feuerboss (`element=0`, `scale=0.63`) und fusionierter Erdboss (`element=2`, `scale=0.61`).
- Die zwei echten 3D-Szenenzustände je Variante sind normale Bosspräsenz und die durch `attack_windup()` ausgelöste Warnphase. Vier PNG-Aufnahmen: `boss_fire_idle.png`, `boss_fire_windup.png`, `boss_earth_idle.png`, `boss_earth_windup.png`.
- **Das Boss-HP-/Countdown-Overlay ist eine ausdrücklich gekennzeichnete QA-Vorschau**, nicht das produktive `ui_manager.gd`-HUD. Der Test behauptet deshalb **keine** geprüfte vollständige HUD-Integration, echte Kampfzeitentwicklung oder reales Android-Gerät.
- Linux xvfb/Mesa, Godot 4.7.2, 720×1280. Keine proprietären Ulala-Modelle oder Clipdaten wurden übernommen.

## Messwerte aus dem echten CI-Artefakt

| Kriterium | Feuerboss | Fusionierter Erdboss |
| --- | ---: | ---: |
| Boss-Silhouette im Kamerabild | 100 % der projizierten AABB | 100 % |
| Vier Helden im Kamerabild | 4/4, je 100 % | 4/4, je 100 % |
| Boss-Silhouette (Pixel-Bounding-Box) | ca. 116 × 178 | ca. 176 × 180 |
| Kamerasichtfeld | 56° | 56° |
| 3D-Warnring aktiv | ja | ja |
| Veränderte Pixel ausschließlich durch 3D-Warnanimation, **ohne HUD-Warntext** | **7.976** | **7.562** |

Der Warnring-Bildunterschied wird zwischen eingefrorenen Boss-Idle- und Windup-Bildern gemessen, bevor die Warntextbeschriftung sichtbar wird. Es gilt ein RGB8-Kanalschwellwert von 24/255. Neben dem Ring können weitere durch `BossMotion._process` veränderte Bossoberflächen zum Pixelunterschied beitragen. Der Wert ist **nicht** identisch mit der sichtbaren Ringpixelzahl.

## Regression

- `tools/boss_camera_qa_state.gd` stellt für den isolierten QA-Aufbau den aktiven Bosszustand bereit. Der produktive Kampfmanager bleibt unverändert.
- `tools/check_boss_gameplay_camera_report.py` validiert die echte Kamera, Bossmodelle, vier Helden, Warnphase, Dateinamen, Mindestgröße sowie mindestens 20 geänderte Bildpixel ohne HUD-Warntext.
- `tests/test_check_boss_gameplay_camera_report.py` enthält sechs Tests: Erfolgsfall und Fehlerfälle bei inaktivem Ring, nicht sichtbarem Ring, abgeschnittenem Helden, falscher HUD-Behauptung und zu kleinem Boss.
- Der GitHub-OpenGL-Workflow liefert **98 PNGs** (94 bisherige Ausrüstungs-/Kamerabilder plus vier Bossbilder) sowie die JSON-Berichte; `boss_camera_report.json` ist Bestandteil des Artefakts `TitanLegends-Rarity-Silhouette-V2-Visual-QA` (ID `13957631856`).
- **Alle sieben GitHub-Workflows auf Commit `bddbf1140d4489f2beab2ea137ecc57f691c0373` erfolgreich.**

## Ergebnisse und weitere Arbeiten

Die Kamera zeigt Boss und Vierer-Team während des normalen Bosskampfs ohne Abschneiden. Allerdings ist der Feuerboss im 720-px-Bild nur etwa 116 px breit und der Erdboss 176 px: In dieser Kamerakonfiguration ist die Bildschirmwirkung der imposanten Bosse begrenzt. Ein gezielter Boss-Größen- und Kameravergleich sollte folgen, ohne die Team-Sichtbarkeit zu verschlechtern.

**Noch offen:** reales produktives HUD inklusive Boss-HP und 60-s-Timer, Bossphase mit zwei Begleitern, tatsächliche Boss- und Heldenaktionen bei realen Kampf-Ticks und Android-GPU-FPS.
