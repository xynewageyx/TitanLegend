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


### Tatsächliche Mesh-Arraylängen – erfolgreich dekodiert (2026-11-04)

Die UnityFS-LZ4-Bundles wurden lokal dekomprimiert; ein TypeTree-geführter Decoder hat jedes betroffene Mesh-Objekt bis exakt zu seinem Objektende gelesen. Die folgenden Zahlen stammen aus den **Array-Längen im Mesh-Payload**, nicht nur aus dem TypeTree-Schema:

| Shared-Bundle | Mesh-Payload | `m_BindPose` | `m_BoneNameHashes` | `m_BonesAABB` |
| --- | ---: | ---: | ---: | ---: |
| `ck_dujiaoxing_hair.prefab_ab_shared` | 35.012 B | 1 | 1 | 1 |
| `ck_dujiaoxing_shoes.prefab_ab_shared` | 18.548 B | 8 | 8 | 8 |
| `ck_dujiaoxing_clothes.prefab_ab_shared` | 135.904 B | 29 | 29 | 29 |
| `ck_chushi_hair.prefab_ab_shared` | 31.640 B | 1 | 1 | 1 |

Die drei Arraylängen stimmen für jedes Mesh überein; die komplette Payload wurde ohne Restbytes durchlaufen. **Noch offen:** Bindpose-Matrixwerte und konkrete Bone-Hash-Identitäten vergleichen. Die Anzahl verwendeter Knochen allein beweist weder vollständige Rig-Gleichheit noch Inkompatibilität. Es wurden keine proprietären Mesh-Daten ins Repository geladen.


### Tatsächliche Bone-Hash- und Bindpose-Payload-Vergleiche (2026-11-04)

Ein lokaler TypeTree-geführter vollständiger Durchlauf der vier Mesh-Payloads (jeweils exakt bis zum Objektende) hat die Bone-Hash-Arrays und die Bindpose-Bytes extrahiert. Aus Datenschutz-/Lizenzgründen werden hier nur aggregierte Vergleiche und SHA-256-Prüfsummen dokumentiert, keine Mesh- oder Matrix-Rohdaten.

| Mesh | Bindposes / Bone-Hashes | Bindpose SHA-256 | Bone-Hash-Array SHA-256 |
| --- | ---: | --- | --- |
| Dujiaoxing Hair | 1 / 1 | `ef1dc6543078090868daa08ae5773d916a74ee56689cc391c9d72bc7393921ae` | `1c30848d8f0befa67b5a4a0a34acff13d3075774b665028ecb8f966a1eafefe2` |
| Chushi Hair | 1 / 1 | `ef1dc6543078090868daa08ae5773d916a74ee56689cc391c9d72bc7393921ae` | `1c30848d8f0befa67b5a4a0a34acff13d3075774b665028ecb8f966a1eafefe2` |
| Dujiaoxing Shoes | 8 / 8 | `ed09f8275847cc8d6f30dc3cc7fe71b09cff7ec2714da7984b97a2b9dec3644b` | `db7d0d718c1cdfa1ffeaad849a026ddd6073dbcdbbe898ef142a2b93ca54a57e` |
| Dujiaoxing Clothes | 29 / 29 | `a0e2b4f299c7233becbf263fc530ae2f71306fde2983bf281b114641ea578314` | `b916a156841cc2a5ebafb674c836ea114a29a232d04134fb1f01f33074d43e97` |

**Set-Überschneidungen:** Hair Dujiaoxing ↔ Hair Chushi: 1/1 Hash, exakt gleiche Bindpose-Bytes; Hair Dujiaoxing ↔ Clothes Dujiaoxing: 1 Hash; Shoes ↔ Clothes Dujiaoxing: 3 Hashes. Diese Überschneidungen allein belegen keine vollständige Rig- oder Animationskompatibilität. Die Hash-Prüfsummen gelten für die Array-Payload-Bytes in Originalreihenfolge.


### Korrektur und Bindpose-Vergleich pro Knochen-Hash (2026-11-04)

**Korrektur der vorherigen Angabe:** Dujiaoxing Shoes und Clothes teilen **2**, nicht 3, Knochen-Hashes. Der frühere Wert 3 ist überholt. Die Matrixvergleiche wurden anhand der aus den vollständig dekodierten Mesh-Payloads extrahierten 64-Byte-Bindpose-Einträge vorgenommen, jeweils nach identischem 32-Bit-Bone-Hash zugeordnet; identisch bedeutet bytegleiche Matrixdaten (SHA-256-Vergleich).

| Paar | Gemeinsame Bone-Hashes | Identische 64-Byte-Bindposes | Unterschiedliche Bindposes |
| --- | ---: | ---: | ---: |
| Dujiaoxing Hair / Chushi Hair | 1 | 1 | 0 |
| Dujiaoxing Hair / Dujiaoxing Clothes | 1 | 0 | 1 |
| Dujiaoxing Shoes / Dujiaoxing Clothes | 2 | 2 | 0 |
| Dujiaoxing Hair / Dujiaoxing Shoes | 0 | 0 | 0 |

Alle vier Mesh-Payloads wurden vollständig bis zu ihrer deklarierten Byte-Länge traversiert (35.012 / 31.640 / 18.548 / 135.904 Byte). **Interpretation:** Gleichheit der Bindpose eines gemeinsamen Knochen-Hashes ist ein Indiz für Rig-Konsistenz an diesem Knochen, beweist aber weder komplette Skelettgleichheit noch Ausrüstungs-Austauschbarkeit. Der Unterschied bei Hair/Clothes verlangt weitere Prüfung der Bindungsräume, Root-Transforms und Renderer-Bone-Zuordnung. Keine proprietären Asset-Rohdaten wurden ins Repository geladen.


### Numerischer Float32-Vergleich statt nur Bytegleichheit (2026-11-04)

Die Bindpose-Matrizen für den gemeinsamen Bone-Hash `0x26921ABD` aus Dujiaoxing Hair und Clothes wurden als jeweils 16 IEEE-754-Float32-Werte aus den bereits vollständig dekodierten Mesh-Objekten gelesen. **Ergebnis:** 6 von 16 Elementen unterscheiden sich bitweise, aber die maximale absolute Differenz beträgt lediglich `2.9802322387695312e-08`; Frobenius-Norm der Differenz `2.9802322388250966e-08`. Bei absoluter Toleranz `1e-6` und relativer Toleranz `0` gelten alle 16 Matrixelemente als numerisch übereinstimmend. Die zuvor dokumentierte Aussage **„unterschiedliche Bindposes“** beschreibt nur Byte-Ungleichheit, nicht eine bedeutsame geometrische Abweichung. **Nicht bewiesen:** vollständige Rig-/Renderer-Kompatibilität, korrekte Transform-Bindungsräume oder Animationsverhalten. Keine Matrix-Rohdaten wurden ins Repository übertragen.


### SkinnedMeshRenderer TypeTree in den Haupt-Bundles (2026-11-04)

Die **Haupt-Bundles** `ck_dujiaoxing_hair.prefab_ab`, `ck_dujiaoxing_shoes.prefab_ab`, `ck_dujiaoxing_clothes.prefab_ab` und `ck_chushi_hair.prefab_ab` wurden lokal per UnityFS/LZ4 dekomprimiert und ihre SerializedFile-v21-TypeTrees direkt gelesen. Alle vier enthalten die Unity-Klasse **137 (`SkinnedMeshRenderer`)** mit jeweils **76 TypeTree-Knoten**. Die relevanten Felder liegen übereinstimmend an den Knotenindizes `m_Mesh` 50, `m_Bones` 53, `m_BlendShapeWeights` 59, `m_RootBone` 63, `m_Quality` 47. `m_Mesh` und `m_RootBone` haben je 12 Byte PPtr-Struktur; `m_Bones` ist ein variables Array. Dies sind **Felddefinitionen**, keine ausgelesenen konkreten Bone-PPtr-Werte. Die Auswertung der `m_Bones`-Arraylängen und PPtr-Zuordnungen zu den Transform-Objekten steht aus. Originaldateien bleiben lokal.


### Tatsächliche SkinnedMeshRenderer-Objektgrößen in Haupt-Bundles (2026-11-04)

Die lokalen UnityFS-Dateien wurden mit LZ4 dekomprimiert und die SerializedFile-v21-Objektverzeichnisse gelesen. Für Klasse 137 (`SkinnedMeshRenderer`) wurden folgende **tatsächliche Objekt-Payload-Größen** festgestellt:

| Haupt-Bundle | Objekte insgesamt | SkinnedMeshRenderer-Objekte | Renderer-Payload-Größe |
| --- | ---: | ---: | ---: |
| `ck_dujiaoxing_hair.prefab_ab` | 163 | 1 | 208 B |
| `ck_dujiaoxing_shoes.prefab_ab` | 163 | 1 | 292 B |
| `ck_dujiaoxing_clothes.prefab_ab` | 135 | 1 | 544 B |
| `ck_chushi_hair.prefab_ab` | 141 | 1 | 208 B |

Die Größen stammen aus den Objektverzeichniseinträgen und sind **keine** bereits dekodierten `m_Bones`-Arraylängen. Alle vier Renderer verwenden den bereits dokumentierten TypeTree mit `m_Mesh`, `m_Bones`, `m_RootBone` und `m_BlendShapeWeights`. Noch offen: Auslesen der PPtr-Listen und Abgleich mit Transform-PathIDs. Die proprietären Original-Bundles bleiben lokal.


### Renderer-m_Bones-Payloads vollständig gelesen (2026-11-04)

Die lokalen Haupt-Bundles wurden als UnityFS/LZ4 und SerializedFile-v21 dekomprimiert. Die SkinnedMeshRenderer-Objekte wurden aus dem Objektverzeichnis lokalisiert; `m_Mesh` bei Byteoffset 136, `m_Bones`-Arraylänge bei 148 und danach die je 12 Byte großen PPtr-Einträge sowie `m_RootBone` wurden direkt aus den Objekt-Payloads gelesen. Alle PPtr-PathIDs der Bones und RootBones sind in den **Transform-Objektverzeichnissen desselben Haupt-Bundles** vorhanden (`fileID=0`).

| Haupt-Bundle | `m_Bones`-Einträge | Mesh-Bindposes | gültige lokale Bone-PPtrs | RootBone lokal vorhanden | BlendShapeWeights | verbleibende Renderer-Bytes nach RootBone |
| --- | ---: | ---: | ---: | --- | ---: | ---: |
| Dujiaoxing Hair | 1 | 1 | 1/1 | ja | 0 | 28 |
| Dujiaoxing Shoes | 8 | 8 | 8/8 | ja | 0 | 28 |
| Dujiaoxing Clothes | 29 | 29 | 29/29 | ja | 0 | 28 |
| Chushi Hair | 1 | 1 | 1/1 | ja | 0 | 28 |

**Befund:** 39 von 39 Bone-PPtrs sind lokal auflösbar; alle vier RootBone-PPtrs ebenfalls. `m_Bones`-Arraylängen stimmen mit den zuvor gelesenen Mesh-Bindpose-Anzahlen überein. Die verbleibenden 28 Bytes sind nachfolgende Renderer-Felder und wurden nicht als Bones interpretiert. **Offen:** Zuordnung der konkreten Renderer-Bone-Reihenfolge zu Mesh-BoneNameHashes und übergreifende Rig-Kompatibilität. Keine Originalasset-Rohdaten in GitHub übertragen.


### RootBone-Mitgliedschaft und Eindeutigkeit der Renderer-Bone-Listen (2026-11-04)

Erneute lokale Dekodierung der vier Haupt-Bundles und direkte Prüfung der `m_Bones`-PPtr-Einträge sowie des `m_RootBone`-PPtrs (Renderer-Payloads). In **allen vier** Renderern sind die Bone-PPtrs innerhalb der Liste eindeutig; der RootBone-PPtr ist jeweils exakt in der Liste enthalten:

| Haupt-Bundle | Bone-PPtrs | Eindeutige PPtrs | RootBone-Index (0-basiert) |
| --- | ---: | --- | ---: |
| Dujiaoxing Hair | 1 | ja | 0 |
| Dujiaoxing Shoes | 8 | ja | 6 |
| Dujiaoxing Clothes | 29 | ja | 10 |
| Chushi Hair | 1 | ja | 0 |

**Implementierungsrelevante Folgerung:** Den RootBone niemals pauschal als `m_Bones[0]` annehmen. Die Reihenfolge der Renderer-Bone-Liste muss für den späteren Abgleich mit dem Mesh beibehalten werden. **Nicht belegt:** Übereinstimmung der BoneNameHashes mit den Transform-Namen oder die Austauschbarkeit der Ausrüstung. Keine proprietären Originaldaten ins Repository übertragen.


### Aufgelöste Renderer-Bone-Namen (2026-11-04)

Die m_Bones-PPtrs wurden lokal über Transform.m_GameObject zu GameObject-Namen aufgelöst. Die Reihenfolge stammt aus den tatsächlichen SkinnedMeshRenderer-Payloads:

- Dujiaoxing Hair: male_Bip001 Head; RootBone male_Bip001 Head.
- Chushi Hair: male_Bip001 Head; RootBone male_Bip001 Head.
- Dujiaoxing Shoes (8): male_Bip001 R Calf, R Foot, R Thigh, R Toe0, L Calf, L Foot, L Thigh, L Toe0 (jeweils Präfix male_Bip001); RootBone male_Bip001 L Thigh, Index 6.
- Dujiaoxing Clothes (29): darunter male_Bip001 Spine1, Head, Spine, Pelvis, beide Clavicles, UpperArms und Thighs sowie eigene male_clothes_* und male_skirt_* Transforms; RootBone male_Bip001 Pelvis, Index 10.

**Grenze:** Gleiche Transform-Namen beweisen keine vollständige Rig-Kompatibilität. Der positionsgetreue Abgleich der Renderer-Knochen mit den Mesh-BoneNameHashes bleibt offen. Keine proprietären Asset-Bytes hochgeladen.


### Positionsgenauer Abgleich Renderer-Bones ↔ Mesh-BoneNameHashes (2026-11-04)

Die vier lokal dekodierten Mesh-Arrays wurden positionsgetreu mit den bereits aufgelösten Renderer-m_Bones-Transform-Namen verbunden (Hair Dujiaoxing 1, Shoes Dujiaoxing 8, Clothes Dujiaoxing 29, Hair Chushi 1): **39 von 39 Positionen** besitzen je einen Namen und einen 32-Bit-Hash. Über alle vier Meshes ergeben sich **35 unterschiedliche Namen und 35 unterschiedliche Hashes**. Weder wurde ein Name mit zwei unterschiedlichen Hashes noch ein Hash mit zwei unterschiedlichen Namen beobachtet.

Mehrfach vorkommende Namen und jeweils identische Hashwerte: `male_Bip001 Head` → `0x26921ABD`; `male_Bip001 R Thigh` → `0xCE1A28CF`; `male_Bip001 L Thigh` → `0xF9FBCF5C`. Die Werte stammen aus den Original-Mesh-Arrays, nicht aus einem vermuteten Hash-Algorithmus. Die Ergebnisse sind eine **konsistente positionsweise Zuordnung**, jedoch noch keine unabhängige Verifikation der Unity-Bone-Hash-Berechnung und kein Beweis für Animationskompatibilität. Keine Original-Mesh-Daten hochgeladen.


### Unabhängige Kandidatenprüfung der Bone-Hash-Funktion (2026-11-04)

Die 39 zuvor positionsweise zugeordneten Renderer-Bone-Einträge wurden auf **35 eindeutige Name/Hash-Paare** reduziert. Für jeden Namen wurde geprüft, ob die in den Mesh-Daten gespeicherte 32-Bit-Zahl durch eine verbreitete Hashfunktion aus den **UTF-8-Bytes des bloßen Transform-Namens** reproduzierbar ist.

| Kandidat | Exakte Treffer von 35 |
| --- | ---: |
| CRC32 (Originalschreibweise) | 0 |
| CRC32 (kleingeschrieben) | 0 |
| FNV-1a 32-bit (Originalschreibweise) | 0 |
| FNV-1a 32-bit (kleingeschrieben) | 0 |
| DJB2 32-bit (Originalschreibweise) | 0 |
| DJB2 32-bit (kleingeschrieben) | 0 |

**Schlussfolgerung:** Keine der sechs geprüften Kombinationen bildet die gespeicherten Mesh-BoneNameHashes direkt aus den bloßen Transform-Namen ab. Dies **widerlegt nicht**, dass Unity beispielsweise vollständige Hierarchiepfade oder andere Encodings/Hashfunktionen verwendet. Für Titan Legends keine dieser Kandidatenfunktionen ungeprüft als Ersatz einsetzen. Die 39 positionsweisen Zuordnungen bleiben gültige Beobachtungen, aber noch keine unabhängige mathematische Hash-Bestätigung.


### Hash-Verfahren reproduziert: CRC32 über Hierarchiepfad ohne Prefab-Root (2026-11-04)

**Neue lokale Validierung:** Die zuvor positionsweise zugeordneten 39 Renderer-BoneNameHash-Einträge wurden mit den Transform-Hierarchien aus `ulala_verified_transform_hierarchies.json` und `ulala_more_equipment_hierarchies.json` verknüpft. Alle **39/39** Pfade waren auflösbar. Für **39/39** Einträge reproduziert `zlib.crc32(path.encode('utf-8')) & 0xffffffff` den gespeicherten Mesh-Hash exakt, wenn `path` aus den Transform-Namen mit `/` zusammengesetzt und der äußerste Prefab-Root ausgelassen wird. Schreibweise der Namen unverändert lassen. Der CRC32-Test des **vollständigen** Pfades einschließlich Prefab-Root ergab 0/39 Treffer; CRC32 bloßer Blattnamen ebenfalls 0/35 (zuvor dokumentiert). Dies erklärt den scheinbaren Widerspruch zum früheren Kandidatentest.

Beispiel eines getesteten Pfadaufbaus: `male_Bip001/male_Bip001 Pelvis/male_Bip001 Spine/male_Bip001 Spine1/male_Bip001 Neck/male_Bip001 Head` (Prefab-Root `CK_DuJiaoXing_Hair` nicht Teil des Hash-Inputs). Die Prüfung erfolgte mit Python `zlib.crc32` über UTF-8; **keine Original-Asset-Payloads oder vollständigen privaten Meshes** wurden hochgeladen. Das Ergebnis ist eine reproduzierte Übereinstimmung für diese 39 Referenzzuordnungen, keine universelle Garantie für alle Unity-Versionen oder alle Assets.


### Unabhängige Wiederholungsprüfung aus gespeicherten Hierarchien (2026-11-04)

Ein separater lokaler Python-Durchlauf hat die bereits gespeicherten JSON-Hierarchien (`ulala_verified_transform_hierarchies.json` sowie die fünf nacheinander gespeicherten JSON-Objekte in `ulala_more_equipment_hierarchies.json`) **neu** mit den 39 Einträgen aus `ulala_renderer_mesh_bone_hash_alignment.json` verbunden. Für jeden Bone-Namen wurden die möglichen Transform-Pfade durch Traversieren der `father`-PathIDs rekonstruiert. Anschließend wurde CRC32 auf dem UTF-8-Pfad **ohne ersten Prefab-Root-Namen** berechnet und mit dem gespeicherten Mesh-Hash verglichen.

**Ergebnis:** 39/39 Hash-Treffer und 39/39 jeweils **genau ein** passender rekonstruierter Pfad. Verteilung: Chushi Hair 1, Dujiaoxing Hair 1, Dujiaoxing Shoes 8, Dujiaoxing Clothes 29. Diese Wiederholungsprüfung benötigte keine erneute Interpretation der UnityFS-Binärdaten und bestätigt die zuvor dokumentierte Hash-Regel unabhängig anhand der gespeicherten Zwischenresultate. Grenzen: Die Zwischenresultate stammen weiterhin aus denselben Originalreferenzen; die Rig-/Animationskompatibilität bleibt gesondert zu prüfen.


### Zusätzlicher lokaler Hierarchie-Audit (2026-11-04)

Die gespeicherten Haupt-Bundle-Hierarchien wurden erneut nach **Transform-Anzahl, unterschiedlichen Namen und tatsächlich getrennten Wurzel-Transforms** ausgewertet. Ergebnisse: Chushi Hair 69 Transforms / 69 Namen / 1 Root; Dujiaoxing Clothes 66 / 65 / 1; Dujiaoxing Hair 80 / 79 / 1; Dujiaoxing Shoes 80 / 79 / 1; Dujiaoxing Weapon 160 / 79 / **2**; Lang Hair 160 / 79 / **2**. Die doppelten Root-Namen in Weapon und Lang Hair stehen für **verschiedene Transform-PathIDs**, nicht bloß doppelt gelesene Zeilen. Für die Rekonstruktion von Bone-Hash-Pfaden darf deshalb weder ein Transform-Name als eindeutiger Schlüssel verwendet noch stillschweigend genau eine Root pro Bundle vorausgesetzt werden. Die vorherige Hash-Validierung wurde lokal gegen die gespeicherten Daten wiederholt: **39/39** eindeutige CRC32-Pfadtreffer. Neue Assets wurden nicht importiert.


### Verifizierte Aufteilung der Doppel-Roots (2026-11-04)

Die lokal verfügbaren gespeicherten `nodes`-Datensätze in `ulala_more_equipment_hierarchies.json` wurden erneut nach `father`-PathID zu **disjunkten Root-Teilbäumen** traversiert. `ck_dujiaoxing_weapon.prefab_ab` enthält zwei Wurzel-Transforms (PathIDs `-5684344176998889724`, `-3773185257480706223`), jeweils **80 Transforms / 80 eindeutige volle Pfade**. `ck_lang_hair.prefab_ab` enthält ebenfalls zwei Wurzel-Transforms (PathIDs `8050062899887709551`, `8542200029756559482`), jeweils **80 Transforms / 80 eindeutige volle Pfade**. Innerhalb eines Bundles sind die beiden nach Entfernen des Root-Namens sortierten relativen Pfadmengen exakt identisch (SHA-256-Präfixe als Prüfsummen: Weapon `da57e60b154b1ddd201b` für beide; Lang Hair `3460ef8056d4837d6b53` für beide). **Nur Pfadstruktur, nicht identische Mesh- oder Animationsdaten, ist damit nachgewiesen.** Wichtig: Identische Namen/relative Pfade dürfen beim Import nicht zum Zusammenführen unterschiedlicher Transform-PathIDs führen.


### Integritätsaudit aller verfügbaren Ausrüstungs-Transform-Hierarchien (2026-11-04)

Neues reproduzierbares Werkzeug: `tools/audit_unity_transform_hierarchies.py` (lokale JSON-Metadaten als Eingabe; Original-Asset-Dateien bleiben außerhalb von GitHub). **Tatsächlich lokal ausgeführt** gegen `ulala_more_equipment_hierarchies.json`: Dujiaoxing Clothes 66 Transforms / 1 Root; Dujiaoxing Hair 80 / 1; Dujiaoxing Shoes 80 / 1; Dujiaoxing Weapon 160 / 2 (80+80); Lang Hair 160 / 2 (80+80). **In allen fünf Bundles: null fehlende Child-Referenzen, null widersprüchliche Parent/Child-Beziehungen, null unerreichbare Transforms, null doppelte PathIDs; innerhalb jedes Roots sind alle relativen Pfade eindeutig.** Die beiden Teilbäume pro Doppel-Root-Bundle haben identische SHA-256-Prüfsummen der sortierten relativen Pfadmengen; dies bestätigt nur die Namens-/Pfadstruktur, nicht Mesh- oder Animationsgleichheit. Das Werkzeug bricht bei strukturellen Problemen mit Exitcode 1 ab und besitzt synthetische Tests in `tests/test_unity_transform_hierarchy_audit.py`.


### Objektklassen-Audit: 17 lokal inventarisierte Bundles (2026-11-04)

Das neue Werkzeug `tools/audit_unity_object_inventory.py` wurde gegen die lokale Datei `ulala_equipment_object_counts.json` **ausgeführt**. Ergebnis: **17 Bundles mit insgesamt 3.121 Unity-Objekten**: 1.514 `GameObject` (Klasse 1), 1.514 `Transform` (4), 13 `Mesh` (43), 12 `Avatar` (90), 24 `Animator` (95), 26 `SkinnedMeshRenderer` (137), 17 `AssetBundle` (142) und 1 `AnimatorOverrideController` (221). Pro Bundle entspricht die Summe der Klassenhäufigkeiten der angegebenen Objektanzahl; sonst beendet das Werkzeug die Analyse mit Fehler. Der Bericht ist eine **Objektklassen-Inventur**, kein Nachweis, dass die 24 Animator-Objekte nutzbare Animationsclips enthalten oder die 13 Meshes mit Godot kompatibel sind. Insbesondere sind `AnimationClip`-Objekte (Klasse 74) in diesen 17 Bundles **nicht enthalten**; Animationen müssen ggf. in extern referenzierten Bundles untersucht werden. Die Auswertung verwendet ausschließlich lokal gespeicherte Metadaten, keine Asset-Payloads im GitHub-Repository.


### Externe CAB-Abhängigkeiten (2026-11-04)

Die lokale Datei `ulala_external_dependencies.json` enthält externe Unity-`archive:/CAB-...`-Referenzen für **3** Bundle-Metadatensätze: `beryl.prefab_ab` **2**, `beryl.prefab_ab_shared` **4**, `brook.prefab_ab` **4**. Insgesamt **10** Referenzen auf **10 unterschiedliche** externe CAB-Pfade, also keine Mehrfachnutzung innerhalb dieser Teilmenge. Der Abdeckungsgrad ist auf diese drei Datensätze begrenzt; daraus darf **nicht** geschlossen werden, dass die anderen 14 Bundles keine Abhängigkeiten haben. Neu: `tools/audit_unity_external_dependencies.py` zur reproduzierbaren Prüfung von CAB-Pfaden, mehrfachen fileIDs und gemeinsamen Referenzen; synthetische Tests `tests/test_unity_external_dependencies.py` sind im CI-Workflow eingebunden. **Eine CAB-Referenz ist noch keine aufgelöste Asset-Datei oder Animation.**


### Rohscan der CAB-Strings in allen 17 lokal vorhandenen Bundle-Dateien (2026-11-04)

Die **tatsächlichen Binärdateien** der 17 lokal vorhandenen `.prefab_ab`/`_shared`-Bundles wurden byteweise nach dem Muster `CAB-[32 Hex-Zeichen]` durchsucht. Resultat: **25 unterschiedliche CAB-Kennungen**, davon **4 Kennungen, die in mehr als einer Bundle-Datei auftreten**. Die vier Gruppen erscheinen in jeweils 2, 7, 2 und 2 Dateien. Von den zuvor aus Beryl/Brook-Metadaten extrahierten 10 externen CAB-Kennungen treten **3** in den gescannten 17 Dateien auf, **7 nicht**. Das ist **kein** Nachweis, dass die sieben Abhängigkeiten im vollständigen 7z-Archiv fehlen; der Scan umfasst nur die 17 extrahierten Dateien. CAB-Strings können auch den *eigenen* internen CAB-Namen eines Bundles bezeichnen und sind daher **keine verifizierten PPtr-Abhängigkeitskanten**. Neues Werkzeug: `tools/scan_unity_cab_tokens.py`, das lediglich Aggregatwerte und Dateinamen ausgibt, keine CAB-Kennungen oder proprietären Inhalte. Weitere Auflösung erfordert vollständige `m_Externals`-Tabellen und Abgleich mit dem Archivindex.


### Kreuzabgleich: externe CAB-Referenzen gegen 17 lokale Binär-Bundles (2026-11-04)

Reproduzierbar lokal ausgeführt: `python tools/crosscheck_unity_cab_references.py --references ulala_external_dependencies.json --bundles *.prefab_ab* --output ulala_cab_crosscheck_report.json` (Dateipfade an lokale Arbeitsumgebung anpassen). Ergebnis: **10** Referenzen aus drei Beryl/Brook-Metadatensätzen; **3/10** referenzierte CAB-Token kommen als Byte-Strings in mindestens einem der **17** lokalen Bundles vor; **7/10** wurden in dieser Stichprobe nicht gefunden. Konkrete Dateinamenszuordnung der drei Treffer: `beryl.prefab_ab` (eigene Datei), `beryl.prefab_ab_shared` (eigene Datei), und ein CAB-Token, das in `ck_lang_weapon.prefab_ab`, `ck_dujiaoxing_shoes.prefab_ab_shared`, `ck_lang_hair.prefab_ab`, `ck_chushi_hair.prefab_ab_shared`, `ck_dujiaoxing_hair.prefab_ab_shared`, `ck_dujiaoxing_clothes.prefab_ab_shared` sowie `beryl.prefab_ab_shared` vorkommt. **Entscheidende Grenze:** Ein Treffer ist bloß ein CAB-String im Binärinhalt, weder eine verifizierte Auflösung eines PPtr-Objekts noch ein Nachweis für einen vorhandenen Animationsclip. Das neue Werkzeug veröffentlicht nur Dateinamen und Summen; CAB-Kennungen und proprietäre Daten bleiben lokal. Ein synthetischer Regressionstest wurde lokal erfolgreich ausgeführt und als `tests/test_unity_cab_crosscheck.py` in den CI-Workflow aufgenommen.


### Entscheidender Fortschritt: 88 AnimationClip-Bundles im vollständigen 7z-Archiv identifiziert (2026-11-04)

Die **neun 7z-Teile** wurden lokal zur vollständigen 1,9-GB-Datei zusammengesetzt und das Archiv mit `libarchive` inventarisiert: **27.270 Einträge**. Darunter **88 `.anim_ab`-Dateien** mit zusammen **13.152.211 komprimierten Bytes**. Alle 88 wurden lokal extrahiert, als `UnityFS` erkannt, entpackt und ihre Unity-SerializedFile-v21-Objekttabellen ausgelesen: **88/88 erfolgreich, 0 Parserfehler**. Es sind **88 `AnimationClip`-Objekte (ClassID 74)** und **88 `AssetBundle`-Objekte (142)** enthalten, plus **2 `MonoScript`-Objekte (115)** in den beiden `jurenkongshou_jianhua`-Clips; insgesamt **178 Unity-Objekte**. Unity-Version: **2019.4.16f1c1**. Gruppierung nach Dateinamenpräfix: `woman` 31, `man` 26, `female` 8, `male` 8, `kid` 8, `nkid` 2, `jurenkongshou_jianhua` 2, übrige Kamera-Clips 3. Die zuvor festgestellte Abwesenheit von ClassID 74 in den **17 Ausrüstungs-/Charakter-Prefab-Bundles** bleibt richtig, ist aber ausdrücklich **nicht** auf das Gesamtarchiv übertragbar. Beispiele der tatsächlich vorhandenen Dateien: `male@n_idle_common.anim_ab`, `female@n_hitidle_common.anim_ab`, `man@f_run_accompanyl.anim_ab`. **Noch nicht nachgewiesen:** Rig-Bindings, tatsächliche Animationskurven, Verwendbarkeit in Godot oder eine zulässige Übernahme von Originalinhalten. Die proprietären `.anim_ab`-Dateien bleiben ausschließlich lokal und werden nicht nach GitHub hochgeladen.
