# Ulala Plain — SceneBase control flow and saved grass/flower activation (2026-11-10)

**Method:** Direct original UnityFS and Lua TextAsset inspection using the user's Ulala reference archive (Unity 2019.4.16f1c1, SerializedFile v21). This is a **read-only metadata audit**. **No commercial scripts, assets, shaders, textures, mesh vertices, scene placements or decoding keys are published or imported into Titan Legends. The game's visuals are unchanged.**

## 1. Shared Lua SceneBase and 240-unit repeated section

The original `assets/lib/scripts/main/scenes_ab_list` UnityFS bundle has a classID 49 TextAsset called **`SceneBase`** containing **106 declared methods**, and a `SceneUnitCacheHelper` TextAsset. The separate `main/scenes/state_ab_list` contains **30** state-controller TextAssets including **`StateBase`** and **`ForwardState`**.

All **165** TextAssets from five targeted original script bundles were decoded locally to human-readable text, validated for byte-exact roundtrip, and scanned *without redistributing script source*:

| Source UnityFS bundle | TextAsset count |
|---|---:|
| `main/scenes/list_ab_list` | 128 |
| `main/scenes/camera_ab_list` | 4 |
| `main/scenes/debug_ab_list` | 1 |
| `main/scenes_ab_list` | 2 |
| `main/scenes/state_ab_list` | 30 |
| **Total** | **165** |

**114** of the 165 Lua scripts directly reference the common `Main.Scenes.SceneBase` dependency. `Plain` and `Plain2` both inherit it.

All **17 independent source-control-flow checks** passed. Specifically, the decoded method-to-method chain is:

1. `Plain:startState` (or `Plain2:startState`) can call `forwardState`, which selects the **`ForwardState`** state controller.
2. During its update, `ForwardState` invokes inherited **`StateBase:checkBounds`** with `scene.bounds.z`.
3. The common scene default is `bounds=(0,0,240)` and `amounts=0`. `checkBounds` compares the highest character Z against **`240 × (amounts+1)`**, then calls the scene's `crossBounds` if crossed.
4. `SceneBase:crossBounds` increments `amounts`, calls `crossScene`, and shifts the particle-space origin.
5. `SceneBase:crossScene` repositions the root **`Terrain`** object's Transform to the counted section offset along Z.
6. Both `Plain:crossBounds` and `Plain2:crossBounds` additionally reposition **two associated scene effects** to corresponding section offsets.

The two Plain scripts also save offsets `(0,0,0)` and `(0,0,240)` for their two special decorative prefab effects. They instantiate different dedicated prefabs, but **neither explicitly activates the flower groups**. This proves there is a coded section-repositioning mechanism. It is **not** a recording of runtime streaming, nor evidence that original scene groups were activated by this control flow.

## 2. Exhaustive saved GameObject activation-hierarchy audit for this Plain scene

The original `plain.unity_ab` scene contains **28,709 GameObjects**, **28,709 Transforms**, **19,191 MeshRenderers** and **9,222 LODGroups**. Independently parsed all classID 1, 4, 23 and 205 records; for every Renderer and LODGroup, walked all original `m_Father` pointers and checked the owning GameObject's `m_IsActive` along the complete ancestor chain.

| Original serialized component group | Active transform hierarchy | Inactive transform hierarchy | Total |
|---|---:|---:|---:|
| **Grass LODGroups** | **482** | **8,740** | **9,222** |
| **Grass MeshRenderers (both LODs)** | **964** | **17,480** | **18,444** |
| **Flower MeshRenderers** | **0** | **496** | **496** |
| **Other decorative MeshRenderers** | **251** | **0** | **251** |
| **All MeshRenderers** | **1,215** | **17,976** | **19,191** |

This reconciles the previously verified two grass material source groups: **8,740** grass LOD groups under inactive `xiaocao` parents and **482** LOD groups with active ancestry.

The original `Plain` scene has only **17 saved-inactive GameObjects**:

| Inactive GameObject name | Count |
|---|---:|
| `hua_001_group` | **5** |
| `hua_002_group` | **5** |
| `xiaocao` | **5** |
| `Baked Light` | **1** |
| `Terrain_01` | **1** |
| **Total** | **17** |

The ten inactive flower parents account for all 496 inactive flowers. The five inactive `xiaocao` parents account for **17,480** inactive grass Renderer components and **8,740** inactive grass LODGroups.

**CRITICAL:** "1,215 Renderer components have active ancestry" is **not** "1,215 visible meshes". Two MeshRenderer components per grass LODGroup describe alternative LOD levels, not both displayed simultaneously. The saved scene state is not a runtime trace, and scripts may change activation after load.

## 3. No confirmed vegetation group activator within 165 examined scripts

A case-insensitive exact-name search across the 165 successfully decoded TextAssets yielded:

| Pattern / evidence | Scripts | Occurrences |
|---|---:|---:|
| `hua_001_group`, `hua_002_group` | **0** | **0** |
| `xiaocao` | **0** | **0** |
| Textual `:SetActive(...)` call sites | **14** | **33** |

All **33** saved `SetActive` call-site occurrences are on **other objects or systems** in these inspected script bodies; none provides a direct named group activator. In `SceneBase`, the one `SetActive(false)` is specifically for a season-decor object, **not** the Plain flower/grass parents. `ForwardState`'s SetActive call sites concern separate equipment or ride effects.

This is **not evidence** that flowers or 8,740 grass groups can *never* be enabled. A different Lua bundle, native/C# client code not present in the backup, runtime-loaded scripts, or indirect object lookups can still change GameObject activation. In particular, these 165 scripts represent **five targeted packs**; the archive includes many other script bundles.

## Verification and boundaries

- All 165 TextAsset objects extracted via original Unity SerializedFile v21 classID 49 records and validated for reversible source decoding; only aggregate function names/counts, no Lua source, are released.
- All 17 control-flow checks passed by examining original decoded method bodies.
- All 28,709 GameObject and Transform records and all 19,191 MeshRenderer/9,222 LODGroup source references parsed and their inactive-ancestor ancestry determined.
- No direct group activation function identified. Thus **runtime flower/grass display state remains open**.
- Dynamic camera visibility, original Unity renderer-level toggles and actual Android GPU cost remain unmeasured.

**Companion metadata-only JSON:** `ulala_scene_base_plain_activation_trace_verified_2026_11_10.json` and `ulala_plain_renderer_lod_active_hierarchy_2026_11_10.json`.

**Next research:** search additional targeted Lua bundles or client runtime systems for indirect vegetation activation and compare how 240-unit scene sections are enabled/disposed. **No Titan Legends graphics were changed.**
