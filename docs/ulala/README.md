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
