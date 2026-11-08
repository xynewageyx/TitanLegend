# Ulala Forest lighting, fog, shadows and lightmap audit — 2026-11-08

**Scope:** Direct read-only decoding of the user's original `forest.unity_ab` (Unity **2019.4.16f1c1**, SerializedFile v21). Research metadata only; **no original Ulala pixels, source meshes, shaders or other game payloads are added to Titan Legends, and no Titan Legends scene or renderer is changed.**

**Input SHA-256:** `acf2945d36b56835df9911d82122a89dac39361c6687b804195d3439d7427e7f`.

## Scene lighting from original serialized component data

The original `BuildPlayer-Forest` scene contains:
- **52 Light** components; all have `m_Enabled=true`.
- Unity light types (stored enum IDs): **37 point lights** (2), **8 spotlights** (0), **4 directional lights** (1), **3 area lights** (3).
- Their `LightBakingOutput.isBaked` fields identify **51 baked lights** and **one non-baked directional light** (`Directional Light`).
- Exactly **one** Light stores a nonzero `m_Shadows` shadow type: `Main_Baked Light` is a baked directional light with shadow type 1 (hard) and stored strength ~0.6. Its shadow flag alone does **not** imply realtime shadow-map rendering.
- One scene Camera named `Main Camera`: active, **100° FOV**, near clip **0.01**, far clip **65**, `m_HDR=false`, `m_AllowMSAA=false`, `m_OcclusionCulling=true`. These are saved camera settings, not verified game runtime settings.

### RenderSettings (directly decoded)

| Setting | Original value |
|---|---|
| Fog enabled | **true** |
| Fog mode | **1 = exponential** |
| Fog density | **0.01** |
| Fog color (linear serialized components) | **R 0.1877, G 0.4451, B 0.6981, A 1** |
| Stored linear fog start / end | **8 / 85** (**not** active in exponential fog mode) |
| Ambient intensity | **1.0** |
| Ambient mode | **1** |
| Skybox material reference | `fileID=11, pathID=-8064568243870292543` |
| Sun light reference | **null** (`fileID=0, pathID=0`) |
| Default reflection mode / resolution | **0 / 128** |

The skybox's **fileID 11** resolves, via the actual scene's external table, to the original bundle `skymat2.mat_ab_shared`; its exact referenced Material object and shader code remain to be inspected. Null `RenderSettings.m_Sun` does not mean the scene has no directional lights.

## Five embedded lightmaps: original texture bytes validated

The same UnityFS archive contains a second serialized file `BuildPlayer-Forest.sharedAssets` (**12 objects**), of which five are Texture2D objects corresponding to **all five** color-lightmap entries in `LightmapSettings`.

| Scene lightmap index | Texture2D pathID | Original name | MeshRenderers assigned |
|---|---:|---|---:|
| 0 | 3 | `Lightmap-0_comp_light` | 41 |
| 1 | 4 | `Lightmap-1_comp_light` | 52 |
| 2 | 5 | `Lightmap-2_comp_light` | 123 |
| 3 | 7 | `Lightmap-3_comp_light` | 481 |
| 4 | 6 | `Lightmap-4_comp_light` | 566 |
| **Total** | | **5** | **1,263** |

All five are **1024 × 1024**, **ETC_RGB4** (Unity TextureFormat 34), **11 mipmaps**, with **699,064 image bytes each embedded** in their Texture2D object, i.e. **3,495,320 bytes** combined. Image metadata and each entire serialized object boundary were verified. No original image bytes were exported.

The five `LightmapSettings.m_Lightmaps` color pointers resolve exactly to those objects; the corresponding directional-lightmap and shadowmask pointers are null. `LightmapSettings.m_EnableBakedLightmaps=true`, `m_EnableRealtimeLightmaps=false`, `m_UseShadowmask=false`. There is one external LightProbes reference (`fileID=1,pathID=12`).

### All 1,271 MeshRenderer components checked

Every renderer object parses to its exact original byte boundary:
- **1,263** have a valid baked lightmap index (0–4).
- **8** have sentinel index **65535** (no baked lightmap assigned).
- **1,271 / 1,271** have stored shadow casting mode **1** and `receiveShadows=true`; these are renderer flags, *not* measured realtime shadow cost.
- None references a dynamic lightmap index (all 65535).
- No explicit static-batch submeshes or non-null static batch roots appear in these scene MeshRenderer records.
- Light probe usage and reflection probe usage are both set to 1 for every renderer.

The scene clearly contains a **baked/static lighting-heavy setup** in its serialized data. This cannot establish its actual graphics appearance, GPU shadow workload, runtime script overrides, live draw calls or FPS on a phone.

## Conclusions to carry forward for original Titan Legends designs (no implementation yet)

For an independently authored, stylized Godot 4.7.2 forest intended for Android, a potential *separately benchmarked* approach is to use baked/static illumination for background scenery, restrict costly dynamic shadows and render distances, and tune fog to the actual combat camera. The original Unity values are evidence about **Ulala's saved source scene** only; they are not Godot rendering presets and should not be copied without testing.

## Generated machine-readable audit files

- `ulala_forest_fog_lighting_shadows_direct_verified_2026_11_08.json`
- `ulala_forest_5_lightmaps_verified_2026_11_08.json`
- `ulala_forest_lightmap_assignment_2026_11_08.csv`

**Remaining:** inspect `skymat2` reference, identify referenced original shader metadata/programs, validate scene light probes, compare quality and performance across Android Godot renderers. **No game graphics changed.**


## Skybox source bundle verified end-to-end

The scene's `RenderSettings.m_SkyboxMaterial` pointer (`fileID=11, pathID=-8064568243870292543`) maps through the Forest external dependency table to `assets/environment/materials/skymat2.mat_ab_shared` (serialized CAB `CAB-3883c56e6f974269502c6e71ee578691`). The exact **classID 21 Material** with that pathID is named `SkyMat2`.

- The material's `_Tex` pointer resolves to the **classID 89 Cubemap**, `pathID=9004076750916660870`, named `SkyMat2`.
- Original Cubemap metadata: **1024 × 1024**, **6 faces**, **RGBA32** (TextureFormat 4), **1 mip level**, **4,194,304 bytes per face** and **25,165,824 streamed bytes** in total (**24 MiB**).
- The material stores shader keywords `_EMISSION _SUNDISK_HIGH_QUALITY`, `_Exposure=0.53`, `_SunSize=0.04`, `_SunDisk=2`, `_AtmosphereThickness=1` and `_Rotation=0`. These are **serialized parameters**, not proof of a particular compiled sky shader or runtime appearance.
- The same source bundle contains Texture2D objects `Forest_FR1` (**1024² ETC_RGB4**), `Forest_UP` (**1024² ETC_RGB4**) and `Forest_BT` (**1×1 RGB24**). The decoded `SkyMat2` Cubemap's six `m_SourceTextures` pointers are null; these other textures should **not** be asserted to be live inputs to the cubemap shader.
- The source resource stream size is **26,563,956 bytes**. Its four image ranges occupy the stream exactly except for **one alignment byte at offset 1,398,131**; all stream ends and serialized object boundaries validate.

This verifies a **large pre-existing baked Cubemap sky asset** (not six shaders running per frame). Its memory footprint is material for mobile device budget discussions, but this source is not a justified Godot runtime memory estimate. No texture pixels or source material programs were copied.

Companion metadata report: `ulala_forest_skybox_skymat2_direct_verified_2026_11_08.json`.
