# 12-class visual QA: 4-hero formation and original Death Knight locomotion

Date: 2026-11-10. This documents original Titan Legends Godot 4.7.2 content, not Ulala game assets.

## Successful verified GitHub run

- [GitHub Actions 42764316137](https://github.com/xynewageyx/TitanLegend/actions/runs/42764316137), conclusion: **success**
- Artifact: `TitanLegends-Rarity-Silhouette-V2-Visual-QA`, ID `13739176942`
- ZIP verified: `72` full-resolution PNG images and `manifest.json`; manifest reports `68` individual captures, of which **four** are the combined formation; four additional summary/contact sheets.
- Formation captures: `formation_mythic_idle.png`, `formation_mythic_walk.png`, `formation_mythic_attack.png`, `formation_mythic_dodge.png`.
- Manifest reports `weapon_anchors: 4` on each formation capture, verified before screenshots were saved.

## Actual four-hero battle configuration

The isolated QA team uses:
- Krieger, Magier, Todesritter, Druide (`class_ids=[0,6,11,2]`)
- Roles: tank, damage, damage, healer (`role_ids=[0,1,1,2]`)
- Rarity-5 procedural weapons and chest armor for all four, with their original imported Godot GLBs and passive pet visuals.
- Animated source clips were sampled in Idle, Walk, Attack and Dodge, all under the same Godot/Mesa OpenGL compatibility renderer used by the established visual pipeline.

**Camera observation:** The first camera at `Vector3(0,4.2,14)` hid most of the rear two heroes behind the front row. An elevated view at `Vector3(0,10,12)`, looking at `Vector3(0,1.2,0)`, makes all four character bodies distinct in the captured images. This was confirmed by viewing the four screenshots, not merely by checking existence.

The high camera is a **QA-only** choice and does not change gameplay camera settings.

## Death Knight 24-bone Idle Walk motion

- `scripts/animation/death_knight_locomotion_polish.gd` duplicates an imported `AnimationLibrary` instance-locally before adding 3 rotation tracks per action for `Shoulder_R`, `Shoulder_L`, `Chest`.
- Only `Idle` and `Walk` are altered, and only when `class_index=11`; Attack/Hit/Dodge, sockets and source GLB are unaffected.
- The independent OpenGL test in the successful visual CI run passed `actions=2 added_tracks=6 original_glb_unchanged=true`.
- Previously problematic headless dummy renderer printed `Parameter "material" is null` on the isolated test fixture. Running the fixture on real OpenGL and removing its extra source-GLB instantiation resolved the issue without suppressing rendering errors.

## Limits and follow-up

- A passing weapon-to-socket check does not prove zero mesh clipping at the fingertips or through large armor/weapon surfaces.
- The pictured formation exposes that passive pets and high-rarity outlines can still visually compete with characters at a 720×1280 portrait viewpoint.
- This is a Linux xvfb/Mesa capture, **not** verified on an Android phone.
- All seven GitHub checks for commit `6e4cd0fff0b682fed8a23933ade65e18ac456e19` completed successfully: Python Regression, Titan Core Regression, modular equipment, Skeleton3D inventory, Skeleton Bridge, OpenGL visual QA and Godot project validation.

The proprietary Ulala source assets were not copied, imported or redistributed.
