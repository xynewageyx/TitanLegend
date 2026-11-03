# Additional equipment UnityFS scan (2026-11-03)

Fifteen distinct local equipment bundles were successfully decompressed and their SerializedFile headers checked. These are original third-party reference bundles; **only metadata is documented here**, not redistributed assets.

| Equipment family | Number of inspected bundles |
| --- | ---: |
| Hair | 5 |
| Clothes | 2 |
| Shoes | 2 |
| Weapon | 3 |
| Subweapon | 2 |
| Bracers | 1 |
| **Total** | **15** |

Inspected file names:

- `ck_chushi_hair.prefab_ab`, `ck_chushi_hair.prefab_ab_shared`
- `ck_dujiaoxing_clothes.prefab_ab`, `ck_dujiaoxing_clothes.prefab_ab_shared`
- `ck_dujiaoxing_hair.prefab_ab`, `ck_dujiaoxing_hair.prefab_ab_shared`
- `ck_dujiaoxing_shoes.prefab_ab`, `ck_dujiaoxing_shoes.prefab_ab_shared`
- `ck_dujiaoxing_subweapon.prefab_ab`, `ck_dujiaoxing_weapon.prefab_ab`
- `ck_lang_hair.prefab_ab`, `ck_lang_subweapon.prefab_ab`, `ck_lang_weapon.prefab_ab`
- `dly_dajiaolu_weapon.prefab_ab`, `dly_pugongying_bracers.prefab_ab`

All 15 files are UnityFS bundles containing Unity SerializedFile version **21**. The count of TypeTree type declarations ranges from **5 to 7**. This scan confirms successful block decompression and readable headers; it does **not** yet identify attachment bones, mesh contents, material properties, or compatibility with the game's own character rig.

Next: parse object directories and PPtr references, compare each main bundle to its `_shared` counterpart, and record only high-level structural insights. Do not copy the original meshes, textures, rigs, animations, or other proprietary content into Titan Legends.

## Parsed SerializedFile object directories (2026-11-03)

A local Python decoder decompressed all 15 selected UnityFS bundles and traversed the actual SerializedFile v21 object directories (not just TypeTree definitions). Each object's type index and byte range were validated. **All 15 decoded without parser errors; 3,097 object records total, including 1,508 GameObjects.**

| Bundle | Objects | GameObject (1) | Transform (4) | SkinnedMeshRenderer (137) | Mesh (43) | Avatar (90) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `ck_chushi_hair.prefab_ab` | 141 | 69 | 69 | 1 | 0 | 0 |
| `ck_chushi_hair.prefab_ab_shared` | 143 | 69 | 69 | 1 | 1 | 1 |
| `ck_dujiaoxing_clothes.prefab_ab` | 135 | 66 | 66 | 1 | 0 | 0 |
| `ck_dujiaoxing_clothes.prefab_ab_shared` | 137 | 66 | 66 | 1 | 1 | 1 |
| `ck_dujiaoxing_hair.prefab_ab` | 163 | 80 | 80 | 1 | 0 | 0 |
| `ck_dujiaoxing_hair.prefab_ab_shared` | 165 | 80 | 80 | 1 | 1 | 1 |
| `ck_dujiaoxing_shoes.prefab_ab` | 163 | 80 | 80 | 1 | 0 | 0 |
| `ck_dujiaoxing_shoes.prefab_ab_shared` | 165 | 80 | 80 | 1 | 1 | 1 |
| `ck_dujiaoxing_subweapon.prefab_ab` | 327 | 160 | 160 | 2 | 1 | 1 |
| `ck_dujiaoxing_weapon.prefab_ab` | 327 | 160 | 160 | 2 | 1 | 1 |
| `ck_lang_hair.prefab_ab` | 327 | 160 | 160 | 2 | 1 | 1 |
| `ck_lang_subweapon.prefab_ab` | 327 | 160 | 160 | 2 | 1 | 1 |
| `ck_lang_weapon.prefab_ab` | 327 | 160 | 160 | 2 | 1 | 1 |
| `dly_dajiaolu_weapon.prefab_ab` | 23 | 8 | 8 | 2 | 1 | 1 |
| `dly_pugongying_bracers.prefab_ab` | 227 | 110 | 110 | 2 | 1 | 1 |

These are **actual object records**, but GameObject/Transform counts do not prove distinct bones or visible submeshes. The presence of Mesh/Avatar objects in shared or combined bundles suggests dependencies or self-contained rigs, but exact attachments require decoding `SkinnedMeshRenderer.m_Bones`, `m_RootBone`, `m_Mesh` and the external references.

The local metadata-only machine-readable output is `ulala_equipment_object_counts.json`; original proprietary asset payloads were not committed.

## Cross-check of main and shared bundle object inventories (2026-11-03)

Recomputed from the locally saved `ulala_equipment_object_counts.json` object-directory results, rather than inferring from filenames alone:

| Pair | Main objects | Shared objects | Difference | GameObjects and Transforms |
| --- | ---: | ---: | --- | --- |
| `ck_chushi_hair` | 141 | 143 | +1 Mesh (43), +1 Avatar (90) | 69 each in both |
| `ck_dujiaoxing_clothes` | 135 | 137 | +1 Mesh (43), +1 Avatar (90) | 66 each in both |
| `ck_dujiaoxing_hair` | 163 | 165 | +1 Mesh (43), +1 Avatar (90) | 80 each in both |
| `ck_dujiaoxing_shoes` | 163 | 165 | +1 Mesh (43), +1 Avatar (90) | 80 each in both |

Each pair also preserves one `SkinnedMeshRenderer` (137) and one `Animator` (95). This establishes **inventory differences**, not necessarily identical path IDs or guaranteed cross-bundle links. The next unresolved technical task is to decode `m_Bones`, `m_RootBone`, `m_Mesh` and `m_Avatar` PPtr field values and verify their targets. No third-party asset content is redistributed.

## Verified Transform trees in five equipment prefabs (2026-11-04)

Ran the local UnityFS LZ4 and SerializedFile v21 hierarchy decoder against actual original bundle bytes. Each count below is from `Transform` objects with resolved `GameObject.m_Name`, `Transform.m_GameObject`, and `m_Father` links, not from a file-name heuristic.

| Original file | GameObjects / Transforms | Root Transform count | Root name |
| --- | ---: | ---: | --- |
| `ck_dujiaoxing_clothes.prefab_ab` | 66 / 66 | 1 | `CK_DuJiaoXing_Clothes` |
| `ck_dujiaoxing_hair.prefab_ab` | 80 / 80 | 1 | `CK_DuJiaoXing_Hair` |
| `ck_dujiaoxing_shoes.prefab_ab` | 80 / 80 | 1 | `CK_DuJiaoXing_Shoes` |
| `ck_dujiaoxing_weapon.prefab_ab` | 160 / 160 | 2 | `CK_DuJiaoXing_Weapon` (twice) |
| `ck_lang_hair.prefab_ab` | 160 / 160 | 2 | `CK_Lang_Hair` (twice) |

Observed object names include `male_Bip001 Pelvis`, `male_Bip001 Neck`, `male_Bip001 L Foot`, `male_Bip001 R Forearm`, and `male_skirt_06`. The duplicate root names in the last two bundles are **distinct Transform objects**, not proof of a specific variant-selection mechanism. A Transform count is **not** a confirmed skinned-bone count. Next correlate these named Transforms with the renderer bone array and mesh bindpose data.

The locally generated metadata-only report is `ulala_more_equipment_hierarchies.json`; no original third-party asset payloads are committed.

## Cross-prefab Transform-name overlap (2026-11-04)

Executed the local UnityFS/SerializedFile Transform decoder on **11 equipment prefab main bundles** and compared the names of the actual Transform-linked GameObjects. Counts are object/name counts, **not skinning bone counts**.

| Prefab | Transforms | Distinct names | Names containing `Bip001` | Root Transforms |
| --- | ---: | ---: | ---: | ---: |
| `ck_chushi_hair` | 69 | 69 | 53 | 1 |
| `ck_dujiaoxing_clothes` | 66 | 65 | 20 | 1 |
| `ck_dujiaoxing_hair` | 80 | 79 | 54 | 1 |
| `ck_dujiaoxing_shoes` | 80 | 79 | 54 | 1 |
| `ck_dujiaoxing_subweapon` | 160 | 79 | 108 | 2 |
| `ck_dujiaoxing_weapon` | 160 | 79 | 108 | 2 |
| `ck_lang_hair` | 160 | 79 | 108 | 2 |
| `ck_lang_subweapon` | 160 | 79 | 108 | 2 |
| `ck_lang_weapon` | 160 | 79 | 108 | 2 |
| `dly_dajiaolu_weapon` | 8 | 3 | 4 | 2 |
| `dly_pugongying_bracers` | 110 | 54 | 106 | 2 |

Pairwise **unique name set** intersections:
- `ck_dujiaoxing_hair` versus `ck_dujiaoxing_shoes`: 78 common names, out of 79 unique names in each. The differing root names are `CK_DuJiaoXing_Hair` and `CK_DuJiaoXing_Shoes`.
- `ck_dujiaoxing_weapon` versus `ck_lang_hair`: 78 common names, out of 79 unique names in each. Again the root names differ.
- `ck_dujiaoxing_hair` versus `ck_dujiaoxing_clothes`: 44 common names (79 and 65 distinct names respectively).

This strongly suggests reusable naming/hierarchy templates across equipment categories. It does **not** prove identical bone transforms, skinning weights, bindposes or runtime attachment behavior. In particular, the 160-Transform bundles contain two separate roots and duplicated object names; a naive name-based join would be ambiguous. Next compare parent-path structures and bindpose data using unique Transform path IDs.

A metadata-only JSON report was generated locally as `ulala_equipment_skeleton_name_comparison.json`; no proprietary asset payloads were committed.
