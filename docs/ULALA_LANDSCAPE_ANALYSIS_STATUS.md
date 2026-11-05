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
