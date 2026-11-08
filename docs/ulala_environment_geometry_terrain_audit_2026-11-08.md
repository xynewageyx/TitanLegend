# Ulala reference audit — environment meshes and four-layer terrain materials (2026-11-08)

Read-only measurements from the user's original nine-part Ulala archive, Unity 2019.4.16f1c1 SerializedFile v21. **Reference evidence only.** No Ulala meshes, textures or shaders are added to Titan Legends.

## New sample: 9 original UnityFS bundles

- Prefab-shared bundles: `env_af_baihuashu_01`, `env_af_caodui_01`, `env_af_huaduo_01`, `env_af_huaduo_02`, `env_af_yanshi_01`, `yl_dashitou_001`, `yl_shudong_001a`.
- Terrain-material-shared bundles: `mtl_cj_terrain_001` and `mtl_cj_terrain_003`.
- 35 distinct Mesh **objects** in six of seven prefab bundles. `env_af_baihuashu_01` has no embedded Mesh-class object in its shared bundle; this does not mean its prefab cannot refer to external geometry.
- Totals across those 35 mesh definitions: **7,893 vertices, 9,520 triangles**.
- Mesh distribution: grass clump 1 mesh / 4 triangles; flowers 3 / 803; rock 1 / 355; rock-and-grass pieces 9 / 1,060; tree, roots and foliage 21 / 7,298.
- All 35 have one triangle-topology submesh with 16-bit indices, valid index-buffer lengths and indices within the corresponding vertex count.
- **27** Mesh objects have inline vertex data, **8** reference external `.resS` vertex data. All eight external streams have valid offsets and byte ranges in the original bundle resource payloads.
- Inline vertex bytes: **128,596**; external vertex bytes: **168,036**; index bytes: **57,120**. These are stored mesh-buffer bytes in this sample, *not* total runtime GPU memory or scene draw cost.
- The eight external-vertex meshes are `hua_002`, `hua_001`, `yl_shu_002`, `yl_shu_003`, `yl_shu_001`, `yl_shuye_001`, `yl_shuye_002`, `yl_bajiaoye_003`. External stream sizes match the vertex counts at 32, 36 or 40 bytes per vertex.

## Terrain materials: 7 Texture2D objects, 2 materials

Both materials contain nine `m_SavedProperties.m_TexEnvs` fields:
`_ControlMap`, four `_TexLayer01`–`_TexLayer04` slots and four corresponding `_Normal` slots.

**`mtl_CJ_Terrain_001`:** 6 local texture pointers, 1 external pointer, 2 null normalmap slots.

| Slot | Stored texture name or reference |
|---|---|
| `_ControlMap` | `tex_CJ_Terrain_001`, 512×512, ETC2_RGBA8 |
| `_TexLayer01` | `tex_CreateCharater_03D`, 64×64, ETC2_RGB4 |
| `_TexLayer01_Normal` | `tex_CreateCharater_03N`, 512×512, ETC2_RGB4 |
| `_TexLayer02` | `tex_CreateCharater_04D`, 64×64, ETC2_RGB4 |
| `_TexLayer02_Normal` | null |
| `_TexLayer03` | `tex_CreateCharater_01D`, 512×512, ETC2_RGB4 |
| `_TexLayer03_Normal` | external PPtr (`fileID=2`, `pathID=2584850385989862130`); target not yet resolved |
| `_TexLayer04` | `tex_CreateCharater_02D`, 64×64, ETC2_RGB4 |
| `_TexLayer04_Normal` | null |

**`mtl_CJ_Terrain_003`:** `_ControlMap` is its only local texture, `tex_CJ_Terrain_007`, 512×512, ETC2_RGBA8; five layer pointers refer to external `fileID=1`, one normal pointer refers to external `fileID=3`, and two normal pointers are null. Identical `pathID` values are not sufficient to prove the external dependency mapping without reading the serialized external references.

The 7 texture objects were decoded with widths, heights, numeric TextureFormat IDs and mip counts, and each of the two `.resS` streams was confirmed **fully covered**, with no gaps or overlaps: 707,336 and 349,552 bytes.

## Implications for original Titan Legends art (not applied yet)

A mobile-friendly, **independently authored** Godot 4 terrain shader could use one RGBA splat/control map and four separately authored tiling terrain textures, with optional normals. Vegetation geometry may use one material/submesh and 16-bit indices, keeping batch overhead small; measurements here do **not** establish the Ulala game's scene-level instance counts or mobile FPS.

## Limitations / remaining work

- Locate actual ground TerrainData/Mesh sources: **terrain materials alone are not ground geometry**.
- Resolve external `fileID` dependency tables before labeling borrowed/shared textures.
- Read original shader code or equivalent compiled shader properties before claiming terrain blending equations.
- Decode vertex positions and UV channels to verify geometry topology and orientation independently.
- Do not redistribute copyrighted reference asset payloads; do not change Titan Legends visuals until the reference evaluation is complete.

Companion local files: `ulala_environment_mesh_geometry_and_streams_verified.json`, `ulala_environment_mesh_geometry_summary.csv`, and `ulala_terrain_material_layers_and_textures_verified.json`. These are analytic reports, not game assets.
