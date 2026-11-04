# Ulala reference archive: landscape inventory (metadata only)

Source: user-provided Google Drive multipart archive `ulala_backup.7z.001`–`.009` (9 parts, ~1.93 GB). Listed via libarchive; 27,270 archive entries. **No original asset payloads are included in this repository.**

## Verified relevant archive paths

- `assets/lib/scenes/forest/cjdw_yulin.prefab_ab` and `cjdw_yulin.prefab_ab_shared`: forest scene prefab bundles.
- `assets/lib/scenes/forest/rain.prefab_ab`, `rain.prefab_ab_shared`, `sun.prefab_ab`: forest weather/lighting-related names.
- `assets/lib/scenes/plain/`, `desert/`, `coast/`, `volcano/`, `glacier/`: other biome scene references.
- `assets/environment/materials/skymat1.mat_ab_shared`, `skymat_dusk.mat_ab_shared`, `bossscene_skymat.mat_ab_shared`: sky material references.
- `assets/models/article/materials/afterglowforest/mtl_af_baihuashu_01.mat_ab_shared`: tree-related material name.
- `assets/models/article/materials/afterglowforest/mtl_af_cao_01.mat_ab_shared`: grass-related material name.
- `assets/models/article/materials/afterglowforest/mtl_af_caodui_01.mat_ab_shared`: grass pile-related material name.
- `assets/models/article/materials/afterglowforest/mtl_af_huaduo_01.mat_ab_shared`: flower-related material name.
- `assets/models/article/materials/afterglowforest/mtl_af_yanshi_01.mat_ab_shared`: stone-related material name.
- `assets/models/article/materials/common/mtl_cj_water.mat_ab_shared`: water-related material name.
- `assets/models/article/materials/terrain/`: terrain material references.

The names indicate likely roles but do not verify visual appearance, geometry, material values, or hierarchy. Further examination requires decoding the UnityFS payloads.

## Titan Legends design decisions

1. Build original forest terrain with gentle height variation, winding trails and shaded clearings.
2. Use original rounded tree silhouettes, grass clumps, flowers, stones, and river materials; batch repetitive vegetation for Android.
3. Add sky gradients and softer lighting; retain low-cost mobile rendering.
4. Keep the battle arena out of the exploration GLB. Instantiate it only on battle start and remove it at battle end.
5. Do not copy, commit, or redistribute Ulala proprietary meshes, textures, or bundles.
