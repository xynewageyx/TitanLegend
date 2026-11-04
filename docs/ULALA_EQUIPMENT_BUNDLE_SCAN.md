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

## Exact name-set differences (2026-11-04)

Compared the previously decoded, unique `Transform.m_GameObject -> GameObject.m_Name` name sets. This is a **name-set comparison only**, not a parent-edge or bindpose equivalence test.

- `ck_dujiaoxing_hair` vs `ck_dujiaoxing_shoes`: 78 names shared; only `CK_DuJiaoXing_Hair` vs `CK_DuJiaoXing_Shoes` differ. Jaccard overlap **78/80 = 97.5%**.
- `ck_dujiaoxing_weapon` vs `ck_lang_hair`: 78 names shared; only `CK_DuJiaoXing_Weapon` vs `CK_Lang_Hair` differ. Jaccard overlap **78/80 = 97.5%**.
- `ck_dujiaoxing_hair` vs `ck_dujiaoxing_clothes`: 44 shared names. The hair prefab has 35 names absent from clothes, including finger/hand transforms. Clothes has 21 names absent from hair, including `male_hair_00` through `male_hair_07` and multiple `male_skirt_*` entries. Jaccard overlap **44/100 = 44%**.

Important limitation: some bundles have duplicate Transform names and two root instances; unique name sets collapse those duplicates. A rigorous structural comparison must use root-relative parent paths or stable per-file object path IDs, and a rig compatibility check must additionally compare bindposes and skinning weights. Metadata-only comparison JSON: `ulala_equipment_exact_name_differences.json` (local).

## Parent-path comparison using resolved Transform links (2026-11-04)

Compared **root-relative full parent/child paths** from actual decoded `Transform.m_Father` and `m_Children` references, not just sets of node names. Paths were counted with multiplicity to retain duplicate subtrees in two-root prefabs. The root name itself was excluded.

| Pair | Root-relative paths A | Paths B | Shared identical paths |
| --- | ---: | ---: | ---: |
| `ck_dujiaoxing_hair` vs `ck_dujiaoxing_shoes` | 79 | 79 | 78 |
| `ck_dujiaoxing_weapon` vs `ck_lang_hair` | 158 | 158 | 156 |
| `ck_dujiaoxing_hair` vs `ck_dujiaoxing_clothes` | 79 | 65 | 44 |

For the first pair, the only difference is the name of the immediate child model object (`CK_DuJiaoXing_Hair` versus `CK_DuJiaoXing_Shoes`). For the second pair, that same model-object-name difference appears **twice** because each prefab contains two roots. Thus all remaining 78/156 root-relative paths match exactly in their ancestral naming structure.

The third pair differs more substantially: hair contains additional finger chains, while clothes contains additional `male_hair_*` and `male_skirt_*` chains. These are **structural naming matches**, not proof of matching local transforms, bindpose matrices, bone weights or compatible skinning. The local report is `ulala_equipment_parent_path_comparison.json`; no original asset binaries are published.

## Local Transform value comparison (2026-11-04)

Re-read the original UnityFS bytes of the relevant equipment main bundles, parsed SerializedFile v21 GameObjects and Transforms, and compared their `m_LocalPosition` (3 floats), `m_LocalRotation` (4 floats) and `m_LocalScale` (3 floats) at corresponding **root-relative parent paths**. Each compared scalar differed by less than `1e-5`.

| Pair | Matching local transforms | Differing values |
| --- | ---: | ---: |
| `ck_dujiaoxing_hair` vs `ck_dujiaoxing_shoes` | 78 / 78 | 0 |
| `ck_dujiaoxing_weapon` vs `ck_lang_hair` | 156 / 156 | 0 |
| `ck_dujiaoxing_hair` vs `ck_dujiaoxing_clothes` | 44 / 44 | 0 |

For the two-root pair, 78 shared root-relative path names occur twice. Their transform-value **multisets** were compared, rather than arbitrarily matching duplicate names. The two differently named immediate model nodes were excluded from the shared-path comparison. This establishes matching local Transform values on the compared paths, but **does not** establish equal Mesh bindposes, skinning weights, material assignments or runtime rig compatibility.

Machine-readable local report: `ulala_equipment_local_transform_comparison.json`. No third-party model data was committed.

## Validation checkpoint: Transform comparisons versus bindposes (2026-11-04)

Recalculated totals from the existing machine-readable `ulala_equipment_local_transform_comparison.json` report:

- **3** pairwise equipment comparisons.
- **278** matching Transform occurrences (78 + 156 + 44).
- **0** differing Transform values reported among those matched occurrences.
- **78** root-relative path names with duplicated instances in the two-root comparison; these are ambiguous without instance-specific mapping.

**Evidence boundary:** This checkpoint verifies the existing comparison report's arithmetic; it is **not a new decode of Mesh bindpose matrices**. Bindposes, skinning weights, and per-instance attachment compatibility remain unverified. The local validation report is `ulala_transform_comparison_validation.json`. A UnityPy install attempt in the current offline environment was unsuccessful, so no UnityPy-based bindpose extraction is claimed. Do not copy third-party reference asset payloads into this repository.

## Mesh and Avatar serialized payload sizes (2026-11-04)

Decompressed original local UnityFS LZ4 blocks and parsed the Unity SerializedFile v21 object directory. These sizes are the **actual serialized object payload byte lengths**, not vertex counts, bone counts or bindpose counts.

| Shared bundle | Mesh (class 43) payload sizes | Avatar (class 90) payload sizes |
| --- | --- | --- |
| `beryl.prefab_ab_shared` | 233,160 and 2,536 bytes | 12,704 bytes |
| `ck_chushi_hair.prefab_ab_shared` | 31,640 bytes | 16,704 bytes |
| `ck_dujiaoxing_hair.prefab_ab_shared` | 35,012 bytes | 18,908 bytes |
| `ck_dujiaoxing_shoes.prefab_ab_shared` | 18,548 bytes | 18,912 bytes |

All four bundles decoded successfully in this pass. Dujiaoxing hair and shoes have substantially different Mesh object byte lengths, despite their previously observed matching Transform values; their Avatar sizes are close but not equal. Byte lengths alone cannot prove skeleton or skinning compatibility. **Bindpose matrices have not yet been parsed.** Metadata-only local report: `ulala_mesh_avatar_payload_sizes.json`. Do not redistribute proprietary asset contents.

## Mesh TypeTree bindpose schema verified (2026-11-04)

Directly decompressed `ck_dujiaoxing_hair.prefab_ab_shared` and `ck_dujiaoxing_shoes.prefab_ab_shared` with UnityFS/LZ4, parsed SerializedFile v21 metadata, and decoded 32-byte TypeTree node records for Mesh class ID 43. Both files contain the following actual Mesh schema field names:

| TypeTree field | Declared purpose | Decoded values? |
| --- | --- | --- |
| `m_BindPose` | Bone bindpose matrices | No |
| `m_BoneNameHashes` | Bone-name hash array | No |
| `m_RootBoneNameHash` | Root-bone name hash | No |
| `m_BonesAABB` | Bone bounding boxes | No |
| `m_Weights` | Packed skinning weights | No |
| `m_BoneIndices` | Packed bone indices | No |
| `m_VariableBoneCountWeights` | Variable bone-weight representation | No |

This is a **verified TypeTree schema inspection**, not an extraction of bindpose matrix counts or values. Both bundles contain 165 SerializedFile objects and 7 type declarations. A subsequent decoder must traverse the Mesh object's complete TypeTree to reach these variable-length fields safely, then compare bindpose matrices with appropriate bone-index mapping. No proprietary assets were committed.


### Vier Shared-Bundles: lokaler TypeTree-Gegencheck (2026-11-04)

Die lokal vorhandenen UnityFS-Dateien wurden mit LZ4 dekomprimiert und ihre SerializedFile-v21-TypeTrees ausgelesen. Diese Ergebnisse beziehen sich auf die **Anzahl sämtlicher SerializedFile-Objekte**, nicht auf Knochen oder Bindposes:

| Shared-Bundle | SerializedFile-Objekte | Mesh-TypeTree-Felder bestätigt |
| --- | ---: | --- |
| `ck_dujiaoxing_hair.prefab_ab_shared` | 165 | ja |
| `ck_dujiaoxing_shoes.prefab_ab_shared` | 165 | ja |
| `ck_dujiaoxing_clothes.prefab_ab_shared` | 137 | ja |
| `ck_chushi_hair.prefab_ab_shared` | 143 | ja |

In allen vier Mesh-TypeTrees sind `m_BindPose` (Knoten 65), `m_BoneNameHashes` (85), `m_RootBoneNameHash` (89), `m_BonesAABB` (90) und `m_VariableBoneCountWeights` (102) vorhanden. Die Knotenindizes beziehen sich auf die jeweilige lokale Mesh-TypeTree-Liste. **Nicht bestimmt:** Array-Längen, Matrixwerte, Bone-Hash-Werte und tatsächliche Skinning-Kompatibilität. Die proprietären Asset-Bytes wurden nicht in GitHub übertragen.


### Bindpose-Array-Elementstruktur (lokaler Mesh-TypeTree-Check)

Für `ck_dujiaoxing_hair.prefab_ab_shared` wurde der Mesh-TypeTree bis auf die Kindknoten geprüft:

- Knoten 65 `m_BindPose`: Array mit Knoten 67 (`size`, 4 Byte) und Knoten 68 (`data`, 64 Byte).
- Knoten 68 enthält die 16 Felder `e00` bis `e33`, jeweils 4 Byte: eine `float4x4`-Matrix pro Arrayeintrag.
- Knoten 85 `m_BoneNameHashes`: Array mit Knoten 87 (`size`, 4 Byte) und Knoten 88 (`data`, 4 Byte pro Hash).
- Knoten 89 `m_RootBoneNameHash`: 4 Byte.
- Knoten 90 `m_BonesAABB`: Array mit 24-Byte-`MinMaxAABB`-Einträgen.

**Einschränkung:** Dies sind nachgewiesene *Schema-Größen*, keine aus Objekt-Payloads gelesenen Arraylängen. Es ist noch nicht nachgewiesen, wie viele Bindposes oder Knochen-Hashes das konkrete Mesh enthält. Keine Original-Asset-Daten wurden hochgeladen.
