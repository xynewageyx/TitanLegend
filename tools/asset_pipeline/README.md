# Titan Legends asset toolchain

Six non-destructive development tools for Godot 4.x (target editor: 4.7.2). All tools use local assets and require no paid service.

1. Character Creator: `character_creator.py` generates editable hero specifications (not finished 3D meshes).
2. Landscape Generator: `landscape_generator.py` generates twelve elemental biome specifications.
3. Animation System: `animation_system.py` generates animation clip manifests.
4. Asset Manager: `asset_manager.py` inventories supported source assets and SHA-256 checksums.
5. Godot Importer: `godot_importer.py` validates asset paths and writes a safe import manifest. Actual Godot import happens in the editor.
6. GitHub Actions: `.github/workflows/asset-toolchain.yml` checks generated manifests and Python scripts; existing Android builds remain unchanged.

Run: `python3 tools/asset_pipeline/character_creator.py && python3 tools/asset_pipeline/landscape_generator.py && python3 tools/asset_pipeline/animation_system.py && python3 tools/asset_pipeline/asset_manager.py && python3 tools/asset_pipeline/godot_importer.py`

Generated JSON goes into `tools/asset_pipeline/generated/`. The scripts never replace game scenes, existing character models or save data. Import GLB/glTF assets using the Godot editor once the actual models are created. All hero designs must be original, even when using a colorful chibi adventure aesthetic.
