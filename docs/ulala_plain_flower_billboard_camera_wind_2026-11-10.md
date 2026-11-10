# Ulala Plain flowers: original camera billboard and wind interaction — 2026-11-10

**Research only.** This is a read-only reconstruction of the user's original Unity 2019.4.16f1c1 data from the nine-part Ulala archive. No copyrighted original shaders, vertex arrays, per-instance level coordinates or graphics payloads are included. **Titan Legends graphics/gameplay are unchanged.**

## 1. Correct original Plain camera world transform

The original `plain.unity_ab` scene's serialized `BuildPlayer-Plain` object table contains exactly one **Camera (classID 20, pathID 57419)**; its owning GameObject pointer is **67**, its enabled byte is 1, and its saved FOV is **100°**, far clipping distance **90**.

Crucially, its parent Transform has a **20° rotation about X**, so simply adding local positions is **not** a correct world position. The source transform chain is:

- Parent position `(0, 1, ~19.8)`, Quaternion representing approximately **20° X** rotation.
- Camera local position `(0, 1, -3)`, camera local X rotation approximately **5°**.
- Applying parent rotation **before** camera-local translation gives the saved camera **world position `(0, 2.96575295, 17.32294144)`**.

The archived `Unlit/GrassShaderWind` GLSL ES program uses `_WorldSpaceCameraPos` rather than the camera rotation to calculate its billboard direction. Actual game runtime scripts may move/replace this camera, which is why the results below are **conditional saved-scene simulations**, not measured gameplay visuals.

## 2. Confirmed shader-dataflow behavior in both original GLSL ES variants

Rechecked the previously extracted original Shader serialized object (classID 48), separately decompressed OpenGL ES 1.00 and OpenGL ES 3.00 programs, and directly compared their camera-facing position dataflow. Both build a direction from **camera position minus each static world vertex**, normalize it, modify the vertical direction using saved `_VerticalBillboarding` (**1.0**), then normalize again. A perpendicular right basis is selected, including a fallback for almost vertical view directions.

This is **vertex-specific camera direction**, rather than a single rotation applied to the entire plant. The shader combines a derived camera-related vector with its separate, time-dependent wind term. Specifically, it takes the **X and Y components of a camera-dependent 3D vector** and applies them as **local X/Z displacements**, after multiplying by saved `vertexLocalY × _WindStrength × windTextureFactor`. It then transforms the modified local vertex position into world and projection space.

Under the stored flower Material, `_WindStrength=1`, `_VerticalBillboarding=1`, `_GrassShakePos=0`, `_Windvector=(10,0,0)`, and the unbound `_Wind` texture uses the shader-declared **white default**. This implies the same conditional wind texture factor **0.6** used in the prior wind-only analysis, provided no runtime bindings override it.

The time-dependent **wind-only** offset and the **camera-dependent billboard** offset are *separate contributions* and then combined before object-to-world transformation. Billboard offset itself is camera-dependent, **not a time-periodic animation unless the camera moves**.

## 3. Exact saved-camera billboard contribution, all 496 placements

For each of **287 `hua_001`** and **209 `hua_002`** scene placements, this audit re-read the original source Mesh Float32 XYZ vertices (320 or 472 respectively), each saved three-axis scale and quaternion, all five verified unit-scale/identity-rotation flower ancestor transforms, and the correctly rotated original scene camera pose. The saved-camera billboard offset of **each original vertex** was reconstructed mathematically. Per-placement maxima were summarized; **individual vertices, source poses and coordinates are not published**.

| Original Mesh | Placements | Median per-placement peak billboard vector length | Largest peak billboard vector length | Median peak as % of static Mesh height |
|---|---:|---:|---:|---:|
| `hua_001` | **287** | **0.01824258** | **0.06815716** | **1.9655%** |
| `hua_002` | **209** | **0.01558438** | **0.05135180** | **1.9540%** |
| **All flowers** | **496** | **0.01717718** | **0.06815716** | **1.9582%** |

All figures are **original Unity scene coordinate units** and **conditional predictions**, not on-screen pixel movement, measured motion or device load.

## 4. Conservative camera-independent analytical upper bounds

To guard against camera-script movement, the original saved-material billboard term also has a direction-independent upper bound for each source vertex:

`world_billboard_offset_length <= max(|scaleX|, |scaleZ|) × |localY| × 0.6 × (sqrt(localX² + localZ²) + |localY|)`.

This follows from the construction of normalized, perpendicular camera/right vectors and the triangle inequality. It is a **conservative bound** for the same saved Material inputs; no particular camera position is assumed.

- Across all 496 instances, the **median conservative billboard upper bound** is **0.01946246**, and the **largest conservative upper bound** is **0.07714141** source units.
- Every individual vertex under the saved camera satisfied its analytical bound (verified numerically).
- The median observed *saved-camera billboard prediction* relative to the independently calculated **wind-only mathematical upper bound** is **10.07%**. **Ratios of separate bounds/peaks are not measured animation intensity.**
- A conservative **full wind + billboard** camera-independent upper bound (sum per vertex, then max across vertices) is **0.75319139** at its largest instance and **0.19002704** at the median instance. The corresponding previous **wind-only upper bound** was **0.67604998 maximum**, **0.17056459 median**.

## 5. Additional conditional combined snapshots

A vector sum of the saved-camera billboard offset and the time-dependent wind term was calculated **at five illustrative timestamps** (0, 15, 30, 45, 60 seconds). Each timestamp uses the original scene flower position for the time phase, default white wind sample, and static saved camera position; the maximum vector displacement per flower was then found over its original Mesh vertices.

| Timestamp | Median of per-flower maximum combined displacement |
|---|---:|
| 0 seconds | **0.06140266** |
| 15 seconds | **0.01715955** |
| 30 seconds | **0.06678552** |
| 45 seconds | **0.10167121** |
| 60 seconds | **0.10424052** |

These are **five discrete mathematical snapshots**, **not** observed game frames, not a continuous-time maximum and not camera-visibility-filtered. The prior 60-second **wind-only** sampler is a different metric, so its `0.16599` median peak must **not** be directly added to these per-timestamp medians.

## 6. Validations and limitations

- Exactly one scene Camera object found and decoded; **parent X rotation properly applied**, local and parent camera Transform chains verified.
- All **496** original flower renderer→mesh→transform joins and **five ancestors per flower** rechecked.
- Both original **GLSL ES 1.00 and 3.00** compiled-program representations contain the same billboard/wind dataflow operators.
- All reconstructed right vectors are perpendicular to normalized view direction; no near-pole fallback vertices occurred in this saved-camera calculation.
- Every saved-camera billboard displacement respects the per-vertex analytic bound, and every combined snapshot respects its combined bound.
- The original `_Wind` texture pointer is null, with white shader default. Runtime overrides, camera scripts, third non-GLSL platform shader and onscreen pixel geometry were **not** verified.
- Camera frustum culling, wind/specular textures at runtime, final image pixels, actual animation speed, GPU time and Android FPS are **not measured**.
- No original mesh buffers, shader bytecode, or authored source positions were distributed.

**Metadata-only supporting exports (generated and validated locally):**
- `ulala_plain_flower_billboard_camera_wind_verified_2026_11_10.json`
- `ulala_plain_flower_billboard_summary_2026_11_10.csv`

**Implication for original Titan Legends art:** A new Godot 4.7.2 stylized vegetation shader can independently combine height-weighted time wind and subtle camera-facing correction, but the source Unity amplitudes should *not* be transferred directly. Tune with actual Android camera framing and frame-time tests. **No Titan Legends graphics have been changed.**
