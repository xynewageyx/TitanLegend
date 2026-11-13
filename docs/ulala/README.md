# Ulala reference metadata — Titan Legends

These files capture **abstract technical reference findings**, not transferable third-party game assets.

- [2026-11-10 skinning/bindpose crosscheck](ULALA_2026_11_10_BINDPOSE_CROSSCHECK.md)
- [Aggregated mapping status](ULALA_2026_11_10_MAPPING_STATUS.csv)
- [Avatar skeleton and pose audit](ULALA_2026_11_10_AVATAR_POSE_AUDIT.md)
- [Resolved DLY/NDLY Avatar indices and weapon/shoe ordering](ULALA_2026_11_10_AVATAR_INDEX_RESOLUTION.md)
- [Weapon renderer and hand-root-bone offset audit](ULALA_2026_11_10_WEAPON_ATTACHMENT_AUDIT.md)
- [Variant weapon anchor metadata CSV](ULALA_2026_11_10_WEAPON_ANCHORS.csv)

Earlier upstream analysis remains in `docs/ULALA_EQUIPMENT_BUNDLE_SCAN.md`, `docs/ULALA_CHARACTER_HIERARCHIES.md`, `docs/ULALA_AGGREGATED_MESH_COMPLEXITY.md` and `tools/analysis/ulala_rig_fullbody_compatibility.md`.

Numbers in this directory are sample results and do not demonstrate full Godot compatibility. Raw archived bundles, textures, animations, vertex buffers, bone matrices and other proprietary payloads are deliberately excluded.

## Titan Legends twelve-class inventory check

After running the existing `.github/workflows/export-skeleton3d-inventory.yml` workflow or exporting Godot Skeleton3D data locally, run:

```bash
python3 tools/audit_titan_twelve_rigs.py build/skeleton3d_inventory.json --output build/twelve_class_rig_coverage.json
```

The validator checks that every class, including `death_knight`, has exactly one nonempty imported skeleton under a scene filename matching its class name. It does not assess retargeting compatibility or prove that all actual character GLBs were imported. Three synthetic test cases were exercised locally while authoring the tool; a real project import remains pending.

## Verified Godot twelve-class rest poses

- [Direct audit from GitHub Actions Skeleton3D export](TITAN_2026_11_10_12_CLASS_REST_AUDIT.md)
- [Successful rest-pose and equipment-socket CI run](https://github.com/xynewageyx/TitanLegend/actions/runs/42759238280): all twelve GLBs have required socket bones; eleven standard rigs match their baseline rest pose; Death Knight 24-bone extended rig is intentionally different. Artifact: `titan-skeleton3d-inventory`, including `twelve_class_pose_compatibility.json`.

No Unity animation retargeting is claimed.

## Animated equipment verification

- [Successful 12-class weapon grip continuity test](TITAN_2026_11_10_WEAPON_GRIP_ANIMATION_TEST.md): 144 grip-to-socket samples across Idle, Walk, Attack and Dodge, run [42759744859](https://github.com/xynewageyx/TitanLegend/actions/runs/42759744859). Actual hand-to-finger alignment and Android rendering still require a visual check.

## OpenGL screenshot validation (2026-11-10)

- [Actual screenshot review: 64 scenes and four contact sheets](TITAN_2026_11_10_VISUAL_SCREENSHOT_AUDIT.md)
- [Per-class RGB differences across Attack, Walk and Dodge](TITAN_2026_11_10_VISUAL_FRAME_DIFFERENCES.csv)
- [Successful screenshot CI workflow](https://github.com/xynewageyx/TitanLegend/actions/runs/42760356033), artifact `TitanLegends-Rarity-Silhouette-V2-Visual-QA`. The Death Knight shows notably less 2D image change; camera and effects influence the metric. Visual clipping and Android performance remain unverified.

## Death Knight 24-bone action motion

- [Per-bone runtime motion measurements](TITAN_2026_11_10_DEATH_KNIGHT_BONE_MOTION.md): the original Death Knight attack hand rotates 62.145 degrees and translates 0.18977 units during sampled active clip motion; idle and walk are subtler. [Successful CI motion audit](https://github.com/xynewageyx/TitanLegend/actions/runs/42762080319). Static attack is a regression, subtle idle/walk are advisory.

## Four-hero real Godot visual QA

- [Original Death Knight Idle/Walk locomotion polish](TITAN_2026_11_10_DK_IDLE_WALK_POLISH.md)
- [Verified four-hero high-rarity formation: 4 actions, 4 weapons](TITAN_2026_11_10_FOUR_HERO_FORMATION_VISUAL_QA.md)
- [Successful OpenGL visual run](https://github.com/xynewageyx/TitanLegend/actions/runs/42764316137): 72 PNGs; four team screenshots in Idle, Walk, Attack and Dodge; camera elevated for distinct front/back row silhouettes. No real Android/GPU measurement is claimed.

## Formation screen visibility and mythic weapon geometry

- [Projected screen coverage and inter-character weapon overlap](TITAN_2026_11_10_FORMATION_SCREEN_COVERAGE.md). Successful [OpenGL CI](https://github.com/xynewageyx/TitanLegend/actions/runs/42782647069): all four imported-body AABBs fully within viewport and no projected body-body or mythic-weapon-to-other-body AABB overlap, for four selected action frames. These are static mesh bounding-box proxies and do not prove full skin deformation, per-pixel occlusion, pet/VFX visibility or Android GPU performance.

## Four-hero pets and active attack FX screen metrics

- [Measured weapon/pet/attack-flash screen coverage](TITAN_2026_11_10_FOUR_HERO_PET_FX_COVERAGE.md): all four original class bodies and passive pets are visible; maximum projected pet-to-other-body box intersection 0.6%, active attack FX 14.6%. These are **screen-space bounds proxies, not actual hidden-pixel counts or collision**.
- [Validated GitHub Actions test](https://github.com/xynewageyx/TitanLegend/actions/runs/42786662858): 72 screenshots, `manifest.json` and `formation_visibility_audit.json`; the four-pose visibility regression passed.

## Pixelbasierte Waffen-/Begleiter-/Effekt-Gegenproben

- [Bestätigte 75-Renderbilder-Pixelanalyse](TITAN_2026_11_10_PIXEL_COUNTERFACTUAL_RESULTS.md): im Attack-Frame ändern sich beim Ausblenden von Waffen 1,806 %, von Begleitern 4,778 % und von Angriffsblitzen 1,512 % aller 720×1280 Bildpixel. **Keine direkte Verdeckungs- oder Mesh-Kollisionsmessung.**
- [Methodik und Grenzen](TITAN_2026_11_10_PIXEL_COUNTERFACTUAL_QA.md) · [Erfolgreicher Pixeltest](https://github.com/xynewageyx/TitanLegend/actions/runs/42852858921)

## Tiefengeprüfte 4-Helden-Silhouetten

- [Maskenmessung mit echter OpenGL-Tiefenprüfung](TITAN_2026_11_10_DEPTH_SILHOUETTE_RESULTS.md): Waffen 0 % Körperabdeckung, Begleiter bis 0,22 %, deckende Angriffseffekte als **konservative Obergrenze** etwa 21–24 % je Charakter in der getesteten Attack-Pose.
- [Erfolgreicher Masken-CI-Lauf](https://github.com/xynewageyx/TitanLegend/actions/runs/42902300703) · 16 zusätzliche Tiefenmasken und insgesamt 91 PNGs. Transparenz und Android-Gameplay-Kamera bleiben separat zu prüfen.

## Halbtransparente Angriffsblitze (2026-11-11)

- [Bestätigter 55-%-gegen-100-%-OpenGL-Vergleich](TITAN_2026_11_11_ATTACK_FLASH_ALPHA_QA.md): 13.405 veränderte Pixel im identischen Attack-Frame, 92 PNG-Aufnahmen und zwei Berichte im [erfolgreichen GitHub-Actions-Lauf](https://github.com/xynewageyx/TitanLegend/actions/runs/43074302659). Die Transparenz betrifft nur die kosmetische magic_flash-Kugel, nicht Schaden, Waffen oder Begleiter.

## Originale Spielkamera und Linux-Framezeit (2026-11-11)

- [Echte perspektivische Kamera, Idle-Attack-Verifikation und 90-Frame-Diagnose](TITAN_2026_11_11_GAMEPLAY_CAMERA_PERFORMANCE.md): 56° FOV, alle vier Helden im Portraitbild und 30.713 veränderte Idle-Attack-Pixel, CI [43076803728](https://github.com/xynewageyx/TitanLegend/actions/runs/43076803728). Der Linux-Software-Renderer liefert ausschließlich diagnostische Framezeiten; **keine Android-FPS-Behauptung**.

## Bosskamera und Elementar-Warnringe (2026-11-12)

- [Getestete Feuer-/Erdbosse mit echtem Boss-Kamerazweig](TITAN_2026_11_12_REAL_BOSS_CAMERA_QA.md): Beide Bosse und alle vier Helden vollständig im Bild. Die originale 3D-Angriffsanimation verändert ohne HUD-Hinweis 7.976 bzw. 7.562 Pixel. [Erfolgreicher GitHub-CI-Lauf](https://github.com/xynewageyx/TitanLegend/actions/runs/43248060128), 98 PNGs. Das im Test gezeichnete Boss-HP-Overlay ist nicht das vollständige produktive HUD.

## Bosskamera – 12. November 2026

- [Boss-Framing-Audit mit Feuerboss und Erd-Fusionsboss](TITAN_2026_11_12_BOSS_CAMERA_FRAMING_AUDIT.md). Realer CameraFollow-Bosszwei­g, 4/4 Helden und beide Bosse vollständig im Bild; tatsächliche Bosswarnungs-Bewegung gemessen. Die Bossanzeige ist eine QA-Testanzeige, noch nicht der produktive UIManager.
- [Verschärfter CI-Test erfolgreich](https://github.com/xynewageyx/TitanLegend/actions/runs/43275726886): Abbruch bei Boss-/Heldencrop, Warnobjekt hinter Kamera oder zu geringem Abstand zwischen Bosswarnung und Frontreihe.

## Bosskamera mit produktiven UIManager-Widgets (2026-11-12)

- [Echtes UIManager-Widgetlayout in Feuer- und Erd-Fusionsboss-Screenshots](TITAN_2026_11_12_REAL_HUD_BOSS_CAMERA_QA.md): Produktions-Bosslebensbalken, Countdown, Chat, Ressourcen und Navigation werden verwendet; Kampfwerte stammen ausdrücklich aus der isolierten QA-Szene. Der Test meldet nun auch Kollisionen zwischen Boss und Boss-HUD sowie hinterer Teamreihe und Chat. [Erfolgreicher OpenGL-Test](https://github.com/xynewageyx/TitanLegend/actions/runs/43278930970).
