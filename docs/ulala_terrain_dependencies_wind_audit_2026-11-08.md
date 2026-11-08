# Ulala reference audit: Terrain instance, material dependencies and vegetation wind — 2026-11-08

**Read-only reverse engineering for research. No original Ulala assets were added to Titan Legends.** Original archive: user's nine-part 7z archive, Unity 2019.4.16f1c1; UnityFS LZ4 blocks and SerializedFile version 21 parsed directly. A dedicated JSON/CSV metadata export was generated locally.

## 1. Confirmed Unity terrain components

Bundle: `terrain_01.prefab_ab_shared`. Its local Unity object table contains **one Terrain (classID 218)**, **one TerrainCollider (154)** and a `TerrainLit` material. Important correction to earlier interpretations: **TerrainData is classID 156** and is **NOT embedded as a local object** in this prefab's shared bundle.

Both the Terrain and TerrainCollider reference the **same external TerrainData** via:

- `fileID=1`
- `pathID=-4041660991872354623`
- External serialized file: `CAB-0293f4be976f0afb9e26f81d9ff8a114`

Until that external file is located and classID 156 decoded, terrain dimensions, heightmap resolution and height samples **remain unknown**.

**Directly parsed component settings:**

| Unity Terrain setting | Stored value |
|---|---:|
| Tree distance | 5000 |
| Tree billboard distance | 50 |
| Tree crossfade length | 5 |
| Maximum full tree LOD count | 50 |
| Detail object distance | 80 |
| Detail object density | 1 |
| Heightmap pixel error | 5 |
| Splatmap distance | 1000 |
| Heightmap max LOD | 0 |
| Draw heightmap | true |
| Draw instanced | false |
| Draw trees and foliage | true |
| Enable tree colliders | true |

These are **serialized config values**, not observed real-world draw distances, frame rate, or evidence of simultaneously rendered objects.

The local `TerrainLit` material stores `_NumLayersCount = 1`, `_EnableHeightBlend = 0` and fifteen texture slots whose references are currently null in that local material. **Do not assume it is the same shading pipeline** as the separate four-layer `mtl_CJ_Terrain` material family below.

## 2. Five custom four-layer terrain materials, now resolved end-to-end

Five original bundles directly decoded: `mtl_cj_terrain_001`, `003`, `004`, `005`, `006`. Together they contain **11 Texture2D objects** and **5 Material objects**. Each material contains one control map, four color layer slots and four optional normal layer slots (nine stored texture slots).

| Material | Control map (local) | Resolved slots | Unresolved external | Null |
|---|---|---:|---:|---:|
| 001 | `tex_CJ_Terrain_001` | 6 | 1 | 2 |
| 003 | `tex_CJ_Terrain_007` | 6 | 1 | 2 |
| 004 | `tex_CJ_Terrain_004` | 6 | 0 | 3 |
| 005 | `tex_CJ_Terrain_005` | 6 | 1 | 2 |
| 006 | `tex_CJ_Terrain_006` | 6 | 1 | 2 |

**Externally stored layer texture references are now positively resolved**, by parsing the SerializedFile external-reference table and matching the referenced `CAB-16915c04cb5c5f9c3e3683ef0bd61e74` against the source bundle `mtl_cj_terrain_001`, then matching each `pathID`. The previously unresolved normal texture reference points into a different CAB and still needs its target object located.

For all five custom terrain materials, the four layer tiling values are **6.9 / 11.4 / 9.3 / 9.0**. `_ColorIntensity` = 0.69 and `_ColorRange` = 0.649. `mtl_CJ_Terrain_004` uniquely uses its local `tex_CreateCharater_05D` for layer 3, and its third normal layer is null. `mtl_CJ_Terrain_003`, `005`, and `006` primarily reuse the color textures defined in bundle 001 while having their own control map.

Five control textures are 512×512 ETC2_RGBA8. The material references reveal layer selection, not the exact shader blending mathematics.

## 3. Original vegetation material values

Four independently extracted source bundles:

| Material | Wind speed | Wind strength |
|---|---:|---:|
| `mtl_AF_cao_01` | 1.36 | 0.50 |
| `mtl_PY5_Grass` | 1.36 | 0.50 |
| `mtl_PYN_Grass_v2_01` | 1.36 | 0.62 |

The leaf material `mtl_PY_shuye` stores `_SwayFrequncy=0.4`, `_SwayStrength=0.6`, `_SwayDirection=15`, `_SwayPosition=0.5`, and `_SecTexXSpeed=_SecTexYSpeed=0.1`. However `_UseLeafSway=0`, so a stored set of sway parameters must **not** be represented as proof the effect was enabled at runtime.

## 4. Verification and open points

- Terrain and TerrainCollider's external `TerrainData` pointers match exactly.
- All five four-layer control textures resolve to local Texture2D objects.
- All five custom materials share the same stored tiling constants.
- External color layer references resolve to their real source CAB and pathIDs, not guessed matching names.
- Still missing: actual classID-156 TerrainData stream, heightmap dimensions, actual terrain mesh/heightfield, referenced normal texture in the other CAB, compiled shader implementation, and real animations/FPS.
- No copyrighted Ulala data payload exported to repository; research metadata only. **Do not change Titan Legends rendering based solely on this partial reference sample.**

Local companion metadata exports: `ulala_terrain_dependences_wind_verified_2026-11-08.json` and `ulala_terrain_material_comparison_2026-11-08.csv`.
