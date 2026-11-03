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
