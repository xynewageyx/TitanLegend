# Update 214 – Optional 3D model pipeline

This is an additive foundation for replacing procedural hero, enemy and companion geometry with original animated GLB models. It does not change existing visuals until wired into the respective spawn routines.

## Usage

1. Import original GLB assets to `res://assets/models/` (e.g. `heroes/warrior.glb`).
2. Call `TitanModelLoader.attach_model(hero_node, "heroes/warrior")`.
3. If a Node3D is returned, hide the existing procedural visual nodes (not the gameplay root, collision, UI or effects). If null is returned, leave the procedural visuals intact.
4. Call `TitanModelLoader.play_animation(model, &"Run")` if the imported scene contains that animation. A false result means the clip is unavailable.

### Constraints
- Companions remain passive; no new attack or damage logic.
- Keep one active tank per team, without automatic replacement.
- Preserve all existing boss, wave and stage rules.
- Use low-poly/optimized original models and compressed textures for Android.
- Confirm Godot import, headless validation and on-device FPS before merging.

### Status
Loader added; no models supplied, no spawn integration performed, and no Android build verified yet.
