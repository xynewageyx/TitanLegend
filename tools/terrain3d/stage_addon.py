#!/usr/bin/env python3
"""Prepare isolated Godot Terrain3D addon test project from pinned official release."""
import io,json,pathlib,urllib.request,zipfile,shutil
tag="v1.1.0-rc1"
root=pathlib.Path("terrain3d-preview")
root.mkdir(exist_ok=True)
(root/"terrain_data").mkdir(exist_ok=True)
headers={"User-Agent":"TitanLegends-CI","Accept":"application/vnd.github+json"}
with urllib.request.urlopen(urllib.request.Request(f"https://api.github.com/repos/TokisanGames/Terrain3D/releases/tags/{tag}",headers=headers),timeout=30) as r: release=json.load(r)
assets=[a for a in release["assets"] if a["name"].lower().endswith(".zip") and "terrain3d" in a["name"].lower()]
if not assets: raise RuntimeError("No official Terrain3D zip")
asset=next((a for a in assets if "1.1.0" in a["name"]),assets[0])
with urllib.request.urlopen(urllib.request.Request(asset["browser_download_url"],headers=headers),timeout=120) as r: payload=r.read()
with zipfile.ZipFile(io.BytesIO(payload)) as z:
 names=z.namelist()
 manifests=[n for n in names if n.endswith(".gdextension")]
 if not manifests: raise RuntimeError("No gdextension in release")
 # Extract only the addon tree, regardless of archive prefix.
 candidates=[n for n in names if "/addons/terrain_3d/" in "/"+n or n.startswith("addons/terrain_3d/")]
 if not candidates: raise RuntimeError("Expected addons/terrain_3d directory missing; inspect release")
 for name in candidates:
  relative=("/"+name).split("/addons/terrain_3d/",1)[1]
  if not relative or name.endswith("/"):continue
  target=root/"addons"/"terrain_3d"/relative
  target.parent.mkdir(parents=True,exist_ok=True)
  target.write_bytes(z.read(name))
(root/"project.godot").write_text('config_version=5\n\n[application]\nconfig/name="Titan Legends Terrain3D Test"\nrun/main_scene="res://scenes/grasland_terrain3d.tscn"\n\n[rendering]\nrenderer/rendering_method="gl_compatibility"\nrenderer/rendering_method.mobile="gl_compatibility"\n',encoding="utf-8")
scene=root/"scenes"/"terrain3d_test.tscn";scene.parent.mkdir(exist_ok=True)
scene.write_text('[gd_scene format=3]\n\n[node name="Terrain3DTest" type="Node3D"]\n\n[node name="Camera3D" type="Camera3D" parent="."]\nposition = Vector3(0, 8, 14)\nrotation_degrees = Vector3(-25, 0, 0)\ncurrent = true\n\n[node name="Sun" type="DirectionalLight3D" parent="."]\nrotation_degrees = Vector3(-50, -30, 0)\n',encoding="utf-8")
print(f"Staged {len(candidates)} addon entries from {asset['name']}; Terrain3D node intentionally not instantiated until compatibility verified")

# Actual Terrain3D GDExtension registration smoke-test scene.
terrain_scene=root/"scenes"/"terrain3d_node_test.tscn"
terrain_scene.write_text(chr(10).join([
 '[gd_scene format=3]',
 '',
 '[node name="Terrain3DNodeTest" type="Node3D"]',
 '',
 '[node name="Terrain3D" type="Terrain3D" parent="."]',
 ''
]), encoding="utf-8")

# Playable landscape prototype: camera, sun, environment and Terrain3D node.
# Region generation is attempted by a separate script and must pass CI before claiming success.
landscape=root/"scenes"/"grasland_terrain3d.tscn"
landscape.write_text(chr(10).join([
 '[gd_scene load_steps=2 format=3]',
 '',
 '[ext_resource type="Script" path="res://scripts/grasland_setup.gd" id="1"]',
 '',
 '[node name="Grasland" type="Node3D"]',
 'script = ExtResource("1")',
 '',
 '[node name="Terrain3D" type="Terrain3D" parent="."]',
 'data_directory = "res://terrain_data"',
 '',
 '[node name="Camera3D" type="Camera3D" parent="."]',
 'position = Vector3(32, 45, 105)',
 'rotation_degrees = Vector3(-28, 0, 0)',
 'current = true',
 '',
 '[node name="Sun" type="DirectionalLight3D" parent="."]',
 'rotation_degrees = Vector3(-55, -35, 0)',
 'light_energy = 1.3',
 ''
]),encoding="utf-8")
scripts=root/"scripts";scripts.mkdir(exist_ok=True)
(scripts/"grasland_setup.gd").write_text(chr(10).join([
 'extends Node3D',
 '',
 '@onready var terrain = $Terrain3D',
 '',
 'func _ready() -> void:',
 '    terrain.set_camera($Camera3D)',
 '    var data = terrain.get_data()',
 '    if data.get_region(Vector2i(0, 0)) == null:',
 '        data.add_region_blank(Vector2i(0, 0))',
 '        DirAccess.make_dir_recursive_absolute("res://terrain_data")',
 '        for x in range(0, 129):',
 '            for z in range(0, 129):',
 '                var fx = float(x)',
 '                var fz = float(z)',
 '                var h = 7.0 * sin(fx * 0.028) * cos(fz * 0.023)',
 '                h += 3.5 * sin(fx * 0.064 + fz * 0.037)',
 '                h += 1.2 * cos(fz * 0.14 - fx * 0.07)',
 '                # Winding walkable route across the meadow.',
 '                var trail_center = 63.0 + 16.0 * sin(fz * 0.036)',
 '                var trail_distance = abs(fx - trail_center)',
 '                var trail_blend = 1.0 - smoothstep(4.0, 12.0, trail_distance)',
 '                h = lerp(h, 0.8 + 0.6 * sin(fz * 0.025), trail_blend)',
 '                # Level boss arena near the far end of the route.',
 '                var arena_distance = Vector2(fx - 63.0, fz - 106.0).length()',
 '                var arena_blend = 1.0 - smoothstep(18.0, 27.0, arena_distance)',
 '                h = lerp(h, 1.0, arena_blend)',
 '                data.set_height(Vector3(x, 0, z), h)',
 '        data.update_maps()',
 '        data.save_directory("res://terrain_data")',
 '    print("GRASLAND_REGION_READY")',
 '    print("GRASLAND_CAMERA_CONNECTED")',
 ''
]),encoding="utf-8")
