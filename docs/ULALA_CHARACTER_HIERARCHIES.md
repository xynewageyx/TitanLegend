# Unity character prefab hierarchy – metadata only

Verified from local Unity SerializedFile v21 object tables and Transform PPtr links in the supplied reference bundles. These are **prefab GameObject hierarchies**, not full skeletal bone trees.

## Beryl (`lib/character/base/beryl.prefab_ab`)

```text
Beryl [root]
├── Beryl
└── Beryl_Weapon
```

- 3 GameObjects and 3 Transforms.
- The root Transform has exactly 2 child Transform references, both resolved to objects in the same SerializedFile.

## Brook (`lib/character/base/brook.prefab_ab`)

```text
Brook [root]
├── Brook
├── Brook_Clothes
├── Brook_Weapon
└── Face
```

- 5 GameObjects and 5 Transforms.
- The root Transform has exactly 4 child Transform references, all resolved to objects in the same SerializedFile.

## Limits and next steps

The object names and parent-child edges are verified by reading `GameObject.m_Name`, `Transform.m_GameObject`, and `Transform.m_Children`. This does **not** establish the full armature, rigging, animation bindings, or whether every named object is rendered. Next analyze `SkinnedMeshRenderer.m_Bones`, `m_RootBone`, `m_Mesh`, and `Animator.m_Avatar` PPtrs, including cross-bundle dependencies. Do not import or redistribute the proprietary original assets.

## TypeTree field inspection of character rigging (2026-11-03)

Locally rechecked the original `beryl.prefab_ab`, `beryl.prefab_ab_shared`, and `brook.prefab_ab` UnityFS samples by decompressing their LZ4 blocks and parsing their Unity SerializedFile v21 TypeTree string tables. The following field names are **verified schema declarations, not yet decoded object values**:

- `SkinnedMeshRenderer` (class ID 137, Beryl and Brook): `m_Bones`, `m_RootBone`, `m_Mesh`, `m_Materials`, `m_BlendShapeWeights`.
- `Animator` (class ID 95, Beryl and Brook): `m_Avatar`, `m_ApplyRootMotion`.
- `Mesh` (class ID 43, Beryl shared): `m_BoneNameHashes`, `m_BonesAABB`, `m_BoneIndices`, `m_RootBoneNameHash`, `m_SubMeshes`.
- `Avatar` (class ID 90, Beryl shared): `m_AvatarSkeleton`, `m_AvatarSkeletonPose`, `m_RootMotionSkeleton`, `HumanBone`, `SkeletonBone`.
- `MeshFilter` (class ID 33, Brook): `m_Mesh`.

This confirms that the serialized schemas expose bone, avatar, skinning and material reference fields. **It does not establish the actual number or names of bones, rig compatibility, material assignments or clip bindings.** Next: decode individual object fields using the TypeTree node layout and resolve PPtr file IDs/path IDs. Proprietary asset payloads remain outside GitHub.

## Resolved Beryl renderer and Animator pointers (2026-11-03)

Decoded actual little-endian PPtr pairs (`int32 fileID`, `int64 pathID`) from `beryl.prefab_ab_shared`, and matched `fileID=0` targets against its SerializedFile v21 object table:

| Source | Byte offset in source object | Target pathID | Target class | Target name |
| --- | ---: | ---: | --- | --- |
| SkinnedMeshRenderer pathID `-4464223284711970495` | 136 | `-92901539420410113` | Mesh (43) | `Beryl` |
| SkinnedMeshRenderer pathID `8141632201946067116` | 136 | `59332492705198890` | Mesh (43) | `Beryl_Weapon` |
| Animator pathID `1116753173661700370` | 16 | `1732061794786354735` | Avatar (90) | `BerylAvatar` |

Target names were read directly from each target object's length-prefixed `m_Name` string, not guessed from filenames. This verifies **internal pointer destinations**; the semantic field identities are consistent with the corresponding Unity TypeTree declarations but require full TypeTree field-offset traversal for definitive field mapping. A scan of the Brook main prefab did not resolve internal Mesh/Avatar objects because none are present in its object table. No proprietary reference assets were committed.

## SerializedFile external reference table (2026-11-03)

Parsed the post-object metadata external reference entries in three local Unity SerializedFile v21 samples. Each entry contains an optional asset path, GUID, type and an archive path. These are **external file table entries**; resolving a particular `PPtr.fileID` requires using its corresponding 1-based index in this table.

| Sample | External references | Archive CAB IDs, in fileID order |
| --- | ---: | --- |
| `beryl.prefab_ab` | 2 | `171319512be50a8698260252625f99b0`, `2062281392ae861281b59ebda30e4835` |
| `beryl.prefab_ab_shared` | 4 | `3f7d60643a476f69c2fb82d710bcc158`, `36ba5602013baa7b33df1bb2728455c9`, `ab9039dc1e4a636dbe2dacb305465166`, `d42019473a517db719d7817159be6e37` |
| `brook.prefab_ab` | 4 | `4db8e5fe34170ee3350b8b9e414400a5`, `d923feb3ad3131129b208e6e16f1ae22`, `8385d6d494407799d12f41f508a655c8`, `4c456cef82792995211031a321bd4db1` |

The external CAB references are confirmed from the source metadata, but they have **not yet been mapped to concrete bundle filenames**. No bone counts or rig compatibility conclusions follow from this step. Only identifiers, not copyrighted mesh/animation payloads, are recorded.

## Brook shared bundle resolved (2026-11-03)

Extracted `brook.prefab_ab_shared` (118,096 bytes) from the supplied original 7z reference archive, decompressed its UnityFS data, and parsed the Unity SerializedFile v21 object table. It contains **23 objects**, including 4 Mesh (43), 3 SkinnedMeshRenderer (137), 1 Avatar (90), 1 AnimatorOverrideController (221), and 1 MeshFilter (33).

Resolved the three `m_Mesh`-candidate pointers at byte offset 136 of the Brook main prefab renderers (`fileID=2`) against exact Mesh path IDs in the shared file (`fileID=0`):

| Mesh path ID | Shared Mesh name |
| --- | --- |
| `-6464302524655367657` | `Brook` |
| `-6069506281926079086` | `Brook_Weapon` |
| `327975107067027973` | `Brook_Clothes` |

The shared file additionally names Mesh `Face`, Avatar `BrookAvatar`, and AnimatorOverrideController `character_brook`. Mesh names were decoded from the serialized object name strings; IDs were checked against actual object records. The main/shared pointer match establishes cross-file mesh identity; skinning bone lists and rig attachment details remain unverified. No third-party binary content was committed.

## Avatar object string probe (2026-11-03)

Read actual Avatar (class 90) object bytes from the local `beryl.prefab_ab_shared` and `brook.prefab_ab_shared` UnityFS samples, then searched for plausible null-terminated ASCII strings. This is a **heuristic string scan**, not a parsed bone array; the number of matches must not be interpreted as the bone count.

| Avatar | Serialized object size | Plausible ASCII strings |
| --- | ---: | ---: |
| `BerylAvatar` | 12,704 bytes | 48 |
| `BrookAvatar` | 10,816 bytes | 40 |

Examples actually present in the Avatar object bytes include `Bip001 R Hand`, `Bip001 L UpperArm`, `Bip001 R Calf`, `Bip001 L Toe0`, `Bip001 R Finger0`, and `Bip001 L Finger4`. `BrookAvatar` additionally contains `Bip001 Spine` and `Bip001 Spine1`; `BerylAvatar` includes names such as `Bone007`, `Bone014`, `Bone019`. The names indicate skeletal labeling exists in these objects, but no definitive hierarchy, binding matrices, or rig compatibility has been established. Next parse the Avatar skeleton nodes and parent indices using the TypeTree instead of scanning printable bytes.

## Validated Transform hierarchy against actual UnityFS files (2026-11-04)

A local UnityFS LZ4 decompression and SerializedFile v21 object/Transform reader was executed on the original `beryl.prefab_ab`, `beryl.prefab_ab_shared`, and `ck_chushi_hair.prefab_ab` reference samples. UnityFS block metadata required **16-byte alignment** after the bundle header; the compressed metadata was at the beginning of these files.

| Source bundle | GameObjects | Transforms | Root Transforms |
| --- | ---: | ---: | ---: |
| `beryl.prefab_ab` | 3 | 3 | 1 |
| `beryl.prefab_ab_shared` | 3 | 3 | 1 |
| `ck_chushi_hair.prefab_ab` | 69 | 69 | 1 |

The Beryl root has children named `Beryl` and `Beryl_Weapon`, confirmed by `Transform.m_Children` pointers and each child's `m_Father` pointer. The Chushi hair prefab root is `CK_ChuShi_Hair` and has two immediate children. Its 69 named Transform objects include `male_Bip001 L Thigh`, `male_Bip001 R Finger2`, `male_Bip001 L Foot`, `male_skirt_22`, and `male_skirt_27`. This is a **Transform hierarchy**, not a verified skinning bone count. These findings are from original object bytes, not just TypeTree schema names.

The metadata-only local validation output is `ulala_verified_transform_hierarchies.json`. No original asset payload was uploaded.
