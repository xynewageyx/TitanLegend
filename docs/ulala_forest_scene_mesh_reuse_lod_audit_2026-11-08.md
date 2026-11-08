# Ulala Forest scene — mesh reuse, hierarchy, material references, collision and LOD (2026-11-08)

## Scope and method

**Reference research only.** No original Ulala mesh, texture, material or shader data is added to Titan Legends, and no game graphics are changed.

Original Unity 2019.4.16f1c1 `forest.unity_ab` was decompressed from the owner's nine-part source archive, and the `BuildPlayer-Forest` SerializedFile v21 (5,447 serialized objects) was parsed directly.

The object arrays were decoded and byte boundaries verified for **all** 1,396 GameObjects, 1,396 Transforms, 1,291 MeshFilters, 1,271 MeshRenderers, and two LODGroups. Every GameObject and parent/child Transform reference was cross-checked.

## Repeated meshes: 1,291 placements, only 55 different mesh references

| Resolved original Unity dependency | External fileID | MeshFilter references | Distinct referenced meshes |
|---|---:|---:|---:|
| `forest.unity_ab_shared` | 6 | 678 | 24 |
| `yl_shudong_001a.prefab_ab_shared` — trees/roots/leaves | 7 | 320 | 20 |
| `yl_dashitou_001.prefab_ab_shared` — rocks | 9 | 268 | 9 |
| `Library/unity default resources` — built-in cube | 8 | 20 | 1 |
| `buluo.unity_ab_shared` — ground detail | 10 | 5 | 1 |
| **Total** | | **1,291** | **55** |

The fileID-to-bundle mapping comes from the **actual serialized external-reference table** in `BuildPlayer-Forest`, matched to the inspected CAB names. The source object `pathID` of **all 54 distinct non-built-in meshes** was verified against the referenced original bundle's object table (for files 7 and 9, against the prior verified source-Mesh tables). The remaining one points to Unity's built-in resources, not a file in the archive.

Top examples of repeated GameObject names and mesh placements: `yl_dashitou_005` 198, `yl_manteng_003` 88, `yl_cao_004` 86, `yl_cao_002` 79, `yl_shugen_002` 67, and `yl_cao_005` 55. Some duplicate names include numbered suffixes; placement counts by *mesh pointer* are more reliable than name alone.

### Collider-only cubes

All **20** MeshFilters referencing the built-in Cube (fileID 8, pathID 10202) are attached to GameObjects with a **BoxCollider (class 65)** and **no MeshRenderer**. Conversely, every other Forest MeshFilter has a corresponding MeshRenderer, and all 1,271 renderers have exactly one material. The 20 boxes are serialized invisible collision geometry, **not 20 rendered cubes**.

## Four materials across 1,271 renderers

| Material source bundle | Renderer references |
|---|---:|
| `yl_wujian_002.mat_ab_shared` | 984 |
| `yl_wujian_001.mat_ab_shared` | 275 |
| `mtl_yl_guang_01.mat_ab_shared` | 7 |
| `yl_dibiao1.mat_ab_shared` | 5 |
| **Total** | **1,271** |

These are references to four **material objects**, not four distinct shaders, and are *not* a measured GPU draw-call count.

## Hierarchy and spatial positions

- Four Transform roots: `Baked Light` (52 direct children), `Terrain` (3), `Directional Light` (0), `MyCamera` (1).
- 1,396 Transforms, 1,392 nonroot parent pointers; maximum hierarchy depth **4**.
- Every Transform's owning GameObject, parent link and reciprocal parent-to-child link is valid.
- MeshFilter owner's calculated world-position bounds from nested Unity TRS transforms:
  - X: **−25.45 to 30.89**
  - Y: **−18.30 to 75.89**
  - Z: **−79.00 to 320.00**
- Scene-local positions do not indicate terrain bounding boxes, mesh sizes or visibility under the active camera.

## Only two explicit LODGroups in the scene

| LODGroup GameObject | LOD0 screen relative height | LOD1 screen relative height | LOD0 renderer | LOD1 renderer | Crossfade |
|---|---:|---:|---|---|---|
| `yl_ShuDong_001c` | ~0.08 | ~0.01 | present | null | false |
| `yl_manteng_006` | ~0.08 | ~0.01 | present | null | false |

The second LOD contains an empty Renderer pointer, consistent with **distance culling rather than replacing the model with another mesh**. LOD behaviour at runtime and camera conditions were not measured. There are only two LODGroup **components** in this specific serialized scene; other scenes or resources may have different LOD arrangements.

## What this means for Titan Legends (no changes yet)

- Study **reuse/instancing** of independently created vegetation and rocks instead of creating distinct meshes for every placement.
- Keep **invisible collision proxies** separate from visible environment renderers.
- Consider simple distance culling and a limited set of materials as candidates for Android optimisation, but validate Godot 4 renderer, material instances, transparency overdraw and device benchmarks before adopting particular thresholds.
- The source has no local Terrain/TerrainData class in `BuildPlayer-Forest`; the root GameObject named `Terrain` should **not** be mistaken for a Unity Terrain component. This forest is organized primarily through MeshFilter/MeshRenderer geometry.

## Metadata-only companion reports

- `ulala_forest_scene_references_lod_collision_verified_2026_11_08.json` — full 11-entry external reference table, object and hierarchy validation, 55 individual mesh references, collision and LOD evidence.
- `ulala_forest_scene_mesh_reuse_55_references.csv` — each unique mesh pointer with source, scene usage count and frequent GameObject names.

**Limitations:** component counts are not camera-visible geometry or draw calls, shared dependencies may be used by other scenes, and no measured graphics performance is available. No visual changes were made to Titan Legends.
