# Ulala Plain flower activation — actual MonoScripts and scene-script bundle inventory (2026-11-10)

**Scope:** Read-only metadata study of the user's nine-part Ulala source archive (Unity 2019.4.16f1c1). This is **not** a confirmed runtime activation trace. No original proprietary game script bytes, meshes, textures, or game-art payloads are included, and **no Titan Legends game graphics were changed**.

## 1. Why all flowers are inactive in the saved original Plain scene

The original `plain.unity_ab` (`BuildPlayer-Plain` serialized file) has **28,709 GameObjects**. Exactly **17** have saved `m_IsActive=false`:

| Original inactive GameObject name | Count |
|---|---:|
| `hua_001_group` | 5 |
| `hua_002_group` | 5 |
| `xiaocao` | 5 |
| `Baked Light` | 1 |
| `Terrain_01` | 1 |
| **Total** | **17** |

The ten flower groups are parents of all **496 flower placements**. Their child GameObjects and MeshRenderer components are individually enabled, but inherited inactive parent state prevents them from rendering in the **saved scene state**. Every one of those ten parent GameObjects has only a Transform component and **no directly attached MonoBehaviour**.

A scan of the payloads of **all 13 scene MonoBehaviour objects** found **zero direct serialized Unity PPtr** references of the form `fileID=0,pathID=<one of the ten flower group GameObjects>`. Such a scan does not detect runtime GameObject lookup by name, script manager logic, reflection, event-driven scene loading, native code or other indirect activation.

## 2. All 13 original MonoBehaviour components and their real class names

The original scene contains exactly **13 classID-114 MonoBehaviour** objects, referencing **six classID-115 MonoScript definitions** in the sibling `BuildPlayer-Plain.sharedAssets` file. All six MonoScript object records were decoded to their final byte without trailing data.

| MonoScript class / namespace | Scene components | Actual owner GameObjects | Assembly indicated by serialized metadata |
|---|---:|---|---|
| `SoFunny.Lua.LuaPrefab` | **8** | `totem`, `totem (1)`, `totem (2)` | `Assembly-CSharp.dll` |
| `CameraControl` | **1** | `MyCamera` | `Assembly-CSharp.dll` |
| `UniversalAdditionalCameraData` | **1** | `Main Camera (2)` | `Unity.RenderPipelines.Universal.Runtime.dll` |
| `AutoAddUICamera` | **1** | `Main Camera (2)` | `Assembly-CSharp.dll` |
| `Volume` | **1** | `Global Volume` | `Unity.RenderPipelines.Core.Runtime.dll` |
| `MeshPainter` | **1** | `PY5_dibiao_01` | `Assembly-CSharp.dll` |
| **Total** | **13** | | |

The eight `LuaPrefab` instances have an `addPrefab` GameObject pointer set to **null** in their serialized records, and a saved totem-prefab path. None is attached to a flower parent.

**Important:** A serialized MonoScript's `m_AssemblyName` is a string reference, **not proof that its DLL is present** in this backup. No original Assembly-CSharp program was decoded.

## 3. Actual scene script *TextAsset* bundles found (not merely directories)

The 7z archive contains `assets/lib/scripts/main/scenes/`, which initially looks empty when searching only for `*.txt_ab`. Its Lua-oriented scripts are packed in **UnityFS bundles named `*_ab_list`** instead:

| Original script bundle | Original Unity TextAsset classID 49 objects |
|---|---:|
| `main/scenes/list_ab_list` | **128** |
| `main/scenes/camera_ab_list` | **4** |
| `main/scenes/debug_ab_list` | **1** |
| **Total inspected** | **133** |

Each UnityFS file was re-extracted directly from the original 7z archive, its LZ4 data decompressed, its SerializedFile v21 object table parsed, and **all TextAsset string and payload boundaries validated**. The original script bytes are **not** included in this report.

Specific verified TextAsset names and stored content lengths:

| TextAsset name | Content bytes | Source |
|---|---:|---|
| `Plain` | **1,628** | `list_ab_list` |
| `Plain2` | **1,373** | `list_ab_list` |
| `Forest` | **3,534** | `list_ab_list` |
| `Forest3` | **2,243** | `list_ab_list` |
| `CameraBase` | **8,189** | `camera_ab_list` |
| `Base` | **9,627** | `camera_ab_list` |
| `ParticleSimScene` | **10,223** | `debug_ab_list` |

The `Plain` and `Plain2` TextAsset payloads **are not ordinary readable Lua source text** in their stored form; their initial bytes and control-byte patterns are consistent with an encoded/obfuscated payload. This audit **has not decoded their source logic** and therefore cannot confirm whether they invoke `SetActive`, how they select flower groups, or whether a runtime manager does so.

The full archive was scanned by **all 27,270 entry names**. It contains **no** `Assembly-CSharp.dll`, other `.dll` executable game assembly, `.exe`, `.so`, or `.apk` file. Its `Managed` directory includes **59 Unity framework `.pdb` debug-symbol files** and the 41 original `.h` files are music-header files, not game code. This filename scan does **not** rule out code stored under other formats, native binaries outside the backup, or runtime-downloaded code.

## 4. Evidence-based conclusion

**Directly verified:** all ten original flower-parent GameObjects are saved inactive; they carry no script components; no scene MonoBehaviour payload directly points to their GameObject pathIDs; the scene references `SoFunny.Lua.LuaPrefab` on **totems**, and separate `Plain` and `Plain2` TextAssets are stored in actual script bundles.

**Not verified:** which method activates the groups at runtime, whether these particular scripts activate them, whether a runtime streaming/vegetation-density controller exists, or whether all 496 flowers ever become visible together. Saved camera-frustum computations must remain explicitly **conditional on activation**.

Before designing an independently authored, Android-optimized vegetation system for Titan Legends, retain these distinctions. Do **not** reproduce, redistribute or port the original commercial scripts, meshes, textures or scene layout.

**Metadata-only local report:** `ulala_plain_flower_activation_scripts_inventory_verified_2026_11_10.json` (script class names, safe provenance, object counts, script TextAsset names/lengths/checksums, archived path inventory and limitations).

**Next investigative path:** decode or identify the original game engine's script encoding scheme from permissible metadata only, or obtain a separate legitimate executable-runtime source with explicit access. At present the archived game does not establish an activating function. **Titan Legends visuals unchanged.**
