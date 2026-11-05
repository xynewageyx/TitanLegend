# Ulala landscape analysis — verified status and reuse plan

## Verified in repository
- The main repository contains `tools/analysis/inspect_unity_bundles.py`, a read-only UnityPy object-type inventory for `.prefab_ab` and `.prefab_ab_shared` files.
- The landscape branch contains `tools/ulala_landscape_inventory.py` (filename/header inventory) and `tools/ulala_landscape_decode.py` (UnityPy object-name inventory).
- The landscape reference index identifies forest, weather, sky, terrain, vegetation and water bundles. Filename-based roles remain hypotheses until payload decoding.
- Neither script establishes geometry statistics, scene parent/child relationships, texture properties or mobile rendering performance.

## Analysis sequence
1. Verify the complete multipart archive and extract only the relevant bundles in a private workspace.
2. Run `tools/analysis/inspect_unity_bundles.py` on forest prefabs; use the landscape decoder on materials and terrain bundles.
3. Record decoded object counts and names, then inspect hierarchy references and numerical mesh/material metadata in a separate read-only report.
4. Distinguish confirmed decoded facts from filename-derived guesses; report errors and missing dependencies.
5. Do not commit copyrighted asset bytes or modify the Titan Legends landscape until the analysis is complete.

## Status
Archive listing and bundle paths documented. Full Unity object decoding for the landscape **not yet independently verified in this branch**.

## Cross-check against current game landscape implementation
- Default-branch `tests/test_landscape_depth.py` checks `scripts/biome_manager.gd`, not the separate Blender preview generator.
- The test asserts a 48 x 160 terrain footprint and a 160-unit path, plus a nature-only distant forest extension.
- It checks a fixed random seed and no collision bodies for distant forest details.
- These are **static source assertions**, not evidence of a successful runtime test or measured Android FPS.
- Before implementing any reference-inspired improvements, reconcile the live `biome_manager.gd` terrain with the standalone `tools/blender/generate_grasland.py` preview; do not assume they render together.
