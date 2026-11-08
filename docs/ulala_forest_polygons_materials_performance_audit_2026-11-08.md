# Ulala Forest — verified polygon and material cost audit (2026-11-08)

**Read-only reference study of the user's own original nine-part Ulala archive.** No original meshes, texture payloads, shader programs, or assets are checked into Titan Legends. **No Titan Legends graphics or scenes were changed.**

## Binary sources and reproducibility

- Original `forest.unity_ab` (`BuildPlayer-Forest` scene, Unity 2019.4.16f1c1, SerializedFile v21): all 1,291 MeshFilters, 1,271 MeshRenderers, their owning GameObjects, and four material pointers.
- Mesh classID 43 objects in original `forest.unity_ab_shared` (**31 mesh definitions**) and `buluo.unity_ab_shared` (ground Mesh definition), plus previously validated pathID-level mesh metadata from `yl_shudong_001a.prefab_ab_shared` and `yl_dashitou_001.prefab_ab_shared`.
- Four original Forest material bundles: `yl_wujian_002.mat_ab_shared`, `yl_wujian_001.mat_ab_shared`, `mtl_yl_guang_01.mat_ab_shared`, and `yl_dibiao1.mat_ab_shared`. Their classID 21 Material and classID 28 Texture2D objects were fully parsed, and all serialized object byte ranges and texture stream bounds verified.
- The component-to-Mesh `fileID` and `pathID` joins resolve all **54 distinct nonbuilt-in Mesh** objects. **20 built-in Cube MeshFilters are collider-only objects** with no MeshRenderer, and are excluded from rendering triangle totals.

## Triangle counts directly from original mesh buffers

| Mesh source | Distinct meshes used | Rendered MeshFilter placements | Unique triangles | Triangles across placements |
|---|---:|---:|---:|---:|
| `forest.unity_ab_shared` | 24 | 678 | 4,982 | 148,308 |
| `yl_shudong_001a` (trees, leaves, roots) | 20 | 320 | 6,999 | 127,989 |
| `yl_dashitou_001` (rocks) | 9 | 268 | 1,060 | 23,613 |
| `buluo.unity_ab_shared` | 1 | 5 | 1,600 | 8,000 |
| **Total** | **54** | **1,271** | **14,641** | **307,910** |

Every used Mesh object has an index buffer whose triangle/index bounds are valid. 16-bit indices are used for all 54. The **307,910** value is simply **sum of the triangle count of each distinct Mesh multiplied by the number of MeshRenderer-linked placements**, without camera visibility, occlusion, distance culling, LOD or transparency assumptions. It is *not* a frame-captured polygon count, draw-call count, triangle throughput measurement, or FPS estimate.

The 20 collider-only Unity primitives explain the difference between **1,291 MeshFilters** and **1,271 MeshRenderers**.

Largest per-model contributions:

- `yl_bajiaoye_003`: 41 placements × 1,724 tris = 70,684
- `yl_cao_004`: 89 × 280 = 24,920
- `yl_cao_007b`: 29 × 784 = 22,736
- `yl_cao_002`: 79 × 252 = 19,908
- `yl_dashitou_005`: 198 × 78 = 15,444

## Material and geometry cross-check

Every one of the **1,271** scene MeshRenderer material pointers was matched to the corresponding exact material identity, and its owning MeshFilter to a validated mesh pathID. Their triangle totals reconcile *exactly* to the independent Mesh-only report (307,910).

| Original material | Renderer components | Triangle placements | Share | Original main texture |
|---|---:|---:|---:|---|
| `YL_wujian_002` | 984 | 208,882 | 67.84% | `yl_wujian_002`, 1024×1024, ETC2_RGB4 (45), 11 mips |
| `YL_wujian_001` | 275 | 91,014 | 29.56% | `yl_wujian_001`, 1024×1024, ETC2_RGB4 (45), 11 mips |
| `YL_DiBiao1` | 5 | 8,000 | 2.60% | `YL_DiBiao_1`, 2048×2048, ETC2_RGB4 (45), 12 mips |
| `mtl_YL_guang_01` | 7 | 14 | <0.01% | `tex_YL_guang_01`, 512×512, ETC2_RGBA8 (47), 10 mips |
| **Total** | **1,271** | **307,910** | **100%** | |

All four textures and their associated material `_MainTex` pointers were decoded directly. The four source resource streams occupy **4,543,896 bytes** total (stored compressed textures; **not** guaranteed runtime GPU memory consumption). Their stream sizes and ranges validate against the original UnityFS resource nodes.

### Stored shader properties — important cautions

- `YL_wujian_001` and `YL_wujian_002` both point to Shader `fileID 1 / pathID 4348326541267101455`, and have identical keyword strings `USEFOG _NORMALMAP`. Their custom render queues are **2066** and **2070** respectively.
- All four materials store `_ZWrite=1` and `_AlphaClip=0`; the two `YL_wujian` materials additionally store `_SrcBlend=1`, `_DstBlend=0` and `_UseLeafSway=0`.
- All four have serialized `m_EnableInstancingVariants=false`.
- Each material has **one non-null local `_MainTex`**. `YL_DiBiao1` additionally has `_SecTex` pointer null.
- The presence of `_NORMALMAP` keyword by itself does **not** demonstrate a bound normal texture or active normal mapping.
- Render queues, stored blend/clip/cull values and shader keywords are only **serialized metadata**, not definitive proof of the compiled shader's transparency mode, actual fragment complexity or realized wind animation. Direct Shader classID 48 source or compiled variants would be necessary.
- These figures do not prove Unity static batching, runtime instancing, camera culling, texture- or mesh-memory allocation, or actual Android FPS.

## Independent-game design implications for Titan Legends — no changes yet

1. For an *originally designed* stylized Android forest, prioritize lowering the triangle count of **high-complexity foliage instantiated frequently**, not just the most often reused low-poly rocks.
2. Consider reuse and batched rendering of original Godot 4 meshes, and evaluate transparent foliage overdraw on target phones. Different Godot renderers/devices can have very different costs.
3. Maintain separate collision proxies and adjust LOD/distance culling through gameplay camera tests.
4. **Do not copy Ulala art, textures or shader bytecode**. The reference helps set performance priorities and author original stylized assets.

## Audit files generated locally

- `ulala_forest_weighted_mesh_polygon_audit_2026_11_08.json`
- `ulala_forest_mesh_polygon_cost_2026_11_08.csv`
- `ulala_forest_material_binary_metadata_verified_2026_11_08.json`
- `ulala_forest_texture2d_metadata_verified_2026_11_08.json`
- `ulala_forest_mesh_material_cost_validated_2026_11_08.json`

These files contain metadata only, **not** the underlying copyrighted original data.
