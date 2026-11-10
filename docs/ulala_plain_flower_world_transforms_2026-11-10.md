# Ulala Plain: 496 original flower scene-instance transforms and static world bounds (2026-11-10)

**Reference audit only.** Direct binary verification against the user's original multipart Ulala archive (Unity 2019.4.16f1c1, SerializedFile v21). **No source mesh vertices, scene placement lists, shader code, textures or other copyrighted original assets are published or copied to Titan Legends. No game graphics changed.**

## Source integrity and procedure

- The original `plain.unity_ab` was extracted again from the nine-part user archive. SHA-256: **`0421a3d278e569e297e48af629a1aef122498dbb2f976114c85cc40ca428ff06`**, matching the independent previous report.
- Parsed `BuildPlayer-Plain` containing **105,075 Unity serialized objects**. All **28,709 Transform** (classID 4), **19,191 MeshFilter** (33), and **19,191 MeshRenderer** (23) object records were read by original object boundaries. For every Transform the byte-length check **68+12×childCount** matched its serialized record size.
- Located the **496 non-LOD flower MeshRenderer placements**, and matched each renderer's GameObject to its MeshFilter and exact Mesh source `fileID,pathID`: **287 `hua_001`** and **209 `hua_002`**.
- For each GameObject the owning Transform was read, and **five** valid parent transforms were traversed with no cycles. All ancestor scales are exactly **(1,1,1)** and their rotations are identity. Therefore their stored translations shift the scene-world location, but do not change the child object's size or orientation.
- For each of the 496 placements, its full local **three-axis scale** and **quaternion rotation** were applied to the **actual Float32 XYZ vertices** of the original flower Mesh, then parent translations were added. The **true static unanimated 3D vertex bounds** were measured. The original Mesh XYZ fields were independently validated against Unity's saved `m_LocalAABB` in the preceding audit.
- Detailed vertex arrays and the 496 original placement coordinate records were **not exported**. This report contains only statistical summaries.

## Actual per-instance scale and full 3D static mesh height

Units below are **Unity original-scene units**, not independently measured physical meters or Titan Legends world sizes.

| Measured quantity | `hua_001` (287) | `hua_002` (209) |
|---|---:|---:|
| Minimum local Y scale | **7.6093×** | **9.0183×** |
| Median local Y scale | **19.3695×** | **16.6407×** |
| Maximum local Y scale | **72.2494×** | **54.6479×** |
| Minimum static transformed 3D vertex height | **0.3655** | **0.4351** |
| Median transformed height | **0.9290** | **0.8025** |
| Maximum transformed height | **3.4667** | **2.6353** |
| 25th-percentile height | **0.7267** | **0.6966** |
| 75th-percentile height | **1.2028** | **1.2191** |

Combined **496 flowers**: median **0.8775** source units of static mesh height, minimum **0.3655**, maximum **3.4667**.

### Why applying only a 20× prefab scale is incorrect

The source prefab archives each include separate **1× and 20× Transform variants**, but the **actual Plain scene objects** have many distinct scale values. Per-scene validation found:

- **2/496** Blumen use **nonuniform local XYZ scales**; both belong to `hua_001`.
- **36/496** have local quaternion rotations with a nontrivial pitch/roll component (**20 `hua_001` and 16 `hua_002`**).
- All **five parents of each flower** have unit scale and identity rotation (the same ancestor can be shared by many flowers).
- Thus a universal estimate such as `(localYmax-localYmin)*20`, or even `height×scene Y-scale`, is **not exact** for these 38* exceptional conditions. We used the **full quaternion and three-axis scale on every original Vertex** to measure actual static bounds.
- `*38` is a count of checks, not necessarily distinct affected placements if a rotated object also has nonuniform scale; the individual overlap is not asserted here.

These are **static source-mesh bounds, prior to shader-driven wind displacement**. Wind amplitude and runtime camera visibility remain unmeasured.

## Source scene organization: ten parent branches, five longitudinal offsets

The 496 placements are grouped under **ten direct parent Transform branches**, two branches per shared Z-offset. Their five distinct **parent-chain Z translations** are **−240, −159.9, −71.6, 0 and +240** (Unity units).

| Parent-chain Z shift | `hua_001` | `hua_002` | Total flower placements |
|---|---:|---:|---:|
| −240.0 | 44 | 31 | **75** |
| −159.9 | 37 | 29 | **66** |
| −71.6 | 36 | 31 | **67** |
| 0.0 | 130 | 81 | **211** |
| +240.0 | 40 | 37 | **77** |
| **Total** | **287** | **209** | **496** |

The actual flower Transform pivot positions (parent transforms applied) span approximately **X −32.56 to +24.25**, **Y −2.05 to +5.62**, **Z −79.50 to +304.84**. These are **position ranges**, *not* combined bounds of plant geometry, terrain dimensions, collision sizes or camera frustum.

This saved hierarchical layout suggests repeated scene sections with offset parent groups. It is **not evidence** that the runtime streams those sections, instantiates them procedurally, or renders all 496 flowers in one frame.

## Validation summary

| Validation | Result |
|---|---|
| Original Plain UnityFS SHA-256 crosschecked | PASS |
| All 28,709 Transform object byte boundaries validated | PASS |
| All 496 renderer→GameObject→MeshFilter→Mesh references | PASS |
| All 496 scene flower Transform chains (five ancestors each) | PASS |
| All flower ancestor quaternion/scale checks | PASS |
| Actual original Mesh-local XYZ arrays match stored Unity bounds | PASS (prior audit) |
| Actual 496 full XYZ/quaternion transformed static height bounds computed | PASS |
| Original vertex positions and original placement coordinate arrays uploaded to GitHub | **NO** |

## Metadata-only report files

- `ulala_plain_496_flower_world_transform_aggregate_2026_11_10.json`: aggregate transform and exact static bounds statistics, branch counts, validation flags and limitations.
- `ulala_plain_496_flower_size_summary_2026_11_10.csv`: two-row comparison with source scale and world-height distributions.

**Still open:** Verify the actual wind-displacement amplitude at representative shader inputs, review camera visibility and occlusion, and evaluate independently authored mobile-friendly scene chunking. **No Titan Legends graphics have been modified.**
