# Ulala water and vegetation texture metadata audit — 2026-11-08

**Scope:** Read-only inspection of two original UnityFS bundles from the user's nine-part 7z reference archive. This is **reference metadata**, not a plan to copy Ulala art. No original textures, pixels, meshes, materials or resource streams are checked in.

## Evidence and procedure

1. Reassembled nine archive parts locally and listed the 7z archive (27,270 entries).
2. Extracted the original `mtl_cj_water.mat_ab_shared` and `mtl_af_cao_01.mat_ab_shared` bundles.
3. Read UnityFS block tables, decompressed LZ4 blocks, parsed Unity SerializedFile **v21**, including the serialized class IDs, object byte ranges, and the `Texture2D` / `Cubemap` type trees.
4. Decoded stored Texture2D metadata and linked each `pathID` to the previously verified material texture pointers. Verified every resource data offset, size and stream boundary.
5. Resolved numerical TextureFormat IDs using the [Unity C# reference TextureFormat enum](https://github.com/Unity-Technologies/UnityCsReference/blob/master/Runtime/Export/Graphics/GraphicsEnums.cs).

Original editor version: **Unity 2019.4.16f1c1**. These figures are read from actual binary resource objects, not estimates.

## Water bundle: `mtl_cj_water.mat_ab_shared`

| Texture name | Dimensions | TextureFormat | Mips | Stream bytes | Material slot |
|---|---:|---|---:|---:|---|
| tex_Noise_anisotropic2 | 512 × 512 | ETC2_RGB4 (45) | 10 | 174,776 | `_NoiseTex` |
| tex_water_noise | 512 × 512 | ETC_RGB4 (34) | 10 | 174,776 | `_NormalTex` |
| Gradual_01 | 512 × 4 | ETC_RGB4 (34) | 1 | 1,024 | **No direct slot** |
| Waterfoam | 512 × 512 | ETC_RGB4 (34) | 1 | 131,072 | **No direct slot** |
| tex_detailfoam_01 | 512 × 512 | ETC2_RGB4 (45) | 10 | 174,776 | `_FoamDetailTex` |
| tex_mainfoam_01 | 512 × 512 | ETC2_RGB4 (45) | 10 | 174,776 | `_FoamMainTex` |
| tex_Caustics_01 | 256 × 256 | ETC2_RGB4 (45) | 9 | 43,704 | `_CausticsTex` |
| WaterDistortion | 512 × 512 | ETC2_RGB4 (45) | 10 | 174,776 | **No direct slot** |
| ramp | 256 × 16 | ETC2_RGB4 (45) | 9 | 2,824 | **No direct slot** |
| tex_ramp_maincolor | 512 × 16 | ETC2_RGBA8 (47) | 10 | 11,280 | `_ColorGradient` |
| **Cubemap SkyMat5** | **1024 × 1024 × 6 faces** | **RGBA32 (4)** | **1** | **25,165,824** | `_CubemapTexture` |

All **seven material texture slots** resolve to these binary objects: six Texture2D entries and one Cubemap. Four additional Texture2D objects have no direct slot **in this material**. This does **not** mean they are globally unused.

Resource stream coverage: **26,229,608 / 26,229,608 bytes accounted for**, with no gaps or overlaps.

The Cubemap `SkyMat5` has six 1,024 × 1,024 RGBA32 faces (4,194,304 bytes each), for 25,165,824 total bytes = 24 MiB. Its `m_CompleteImageSize` is the per-face size, so it must be multiplied by six when compared with the Cubemap stream size.

## Vegetation bundle: `mtl_af_cao_01.mat_ab_shared`

| Texture name | Dimensions | TextureFormat | Mips | Stream bytes | Material slot |
|---|---:|---|---:|---:|---|
| WindmutatioGB2 Specular | 1024 × 1024 | ETC2_RGB4 (45) | 11 | 699,064 | `_WindSpecular` |

Vegetation resource stream coverage: **699,064 / 699,064 bytes accounted for**, no gaps or overlaps. The other three vegetation material texture slots are null.

## Verification

- 11 Texture2D objects parsed with valid names, widths, heights, mip counts, numerical texture formats, stream offsets and stream sizes.
- 1 Cubemap parsed with six source pointers and matching face-size accounting.
- 12 / 12 resource byte ranges stay within their original `.resS` streams.
- 11 / 11 Texture2D stream sizes match `m_CompleteImageSize`.
- Both resource streams are **100% accounted for**, yielding **26,928,672 bytes** of stored image data across both bundles.
- No game graphics, original materials, or landscape scenes were changed in Titan Legends.

**Limits:** Only these two bundles were inspected. This does not cover the full Ulala landscape, prove which resources are loaded simultaneously at runtime, or imply that standalone unassigned textures are unused elsewhere. Avoid applying Unity resource payloads directly to Titan Legends; use the findings for independent, mobile-friendly art and technical decisions.
