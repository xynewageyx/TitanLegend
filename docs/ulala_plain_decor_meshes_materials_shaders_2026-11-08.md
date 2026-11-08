# Ulala Plain decorative meshes: 31 original meshes, 11 materials, four actual shaders — 2026-11-08

**Read-only reference analysis.** All figures below were decoded directly from the user's original Ulala UnityFS/SerializedFile v21 archive (Unity 2019.4.16f1c1). This document contains **metadata only**. **No Ulala model, texture, image, shader bytecode, or asset payload was added to Titan Legends; no Titan Legends graphics were modified.**

## Reproducible source coverage

- Earlier original `plain.unity_ab` scene analysis identified **19,191 MeshRenderers** and **9,222 LODGroups** with one valid MeshRenderer at each of two levels. Removing those 18,444 LOD-assigned renderer IDs leaves exactly **747 decoration MeshRenderers**.
- Their actual `MeshFilter.m_Mesh` and `MeshRenderer.m_Materials` pointers refer to **31 distinct Mesh objects** and **11 distinct Material objects**.
- Extracted **35 specifically referenced original UnityFS bundles** directly from the user's nine-part 7z archive: 24 Mesh-source bundles and 11 Material-source bundles. The bundles were kept as *local inputs only*.
- Verified **all 31/31 required classID-43 Mesh object records**, including serialized object byte boundaries, Vertex counts, triangle-topology index buffer lengths and in-range vertex indices.
- Verified **all 11/11 required classID-21 Material records**, including texture-pointer fields, floats, keywords, render queues and exact byte consumption.
- Resolved each Material's external Shader `fileID` through that material's **own** SerializedFile external-reference table. Every one maps to CAB `CAB-259b3a6b4ed11e2f71f4a3e2ebc98a40` in the original `assets/shaders` UnityFS file, and all **4 distinct referenced classID-48 Shader objects** were decoded exactly to their serialized byte boundaries.
- Joined **every one of the 747 original scene renderer records** to its resolved Mesh and Material. Cross-checked the independently calculated **213,618 triangle** total by Mesh pointer and by Material pointer.

## Measured polygon count of the decoration scene sample

| Metric | Verified count |
|---|---:|
| Unique Mesh objects | **31** |
| Sum of distinct Mesh triangles | **21,865** |
| MeshRenderer placements | **747** |
| Sum of triangles multiplied by placements | **213,618** |
| Mesh objects with invalid index or object boundaries | **0** |
| Material objects successfully decoded | **11** |
| Distinct original Shader objects successfully decoded | **4** |

These are **original serialized counts**, not real-time camera-visible triangle counts, draw calls, overdraw or FPS. All 747 placements were summed independently of view culling, LOD and visibility.

### Largest single-model contributors

| Original stored Mesh name | Placements | Triangles per mesh | Sum |
|---|---:|---:|---:|
| `hua_002` | 209 | 340 | **71,060** |
| `hua_001` | 287 | 216 | **61,992** |
| `PY5_bajiaoye_003` | 55 | 204 | **11,220** |
| `Mossy rock` | 19 | 573 | **10,887** |
| `PY5_dibiao_005` | 2 | 3,773 | **7,546** |
| `PY5_dibiao_004` | 2 | 3,528 | **7,056** |

The two flower meshes alone contribute **133,052 / 213,618 = 62.29%** of the *unculled* 747-decoration geometry.

## Eleven Material objects: exact scene-to-mesh triangle attribution

| Original material name | Renderer placements | Triangle placements | Share of 213,618 |
|---|---:|---:|---:|
| `mtl_PY5_hua_01` | 496 | 133,052 | 62.29% |
| `mtl_PY_shuye` | 78 | 15,912 | 7.45% |
| `mtl_PY5_shitou_02` | 41 | 15,394 | 7.21% |
| `mtl_Tex_02` | 4 | 14,602 | 6.84% |
| `mtl_YP5_dibiao_0804` | 5 | 13,230 | 6.19% |
| `mtl_PY5_gutou` | 27 | 8,401 | 3.93% |
| `HA5_WuJian_30` | 18 | 5,536 | 2.59% |
| `mtl_PYaaaa` | 64 | 3,854 | 1.80% |
| `mtl_PY5_shitou_01` | 7 | 2,431 | 1.14% |
| `mtl_PY_diaoxian_30` | 4 | 744 | 0.35% |
| `HA5_WuJian_31` | 3 | 462 | 0.22% |
| **Total** | **747** | **213,618** | **100%** |

The first material has **496 / 496** renderers with no saved baked-lightmap index; the other ten materials account for **251 / 251** with a saved index. No saved baked-lightmap index does **not** mean an unlit runtime surface.

## Actual referenced Shader objects, not inferred from material labels

| Source Shader name | Material objects | Original Shader pass count | Saved technical behavior |
|---|---:|---:|---|
| `SoFunny/SPToon/SPToonNew_v2_Demo` | **8** | **2** | Opaque Toon pass with ZWrite=1, back culling; separate DepthOnly pass with ColorMask=0 |
| `Unlit/GrassShaderWind` | **1** | **1** | `RenderType=Opaque`, `RenderPipeline=UniversalPipeline`, ZWrite=1, cull off, no alpha blending |
| `SoFunny/SPToon/SPToonNew_v2_Fade` | **1** | **1** | `RenderType=Transparent`, SrcAlpha/OneMinusSrcAlpha blend, **ZWrite=1** |
| `SoFunny/Plain3SPToon/SPToonNew_v4_Terrain` | **1** | **3** | Opaque Terrain, ShadowCast, and DepthOnly passes, depth-writing on all three |

**Important details and cautions:**

- The `SPToonNew_v2_Fade` transparent shader stores **ZWrite enabled**, unlike a typical standard transparent blending preset. Do not flatten this into "all transparency has depth writing disabled" or infer runtime transparency sorting without testing.
- The `GrassShaderWind` identifier proves the source Shader name and its declared render state. It does **not** by itself verify live vertex wind motion or determine its amount.
- The `SPToonNew_v4_Terrain` main pass stores **512 vertex and 512 fragment subprogram entries**. Those are *compiled variants/entries*, **not** simultaneous passes or draw calls. The other two passes hold three entries each.
- All **11 Material objects** store `m_EnableInstancingVariants=false`. Some Shader passes expose instancing variants; that does not mean the source enabled Material-level instancing.
- The flower Material `_MainTex` points to an *external* texture (fileID=2) and its `_WindSpecular` points to another external texture (fileID=3). Both are **referenced pointers**, not local payloads in that Material bundle, and their target image metadata is **not** claimed as decoded here.
- The decorative Terrain Material stores **10 texture slot definitions**, including control/splat references, but only its actual Shader pass declarations—not full pixel blending equations—have been verified.

## Implications for original Titan Legends Android art (not applied)

- Investigate reducing polygon counts in **dense decorative plants and flowers** before indiscriminately reducing already inexpensive rocks. A separately authored stylized forest can preserve silhouette with fewer triangles, alpha/vertex techniques and careful overdraw testing.
- Prefer an independently designed **small set of original opaque toon shaders**, a separately benchmarked grass/wind shader and transparent effects where needed. Avoid blindly copying Unity render queue numbers, shader features, variant counts, or full terrain pipeline into Godot 4.7.2.
- Benchmark real Android camera scenes before choosing terrain grass/foliage LOD and density; a source mesh multiplied by instance count does not directly predict FPS.
- **No visual or gameplay code changes performed.**

## Machine-readable metadata-only outputs

- `ulala_plain_nonlod_31_mesh_11_materials_4_shaders_verified_2026_11_08.json`: full per-Mesh provenance, counts, Material fields and Shader pass render states, together with exact validation checks.
- `ulala_plain_nonlod_31_mesh_triangle_cost_2026_11_08.csv`: all 31 distinct original Mesh objects with vertex count, triangle count, placements and derived triangle cost.
- `ulala_plain_nonlod_material_shader_triangle_cost_2026_11_08.csv`: all 11 Material objects, the mapped Shader name, baked lightmap coverage and polygon share.

**Remaining research:** resolve the specific texture targets and image format of each `Plain` Material, camera-visible decoration populations and effective shadow/transparent overdraw. Nothing has been copied into Titan Legends game assets.
