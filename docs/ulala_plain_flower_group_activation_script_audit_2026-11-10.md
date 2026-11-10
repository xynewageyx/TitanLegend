# Ulala Plain – ten disabled flower groups and script-activation trace (2026-11-10)

**Status: runtime activation is NOT proven.** All checks below are based on directly decoded serialized source binary data from the user's original nine-part reference archive, not a live running game. **No original copyrighted source code, shader bytecode, meshes, scene positions or textures were committed, and Titan Legends graphics remain unchanged.**

## Verified original data and method

- Reassembled all nine source archive volumes and extracted `assets/scenes/art/plain.unity_ab` again.
- Recomputed the original UnityFS bundle SHA-256: `0421a3d278e569e297e48af629a1aef122498dbb2f976114c85cc40ca428ff06`, consistent with earlier audits.
- Decompressed **110** UnityFS LZ4 content blocks and obtained `BuildPlayer-Plain` (**10,652,920 bytes**) plus `BuildPlayer-Plain.sharedAssets` (**3,653,728 bytes**).
- Parsed SerializedFile v21 type tables and complete object tables. The scene contains exactly **105,075** serialized Unity objects, including **28,709 GameObjects** (class 1), **13 MonoBehaviours** (114), and six different MonoBehaviour type-tree signatures.
- Parsed every original GameObject's variable-length component pointers, layer, name, tag and `m_IsActive` field; joined all script components to their owner GameObjects via `m_GameObject` PPtr.
- Parsed the sibling sharedAssets' six **MonoScript** (class 115) objects to their exact byte boundaries; resolved every MonoBehaviour `m_Script` pointer to its **actual class name, namespace and assembly**, not guessed by GameObject naming.

## What the saved scene actually contains

| Item | Directly measured |
|---|---:|
| GameObjects | **28,709** |
| Saved active GameObjects | **28,692** |
| Saved inactive GameObjects | **17** |
| Flower-group parents `hua_001_group` and `hua_002_group` | **10**, all inactive |
| Other inactive scene GameObjects | **7** |
| MonoBehaviour components | **13** |
| Distinct MonoScript classes | **6** |
| MonoBehaviour components directly attached to flower-group parents | **0** |
| Matching serialized `PPtr(fileID=0,pathID=flowerGroupID)` occurrences in the 13 MonoBehaviour payloads | **0** |

The ten inactive flower-group parents have GameObject IDs **37, 48, 49, 65, 82, 83, 96, 99, 116, 121**; each has exactly **one Transform** component, and no attached MonoBehaviour. The **seven other** inactive source GameObjects are `Baked Light` (1), `Terrain_01` (1), and `xiaocao` (5). These statuses are **saved scene flags**, not evidence of runtime use.

### All 13 script components resolved to true MonoScript classes

| MonoScript class | Scene owner object(s) | Component count | Status for the flower activation question |
|---|---|---:|---|
| `SoFunny.Lua.LuaPrefab` | 8 `totem` objects/variants | **8** | Each `prefabPath` is `Assets/Models/Article/Prefabs/Seaaon/diaoxian.prefab`; each `addPrefab` pointer is null |
| `CameraControl` | `MyCamera` | 1 | Serialized class is a camera controller, not attached to a flower group |
| `UniversalAdditionalCameraData` | `Main Camera (2)` | 1 | URP camera data, not attached to a flower group |
| `AutoAddUICamera` | `Main Camera (2)` | 1 | Camera script, not attached to a flower group |
| `UnityEngine.Rendering.Volume` | `Global Volume` | 1 | Global rendering volume, not attached to a flower group |
| `MeshPainter` | `PY5_dibiao_01` | 1 | Component saved disabled (`m_Enabled=0`); not attached to a flower group |
| **Total** | | **13** | |

**Important:** The table establishes original serialized ownership and saved property pointers. It does **not** prove that arbitrary C# or Lua code cannot find/activate flower parents dynamically by name, or that another dynamically loaded script cannot affect the scene.

## External scene-script assets exist — but their bodies are not plaintext Lua

Independently extracted and decoded five UnityFS script list bundles:

| Script bundle | Decoded classID-49 TextAssets |
|---|---:|
| `main/scenes/camera_ab_list` | 4 |
| `main/scenes/debug_ab_list` | 1 |
| `main/scenes/list_ab_list` | **128** |
| `main/scenes/state_ab_list` | **30** |
| `main/scenes_ab_list` | 2 |
| **Total** | **165** |

In the `scenes/list_ab_list` bundle, original classID-49 TextAsset objects with exact saved `m_Name` values **`Plain` (1,628 script bytes)** and **`Plain2` (1,373 bytes)** were located and byte-boundary checked. Their contents contain substantial binary/control-byte data (only roughly **40.9%** and **38.9%** printable ASCII), **not immediately inspectable plaintext Lua**. Related `Forest`, `Forest2`, `SceneBase` source assets also exist in these bundles.

Raw token scans find no literal `SetActive`, `hua_001_group` or `GameObject` in these two binary bodies. **That absence is not evidence that no activation code exists:** the TextAsset bodies appear encoded/obfuscated or otherwise non-plaintext. No script source was exported to the repo.

## Conclusion and next research boundary

**Confirmed**: all ten flower groups are saved disabled; no one of the 13 serialized MonoBehaviours is directly assigned to a flower-group parent; the eight `LuaPrefab` components reference the *totem* prefab `diaoxian.prefab`, not a flower prefab; external `Plain` and `Plain2` script TextAssets exist.

**Not confirmed**: the exact runtime caller, function or condition (if any) that activates the flower groups. An archived scene alone cannot prove that it ever happens. The next investigation would need a *legible/decodable* scene-controller script, a native assembly call-site analysis, or runtime observation; no unsupported claim about actual displayed flowers should be made.

**Local metadata-only outputs**:
- `ulala_plain_flower_activation_script_inventory_2026_11_10.json`
- `ulala_plain_monobehaviour_ownership_2026_11_10.csv`

**No Titan Legends game assets or graphics were changed.**
