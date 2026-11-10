# Ulala Plain: exhaustive non-language Lua list-package activation search (2026-11-10)

**Read-only reference research.** Input: user's original nine-part Ulala Unity 2019.4 backup. Only research metadata is reported. **No original Lua source text, obfuscation key, textures, meshes or shader code have been committed. No Titan Legends game or graphics files were changed.**

## Search scope and reproducibility

1. Enumerated **27,270** entries in the original multipart archive using libarchive, of which **16,051** entries lie under `assets/lib/scripts/`, including large sets of language/template files.
2. Selected **every 995 nonempty `*_ab_list` bundle in `assets/lib/scripts/main/` and `assets/lib/scripts/ui/`**. Excluded language template packages and unrelated binary resources.
3. Extracted **995/995** selected original UnityFS bundles without changing them. Decompressed UnityFS LZ4 blocks and parsed serialized classID **49 TextAsset** records, including object boundaries and content sizes.
4. Successfully processed **9,134 TextAssets from all 995 bundles**, using independently verified reversible character-wise text decoding. A single `AnimusResetTimesCtrl` payload contains seven nonstandard Unicode codepoints (its source roundtrip still validates); this case was **not** treated as evidence of plant logic.
5. Conducted case-insensitive searches for `hua_001_group`, `hua_002_group` and `xiaocao`, plus static searches for `SetActive`, GameObject/Transform lookup and generic environment/quality words.
6. Reviewed 20 possible scripts matching **both** an activation call and a generic terrain/vegetation keyword; specifically examined the source function ownership and target object categories for the five such scripts in `main/`.

## Quantified results

| Static source search | Verified count |
|---|---:|
| Selected, extracted and decoded `*_ab_list` bundles | **995/995** |
| Decoded original TextAssets | **9,134** |
| Bundles with parser errors | **0** |
| TextAssets containing a `SetActive(...)` call | **2,837** |
| TextAssets containing a GameObject-Find-style call | **112** |
| TextAssets containing a generic vegetation word | **80** |
| TextAssets containing `terrain` | **31** |
| TextAssets containing both `SetActive` and a generic vegetation/terrain term | **20** |
| TextAssets mentioning `hua_001_group`, `hua_002_group`, or `xiaocao` directly | **0** |

The `2,837` value is the **number of TextAssets containing at least one invocation**, *not* the count of individual SetActive calls. The earlier 165 inspected scene scripts and 114 targeted bundles are **subsets of this larger scan**, not additional scripts to add to 9,134.

## Five main-game candidates individually reviewed

| Original Lua script | Actual activation target inferred from the decoded calling function |
|---|---|
| `SceneBase` | `SceneBase:initSeasonOrn` deactivates a season ornament (not the Plain flower or grass group) |
| `WorldBossV2` | Hides boss-scene seasonal decoration |
| `CombatScene` | Deactivates a camera |
| `Dungeon` | `Dungeon:setPlant` activates a separate **Dungeon** plant |
| `GardenAvatar` | Updates garden seed detector and overlapping model visibility |

The remaining 15 candidates occur in UI/minigame domains (e.g. garden or Sonic terrain visuals), **without any literal reference to the Plain flower/grass groups**. Generic `terrain` or `plant` text in an unrelated UI script is not a Plain vegetation activator.

### Earlier directly confirmed source-scene state

The saved original `Plain` hierarchy contains **ten disabled flower parents** with **496 inactive-by-ancestry flower MeshRenderer components**, plus **five disabled `xiaocao` parent groups** with **8,740 inactive-by-ancestry grass LODGroups** / **17,480 grass MeshRenderer components**. Each of those inactive parent groups has a Transform but no directly attached MonoBehaviour. This is a **serialized pre-runtime state**, not proof that the player never sees flowers.

The actual `SceneBase` / `ForwardState` call chain moves world sections in **240-unit** steps, but the reviewed source does not include a direct group-activation call for those saved-inactive objects.

## Conclusion: direct activation function remains **unverified**

This new exhaustive `main+`UI `*_ab_list` search provides strong **negative evidence against a direct literal-name Lua activator in these packages**, but **cannot prove the groups are never activated**. Potential remaining mechanisms include:

- Runtime C#/native systems or client executable modules **not included** in this archive.
- Indirect GameObject hierarchy traversal or dynamically generated names, generic settings/quality toggles, or external engine calls.
- Other script formats and localized/template packages not part of the 995 `*_ab_list` scope.
- Runtime-created scene sections, additional remote assets or Unity initialization overrides.

**Do not report a runtime `SetActive(true)` on `hua_001_group` or `xiaocao` as established.**

## Research exports

- `ulala_full_lua_vegetation_activation_audit_2026_11_10.json` — metadata-only inventory, validated counts and narrowed shortlist.
- `ulala_lua_activation_candidate_review_2026_11_10.csv` — 20 candidate script names and review classifications.
- Local extract/decode/search scripts are deliberately kept off GitHub because they contain original game encoding details; **only derived metadata** is shared.

**Implication for Titan Legends:** the archive has already provided useful independent design insights on repeating 240-unit sections, mesh reuse, grass LOD geometry, opaque materials and wind calculations. The **runtime activation of inactive Ulala vegetation remains unknown**; do not copy its disabled-by-default flags into Titan Legends. Any future Godot implementation must be original and separately benchmarked on Android. **Titan Legends graphics unchanged.**
