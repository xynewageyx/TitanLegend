# Ulala reference: aggregated mesh complexity (2026-11-06)

Read-only measurements from the locally decoded Unity serialized Mesh objects. These are reference observations, **not** copied assets or production budgets. Source dataset: `ulala_expanded_monster_analysis.csv` (102 inspected objects, 47 mesh records). Triangle totals sum Mesh records grouped by bundle; external referenced meshes, equipment, particles, LOD variants and effects may be absent. Do not interpret bundle totals as a full rendered character or scene.

| Bundle | Mesh records | Vertex sum | Triangle sum |
|---|---:|---:|---:|
| bs_yilika.prefab_ab_shared | 4 | 8747 | 12870 |
| bs_shouya_sq.prefab_ab_shared | 6 | 8815 | 10092 |
| duoluoxi_boss.prefab_ab_shared | 2 | 6246 | 9402 |
| bs_guluoer.prefab_ab_shared | 4 | 6256 | 8883 |
| fankangjuntouling_boss.prefab_ab_shared | 1 | 7196 | 8756 |
| baojunlong.prefab_ab_shared | 1 | 3712 | 6064 |
| bawanglong.prefab_ab_shared | 1 | 3427 | 5584 |
| daolang.prefab_ab_shared | 3 | 3825 | 4867 |
| fenglong_yue.prefab_ab_shared | 2 | 2929 | 4316 |
| fenglong.prefab_ab_shared | 1 | 2720 | 4108 |

Median triangle count per individual Mesh across 47 records: **1802**. This is not a per-monster median. Triangle counts do not predict Android performance alone: draw calls, materials, skinning, overdraw, lighting and screen resolution also matter.

## Next validation

1. Measure the nine original Titan Legends forest GLBs after Godot import, with triangles, surfaces, bones and draw calls.
2. Profile a 4-player team against 7 simultaneous enemies on low-end Android with the intended graphical profiles.
3. Set quality-tier limits from measured frame time, not directly from reference triangle counts.
4. Investigate AnimationClip curves and rig paths separately; existing Unity clip duration is not evidence of combat timing.
