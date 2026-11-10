# Ulala Plain flower Mesh vertex heights: direct original-binary audit (2026-11-10)

**Scope:** Follow-up to the previously validated `Unlit/GrassShaderWind` vertex-deformation finding. Original user-provided multipart Ulala reference archive, Unity 2019.4.16f1c1, serialized file version 21. **Reference metadata only: neither mesh vertex arrays, textures nor shader code are copied to Titan Legends. No game graphics have been changed.**

## Source integrity and readout method

1. Reassembled the nine archive volumes in the local analysis environment and opened the resulting 7z using libarchive.
2. Extracted **only** the two original source bundles `env_af_huaduo_01.prefab_ab_shared` and `env_af_huaduo_02.prefab_ab_shared`.
3. Rechecked their SHA-256 hashes against the independent prior Plain-decoration mesh report. Both match exactly:

| Bundle | SHA-256 |
|---|---|
| `env_af_huaduo_01.prefab_ab_shared` | `14d454bae28665bb0639c21b84fe90bfe5249e307905bf38a15039ad355307df` |
| `env_af_huaduo_02.prefab_ab_shared` | `4926e018ba5122540ce7588fb8f260a42cec655db973c9438f057621682f7b13` |

4. Decompressed each UnityFS **LZ4** block and obtained the original serialized `CAB-...` node and its corresponding `.resS` node.
5. Parsed each SerializedFile **v21 type table and complete object table**, and located the exact Mesh **classID 43** object by its signed `pathID`.
6. Identified `m_VertexData` in the Mesh's serialized bytes using its saved vertex count and **14 ChannelInfo records**. The first channel explicitly states **stream 0, offset 0, format 0 (Float32), dimension 3**. Each stream is **40 bytes per vertex**.
7. Read the X/Y/Z channels directly from the externally streamed original vertex buffer, and cross-validated all six calculated minimum/maximum coordinates against the original Mesh's stored `m_LocalAABB` center/extents. The largest deviation per Mesh is **9.313225746154785×10⁻¹⁰ local units**.
8. Exported **aggregate statistics only**, not individual vertex positions or source art.

## Verified original flower Meshes

| Field | `hua_001` | `hua_002` |
|---|---:|---:|
| Original Mesh source | `env_af_huaduo_02.prefab_ab_shared` | `env_af_huaduo_01.prefab_ab_shared` |
| Original Mesh `pathID` | `-2380014778547825205` | `-4557394364495080719` |
| Vertex count | **320** | **472** |
| Triangle count | **216** | **340** |
| Plain-scene MeshRenderer placements | **287** | **209** |
| Vertex-stream bytes | **12,800** | **18,880** |
| Local X min / max | −0.01066878 / 0.01234104 | −0.01099379 / 0.01314176 |
| Local Y min / max | **−0.00847200 / 0.03949087** | **−0.00873284 / 0.03949087** |
| Local Z min / max | −0.00210394 / 0.00776860 | −0.00594263 / 0.01084134 |
| Vertex count where Y < 0 | **12** | **20** |
| Vertex count where Y = 0 | **0** | **0** |
| Vertex count where Y > 0 | **308** | **452** |
| Median local Y | **0.01684920** | **0.02555317** |
| Local Y 75th percentile | **0.03290495** | **0.03205204** |
| Vertices in highest 25% of local height range | **148** | **164** |

**Important distinction:** "Highest 25% of local height range" means **Y ≥ minY + 0.75 × (maxY−minY)**, *not* the top 25% of vertex ranks.

### Original height distribution

The five columns below use **five equally sized Y-height intervals for each individual Mesh**. Each row totals its verified vertex count.

| Mesh | 0–20% | 20–40% | 40–60% | 60–80% | 80–100% |
|---|---:|---:|---:|---:|---:|
| `hua_001` | 12 | 12 | **144** | 4 | **148** |
| `hua_002` | 20 | 16 | **156** | **132** | **148** |

Together the two meshes contain **792 unique vertices**; **760** have positive saved Mesh-local Y, **32** have negative Y and none exactly zero. In total there are **496 Plain-scene placements** of these two meshes, contributing **133,052 theoretical unculled triangles** (287×216 + 209×340). These are scene-definition arithmetic, **not** camera-visible draw cost.

## Relation to the verified wind shader

Previous independent source binary inspection established that `Unlit/GrassShaderWind` has time-dependent, sine/cosine-based **vertex displacement** and uses local vertex height and material controls (including `_GrassShakePos`) among its inputs. Its linked flower material stores **`_GrassShakePos=0`**, `_WindStrength=1`, `_WindSpeed≈1.36`, and a nonzero `_Windvector`.

The measurements in this document establish which **local Y coordinates are actually available** in the two mesh streams. The high percentage of vertices with Y>0 does **not** by itself prove that precisely those vertices animate, how strongly they move, or how they appear in runtime. A correct movement-strength prediction also requires the full vertex displacement expression, per-mesh/instance object-to-world transforms, wind texture values, and runtime inputs.

No original GLSL, serialized mesh buffer or commercial game art was transferred to the repo.

## Reproducibility and remaining checks

The local metadata-only exports are:
- `ulala_plain_flower_vertex_height_audit_2026_11_10.json` — source checksums, channel0 provenance, computed coordinate ranges, 8 Y percentiles, sign counts and 5-bin distribution with AABB verification.
- `ulala_plain_flower_vertex_height_summary_2026_11_10.csv` — short side-by-side summary.

**Next:** inspect the flower prefab Transform scaling and orientation, then optionally join actual Plain-scene instance transforms if camera/world-space bounds are needed. **No change to Titan Legends graphics.**
