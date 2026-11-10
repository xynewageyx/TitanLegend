# Ulala reference metadata — Titan Legends

These files capture **abstract technical reference findings**, not transferable third-party game assets.

- [2026-11-10 skinning/bindpose crosscheck](ULALA_2026_11_10_BINDPOSE_CROSSCHECK.md)
- [Aggregated mapping status](ULALA_2026_11_10_MAPPING_STATUS.csv)
- [Avatar skeleton and pose audit](ULALA_2026_11_10_AVATAR_POSE_AUDIT.md)
- [Resolved DLY/NDLY Avatar indices and weapon/shoe ordering](ULALA_2026_11_10_AVATAR_INDEX_RESOLUTION.md)
- [Weapon renderer and hand-root-bone offset audit](ULALA_2026_11_10_WEAPON_ATTACHMENT_AUDIT.md)
- [Variant weapon anchor metadata CSV](ULALA_2026_11_10_WEAPON_ANCHORS.csv)

Earlier upstream analysis remains in `docs/ULALA_EQUIPMENT_BUNDLE_SCAN.md`, `docs/ULALA_CHARACTER_HIERARCHIES.md`, `docs/ULALA_AGGREGATED_MESH_COMPLEXITY.md` and `tools/analysis/ulala_rig_fullbody_compatibility.md`.

Numbers in this directory are sample results and do not demonstrate full Godot compatibility. Raw archived bundles, textures, animations, vertex buffers, bone matrices and other proprietary payloads are deliberately excluded.

## Titan Legends twelve-class inventory check

After running the existing `.github/workflows/export-skeleton3d-inventory.yml` workflow or exporting Godot Skeleton3D data locally, run:

```bash
python3 tools/audit_titan_twelve_rigs.py build/skeleton3d_inventory.json --output build/twelve_class_rig_coverage.json
```

The validator checks that every class, including `death_knight`, has exactly one nonempty imported skeleton under a scene filename matching its class name. It does not assess retargeting compatibility or prove that all actual character GLBs were imported. Three synthetic test cases were exercised locally while authoring the tool; a real project import remains pending.

## Verified Godot twelve-class rest poses

- [Direct audit from GitHub Actions Skeleton3D export](TITAN_2026_11_10_12_CLASS_REST_AUDIT.md)
- [Successful rest-pose and equipment-socket CI run](https://github.com/xynewageyx/TitanLegend/actions/runs/42759238280): all twelve GLBs have required socket bones; eleven standard rigs match their baseline rest pose; Death Knight 24-bone extended rig is intentionally different. Artifact: `titan-skeleton3d-inventory`, including `twelve_class_pose_compatibility.json`.

No Unity animation retargeting is claimed.

## Animated equipment verification

- [Successful 12-class weapon grip continuity test](TITAN_2026_11_10_WEAPON_GRIP_ANIMATION_TEST.md): 144 grip-to-socket samples across Idle, Walk, Attack and Dodge, run [42759744859](https://github.com/xynewageyx/TitanLegend/actions/runs/42759744859). Actual hand-to-finger alignment and Android rendering still require a visual check.
