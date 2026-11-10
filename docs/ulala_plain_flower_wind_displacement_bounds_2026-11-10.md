# Ulala Plain flower wind: verified shader-derived displacement bounds and conditional 60-second sample — 2026-11-10

**Purpose:** Research metadata for a future **independently authored** Godot 4.7.2 mobile environment. The source is the user's original multipart Ulala backup; **no original shaders, textures, model geometry or placement records are committed, and Titan Legends graphics have NOT been changed.**

## Direct binary evidence (not a guessed wind system)

- Re-extracted the original `assets/shaders` UnityFS bundle and verified its **SHA-256** `ac8ae1ab0490852259b8ddddfaa7e46ae7783f5cf92b0118f5c3c9c258bdd7e2`, matching the earlier audit.
- Re-parsed the target `Unlit/GrassShaderWind` classID 48 Shader **pathID 5497956564624892993** (16,928 serialized bytes). Its three compressed platform program blobs decompress successfully; the first two contain matching original **GLSL ES 1.00 and GLSL ES 3.00 vertex-deformation logic**.
- The original flower Material's known properties were crosschecked: **`_WindStrength=1`**, `_Windvector=(10,0,0,0)`, `_GrassShakePos=0`, `_TimeScale=1`. Its `_Wind` slot is null; the Shader declares **white** as the default texture.
- Reused the separately verified source `hua_001` and `hua_002` classID 43 Float32 vertex-position streams (**320 and 472 vertices**) and the original `Plain` scene's exact **496 MeshRenderer→MeshFilter→GameObject→Transform** joins (**287 and 209 placements**). Parent Transforms have identity rotation and unit scale.
- Independently validated both vertex-stream bounds against their original Unity local AABB. All 496 per-scene X/Y/Z scales and quaternions were read; the displacement magnitude after each rotation uses the actual **local X scale**.

## 1. Conditional analytical upper bound for the actual time-varying wind term

The two decoded original OpenGL ES vertex programs:
- sample a `_Wind` texture, use an oscillatory sine × cosine term and scale it by `_Windvector`, the positive local vertex-height mask, vertex Y and `_WindStrength`;
- add the resulting deformation to the local vertex coordinates **before world/view-projection transforms**;
- also contain a **separate camera-facing/billboard contribution**, deliberately *excluded* from this **wind-only** estimate.

With the original saved values and **no runtime material/global override of the unassigned white `_Wind` texture**, its blue channel is 1 and the original Shader-derived wind scalar becomes **0.6**. For a vertex with local coordinate `0 < y < 1`, the absolute *wind-only local X displacement* has a conservative upper bound of **6 × y²** (since |sin × cos| ≤ 1). For source local Y ≤ 0, the shader's positive-height wind mask yields no wind-only displacement.

Both original flower meshes have the same maximum source-local Y of approximately **0.03949087**, giving the same **0.00935718 Unity source Mesh-local units** upper bound per unscaled vertex. The wind direction vector points along source local X. Each saved scene-instance rotation preserves vector magnitude, while its actual **local scale X** scales the world displacement magnitude. Ancestor scales are one.

| Source mesh | Scene placements | Local wind-only magnitude upper bound | Median instance world-space upper bound | Maximum instance world-space upper bound |
|---|---:|---:|---:|---:|
| `hua_001` | 287 | 0.00935718 | **0.18124** | **0.67605** |
| `hua_002` | 209 | 0.00935718 | **0.15571** | **0.51135** |
| **All 496** | **496** | | **0.17056** | **0.67605** |

Across all 496 original placements, the median upper bound divided by the previously calculated **static transformed mesh height** is about **19.51%**. This is a **bound**, not a report of actual peak swing angle or movement amplitude in the original running game. It does **not** include the billboard/camera-facing portion of total position changes.

**Nuance:** The Shader's `_WindSpecular` sample feeds a varying output; in the two verified GLSL ES vertex programs it does **not** multiply the wind-only position displacement. The material's `_WindSpeed` influences `_Wind` sample coordinates; with a uniform white default texture, this sampling speed does **not** by itself change the time-varying displacement. The original time-dependent oscillation still operates via the material's `_TimeScale`.

## 2. Conditional 60-second CPU sampling of the original wind waveform

Read original scene-object world-origin X/Z from the full five-parent Transform chain and evaluated the isolated **wind-only** original GLSL ES oscillation with:
- Unity built-in `_Time.y = elapsed seconds`;
- no runtime overrides, `_TimeScale=1`, the original `_Windvector`, `_WindStrength`, `_GrassShakePos`;
- white `_Wind` fallback;
- **0–60 s inclusive**, sampled every **0.02 seconds** (**3,001 timestamps**) per each of **496** original flowers.

The sampled predicted peak absolute wind-only displacement is:

| Mesh | Number of placements | Median 60 s sampled peak | Maximum sampled peak |
|---|---:|---:|---:|
| `hua_001` | 287 | **0.17681** | **0.66550** |
| `hua_002` | 209 | **0.15133** | **0.51061** |
| **All 496** | **496** | **0.16599** | **0.66550** |

The sampled **median mean-absolute displacement over time** across all flowers is **0.06884** scene units (not the same statistic as each flower's maximal peak). The median ratio between sampled peak and conservative analytical bound is **97.59%**. It is possible for the continuous-time peak to exceed the sampled estimate slightly; it cannot exceed the separate analytic bound given the stated static inputs.

These numbers are an **independent CPU mathematical prediction**, not recorded Unity runtime animation, measured mobile frame timings, actual on-screen pixel motion, a complete simulation of all shader deformation, or a claim that every flower is visible at once.

## 3. What is still unknown

- The original game's scripts, global material bindings or property blocks may override `_Wind`, even though the original saved Material slot is null. Different sampled wind texture values alter both phase and multiplier.
- The complete shader also contains a camera-facing billboard component. Actual total vertex world position changes need the in-game camera and material state.
- The third compressed program variant has not been decoded as readable GLSL, so these checks apply to the two directly inspected **GLSL ES** versions.
- The relative heights and scene scales are source Unity units, *not* Titan Legends world units or a recommended Godot wind amplitude.
- The original winding geometry and shaders must not be copied into Titan Legends; any future Godot system should be independently created and validated on Android.

## Produced local metadata-only reports

- `ulala_plain_496_flower_wind_conditional_bound_2026_11_10.json` — direct source checksums, saved Material values, per-source-mesh conservative bounds and 496-placements summary.
- `ulala_plain_flower_wind_bound_summary_2026_11_10.csv` — two-row mesh comparison.
- `ulala_plain_496_flower_wind_60s_sampled_2026_11_10.json` — 60-second sampled predicted wind-only displacement distributions.
- `ulala_plain_flower_wind_60s_sampled_summary_2026_11_10.csv` — two-row sampled comparison.

The local Python audit programs decode original owner-provided source data strictly for analysis; **original vertex arrays, shaders and per-instance source placement data are not in the GitHub commit**.

**Conclusion:** the source wind function is real; under its saved default input bindings the flower's positive vertex height leads to a *quadratically height-weighted* sinusoidal wind offset. The figures here quantify a conditional **upper bound and sampled prediction** for all 496 actual placements, **not** a measurement from the game or an implementation in Titan Legends.
