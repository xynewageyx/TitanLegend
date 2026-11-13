# Four-character combat screen coverage and weapon interference audit

Date: 2026-11-10. Source: original Titan Legends Godot 4.7.2 imported GLBs and procedural mythic equipment.

## Reproduced CI evidence

- [Visible body geometry validation](https://github.com/xynewageyx/TitanLegend/actions/runs/42782402257) (all four actions passed)
- [Weapon-to-other-body overlap audit](https://github.com/xynewageyx/TitanLegend/actions/runs/42782647069) (**success**)
- Four class IDs: `[0,6,11,2]` = Warrior, Mage, Death Knight, Druid
- Test scene uses the elevated QA-only camera `(0,10,12)` looking toward `(0,1.2,0)`, in a 720×1280 portrait OpenGL viewport.
- Four sampling actions: Idle, Walk, Attack, Dodge; Godot screenshots, frame geometries and per-action metrics are published in `build/animated_equipment_qa/manifest.json` and the CI stdout records prefixed `TITAN_FORMATION_SCREEN_COVERAGE`.

## Measured results

| Action | Min fraction of imported-body bounding box within viewport | Max pairwise body bounding box overlap | Max weapon bounding box overlap with another hero's body bounding box |
| --- | ---: | ---: | ---: |
| Idle | 1.000 | 0.000 | 0.000 |
| Walk | 1.000 | 0.000 | 0.000 |
| Attack | 1.000 | 0.000 | 0.000 |
| Dodge | 1.000 | 0.000 | 0.000 |

In this controlled four-hero portrait capture, all four imported character **projected bounding regions** fit fully within the camera viewport, and each pair of measured body rectangles is separate. The projected mythic weapon rectangles also do not intersect the *other heroes'* imported-body rectangles.

Per-hero geometry boxes (Idle in pixels, `x,y,width,height`):
- Warrior: `[140.7, 325.9, 188.0, 314.8]`
- Mage: `[141.3, 648.8, 152.8, 277.7]`
- Death Knight: `[443.0, 327.9, 182.4, 307.5]`
- Druid: `[416.8, 645.2, 185.0, 281.3]`

## Method and limitations

The audit projects each visible `MeshInstance3D.get_aabb()` corner through the current Godot camera, merges the projected points per character/weapon, and measures `Rect2` intersections. This is a **conservative projected mesh-AABB footprint**, not pixel-accurate alpha segmentation or physical collision detection.

Important: the imported skinned mesh's ordinary static AABB can stay unchanged between actions, even when its bones animate. The same body rectangle is indeed reported for Idle, Walk, Attack and Dodge, so this audit must **not** be interpreted as animated vertex-bound completeness or proof that no sword moves through a character during an in-between frame.

The QA tests one exact composition, camera direction, four action samples, mythic main-hand weapons and chest armor only. They do **not** verify every class mix, boss, pet/VFX overlay, zoom level, transparency layer, render-quality profile, or physical Android GPU.

Do not change gameplay formation rules or weapon models based solely on this metadata pass. A future pixel-accurate visual QA should record separate color/depth masks for each hero and pet/VFX layer, with moving skin geometry under real game camera conditions.

No proprietary reference-game content is incorporated.
