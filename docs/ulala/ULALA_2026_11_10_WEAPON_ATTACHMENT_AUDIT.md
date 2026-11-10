# Unity weapon renderer attachment offset — DLY vs NDLY (2026-11-10)

**Read-only technical metadata analysis.** Original assets, clips, matrices and pose arrays are not committed.

## Independent comparison from source UnityFS bytes

Re-read original `1869_dly.prefab_ab_shared` and `1917_ndly.prefab_ab_shared` (Unity SerializedFile v21). For each bundle:

1. Decode the `SkinnedMeshRenderer.m_Bones`, `m_RootBone` and `m_Mesh` fields from their actual TypeTree payloads.
2. Resolve renderer `m_GameObject` to its local `Transform`, then traverse parent links.
3. Reconstruct renderer and hand-bone world-rest transforms from each stored local position, quaternion and scale.
4. Calculate `inverse(HandBoneWorldRest) × WeaponRendererWorldRest`.
5. Compare DLY vs NDLY in hand-bone-relative space.

| Property | DLY | NDLY |
| --- | --- | --- |
| Renderer hierarchy path | `DLY/DLY_PuGongYing_Weapon` | `NDLY/NDLY_PuGongYing_Weapon` |
| Root-bone path | `DLY/kid_Bip001/kid_Bip001_M_Hand` | `NDLY/kid_Bip001/kid_Bip001_M_Hand` |
| Skinning bones on weapon renderer | 1 | 1 |
| `m_RootBone` points to its sole bone | yes | yes |
| Renderer local position x | 0.339315027 | 0.352561265 |
| Renderer local position y | -0.029690258 | 0.049093235 |
| Renderer local position z | 0.004377628 | -0.000000134 |
| Hand-relative renderer position x | -0.58779978 | -0.50966234 |
| Hand-relative renderer position y | -0.17253294 | -0.15567531 |
| Hand-relative renderer position z | 0.40747089 | 0.41091011 |

**Measured relative offset:** `inverse(DLY hand→renderer) × (NDLY hand→renderer)` yields a translation norm of **0.0800091545 Unity units** with a rotation angle approximately **0 degrees**. Numeric translation components depend on coordinate convention; the magnitude is stable.

This independently confirms the previously observed approximately 0.08-unit variant difference. The renderer transform itself differs: the offset is **not solely an artifact of matrix byte layout**. Both renderer objects are direct children of their respective character roots, not bone-parented weapon nodes; the skinning connects their meshes to the hand bone.

## What the result does and does not establish

- The weapon-hand root-bone pointer and sole `m_Bones` entry agree in each variant.
- Both have a distinct renderer-local position and distinct hand-relative renderer offset, even though their relative rotations agree.
- **Likely interpretation:** per-variant weapon attachment adjustment. This is an interpretation, **not** proof of design intent or game-runtime behavior.
- No Unity material, texture, mesh vertices, original bindpose matrix, or animation track was exported.
- This does **not** prove direct skin/animation compatibility with original Titan Legends Godot rigs.

## Recommended Titan Legends implementation

Use independent, original Godot weapon-socket transforms for each class/equipment family rather than rewriting the source skeleton's rest matrices. Validate the weapon grip in idle, attack, dodge and character rotations; preserve Godot 4.7.2 and Android performance. This is a design recommendation, not a transplant of Unity assets.

## Next checks

- Obtain an actual, per-class `Skeleton3D` inventory from the current twelve-class build; the separate 18-bone prototype is insufficient.
- Validate each exported GLB's bone names, parent indices, rest matrices and hand attachment coordinates.
- Test original Godot weapon sockets and animations with runtime and visual tests.

