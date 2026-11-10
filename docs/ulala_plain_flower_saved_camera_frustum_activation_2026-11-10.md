# Ulala Plain — Flower parent activation and saved-camera frustum (2026-11-10)

**Read-only reference research, not a Titan Legends visual change.** All measurements are from the user-provided original Ulala multipart UnityFS archive (Unity 2019.4.16f1c1, SerializedFile v21). The original binary assets, individual placements and original vertex arrays remain outside the repository.

## Direct binary source checks

- Source archive scene: `plain.unity_ab`, source SHA-256 `0421a3d278e569e297e48af629a1aef122498dbb2f976114c85cc40ca428ff06`, rechecked against the previously verified original.
- `BuildPlayer-Plain` object table has **105,075** Unity serialized objects.
- Parsed all **28,709** Transform components (classID 4) and all **28,709** GameObjects (classID 1); each GameObject's `m_Component` array length, `m_Layer`, aligned `m_Name`, `m_Tag` and `m_IsActive` read from its serialized binary record.
- Joined the previously verified **496 flower MeshRenderers**, their MeshFilter and Mesh pathIDs, their owning GameObjects and their five-level valid original Transform ancestry.
- Verified all source flower GameObjects are **layer 17** and `m_IsActive=true`.
- **All 10 immediate parent flower groups** have `m_IsActive=false`, regardless of flower MeshRenderer `m_Enabled=true`. The sorted counts of flower child GameObjects per disabled group are **29, 31, 31, 36, 37, 37, 40, 44, 81, 130**, summing to 496.
- The saved scene Camera GameObject and its own parent are enabled, and the Camera's original culling-mask **`0x00326e17` includes layer 17**.
- Therefore **none of the 496 flower instances is active in the saved scene hierarchy**. It would be inaccurate to say that 118 flowers are rendered by default. Runtime scripts could activate the groups, but that has not been established.

## Saved camera pose and projection

Original scene Camera (classID 20, pathID 57419) decoded directly:

| Camera setting | Verified serialized value |
|---|---|
| Camera world position after parent rotation | **(0, 2.965753, 17.322941)** |
| World forward direction | **(0, −0.422618, 0.906308)** |
| `m_projectionMatrixMode` | **1 (Implicit)** |
| Projection | Perspective (`orthographic=false`) |
| Vertical field of view | **100°** |
| Near / far clip | **0.01 / 90** original Unity units |
| Normalized viewport | **(0,0,1,1)** |
| Culling mask | **0x00326e17**, including flower layer 17 |
| Camera and parent source activation | **enabled** |

The Camera's parent has **20° X rotation**, and the Camera has a further **5° local X rotation**, giving an approximately **25° down-tilted forward direction**; original translation must be rotated by the parent's quaternion before adding. Original Camera `m_projectionMatrixMode=1` corresponds to the **Implicit** perspective mode (UnityCsReference Camera.bindings.cs); the Camera's saved FOV is vertical. The final display aspect ratio depends on the runtime display, not a field fixed in this scene.

## Conditional geometrical frustum classification

For **each of the 496 original flower instances**, the decoder applies the original three-axis scale and quaternion to **every original source-Mesh XYZ vertex** (320 or 472 per flower mesh), adds all five verified ancestor translations, and projects into the correctly reconstructed saved Camera's coordinate system.

For three **explicit assumed** screen aspect ratios, it tests all six convex frustum planes (near, far, left, right, top, bottom) using the saved FOV and clip distances:
- **Guaranteed outside:** all source vertices fall outside at least one *same* frustum halfspace, so the whole original static mesh is outside the frustum before wind displacement.
- **All vertices inside:** every source vertex is inside all six planes.
- **Partial — vertex inside:** at least one source vertex falls inside, but not all are inside.
- **Ambiguous boundary:** no vertex inside, yet not provably outside by a common halfspace; there were **zero** such cases in these three scenarios.

| Assumed aspect | Guaranteed outside | All vertices inside | Partially intersects, vertex inside | Potentially inside (if activated) |
|---|---:|---:|---:|---:|
| **Portrait 9:16** | **378** | **113** | **5** | **118** |
| Square 1:1 | **363** | **125** | **8** | **133** |
| Landscape 16:9 | **350** | **140** | **6** | **146** |

Under portrait 9:16, **`hua_001`** accounts for **70** geometrically intersecting meshes (69 fully inside, 1 partial) and **`hua_002`** for **48** (44 fully inside, 4 partial). All **496 source flower GameObjects** pass the saved Camera's layer mask, but **zero** pass the GameObject **parent hierarchy activation** check in the saved scene state.

These numbers are **geometric conditional frustum results**: they do **not** imply that any flower was actually visible in a screenshot or at runtime. Original source scripts might activate/deactivate groups, move the Camera, change the culling mask or alter projection. The game may use a different viewport aspect ratio.

## Strong limitations and comparison with prior wind analysis

1. **Most important:** the original saved parent group flags make the flower population **inactive**. A scene's GameObject m_IsActive flag is not runtime evidence; activation scripts are unverified.
2. The calculation uses **static original Mesh vertices**, before the previously verified height-dependent wind/billboard displacement. Deformed geometry can cross geometric frustum boundaries. Thus the 378 "outside" objects are only guaranteed outside for **static undeformed geometry**, not every possible shader-driven animated vertex location.
3. Occlusion by terrain/rocks, per-object renderer culling bounds after shader deformation, Unity custom visibility hooks, shadow casting, final screen pixels and actual Android GPU draw calls have **not been measured**.
4. Assumed 9:16, 1:1 and 16:9 are controlled projection scenarios, **not** inferred actual device orientations.
5. The source mesh vertices and 496 original object world positions are **not redistributed**; reports include only aggregates.

## Local metadata-only audit artifacts

- `ulala_plain_496_flower_saved_camera_frustum_audit_2026_11_10.json`: camera, source activations, layer mask, 3 scenario totals, validation and limitations.
- `ulala_plain_496_flower_frustum_comparison_2026_11_10.csv`: six aggregate scenario × mesh rows.
- Local read-only reproducibility script: `audit_ulala_plain_flower_camera_frustum_2026_11_10.py`.

**Next reference task:** inspect original Unity MonoBehaviour/scene trigger references to determine whether the ten disabled flower groups are enabled at runtime. Without that, reporting runtime visible flowers is not supported. **No changes to Titan Legends visuals.**


### Verified component ownership of the ten disabled flower groups

For each of the ten `hua_001_group` and `hua_002_group` GameObjects, the original classID-1 `m_Component` array contains **exactly one PPtr**, resolving to its own **Transform (classID 4)**. None of the ten group GameObjects has a directly attached `MonoBehaviour (classID 114)` or other component. This does **not** rule out activation by scripts on other objects, scene managers, or dynamically loaded code.

The original serialized `Plain` scene has **28,692 active and 17 inactive GameObjects** overall. Ten of those inactive ones are the flower-group parents. These flags were obtained from the aligned `m_IsActive` field after the variable-length component array and GameObject name, not inferred from MeshRenderer settings.
