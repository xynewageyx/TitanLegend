# Godot 4.7.2 — actual twelve-class Skeleton3D rest hierarchy audit

Source: GitHub Actions artifact `titan-skeleton3d-inventory` from [successful export run 42758320173](https://github.com/xynewageyx/TitanLegend/actions/runs/42758320173), artifact ID `13735864841`. The artifact includes `skeleton3d_inventory.json`, `skeleton3d_validation.json`, `twelve_class_rig_coverage.json` and animation metadata. The inventory was downloaded and compared independently on 2026-11-10.

## Verified current skeletons

- **12/12 class GLB skeletons present:** 11 standard 8-bone rigs and one 24-bone `death_knight.glb`.
- **11/11 standard 8-bone rigs have exactly identical exported bone metadata**, including name, parent/index and full Float32 rest origin/basis. Standard bones: `Root`, `Hips`, `Spine`, `Head`, `Arm_L`, `Arm_R`, `Leg_L`, `Leg_R`.
- **Death Knight:** shares those eight *names*, but is **not** a rest-pose/hierarchy-compatible 8-bone clone. It adds `Chest` and `Neck`; `Head` is parented to `Neck`, and `Arm_L`/`Arm_R` are parented to `Chest` instead of `Spine`. The local rest matrices for `Head`, `Arm_L`, `Arm_R`, `Leg_L` and `Leg_R` differ from the standard rig; `Root`, `Hips`, `Spine` match.
- Death Knight extras: `Shoulder_L/R`, `UpperArm_L/R_2`, `Forearm_L/R_2`, `Hand_L/R_2`, `UpperLeg_L/R_2`, `LowerLeg_L/R_2`, `Foot_L/R_2`. The notation here groups left and right variants; actual bone names use e.g. `Hand_R_2`.
- The non-class `assets/characters/titan_warrior.glb` contains a separate **7-bone** rig and is **not** one of the 12 playable imported GLBs.
- The non-class prototype `scenes/character/titan_modular_character.tscn` contains an intentionally empty `Skeleton3D` which requires a targeted exception in the generic skeleton validator; this is not an error in the class GLBs.
- The exported inventory has **14 total Skeleton3D nodes, 119 bones**, and zero exporter warnings (88 standard-class bones + 24 Death Knight bones + 7 legacy bones = 119).

## Actual equipment socket mapping (current Godot implementation)

The existing `scripts/equipment/chibi_imported_equipment_sockets.gd` selects `Arm_R`/`Arm_L` for standard-class right/left hand sockets (there are **no `Hand_R`/`Hand_L` bones** in their 8-bone GLBs). On the Death Knight it selects the more detailed `Hand_R_2`/`Hand_L_2`, plus its `Chest`, forearm and foot bones. The socket helper compensates rest orientation via its child `EquipmentAnchor` rather than rewriting original rest poses.

These are *different attachment strategies*, and the current eight-bone standard rig cannot be assumed to support individual wrist/hand animation independent of the arm.

## Reproducible automated checks

- `tools/audit_titan_twelve_rigs.py`: presence and nonempty class inventory.
- `tools/audit_titan_rig_pose_compatibility.py`: canonical 8-bone metadata, topology and rest-pose divergence plus required socket-bone presence on all 12 imported class GLBs.
- The workflow `.github/workflows/export-skeleton3d-inventory.yml` creates `build/twelve_class_pose_compatibility.json` and includes it in the artifact.

## Safety and limitations

This uses **original Titan Legends Godot GLBs** and *structural* comparisons only. Unity Avatar poses or clips are not imported. Passing metadata tests does **not** prove animation retargeting, visual weapon grip alignment, performance or runtime usability on Android.
