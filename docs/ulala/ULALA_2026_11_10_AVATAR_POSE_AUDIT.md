# Unity Avatar pose audit — DLY vs NDLY (2026-11-10)

Read-only follow-up to `ULALA_2026_11_10_BINDPOSE_CROSSCHECK.md`. Technical metadata only; no original Avatar pose vectors/matrices or game assets are distributed.

## Method

Unpacked the original reference `1869_dly.prefab_ab_shared`, `1917_ndly.prefab_ab_shared` and `1857_beryl.prefab_ab_shared` using UnityFS LZ4. Parsed Unity SerializedFile v21 class 90 `Avatar` using its serialized TypeTree; nested arrays were handled with child/parent 4-byte alignment. All three inspected Avatar object bodies were consumed exactly to their serialized byte boundaries, with no parser errors.

Per-array measurements:

| Avatar | object bytes | AvatarSkeleton nodes | AvatarSkeleton IDs | AvatarSkeletonPose items | DefaultPose items | SkeletonNameID items | TOS entries |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| DLYAvatar | 33860 | 155 | 155 | 155 | 155 | 155 | 155 |
| NDLYAvatar | 33868 | 155 | 155 | 155 | 155 | 155 | 155 |
| BerylAvatar | 12704 | 59 | 59 | 59 | 59 | 59 | 59 |

## Per-index DLY ↔ NDLY pose comparison

Byte-for-byte SHA256 comparisons were made over each independently consumed serialized pose-array element (the original pose bytes are *not* included here).

| Array | Equal index elements | Different index elements |
| --- | ---: | --- |
| `m_AvatarSkeletonPose` | 153 / 155 | 150, 154 |
| `m_DefaultPose` | 153 / 155 | 150, 154 |

Thus the two Avatar objects share an equal number of serialized skeleton pose entries and their per-index serialized payloads agree for 153 entries; **two entries differ** in each pose array. The 8-byte difference in total serialized Avatar object size is consistent with variation elsewhere but by itself does not identify a cause.

**Limits:** Equal index bytes are evidence for serialized pose equality at those positions, *not* proof that Avatar skeleton name/parent mappings are identical. The differing indices are **not yet mapped to specific bones**. This check does not prove that the dly/ndly weapon-hand bindpose discrepancy is caused by either index, nor that Godot 4.7.2 character rigs match the Avatars.

## Further verification (2026-11-10)

The two differing indices have now been identified by `m_SkeletonNameIDArray` and `m_TOS`. Their ordering is reversed across variants: DLY index 150 = shoes and 154 = weapon; NDLY index 150 = weapon and 154 = shoes. For the same named equipment category, shoe poses match exactly and weapon poses differ only in translation (maximum absolute coordinate difference 0.078783493 Unity units). See [the detailed resolution](ULALA_2026_11_10_AVATAR_INDEX_RESOLUTION.md). The earlier per-index mismatches do not indicate two changed biological skeletal bones.

## Next validation

1. Decode `m_AvatarSkeleton.m_Node` parent indices and `m_SkeletonNameIDArray` against `m_TOS` to name the two differing entries.
2. Numerically compare per-index position/rotation/scale without publishing original proprietary pose arrays.
3. Compare against mapped `SkinnedMeshRenderer.m_Bones` and original Mesh bindposes.
4. Export real Titan Legends Godot `Skeleton3D` inventories for all twelve classes; run independent authoring/runtime tests.

Do not copy original third-party Avatar rigs or clips into Titan Legends.
