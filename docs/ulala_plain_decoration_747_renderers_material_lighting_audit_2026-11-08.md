# Ulala Plain — 747 non-LOD decoration renderers, mesh sources and lightmaps (2026-11-08)

**Purpose:** Read-only verification of original Ulala scene metadata for independent Titan Legends Android optimization research. **No original Ulala assets or game graphics are modified or committed.**

## Evidence, checks and method

Parsed the original owner-provided `plain.unity_ab` UnityFS binary (Unity 2019.4.16f1c1, SerializedFile v21). Resolved the **entire** object table and directly read GameObject (class 1), MeshFilter (33), MeshRenderer (23) and LODGroup (205) records.

1. Verified all **19,191** MeshRenderer component IDs, GameObject pointers and corresponding MeshFilter/Mesh pointers.
2. Verified **9,222 LODGroups** with two non-null renderer pointers each; all **18,444 LOD renderer IDs are distinct** and exist in the scene.
3. Set-difference against all scene renderer IDs yields **747** MeshRenderers with **no direct membership in the serialized LODGroup renderer arrays**. This is *not* a claim that no other runtime visibility system affects them.
4. Joined each remaining renderer's exact Material `fileID,pathID` and Mesh `fileID,pathID` to the scene's serialized external-CAB table.
5. Compared those CAB names against the previously verified inventory of **3,076 original shared asset bundles**. Each of the CAB-to-bundle matches is unique.
6. Compared all 747 renderer lightmap-index fields against material and mesh pointers; checked the independent totals against 19,191 scene renderers.

## Exact full-scene breakdown

| Scene category | MeshRenderers | Distinct mesh refs | Distinct material refs | Have stored baked lightmap index |
|---|---:|---:|---:|---:|
| Grass LOD 0 | 9,222 | 3 | 2 | 0 |
| Grass LOD 1 | 9,222 | 3 | 2 | 0 |
| Remaining objects, no LODGroup entry | **747** | **31** | **11** | **251** |
| **Total** | **19,191** | **37 overall** | **13 overall** | **251** |

The LOD and non-LOD groups use **disjoint** mesh pointers and material pointers. Their distinct pointer counts therefore reconcile to 6+31=37 mesh refs, and 2+11=13 material refs.

All 747 non-LOD MeshRenderers have `m_Enabled=true`, stored shadow casting mode 1, and `m_ReceiveShadows=true`. These are serialized flags, **not** measured shadow-map costs. Of these, **251** have lightmap indices 0–4; **496** use sentinel index 65535 (no baked lightmap assigned).

## Eleven source Material bundles for the 747 decorative renderer placements

| Verified material source bundle name | Renderer placements | With baked lightmap | Without baked lightmap |
|---|---:|---:|---:|
| `mtl_py5_hua_01.mat_ab_shared` | 496 | 0 | **496** |
| `mtl_py_shuye.mat_ab_shared` | 78 | 78 | 0 |
| `mtl_pyaaaa.mat_ab_shared` | 64 | 64 | 0 |
| `mtl_py5_shitou_02.mat_ab_shared` | 41 | 41 | 0 |
| `mtl_py5_gutou.mat_ab_shared` | 27 | 27 | 0 |
| `ha5_wujian_30.mat_ab_shared` | 18 | 18 | 0 |
| `mtl_py5_shitou_01.mat_ab_shared` | 7 | 7 | 0 |
| `mtl_yp5_dibiao_0804.mat_ab_shared` | 5 | 5 | 0 |
| `mtl_py_diaoxian_30.mat_ab_shared` | 4 | 4 | 0 |
| `mtl_tex_02.mat_ab_shared` | 4 | 4 | 0 |
| `ha5_wujian_31.mat_ab_shared` | 3 | 3 | 0 |
| **Total** | **747** | **251** | **496** |

`mtl_py5_hua_01` material references are all used by only **two distinct Mesh pointers**:
- `env_af_huaduo_02.prefab_ab_shared`, **287** renderer placements
- `env_af_huaduo_01.prefab_ab_shared`, **209** renderer placements

The top exact original GameObject names in the non-LOD group are `hua_001` (**184**) and `hua_002` (**141**); suffixes such as `hua_001 (34)` explain why object-name counts need not equal per-mesh counts. The two source Mesh pointers are the reliable identity, not GameObject name strings.

## Two source materials for the 9,222 two-level grass groups

Both grass LOD levels have the **same distribution of Material pointers**:

| Verified grass material bundle | Groups / placements per LOD level |
|---|---:|
| `mtl_py5_grass.mat_ab_shared` | **8,740** |
| `mtl_pyn_grass_v2_01.mat_ab_shared` | **482** |
| **Total per level** | **9,222** |

Mesh geometry **does change** between LOD0 and LOD1 (previously checked `_low` models, ~81% fewer triangles). **Material identity does not change** for each corresponding group. Neither level has stored baked Lightmap indices.

## Notes and limitations

- The CAB lookup proves the **source bundle filename**, not the internal `Material.m_Name` string (not independently decoded as part of this pass).
- No lightmap index on flowers or grass does **not** imply they are unlit; forward, dynamic, ambient, shader-based or vertex lighting may still apply.
- "Without LODGroup" means not referenced by these scene LODGroup arrays; camera frustum culling, runtime scripts, transforms and other load-time behavior still need testing.
- The 19,191 renderer count is not a draw call count. Two LOD levels do not imply both are rendered simultaneously.
- No copyrighted original Ulala art is copied into the Titan Legends game, nor are the original shaders reproduced.

## Local metadata-only outputs

- `ulala_plain_747_nonlod_renderers_verified_2026_11_08.json`
- `ulala_plain_747_nonlod_renderers_verified_2026_11_08.csv` — one row per leftover renderer, with object name, Mesh and Material pointers, CABs, lightmap and flags
- `ulala_plain_lod_nonlod_full_source_breakdown_2026_11_08.json` — verified external CAB-to-source file mapping, LOD0/LOD1/decor joins and crosschecks
- `ulala_plain_11_decoration_materials_lightmap_breakdown_2026_11_08.csv` — per material source and lightmap counts

**Next reference questions:** decoded original material and texture settings of the eleven non-LOD bundles, geometry triangle costs of these 31 distinct meshes, and visibility ranges. **No Titan Legends visuals altered.**
