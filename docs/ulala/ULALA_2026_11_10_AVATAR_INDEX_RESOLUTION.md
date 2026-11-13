# DLY/NDLY Avatar index resolution — 2026-11-10

Read-only technical metadata analysis, no proprietary model/pose arrays, textures or clips included.

## What changed compared to the initial index-only comparison

The `m_AvatarSkeleton.m_ID` and `m_SkeletonNameIDArray` entries were decoded for 155 Avatar nodes in each of `DLYAvatar` and `NDLYAvatar`. The IDs were resolved against each Avatar's `m_TOS` hash-to-transform-name map. All corresponding pose arrays were consumed to their exact original serialized boundaries (33,860 bytes and 33,868 bytes).

The six final indices are **not interchangeable by array index**:

| index | DLY name | NDLY name |
|---|---|---|
| 149 | FS_Body | NDLY_Body |
| 150 | DLY_PuGongYing_Shoes | NDLY_PuGongYing_Weapon |
| 151 | DLY_PuGongYing_Bracers | NDLY_PuGongYing_Bracers |
| 152 | DLY_PuGongYing_Clothes | NDLY_PuGongYing_Clothes |
| 153 | DLY_PuGongYing_Hair | NDLY_PuGongYing_Hair |
| 154 | DLY_PuGongYing_Weapon | NDLY_PuGongYing_Shoes |

Both avatars contain 155 name IDs, 155 skeleton nodes and 155 poses; **149/155 name IDs match at the same indices**, while **153/155 pose entries are byte-identical at the same indices**. The discrepancy in pose indices 150 and 154 is substantially explained by the exchange of weapon/shoes ordering.

### Semantic comparison after resolving IDs to names

- Shoes: DLY index 150 vs NDLY index 154: all ten serialized TRS float32 components are **bit-identical**.
- Weapons: DLY index 154 vs NDLY index 150: identical quaternion and scale components, translation-only difference.
- Weapon translation delta NDLY minus DLY: `(+0.013246238, +0.078783493, -0.004377762)` Unity units (rounded).
- Maximum absolute TRS component discrepancy in weapon comparison: **0.078783493**; no additional rotation/scale difference in the Avatar rest-pose values.
- The earlier ~87.22° rotation was obtained comparing Mesh bindpose against a calculated Prefab rest transform, **not** by comparing DLY weapon vs NDLY weapon Avatar poses. These are different comparisons.

### Interpretation

It is **incorrect** to report indices 150 and 154 as the same bone across DLY and NDLY. The resolved objects are shoe and weapon attachment/model nodes, not evidence that a finger bone's Avatar pose changed.

The weapon-position difference is consistent with the independently reported ~0.08 Unity-unit difference in the weapon-hand bindpose comparison. This is a correlation, not a causal proof; authoring offset and original rig architecture remain to be checked.

## Evidence and next work

The mapping was verified using real `Avatar` class-90 payload bytes from `1869_dly.prefab_ab_shared` and `1917_ndly.prefab_ab_shared`; CRC32 on the textual TOS entries agrees with the stored name IDs for the changed nodes. No original pose matrices are reproduced in this document.

Next: connect identified weapon-specific Avatar node poses to the corresponding SkinnedMeshRenderer root-bone and renderer-to-mesh transforms, and independently inspect the actual Godot Skeleton3D GLBs. No Godot retargeting compatibility or animation playback is established.
