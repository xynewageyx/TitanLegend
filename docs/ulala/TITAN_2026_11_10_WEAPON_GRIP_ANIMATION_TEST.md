# Original Titan Legends weapon grip — animated 12-class runtime verification

Date: 2026-11-10. Scope: **original Godot GLB animations**, not Ulala clips or animation retargeting.

## Verified GitHub Action
[Run 42759744859](https://github.com/xynewageyx/TitanLegend/actions/runs/42759744859) — `Titan Skeleton Bridge Smoke` — **success**.

The new `tests/test_chibi_weapon_animation_grip.gd` loaded all twelve class scenes under `assets/heroes/chibi/`, initialized actual `ChibiGLBVisual` and the same imported equipment adapter as the game, equipped a rarity-5 weapon and drove the actual Godot `AnimationPlayer` for:

- Idle
- Walk
- Attack
- Dodge

For each of 12×4 combinations, the test sampled three time positions in the selected clip's active tail window (**144 samples total**). At each sample it forced bone updates and compared the weapon's authored grip point with the live right-hand `EquipmentAnchor` using a tolerance of 0.001 Godot units.

**Result:** 144/144 samples passed the grip-to-anchor continuity assertion. No duplicate or missing weapon attachment was detected during initialization. All twelve expected animation clips were present with at least one track.

## Variant-specific socket choices

- Eleven eight-bone class GLBs: `RightHandSocket` attaches to `Arm_R` because these rigs do **not** have a separately animated wrist or hand bone.
- Death Knight's 24-bone GLB: `RightHandSocket` attaches to `Hand_R_2`.

## What is still not proven

The test checks that weapon grip remains at the *chosen bone socket*, **not** that the socket is visually aligned with the character's fingers throughout each animation, that the weapon avoids mesh clipping, or that the clips produce visible motion in every sampled section. It is a headless Godot test, not an Android screenshot or real-device performance check.

No third-party reference animation or bindpose was imported or copied.
