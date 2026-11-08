# Ulala Plain: all 11 decoration materials' Texture2D references verified — 2026-11-08

**Read-only technical research.** This report records metadata from the user's original multipart Ulala backup; it contains no source image/texture payload, copyrighted asset data, game art or shader bytecode. **No Titan Legends graphics or gameplay code was changed.**

## Direct original-binary evidence

Starting with the 747 non-LOD MeshRenderers in the original `Plain` scene, eleven original classID-21 Material objects were previously decoded with their complete `m_SavedProperties.m_TexEnvs` fields. This pass directly re-read the **13 original extracted material bundles**, found the two unresolved flower texture sources and three remaining external CABs in the user's original 7z archive, and extracted the **five referenced source bundles** for read-only analysis:

| Original Unity CAB | Original source bundle | Referenced fields |
|---|---|---|
| `CAB-acd766e181821d15c1140ac8f30836d7` | `mtl_py5_hua.mat_ab_shared` | Flower `_MainTex` |
| `CAB-d74fa25054788e643de64a3e4cf75ff1` | `mtl_af_cao_01.mat_ab_shared` | Flower `_WindSpecular` |
| `CAB-eeb33bd82d5f2b62b5041b4b92411cb2` | `mtl_2years_diaoxiang.mat_ab_shared` | Decoration `_MainTex` |
| `CAB-7a6a836bdaccbc290deb49a40afc1669` | `mtl_bs_shikuai_01.mat_ab_shared` | Decoration `_MainTex` |
| `CAB-0293f4be976f0afb9e26f81d9ff8a114` | `mtl_bs_dibiao_01.mat_ab_shared` | Terrain control and splat slots |

All five source CAB IDs were located by scanning original UnityFS directory metadata of archive entries (not filename inference). For every Texture2D pointer, the referenced **fileID resolves to a CAB through that material's own serialized external-reference table**; the **pathID is then found in the exact original classID-28 object**. The decoded Texture2D object records consume their full serialized byte count, and each external image stream offset + size was validated against the original resource nodes.

## Texture slot reconciliation across eleven Plain decoration materials

| Metric | Verified result |
|---|---:|
| Saved `m_TexEnvs` entries | **23** |
| Assigned pointers, all resolved to original Texture2D | **18** |
| Explicitly null/unassigned entries | **5** |
| Unresolved assigned pointers | **0** |
| Distinct referenced Texture2D objects | **16** |
| Distinct TextureFormats | **13 ETC2_RGB4, 1 ETC2_RGBA8, 2 RGBA32** |
| Sum of stored image sizes across the 16 unique source objects | **8,301,424 bytes (~7.92 MiB)** |
| Embedded image bytes within two RGBA32 control textures | **2,796,200 bytes** |

**Do not mistake 18 assigned slots for 18 separate image files**: two source textures are each referenced by more than one material/slot. Summed image byte sizes are original stored source bytes, **not measured Android runtime GPU texture allocation**, and the 16 textures need not be simultaneously resident.

### Two original flower textures — source directly confirmed

Both slots in `mtl_PY5_hua_01` are externally referenced:

| Material slot | True saved Texture2D name | Original dimensions | Format | Mipmaps | Source image bytes |
|---|---|---|---|---:|---:|
| `_MainTex` | `tex_PY_hua` | 256 × 256 | ETC2_RGB4 (45) | 9 | **43,704** |
| `_WindSpecular` | `WindmutatioGB2 Specular` | 1024 × 1024 | ETC2_RGB4 (45) | 11 | **699,064** |

Both streamed resource ranges exactly cover their respective `.resS` nodes (offset 0), and `m_CompleteImageSize` matches `m_StreamData.size` for each. The saved additional flower slots `_Wind` and `_GrassColor` are **null**, despite their names. The flower material stores `_WindSpeed≈1.36`, `_WindStrength=1.0`, `_VerticalBillboarding=1`, `_UseLeafSway=0` (previously decoded). These are **stored configuration values**; they do not prove animated wind displacement without examining the actual shader instructions at runtime or static instruction level.

### Ground material: two embedded RGBA32 splat controls

The original `mtl_YP5_dibiao_0804` has **7 populated** texture pointers: `_Control`, `_Control2`, `_Splat0` through `_Splat4`; `_Splat5` through `_Splat7` are null.

- `_Control` resolves to **`SplatAlpha 0`**, **512×512 RGBA32**, 10 mips, **1,398,100 embedded bytes**.
- `_Control2` resolves to **`SplatAlpha 1`**, same dimensions, format, mipmap count and image size.
- `_Splat0`–`_Splat4` resolve to **`Tex_01`–`Tex_05`**, 512×512 ETC2_RGB4 with 10 mips each. Three are local to the source Material bundle and two resolve to the external bossscene TerrainData CAB.
- Both control textures are **embedded in their classID-28 object** (not streamed), while the relevant ETC2 color textures are streamed. All record byte boundaries validated. This distinction matters: absent `m_StreamData` is not a missing image if the `image data` field is populated.

### Other referenced textures

| Material / main texture | Verified original texture | Dimensions / format |
|---|---|---|
| `HA5_WuJian_30`, `HA5_WuJian_31` | `tex_PY_shu` (one shared texture) | 512×512 ETC2_RGB4 |
| `mtl_PY5_gutou` | `tex_PY5_gutou` | 512×512 ETC2_RGB4 |
| `mtl_PY5_shitou_01` | `tex_PY5_shitou` | 512×512 ETC2_RGB4 |
| `mtl_PY5_shitou_02` | `tex_PY5_shitou_02` | 512×512 ETC2_RGBA8 |
| `mtl_PY_diaoxian_30` | `tex_PY_shuPY_diaoxian_005` | 512×512 ETC2_RGB4 |
| `mtl_PY_shuye` | `tex_PY_shuye` | 256×256 ETC2_RGB4 |
| `mtl_PYaaaa` | `tex_PY1_WuJian_zj` | 2048×2048 ETC2_RGB4 |
| `mtl_Tex_02` | `Tex_02` | 512×512 ETC2_RGB4 |

## Constraints and next checks

- Linking a texture slot to a saved texture proves a serialized reference, **not that the runtime shader samples it**. A wind-related name does not itself prove wind animation.
- Physical runtime memory, alpha overdraw, culling, texture cache residency and shader instruction timings were not measured on an Android device.
- For Titan Legends, the next step is to *design independently authored* low-cost grass/flower textures and test Godot 4.7.2 wind/visibility/overdraw, **after reference analysis**.
- **No source texture, image or Unity material was imported into Titan Legends.**

## Generated metadata-only audit exports

- `ulala_plain_material_texture_slots_resolved_2026_11_08.json`: 23 verified field-level references; CAB, pathID, exact source bundle, decoded Texture2D metadata and validation results.
- `ulala_plain_11_material_texture_slots_verified_2026_11_08.csv`: spreadsheet-friendly summary, one row per saved texture slot.
