# Ulala metadata audit – Titan Legends

Status: implementation plan, **not** evidence that the archive contents have been fully inspected.

## Source and scope
- Reference: Google Drive folder `1exzf9zslKN4U0jPu41Ay-gwkcSBTP0oo`, nine split 7z volumes.
- Existing scanner: `tools/analysis/inventory_unity_bundles.py` (read-only UnityFS type inventory).
- Do not commit archives, proprietary meshes, textures, audio, animation curves or derived copies of distinctive characters.
- Verify permission before processing source material. Use only abstract technical metadata to inform independently created Titan Legends assets.

## Audit stages
1. Confirm all nine volume names and byte sizes, record SHA-256 hashes locally; validate the multi-volume archive with 7z test before extraction.
2. List archive entries without extracting the full backup. Select a small set of relevant UnityFS bundles.
3. Run existing scanner on an isolated extracted sample. Record scanned files, skipped oversized files, errors and object-type totals.
4. Extend a separate read-only metadata pass with defensive exception handling. For each bundle capture: anonymized bundle identifier, GameObject count, Mesh count, SkinnedMeshRenderer count, Avatar count, Animator count, AnimationClip count, Material count.
5. For successfully parsed clips, record only duration and sample-rate statistics; for rigs, bone count and parent-depth statistics; for meshes, vertex-count ranges. Do not serialize names, geometry, textures, bone transforms or animation curves into the report.
6. Compare those *aggregate* metrics against original Godot assets and validate each class with a headless Godot import/smoke test and a separate Android visual test.

## Class coverage
warrior, rogue, shaman, hunter, druid, paladin, priest, mage, warlock, summoner, brawler, death_knight.

## Acceptance checklist
- [ ] Archive integrity independently confirmed
- [ ] Metadata report reproducible and free of copyrighted asset payloads
- [ ] No original Ulala assets added to repository
- [ ] All twelve classes have their own mesh/rig/animation checks
- [ ] Godot headless tests pass
- [ ] Android performance and readability reviewed

## Current evidence boundary
The existing `docs/ULALA_FOREST_REFERENCE_ANALYSIS.md` explicitly states that inner Unity mesh/skeleton/animation/material analysis is not yet established. The existing scanner counts Unity object types only; it does not prove successful clip or rig inspection. Do not report these steps as completed until reports and tests exist.
