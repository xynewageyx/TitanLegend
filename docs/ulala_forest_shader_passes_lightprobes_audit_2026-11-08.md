# Ulala Forest: original Shader objects and LightProbes — directly verified 2026-11-08

**Source and scope:** Read-only examination of the user's original multipart Ulala archive (Unity **2019.4.16f1c1**, SerializedFile v21). These findings are *research evidence*, not files or instructions for copying copyrighted Ulala shader code, meshes, textures, or art. **No Titan Legends game graphics have been changed.**

## 1. Original common Shader bundle located

The asset file `assets/AssetBundles/Asset/assets/shaders` (8,664,523 on-disk bytes) is a UnityFS bundle containing the serialized node **`CAB-259b3a6b4ed11e2f71f4a3e2ebc98a40`**, about 22.57 MB uncompressed and **154 classID 48 Shader objects**.

All four previously decoded Forest materials point through the *actual* external serialized-file reference tables to this CAB (their `fileID=1`). Three distinct Shader objects were found by exact `pathID` and decoded with the classID-48 Unity TypeTree; **all three consumed their exact serialized object size**, including the program blob but without exporting its bytes:

| Materials | Original Shader name | Shader pathID | Serialized bytes | Serialized properties |
|---|---|---:|---:|---:|
| `YL_wujian_001`, `YL_wujian_002` | `SoFunny/SPToon/SPToonNew_v2_Demo` | `4348326541267101455` | 40,924 | 13 |
| `YL_DiBiao1` | `SoFunny/SPToon/SPToon` | `-6434712721699949209` | 970,580 | 28 |
| `mtl_YL_guang_01` | `SoFunny/Particles/Blended` | `5483553206422771921` | 8,832 | 4 |

Each has one serialized SubShader. The two toon shaders' SubShader tags are **`RenderType=Opaque`** and **`QUEUE=Geometry+20`**, while the particle effect has **`RenderType=Transparent`** and **`QUEUE=Transparent`**.

### Actual per-pass render states

Directly decoded `m_ParsedForm.m_SubShaders[].m_Passes[].m_State`, rather than guessing from saved Material floats:

| Shader / pass name | Vertex subprogram entries | Fragment subprogram entries | ZWrite | ZTest | Culling | Blend | Color mask |
|---|---:|---:|---:|---:|---|---|---:|
| SPToonNew_v2_Demo / **SPToon** | 36 | 36 | 1 | 4 (LEqual) | 2 (Back) | One / Zero | 15 |
| SPToonNew_v2_Demo / **DepthOnly** | 3 | 3 | 1 | 4 (LEqual) | 0 / `_Cull` property | One / Zero | **0** |
| SPToon / **SPToon** | 1,152 | 1,152 | 1 | 4 (LEqual) | 2 (Back) | One / Zero | 15 |
| Particles/Blended / unnamed pass | 3 | 3 | **0** | 4 (LEqual) | **0 (Off)** | **SrcAlpha / OneMinusSrcAlpha** (5/10) | 15 |

Notes:
- `ColorMask=0` on `DepthOnly` is explicit evidence that this shader pass writes depth without writing color. It does **not** prove when the pass is executed by the original Unity rendering pipeline.
- There are **1,152 serialized vertex and fragment subprogram entries** for the larger Toon shader. This is a count of stored shader *variants/entries*, **not** simultaneous GPU programs, draw calls or runtime work.
- The first toon shader has `m_HasInstancingVariant=true` in both passes, but the separate Forest Material objects store `m_EnableInstancingVariants=false`. Shader capability does **not** prove active material instancing or batching in-game.
- Stored `ShaderIsBaked=true` and program blob lengths are metadata, not proof of platform-specific features being executed.
- These names and render states prove that some saved forest materials are technically **opaque** while the glow material has a **transparent alpha-blended pass**. They do not establish the full artistic appearance of all scenes.

### Material coverage in previously validated Forest scene

- `YL_wujian_002`: **984** MeshRenderers
- `YL_wujian_001`: **275** MeshRenderers
- `mtl_YL_guang_01`: **7** MeshRenderers
- `YL_DiBiao1`: **5** MeshRenderers
- Combined **1,271** renderers; numbers are serialized placements, not on-screen draw calls.

## 2. LightProbes resource is empty

The Forest `LightmapSettings` contains `fileID=1,pathID=12`; this was resolved to the actual **classID 258 LightProbes** object in the scene's sibling serialized node `BuildPlayer-Forest.sharedAssets`.

- Original object pathID **12**, name `(Clone)`, length **40 bytes**.
- All **seven** uint32 array/map sizes after the aligned name are **0**: `m_Tetrahedra`, `m_HullRays`, `m_ProbeSets`, `m_Positions`, `m_NonTetrahedralizedProbeSetIndexMap`, `m_BakedCoefficients` and `m_BakedLightOcclusion`.
- Parser consumed **40/40 bytes**. This is an *empty stored probe collection*, not evidence that the scene uses nonzero baked probe SH data.
- Prior original scene audit found **1,263/1,271** MeshRenderers with baked lightmap indices and five valid 1,024² ETC_RGB4 lightmaps. All renderers' `lightProbeUsage=1` **does not imply populated probe positions**, and shader symbol names such as `unity_SHAr` are not probe records.

## Relevance to Titan Legends (no graphics changes yet)

For an independently authored Android Godot 4.7.2 environment, test a small number of custom opaque toon shaders with baked/background illumination and a separate alpha-blended effect shader, rather than transferring the source shader variants or relying on a heavy all-in-one shader. Evaluate scene instancing, lightmapping, culling and transparency overdraw on a real Android target before setting thresholds.

## Reproducible metadata-only artifacts

- `ulala_forest_shader_render_state_and_lightprobes_verified_2026_11_08.json`: shader names, pathIDs, parsed-object byte counts, declared passes and their states, subprogram-entry counts, original source SHA-256 and LightProbe counts.
- `ulala_forest_shader_passes_verified_2026_11_08.csv`: concise four-row pass-state table.

All original shader bytecode, texture/image data, actual Lightmap pixels and mesh vertices remain outside the GitHub repository. **No Titan Legends visuals changed.**
