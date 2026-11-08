# Ulala Plain: original GrassShaderWind vertex displacement confirmed — 2026-11-08

**Scope:** Read-only technical examination of the user's original Ulala UnityFS backup, Unity 2019.4.16f1c1. **Research metadata only; no original shader source, compiled shader bytes, textures, meshes or artwork included. The Titan Legends game has not been changed.**

## Evidence and exact original asset linkage

- Original `assets/shaders` UnityFS bundle, serialized node **`CAB-259b3a6b4ed11e2f71f4a3e2ebc98a40`**.
- Exact classID **48** Shader object: `Unlit/GrassShaderWind`, **pathID `5497956564624892993`**, serialized object **16,928 bytes**.
- Original flower material `mtl_py5_hua_01.mat_ab_shared`, exact classID **21** Material object `mtl_PY5_hua_01`, **pathID `2199086455782193355`**, serialized object **1,656 bytes**, points directly to that Shader via external `fileID=1`.
- The two objects were independently decoded using the original Unity SerializedFile v21 TypeTrees, and **both parsers consumed exactly their entire object byte length**, with no remaining bytes.
- The Shader TypeTree contains three compressed-platform blobs with platform numeric IDs **5**, **9**, **18**. Their compressed sizes are **2,211 / 3,267 / 3,897 bytes**, summing to **9,375 bytes**. All three **LZ4 blocks decompress successfully** to **14,588 / 23,980 / 12,972 bytes** respectively.
- The decoded output identifies **GLSL ES 1.00** and **GLSL ES 3.00** in the first two blocks. The third block is not plain GLSL in this inspection, so no instruction-level conclusions are asserted for it.

## The wind deformation is real: original compiled vertex-program dataflow

**This is more than the presence of a Wind property.** Both GLSL ES vertex stages contain all the following operations, verified together in the original compiled programs:

1. A time-dependent phase that incorporates a time uniform and per-object world coordinates.
2. Texture lookup in the **vertex stage**, including `_Wind` and `_WindSpecular`.
3. Oscillation from both **sine and cosine** functions.
4. Multiplication of the oscillating value by `_Windvector` (the wind-direction vector).
5. Height-dependent weighting from the original vertex Y coordinate, the `_GrassShakePos` threshold and `_WindStrength`.
6. Application of the resulting offset to the original vertex horizontal **X/Z** position.
7. Object/world/view-projection transformations using the **modified position**, reaching the final GPU vertex position.
8. A camera-related orientation calculation involving `_WorldSpaceCameraPos` and `_VerticalBillboarding`.

The two GLSL variants each pass **all nine independent structural/dataflow checks** in the metadata-only audit. This establishes that the archived Shader **implements actual animated vertex displacement**.

**Do not publish the original GLSL or port its compiled program verbatim.** For Titan Legends, the useful general design pattern is a separately authored Godot 4 vertex sway with independent time, wind-direction, height and variation controls.

## Original material values (not Shader defaults)

Directly decoded `m_SavedProperties.m_Floats`, `m_Colors`, and `m_TexEnvs`:

| Stored property | Original flower material value |
|---|---|
| `_WindSpeed` | **1.36** |
| `_WindStrength` | **1.0** |
| `_Windvector` | **(10, 0, 0, 0)** |
| `_TimeScale` | **1.0** |
| `_GrassShakePos` | **0.0** |
| `_Mapwidth` | **80.0** |
| `_VerticalBillboarding` | **1.0** |
| `_UseLeafSway` | **0.0** |

The value `_Windvector=(10,0,0,0)` is confirmed by directly parsing the Material's saved **vector/color property** array; it was absent from the earlier floats-only report.

### Texture bindings

- `_MainTex` points to the externally verified original `tex_PY_hua` (256×256 ETC2_RGB4).
- `_WindSpecular` points to the externally verified original `WindmutatioGB2 Specular` (1024×1024 ETC2_RGB4).
- `_Wind` has a **null material texture pointer**; the original Shader declares a built-in **white** fallback texture. Runtime substitution or scripts were not inspected.
- `_GrassColor` has a **null material texture pointer**; the original Shader also declares a built-in **white** fallback.
- The property `_UseLeafSway` does **not** occur in this Shader's 16 declared properties; the `_UseLeafSway=0` value saved in the Material does **not** deactivate this Shader's separate time-dependent vertex deformation.

## Constraints / interpretation

- The compiled **vertex program contains functional time-dependent displacement** and the linked original Material has nonzero wind magnitude/direction. This proves capacity for movement in the original material/shader pair, **not a recorded runtime animation clip, measured vertex velocity or visible motion in every frame**.
- Actual amplitude also depends on the original mesh positions/height, texture values, time input, renderer state, and any game runtime overrides.
- The second/third platform mapping to hardware should not be inferred solely from numeric platform IDs. Only the first two program blocks are confirmed as GLSL ES 1.00 and GLSL ES 3.00 by their actual program headers.
- No original copyrighted source/compiled shader program has been checked into the repository or attached to the report.

## Metadata-only audit artifact

`ulala_plain_grassshaderwind_vertex_displacement_verified_2026_11_08.json`: original bundle/object SHA-256, material property metadata, serialized CAB/pathID linkage, program blob sizes, independent compressed-block decompression checks, and nine boolean vertex-dataflow checks for each GLSL variant. The report intentionally excludes original shader code.

**Next analysis:** compare wind inputs and the affected vertex-height ranges against original two flower Meshes, then plan an original Android-friendly Godot implementation only after reference research is complete.
