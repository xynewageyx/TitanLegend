# Grasland Godot preview
This scene references `res://assets/worlds/grasland/grasland.glb`, which must first be downloaded from the successful **Generate Grasland 3D GLB** Actions artifact and copied to that exact path. The GLB is not committed by the generator.

Open `res://scenes/grasland_preview.tscn` in Godot 4.x after importing the GLB. This is a separate scene and does **not** replace `scenes/main.tscn` or affect gameplay. Camera and lighting are initial test settings only.

To build an APK with this preview, the GLB must be added to the repository and the existing Android export workflow adapted; neither is done automatically.
