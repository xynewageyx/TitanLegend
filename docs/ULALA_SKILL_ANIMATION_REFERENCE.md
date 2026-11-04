# Ulala animation reference: verified extraction and Godot implementation guidance

Date: 2026-11-04. Metadata-only technical analysis. Do not redistribute third-party assets.

## Source
The nine-part `ulala_backup.7z.001`–`.009` archive was assembled and opened locally. Seven UnityFS reference bundles (Unity 2019.4.16f1c1) were extracted, their LZ4 payload blocks decoded, and their serialized type names inspected.

| Bundle | UnityFS bytes | Decompressed payload bytes | Confirmed metadata |
|---|---:|---:|---|
| male@n_idle_common.anim_ab | 29114 | 73820 | AnimationClip schema; n_idle |
| female@n_idle_common.anim_ab | 41085 | 100800 | AnimationClip schema; n_idle |
| male@n_hitidle_common.anim_ab | 209014 | 316640 | AnimationClip schema; n_hitidle |
| female@n_hitidle_common.anim_ab | 303863 | 438916 | AnimationClip schema; n_hitidle |
| ck.overridecontroller_ab | 3537 | 7784 | AnimatorOverrideController and AnimationClip schema names |
| tx_cike_attack_release.prefab_ab | 2751 | 7519 | attack-labelled skill prefab |
| tx_deluyi_zhiyu_release.prefab_ab | 1694 | 4515 | zhiyu-labelled skill prefab |

These are *type metadata and name checks*, **not** decoded keyframes, clip lengths, animation bindings, or confirmed visual appearance.

## Original Titan Legends implementation plan
- Keep distinct idle, cast anticipation, release, impact, hit and recovery phases.
- Reuse existing procedural `HeroCombatMotion` poses and `skill_vfx_3d_v1.gd` for Godot 4.7.2 Android.
- Distinguish tank, damage and healer cast silhouettes; give each of the 11 classes original movement accents.
- Keep visual timing independent of combat: strict four-slot skill rotation, charged interrupts, one primary effect per skill and lowest-HP-percent single heal remain unchanged.
- Prefer shared meshes, unshaded materials, capped simultaneous VFX and no extra real-time lights.

## Unverified / follow-up
1. Decode SerializedFile v21 AnimationClip object tables and exact clip names/path IDs.
2. Decode curves and keyframe times; identify actual animated transform paths.
3. Resolve `ck.overridecontroller_ab` PPtr references and their external dependencies.
4. Decode skill prefab hierarchy and exact release/impact links.
5. Create original Godot motion timings based on verified structural principles only.

The original proprietary binary files must remain outside this repository.
