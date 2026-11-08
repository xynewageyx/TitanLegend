# Ulala original scene comparison: Forest vs Plain vs ValleyWoodland (2026-11-08)

**Status:** Direct binary analysis of user-provided original Ulala UnityFS archives (Unity 2019.4.16f1c1, SerializedFile v21), for reference **only**. No Ulala image, vertex, mesh, shader, or scene payload is committed; **Titan Legends gameplay and visuals remain unchanged**.

## Original scenes, exactly decoded

Used the on-disk `forest.unity_ab`, `plain.unity_ab`, and `valleywoodland.unity_ab`. Decompressed UnityFS LZ4 blocks and parsed each `BuildPlayer-...` SerializedFile's entire object table, then directly decoded GameObject, MeshFilter, MeshRenderer and LODGroup components with byte-length assertions.

| Serialized component metric | Forest | Plain | ValleyWoodland |
|---|---:|---:|---:|
| All serialized objects | 5,447 | 105,075 | 3,584 |
| GameObjects | 1,396 | 28,709 | 914 |
| MeshFilters | 1,291 | 19,191 | 873 |
| MeshRenderers | 1,271 | 19,191 | 873 |
| Distinct Mesh pathID pointers | 55 | **37** | 41 |
| Distinct Material pathID pointers | 4 | **13** | 4 |
| LODGroup components | **2** | **9,222** | **0** |
| Terrain components (Unity class 218) | 0 | 1 | 0 |
| Light components | 52 | 29 | 2 |

These are *saved scene component counts*, not simultaneous GPU draw calls, visible meshes or FPS. The single Unity Terrain in Plain was previously linked by exact CAB and pathID to a 513×513 flat TerrainData, while the scene also includes many mesh-constructed plants and environment objects.

## Major difference: all Plain grass LODGroups use two *real* MeshRenderers

**9,222 / 9,222** LODGroup objects:
- Have exactly **2 LOD stages** and 1 valid, non-null MeshRenderer pointer **per stage**.
- Contain **18,444 distinct MeshRenderer pointers**, all resolved against the original scene's serialized renderer objects. A further **747** MeshRenderers in the scene do not occur in those LOD stage slots.
- Store `fadeMode=0` and disabled crossfade.
- Have distinct actual Mesh resource pointers for LOD0 versus LOD1.
- Reuse three grass GameObject types: `mdl_PYN_XiaoCao_003` (2,748 groups), `_004` (2,796), and `_005` (3,678).
- The group names have stored LOD0 screen-relative heights of **0.147931 / 0.145765 / 0.154525**, and LOD1 of **0.025693 / 0.028526 / 0.029502**, respectively. These screen-relative thresholds are **not direct distance or meter measurements**.

To verify actual geometry, extracted **three original grass prefab shared bundles** from the user's 7z archive (`env_pyn_xiaocao_003_0716`, `004`, `005`) and parsed their six Mesh classID-43 objects and index buffers. Every source mesh has verified valid submesh index ranges. All three lower-detail meshes are separately stored and have `_low` in the saved Unity Mesh names.

| Original grass mesh | LODGroup instances | LOD0 triangles | LOD1 triangles | Geometric reduction |
|---|---:|---:|---:|---:|
| `mdl_PYN_XiaoCao_003` | 2,748 | 3,322 | 627 | 81.1% |
| `mdl_PYN_XiaoCao_004` | 2,796 | 3,036 | 547 | 82.0% |
| `mdl_PYN_XiaoCao_005` | 3,678 | 2,090 | 384 | 81.6% |

Across the stored 9,222 scene instances **if all groups were forced to one stage**:
- Hypothetical all-LOD0 geometry: **25,304,532 triangles**
- Hypothetical all-LOD1 geometry: **4,664,760 triangles**
- Weighted difference: **81.57%**

**Critical:** These are not camera-visible triangles, FPS measurements, per-frame simultaneous geometry, or a practical device budget. Unity chooses LOD stages according to screen size; some objects can be outside the camera or culled entirely. Do **not** claim the original game rendered 25 million grass triangles each frame.

## Contrast with Forest and ValleyWoodland

- **Forest:** only **2** LODGroup objects, each has 2 stages but the second stage contains a *null Renderer*. They indicate potential distance culling, not a verified second lower-triangle mesh. The scene has 55 distinct mesh pointers (54 external sources plus a built-in collision Cube) with 1,291 MeshFilter placements.
- **ValleyWoodland:** **0** LODGroup components in its saved `BuildPlayer-ValleyWoodland` scene; 873 MeshRenderers refer to 41 distinct Mesh pointers, all under one source fileID in its serialized scene dependency table. This does not rule out culling or LOD implemented by prefabs/scripts elsewhere.
- **Plain:** two real triangle-reduced Mesh levels in 9,222 grass LODGroups, only 37 distinct Mesh pointers used by 19,191 MeshFilters. Reuse does not prove GPU instancing, and LOD counts do not prove how many grasses appear in a frame.

## Independent design implications for Titan Legends (not implemented)

Given the Android-only Godot 4.7.2 target, investigate an *original*, lightweight stylized grass family with optional mesh LOD and visibility culling. Do **not** transfer source Unity meshes, materials, textures, shader variants or whole scene structure. Record real draw calls and GPU frame time on target Android hardware before selecting LOD count, model triangle budgets, shadows or density.

## Metadata-only companion outputs

- `ulala_forest_plain_valleywoodland_scene_comparison_verified_2026_11_08.json`
- `ulala_forest_plain_valleywoodland_scene_comparison_verified_2026_11_08.csv`
- `ulala_plain_grass_lod_two_mesh_levels_verified_2026_11_08.json`
- `ulala_plain_grass_lod_two_mesh_levels_verified_2026_11_08.csv`

**Further analysis:** decode the 747 Plain renderers not in these LOD groups, determine scene partitioning and ground meshes, check original in-scene cameras / visibility and compare actual materials and lightmaps. No visuals were changed in Titan Legends.
