# Ulala — Extended Lua search for Plain flower and grass activation (2026-11-10)

**Read-only reference analysis.** No original Lua script source, deobfuscation keys, artwork, shaders, models or source-level assets are published or committed to Titan Legends. **No Titan Legends graphics changed.**

## Search coverage and limitations

A local archive scanner analyzed the user's original nine-part Ulala 7z source archive. It enumerated **27,270 archive entries**, indexed **16,051 entries** under the script areas and selected **995 `*_ab_list` UnityFS bundles** in `assets/lib/scripts/main/` and `assets/lib/scripts/ui/`. All 995 were extracted, parsed and decoded as Unity SerializedFile v21 / TextAsset classID 49 without bundle parser failures, yielding **9,134 original TextAsset scripts**.

The static audit checked reversible decoding, without publishing the original source. **One** TextAsset contains some nonstandard decoded printable-codepoint handling but still passed exact roundtrip. Results are **static searches**, not a running Unity client trace, and the selection excludes localized templates and other non-`*_ab_list` entries.

| Static signal | Verified aggregate |
|---|---:|
| Bundles inspected | **995 / 995** |
| TextAssets decoded | **9,134** |
| Bundle parse failures | **0** |
| Scripts with a `SetActive` call-like text match | **2,837** |
| Scripts with `GameObject.Find`-type text matches | **112** |
| Scripts containing vegetation-related keywords | **80** |
| Scripts containing terrain-related keywords | **31** |
| Scripts with *both* activation match and vegetation/terrain terminology | **20** |
| Exact occurrences of `hua_001_group` | **0** |
| Exact occurrences of `hua_002_group` | **0** |
| Exact occurrences of `xiaocao` | **0** |

The **20** dual-keyword candidate scripts consist of **5** in `main` and **15** in `ui`. Keyword co-occurrence is **not** a call graph or proof that one call activates an environment group.

## Source-level interpretation of the five `main` candidates

The five `main` candidate scripts were reviewed in their functional context. They **do not** provide the missing direct named `Plain` flower/grass group activator.

| Original text-asset location | Script | What the matched activation relates to |
|---|---|---|
| `main/scenes_ab_list` | `SceneBase` | `SetActive(false)` for seasonal decoration |
| `main/scenes/list_ab_list` | `WorldBossV2` | Boss-scene seasonal decoration |
| `main/scenes/list_ab_list` | `CombatScene` | Camera activation |
| `main/scenes/list_ab_list` | `Dungeon` | A dungeon plant, not a `Plain` scenery group |
| `main/avatar/garden_ab_list` | `GardenAvatar` | Garden seed detector / plant interaction objects |

The UI candidates belong to other contexts such as dungeon screens, garden/adventure UI, market UI and a separate Sonic minigame's terrain. The word `terrain` in a minigame name is not evidence of a link to the saved `Plain` landscape.

## Prior independently verified scene state

- `Plain` contains **10** saved inactive flower group parents, accounting for **496** flower MeshRenderers.
- **5** saved inactive `xiaocao` parents account for **8,740** inactive grass LODGroups / **17,480** MeshRenderer components.
- The other **482** grass LODGroups have active transform ancestry in the saved scene.
- The 165 previously inspected scene-level Lua TextAssets verify `SceneBase` section repositioning at a saved **240-unit** section boundary, **not** a vegetation activation.
- Scene saved flags and their script source references cannot establish the state after Unity initializes the client.

## What is established, and what is not

**Established:** none of the **9,134 decoded nonlocalized `main`/`ui` TextAssets** contains any of the three original group-name literals. The *functionally reviewed* five `main` scripts with both activation and terrain/vegetation keywords target other objects. A direct named Lua activator for the saved flower and grass groups has **not** been identified.

**Not established:** that the groups *never* activate; that no indirect lookup, runtime-generated group name, Unity/C# or native client component, property/quality setting, remote-loaded code, or game-state transition changes group activation. The user-provided asset backup lacks the complete runnable client.

**Research result:** no defensible runtime vegetation visibility or FPS claim is possible from these archived Lua TextAssets alone. The saved inactive flags and a potential runtime activator must be kept separate in every Titan Legends optimization comparison.

## Metadata-only local evidence

- `ulala_full_lua_vegetation_activation_audit_2026_11_10.json`: compact verified summary, candidate classifications, limitations.
- `ulala_all_nonlocale_lua_activation_scan_2026_11_10.json`: broader static per-script search statistics; contains no Lua source text.

**Next:** investigate lower-level Unity component activators, quality systems and loading code with original client access if available, rather than assuming that all saved grass and flowers are always rendered. **Titan Legends game graphics remain unchanged.**
