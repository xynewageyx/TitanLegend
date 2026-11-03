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
