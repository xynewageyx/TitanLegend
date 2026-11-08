# Ulala original TerrainData: CAB-resolved heightfield audit (2026-11-08)

**Evidence:** direct binary inspection of the user's original nine-part Ulala 7z backup, Unity 2019.4.16f1c1. This is a read-only factual reference report, **not** a proposal to copy Ulala art into Titan Legends.

## Discovery

Scanned the UnityFS block-directory metadata of all **3,076** `*_ab_shared` bundles in the archive. The exact serialized-file node `CAB-0293f4be976f0afb9e26f81d9ff8a114` occurs once, in:

`assets/AssetBundles/Asset/assets/models/article/auto/bossscene/mtl_bs_dibiao_01.mat_ab_shared`

The found serialized file is Unity v21, containing **one TerrainData object (class 156)** with **pathID `-4041660991872354623`**, exactly matching the previously decoded external pointer from `terrain_01.prefab_ab_shared`. The TerrainData object is **575,928 serialized bytes** and the type-tree-based field reader consumed exactly **575,928 / 575,928 bytes**, including arrays and alignment.

## Actual heightfield measurements

| Field | Verified value |
|---|---|
| TerrainData name | `PY5_dibiao_Terrain_01` |
| Heightmap resolution | **513 × 513** |
| Stored uint16 samples | **263,169** |
| Nonzero height samples | **0** |
| Minimum / maximum | **0 / 0** |
| Stored `m_Heightmap.m_Scale` (x,y,z) | **(0.15625, 600, 0.46875)** |
| Horizontal extent, (resolution−1) × step | **80 × 240 Unity world units** |
| Vertical range parameter | **600** (not observed elevation: the heightfield is flat) |
| Alphamap resolution | **512** |
| Basemap resolution | **1024** |
| Terrain-layer references | **5** |
| Alpha texture references | **2** |
| Detail patch array | **1,024** entries |
| `m_PatchCount` / `m_PatchSamples` | **32 / 16** |
| Detail prototypes | **0** |
| Tree instances | **0** |
| Tree prototypes | **0** |
| Waving grass strength / amount / speed | **0.5 / 0.5 / 0.5** (stored fields, not evidence of visible grass) |

The five TerrainLayer pointers all resolve locally to **`mtl_layer_01`–`mtl_layer_05`**. The two alphamap pointers resolve locally to **`SplatAlpha 0`** and **`SplatAlpha 1`**. This source includes seven Texture2D objects, five TerrainLayer objects and the one TerrainData object.

The height sample block consists of **526,338 bytes** of little-endian uint16 values; all 263,169 samples were directly checked and are zero. The 600-unit Y scale does **not** imply 600 units of actual relief.

## Evidence from full Unity scenes

Parsed the original `plain.unity_ab` scene, not merely its filename. Its `BuildPlayer-Plain` serialized scene has an external-reference table with **45 entries**. The **44th** points directly to `CAB-0293f4be976f0afb9e26f81d9ff8a114`.

The Plain scene's `Terrain` (class 218, pathID **105062**) and `TerrainCollider` (class 154, pathID **95837**) both refer to `fileID 44, pathID -4041660991872354623`. This **confirms the actual Plain scene references the same flat TerrainData**. The scene also contains **19,191 MeshFilter** and **19,191 MeshRenderer** components; flat TerrainData does *not* mean every visible ground/object mesh is flat.

The `forest.unity_ab` scene contains **5,447 objects**, including **1,291 MeshFilter** and **1,271 MeshRenderer** components, with no local Terrain, TerrainCollider or TerrainData class object. The `plain.unity_ab` `BuildPlayer-Plain` scene contains **105,075 objects**. These are component/object counts, not distinct meshes, instances simultaneously on screen, draw calls or measured Android GPU performance.

## Important separation

- This TerrainData asset is stored in a **boss-scene material bundle** and used by the **Plain** scene. Do **not** treat its flat heights as proof every Ulala environment has no elevation.
- `mtl_BS_dibiao_01` with its five TerrainLayers and two splat-alpha textures is **not automatically equivalent** to the independently researched family of four-layer `mtl_CJ_Terrain` shaders.
- The Forest scene is predominantly MeshFilter/MeshRenderer-based in the scanned scene file, and requires a separate geometry, transforms, lighting and material analysis.
- No Ulala original textures, heightfield data grid, meshes or other asset payloads have been committed or copied into Titan Legends.

**Local machine-generated metadata-only evidence:** `ulala_bossscene_terraindata_full_metadata_verified_2026_11_08.json`; `ulala_scene_classid_scan_verified.json`; `ulala_shared_cab_scan.json`.

**Status:** reference analysis only; no changes to Titan Legends game graphics.
