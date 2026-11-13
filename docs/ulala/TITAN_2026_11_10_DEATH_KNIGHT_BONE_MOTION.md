# Original Titan Legends animations: actual bone motion audit (2026-11-10)

## Evidence

- The Godot 4.7.2 export [run 42761873577](https://github.com/xynewageyx/TitanLegend/actions/runs/42761873577) completed successfully, and its `titan-skeleton3d-inventory` ZIP contains `twelve_class_bone_motion.json` with **48 rows and zero errors**.
- Measured 12 original imported hero GLBs × four original Godot clips (`Idle`, `Walk`, `Attack`, `Dodge`). Five samples per action in the clip's active tail window, comparing per-bone global pose to the first sample; values are **maximum relative sampled translation and rotation**, not instantaneous joint angles or visual collision distances.
- All eleven eight-bone standard class GLBs produced the same motion measurements in the measured roles/actions.

| Action | Standard `Arm_R` rotation | DK `Hand_R_2` rotation | DK `Hand_R_2` position delta |
| --- | ---: | ---: | ---: |
| Idle | 2.642° | 0.000° | 0.00000 |
| Walk | 29.331° | 3.532° | 0.02907 |
| Attack | 77.676° | 62.145° | 0.18977 |
| Dodge | 22.016° | 19.437° | 0.15868 |

### Crucial bone-chain breakdown

- Death Knight **Attack**: `Hand_R_2` and `Forearm_R_2` each undergo approximately 62.145° of sampled world-pose rotation. In the inspected sample window, `Arm_R`, `Spine` and `Chest` show no significant rotation. This means the attack is **not static**, but the movement is concentrated in the extended hand/forearm chain.
- Death Knight **Walk**: `Arm_R` and `Hand_R_2` each move only ~3.532°, far below the standard right-arm walk change (~29.331°). Hands translate by ~0.02907.
- Death Knight **Idle**: right hand and forearm appear static in sampled positions; head rotates only ~0.224°. This is a promising candidate for original subtle breathing/weight-shift animation.
- Death Knight **Dodge**: `Spine`, `Chest`, `Arm_R`, `Hand_R_2` all rotate ~19.437° in world pose. This need not indicate independently animated joints—parent motion can carry descendants.
- The standard classes' 2D picture differences are larger in the previously measured camera view, but the Death Knight's 62.145° hand attack proves visual similarity is **not** evidence of a missing attack animation.

## Regression protection

- `tools/export_twelve_class_bone_motion.gd` captures these measurements on every relevant Godot skeleton workflow run.
- `tools/analyze_twelve_class_bone_motion.py` verifies presence of all 48 action profiles and minimum DK hand movement in `Attack` (>= 20° and >= 0.03 displacement); small `Idle` and `Walk` movement is a documented advisory, not an error.
- `tests/test_analyze_twelve_class_bone_motion.py` checks successful coverage, missing actions, completely static attack detection and advisory handling.

## Next improvement, without altering gameplay

Design independent *original* Death Knight idle breathing/shoulder sway and a clearer walk arm swing for the 24-bone rig. Validate against existing equipment grip tests, pose metrics and real rendered front/side views. Do not blindly rotate `Arm_R` or replace the `Hand_R_2` socket; this can distort existing weapon alignments.

This is a *Godot original* metadata + runtime sample audit. It does not validate Ulala/Unity animation transfer, clipping/collision-free silhouettes or real Android performance.
