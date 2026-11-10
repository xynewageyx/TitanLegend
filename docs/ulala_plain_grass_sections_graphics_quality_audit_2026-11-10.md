# Ulala Plain — Grass section replication and Lua graphics-quality API audit (2026-11-10)

**Scope:** Read-only research of the user's original Ulala Unity 2019.4.16f1c1 backup to inform *independently authored* Titan Legends Android environments. **No original asset geometry, texture payloads, Lua code, decoding secrets, level placements or shader bytecode are copied into the repository; no Titan Legends visual/gameplay code was changed.**

## 1. All 9,222 original Plain grass LODGroups reassessed in the original scene

Binary source: `plain.unity_ab` (SHA-256 `0421a3d278e569e297e48af629a1aef122498dbb2f976114c85cc40ca428ff06`); Unity SerializedFile v21 with **105,075 serialized objects**.

Method: directly decoded all **28,709 GameObjects (classID 1)**, all **28,709 Transforms (classID 4)**, and all **9,222 LODGroups (classID 205)**. Each LODGroup's owning GameObject pathID was joined to its Transform and all ancestor Transforms, verifying the source `m_IsActive` flags. All 9,222 groups are accounted for.

| Saved scene category | LODGroups |
|---|---:|
| Five disabled `xiaocao` ancestor subtrees | **8,740** |
| Active ancestor chains (outside those five subtrees) | **482** |
| **All saved LODGroups** | **9,222** |

### Five `xiaocao` sections have identical *counts* of each grass type

Each of five disabled parent groups has **exactly 1,748 LODGroups**, with an identical per-grass-type breakdown:

| Original grass name | Each disabled section | All five |
|---|---:|---:|
| `mdl_PYN_XiaoCao_003` | 548 | 2,740 |
| `mdl_PYN_XiaoCao_004` | 477 | 2,385 |
| `mdl_PYN_XiaoCao_005` | 723 | 3,615 |
| **Total** | **1,748** | **8,740** |

Identical type **counts** do not establish bit-for-bit identical per-instance vertex coordinates or that all these sections are loaded/shown during gameplay.

The five parent chains have the structural pattern `Terrain / Main / Di0..Di4 / cao0..cao4 / xiaocao`. The corresponding saved **group-pivot** source-world Z coordinates are **−240, −159.9, −71.6, 0 and 481.45**. These are pivot values, **not geographic terrain bounds or camera visibility**.

**Unexpected geometry configuration:** The section at **Z pivot 481.45** uses **`m_LocalScale=(1,1,−1)`** at its `xiaocao` group. Its parent transform contributes a +240 Z offset; its `xiaocao` Transform adds about +241.45. The world pivot is derived by applying the parent-chain TRS in order. This is a **Z-axis mirror**, unlike the other four groups (all `scaleZ=1`). A mirrored pivot does not imply the entire world-space section lies beyond Z=481: its child mesh positions are reflected around the parent pivot.

The distinct **482** originally active-hierarchy groups occur under prefab-named parents rather than the five saved-disabled `xiaocao` trees:

| Original grass type | Active LODGroups |
|---|---:|
| `mdl_PYN_XiaoCao_003` | 8 |
| `mdl_PYN_XiaoCao_004` | 411 |
| `mdl_PYN_XiaoCao_005` | 63 |
| **Total** | **482** |

All 482 have the saved root `Terrain`. This finding establishes source GameObject ancestry, **not a runtime culling or rendering trace**. Source `LODGroup` describes two alternate level meshes, not two simultaneously visible renderers.

## 2. Static graphics-quality API search in all 9,134 decoded Lua TextAssets

Independently scanned the **995 original extracted `*_ab_list` UnityFS script bundles** under nonlocalized `main` and `ui`, decoding **9,134 classID-49 TextAssets**, with **0 bundle parse failures**. Queries were designed to distinguish actual Unity graphics-quality APIs from irrelevant game item rarity named `quality`.

| Original Lua token family searched | Matched scripts |
|---|---:|
| `QualitySettings`, `SetQualityLevel(...)` | **0** |
| `lodBias`, `maximumLODLevel`, `LODGroup` | **0** |
| `targetFrameRate` | **0** |
| `detailObjectDistance`, `detailObjectDensity`, `treeDistance`, etc. | **0** |
| `shadowDistance`, `shadowCascades`, `shadowResolution` | **0** |
| `GraphicsSettings`, `Screen.SetResolution`, anti-aliasing, VSync, renderer scale tokens | **1** |
| Camera culling mask / clip distance tokens | **1** |
| Direct `hua_001_group`, `hua_002_group`, `xiaocao` names | **0** (prior independent scan) |

The two apparent graphics matches were manually inspected:

- `GiantsCamera` (under `main/scenes/camera_ab_list`) reads/uses a **camera culling mask** for camera switching. This does **not** establish a global plant visibility switch.
- `CrystalHole` (under `ui/talenttree/crystalinlay_ab_list`) has a local UI function named **`renderScale`**; it is a crystal interface presentation routine, **not** a Unity render-resolution setting.

Thus **no direct Lua-side Unity global graphics-quality switching API was found in this 9,134-script selection**. This does **not** show that the game has no graphics quality settings: C# managed assemblies or executable client code that handles the engine may be absent from this user asset archive. Do not use the absence of a Lua token as evidence of a non-existent runtime feature.

## Limits and design relevance

- Five repeated grass-section compositions plus one mirrored Z section are strongly evidenced by **serialized hierarchy and transformations**, not by the runtime level loading logic.
- Previously decoded Lua `SceneBase` scripts have **240-unit** section-shifting behavior; these recorded transform pivots are *not* all 240-unit multiples, and that script mechanism **does not establish these disabled sections are activated**.
- Across the wider 9,134-script scan, no directly named activator was found. Native engine code, runtime state changes, indirect Lua lookups, and client quality settings remain unverified.
- Saved **inactive** grass groups must not be counted as actively rendered vegetation.
- For Godot 4.7.2 Android, a future original-art system could independently explore pooled/reused vegetation sections with LOD/culling and optional mirroring, but should be benchmarked in the actual game's camera before adoption.

## New metadata-only local audit artifacts

- `ulala_plain_grass_five_sections_verified_2026_11_10.json`: complete group-type counts, five section pivot/scale summaries, active group breakdown, source SHA-256 and validations.
- `ulala_plain_grass_five_sections_verified_2026_11_10.csv`: five-row section comparison.
- `ulala_lua_graphics_quality_api_scan_2026_11_10.json`: static Unity API-token search, only matched **script names**, source bundle paths and counts, with no code payload.
- Analysis-only local scripts verify object-by-object Transform ancestry and 995 original UnityFS Lua bundles. No original client game code redistributed.

**Result:** New evidence of per-section grass reuse and Z mirroring, plus a robust negative result for *direct Lua graphics API calls*. **No Titan Legends visuals were changed.**
