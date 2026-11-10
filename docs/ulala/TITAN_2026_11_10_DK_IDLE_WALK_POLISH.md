# Titan Legends — original Death Knight locomotion polish (Godot 4.7.2)

## Scope

Add a restrained original Death Knight Idle/Walk motion to the imported 24-bone character without modifying original GLB files, default character rest poses, Attack/Hit/Dodge action data, sockets, combat stats or other 11 classes.

Files:
- `scripts/animation/death_knight_locomotion_polish.gd`: duplicates the instance's default `AnimationLibrary`, then replaces **only** a private copy of the imported Idle/Walk clips with added `Shoulder_R`, `Shoulder_L` and `Chest` rotation tracks.
- `scripts/chibi_glb_visual.gd`: applies the override only to class index 11 after the original Death Knight 24-bone model imports. Failure is nonfatal; original animation remains available.
- `tests/test_death_knight_locomotion_polish.gd`: samples the beginning and quarter phase of both clips to assert new shoulder motion, checks loop return, Attack/Dodge presence, track count and instance-local library isolation.
- `.github/workflows/animated-equipment-visual-qa.yml`: runs this test on a real xvfb/Mesa OpenGL renderer rather than Godot's dummy renderer.

## Original animation controls

Each action's active tail interval is used: 1.4 seconds Idle, 1.1 seconds Walk. Shoulder rotations are paired and opposite in phase; Chest uses small breathing/lean motion. The 0 and 100% boundaries return to the neutral pose. No new material, asset or outside-game motion source is used.

Idle shoulder amplitude ~0.07 radians (4.0°), Chest ~0.022 radians (1.3°).
Walk shoulder amplitude ~0.28 radians (16.0°), Chest ~0.035 radians (2.0°).

These amplitudes describe the **authored extra local rotation tracks**, not proof of their total visual effect or real-device motion blur. Animation frames are composed with existing GLB poses.

## Verification

The standalone 2-action motion test reached its PASS marker in headless tests, but the headless dummy renderer produced material teardown errors. The test was moved to the existing OpenGL rendering CI, where `Verify Death Knight Idle Walk polish with real OpenGL renderer` **passed** in workflow run [42763466540](https://github.com/xynewageyx/TitanLegend/actions/runs/42763466540).

The separate headless `Titan Skeleton Bridge Smoke` and 12-class grip test still pass; 144/144 grip-to-socket samples were previously verified.

## Remaining visual work

- Inspect full 4-hero formation images for weapon overlap and clipping (work included in this branch, screenshots only valid after visual workflow completes).
- Compare the original and new Death Knight Idle/Walk frames at fixed camera framing.
- Verify actual Android performance and gameplay-scale appearance.

No original Ulala/Unity content is imported.
