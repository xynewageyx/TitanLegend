#!/usr/bin/env python3
"""Prepare isolated Godot Terrain3D addon test project from pinned official release."""
import io,json,os,pathlib,urllib.request,zipfile,shutil
tag="v1.1.0-rc1"
root=pathlib.Path("terrain3d-preview")
root.mkdir(exist_ok=True)
(root/"terrain_data").mkdir(exist_ok=True)
headers={"User-Agent":"TitanLegends-CI","Accept":"application/vnd.github+json"}
if os.environ.get("GH_TOKEN"):
 headers["Authorization"]="Bearer "+os.environ["GH_TOKEN"]
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
 'position = Vector3(64, 58, 158)',
 'rotation_degrees = Vector3(-35, 0, 0)',
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
 '    # Overlay a textured winding path and a circular boss arena.',
 '    _build_path_and_arena()',
 '    _scatter_grassland_props()',
 '    print("GRASLAND_REGION_READY")',
 '    print("GRASLAND_REGION_EXISTS:", data.get_region(Vector2i(0, 0)) != null)',
 '    print("GRASLAND_CAMERA_CONNECTED")',
 '',
 'func _scatter_grassland_props() -> void:',
 '    # Low-poly environmental props; deterministic and mobile-friendly.',
 '    var foliage := StandardMaterial3D.new()',
 '    foliage.albedo_color = Color(0.21, 0.49, 0.20)',
 '    foliage.roughness = 1.0',
 '    var bark := StandardMaterial3D.new()',
 '    bark.albedo_color = Color(0.39, 0.25, 0.15)',
 '    bark.roughness = 1.0',
 '    var stone := StandardMaterial3D.new()',
 '    stone.albedo_color = Color(0.47, 0.49, 0.45)',
 '    stone.roughness = 1.0',
 '    var trunk_mesh := CylinderMesh.new()',
 '    trunk_mesh.top_radius = 0.30',
 '    trunk_mesh.bottom_radius = 0.43',
 '    trunk_mesh.height = 3.0',
 '    var canopy_mesh := SphereMesh.new()',
 '    canopy_mesh.radius = 2.2',
 '    canopy_mesh.height = 3.4',
 '    canopy_mesh.radial_segments = 8',
 '    canopy_mesh.rings = 4',
 '    var rock_mesh := SphereMesh.new()',
 '    rock_mesh.radius = 1.0',
 '    rock_mesh.height = 1.6',
 '    rock_mesh.radial_segments = 8',
 '    rock_mesh.rings = 4',
 '    for i in range(45):',
 '        var x: float = 7.0 + float((i * 37 + 13) % 112)',
 '        var z: float = 6.0 + float((i * 53 + 17) % 116)',
 '        var trail: float = 63.0 + 16.0 * sin(z * 0.036)',
 '        if abs(x - trail) < 11.0 or Vector2(x - 63.0, z - 106.0).length() < 27.0:',
 '            continue',
 '        var trunk := MeshInstance3D.new()',
 '        trunk.name = "TreeTrunk_%02d" % i',
 '        trunk.mesh = trunk_mesh',
 '        trunk.material_override = bark',
 '        trunk.position = Vector3(x, _height_at(x, z) + 1.5, z)',
 '        add_child(trunk)',
 '        var canopy := MeshInstance3D.new()',
 '        canopy.name = "TreeCrown_%02d" % i',
 '        canopy.mesh = canopy_mesh',
 '        canopy.material_override = foliage',
 '        canopy.position = Vector3(x, _height_at(x, z) + 4.2, z)',
 '        add_child(canopy)',
 '    for i in range(28):',
 '        var x: float = 5.0 + float((i * 41 + 21) % 116)',
 '        var z: float = 4.0 + float((i * 47 + 29) % 118)',
 '        var trail: float = 63.0 + 16.0 * sin(z * 0.036)',
 '        if abs(x - trail) < 6.0 or Vector2(x - 63.0, z - 106.0).length() < 18.0:',
 '            continue',
 '        var rock := MeshInstance3D.new()',
 '        rock.name = "Rock_%02d" % i',
 '        rock.mesh = rock_mesh',
 '        rock.material_override = stone',
 '        rock.position = Vector3(x, _height_at(x, z) + 0.5, z)',
 '        rock.scale = Vector3(1.1, 0.7, 0.85)',
 '        add_child(rock)',
 '    print("GRASLAND_PROPS_READY")',
 '',
 '',
 'func _height_at(fx: float, fz: float) -> float:',
 '    var h: float = 7.0 * sin(fx * 0.028) * cos(fz * 0.023)',
 '    h += 3.5 * sin(fx * 0.064 + fz * 0.037)',
 '    h += 1.2 * cos(fz * 0.14 - fx * 0.07)',
 '    var trail_center: float = 63.0 + 16.0 * sin(fz * 0.036)',
 '    h = lerp(h, 0.8 + 0.6 * sin(fz * 0.025), 1.0 - smoothstep(4.0, 12.0, abs(fx - trail_center)))',
 '    h = lerp(h, 1.0, 1.0 - smoothstep(18.0, 27.0, Vector2(fx - 63.0, fz - 106.0).length()))',
 '    return h',
 '',
 'func _surface_material(path: String, fallback: Color) -> StandardMaterial3D:',
 '    var mat := StandardMaterial3D.new()',
 '    mat.albedo_color = fallback',
 '    mat.roughness = 0.95',
 '    mat.cull_mode = BaseMaterial3D.CULL_DISABLED',
 '    if ResourceLoader.exists(path):',
 '        mat.albedo_texture = load(path)',
 '    return mat',
 '',
 'func _add_surface(name: String, points: PackedVector3Array, uv: PackedVector2Array, indices: PackedInt32Array, material: Material) -> void:',
 '    var arrays := []',
 '    arrays.resize(Mesh.ARRAY_MAX)',
 '    arrays[Mesh.ARRAY_VERTEX] = points',
 '    arrays[Mesh.ARRAY_TEX_UV] = uv',
 '    arrays[Mesh.ARRAY_INDEX] = indices',
 '    var mesh := ArrayMesh.new()',
 '    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)',
 '    var node := MeshInstance3D.new()',
 '    node.name = name',
 '    node.mesh = mesh',
 '    node.material_override = material',
 '    add_child(node)',
 '',
 'func _build_path_and_arena() -> void:',
 '    var vertices := PackedVector3Array()',
 '    var uv := PackedVector2Array()',
 '    var triangles := PackedInt32Array()',
 '    for z in range(0, 100):',
 '        var center: float = 63.0 + 16.0 * sin(float(z) * 0.036)',
 '        for side in [-1.0, 1.0]:',
 '            var x: float = center + side * 3.5',
 '            vertices.append(Vector3(x, _height_at(x, float(z)) + 0.12, float(z)))',
 '            uv.append(Vector2(0.0 if side < 0.0 else 1.0, float(z) / 5.0))',
 '        if z > 0:',
 '            var a: int = (z - 1) * 2',
 '            triangles.append_array(PackedInt32Array([a, a + 2, a + 1, a + 1, a + 2, a + 3]))',
 '    _add_surface("WindingDirtPath", vertices, uv, triangles, _surface_material("res://textures/terrain/weg_albedo.png", Color(0.66, 0.46, 0.28)))',
 '    vertices = PackedVector3Array()',
 '    uv = PackedVector2Array()',
 '    triangles = PackedInt32Array()',
 '    vertices.append(Vector3(63.0, 1.15, 106.0))',
 '    uv.append(Vector2(0.5, 0.5))',
 '    for i in range(0, 65):',
 '        var angle: float = TAU * float(i) / 64.0',
 '        var x: float = 63.0 + cos(angle) * 16.0',
 '        var z: float = 106.0 + sin(angle) * 16.0',
 '        vertices.append(Vector3(x, _height_at(x, z) + 0.15, z))',
 '        uv.append(Vector2(0.5 + cos(angle) * 1.6, 0.5 + sin(angle) * 1.6))',
 '        if i > 0:',
 '            triangles.append_array(PackedInt32Array([0, i, i + 1]))',
 '    _add_surface("BossArena", vertices, uv, triangles, _surface_material("res://textures/terrain/fels_albedo.png", Color(0.48, 0.47, 0.43)))',
 '    print("GRASLAND_PATH_AND_ARENA_READY")',
 '',
 ''
]),encoding="utf-8")


# Install the official ProtonScatter editor addon into the isolated test project.
# Download archive directly to avoid GitHub release API rate limits.
scatter_url="https://github.com/HungryProton/scatter/archive/refs/heads/main.zip"
with urllib.request.urlopen(urllib.request.Request(scatter_url,headers={"User-Agent":"TitanLegends-CI"}),timeout=120) as response:
 scatter_zip=response.read()
with zipfile.ZipFile(io.BytesIO(scatter_zip)) as archive:
 addon_files=[n for n in archive.namelist() if "/addons/proton_scatter/" in n and not n.endswith("/")]
 if not any(n.endswith("/addons/proton_scatter/plugin.cfg") for n in addon_files):
  raise RuntimeError("ProtonScatter addon plugin.cfg missing in upstream archive")
 for name in addon_files:
  rel=name.split("/addons/proton_scatter/",1)[1]
  if not rel or ".." in pathlib.PurePosixPath(rel).parts:
   continue
  dest=root/"addons"/"proton_scatter"/rel
  dest.parent.mkdir(parents=True,exist_ok=True)
  dest.write_bytes(archive.read(name))
print("PROTON_SCATTER_STAGED",len(addon_files))
project_file=root/"project.godot"
project_text=project_file.read_text(encoding="utf-8")
project_text+='\\n[editor_plugins]\\nenabled=PackedStringArray("res://addons/proton_scatter/plugin.cfg")\\n'
project_file.write_text(project_text,encoding="utf-8")

# Generate independent scenes and terrain data directories for all 12 biomes.
# Each scene has its own deterministic height profile and can be opened on Android.
region_config=json.loads(pathlib.Path("tools/terrain3d/regions.json").read_text(encoding="utf-8"))
regions=region_config["regions"]
assert len(regions)==12 and all(r["stage_end"]-r["stage_start"]==99 for r in regions)
base_scene=landscape.read_text(encoding="utf-8")
base_script=(scripts/"grasland_setup.gd").read_text(encoding="utf-8")
import re
for region in regions:
 key=region["key"]
 amplitude=float(region["terrain"]["height_amplitude"])
 # Scale the main ridgeline per biome; preserve the flattened trail and boss arena.
 script=base_script.replace("7.0 * sin(fx * 0.028)",f"{amplitude:.2f} * sin(fx * 0.028)")
 # Biome-specific vegetation and rock palettes; avoid identical scenery across all regions.
 def gd_color(hex_color):
  value=hex_color.lstrip("#")
  return "Color(%s)" % ", ".join(f"{int(value[i:i+2],16)/255:.4f}" for i in (0,2,4))
 foliage=gd_color(region["terrain"]["grass_color"])
 rock=gd_color(region["terrain"]["rock_color"])
 bark=gd_color(region["terrain"]["path_color"])
 script=script.replace("Color(0.21, 0.49, 0.20)",foliage)
 script=script.replace("Color(0.47, 0.49, 0.45)",rock)
 script=script.replace("Color(0.39, 0.25, 0.15)",bark)
 # Reduce trees in barren biomes; use crystals/stone formations instead.
 barren=region["element"] in ("fire","ice","earth","arcane","lightning","dark","light")
 if barren:
  script=script.replace("for i in range(45):","for i in range(12):")
  script=script.replace("for i in range(28):","for i in range(55):")
 else:
  script=script.replace("for i in range(45):","for i in range(65):")
  script=script.replace("for i in range(28):","for i in range(24):")
 # Distinct silhouettes for rocky, frozen, magical and desert biomes.
 if region["element"] in ("ice","arcane","lightning","light"):
  script=script.replace("var rock_mesh := SphereMesh.new()","var rock_mesh := CylinderMesh.new()")
  script=script.replace("rock_mesh.radius = 1.0","rock_mesh.top_radius = 0.0\n    rock_mesh.bottom_radius = 0.85")
  script=script.replace("rock_mesh.height = 1.6","rock_mesh.height = 3.2")
  script=script.replace("rock_mesh.radial_segments = 8","rock_mesh.radial_segments = 5")
  script=script.replace("rock_mesh.rings = 4","")
 elif region["element"]=="earth":
  script=script.replace("var canopy_mesh := SphereMesh.new()","var canopy_mesh := CylinderMesh.new()")
  script=script.replace("canopy_mesh.radius = 2.2","canopy_mesh.top_radius = 0.55\n    canopy_mesh.bottom_radius = 0.7")
  script=script.replace("canopy_mesh.height = 3.4","canopy_mesh.height = 3.4")
  script=script.replace("canopy_mesh.rings = 4","")
 # Special biome props and weather, implemented with built-in Godot meshes and CPU particles.
 if key in ("frost_peaks","ember_volcano"):
  weather_snow=key=="frost_peaks"
  extra=[
   "",
   "func _add_elemental_environment() -> void:",
   "    var sky_particles := CPUParticles3D.new()",
  ]
  extra[3]='    sky_particles.name = "'+('Snowstorm' if weather_snow else 'Ashfall')+'"'
  extra.extend([
   "    sky_particles.amount = 140",
   "    sky_particles.lifetime = 7.0",
   "    sky_particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX",
   "    sky_particles.emission_box_extents = Vector3(58.0, 3.0, 58.0)",
   "    sky_particles.position = Vector3(63.0, 28.0, 65.0)",
   "    sky_particles.direction = Vector3(0.25, -1.0, 0.12)",
   "    sky_particles.spread = 12.0",
   "    sky_particles.gravity = Vector3(0.0, -3.0, 0.0)",
   "    sky_particles.initial_velocity_min = 1.5",
   "    sky_particles.initial_velocity_max = 3.5",
   "    var weather_mesh := SphereMesh.new()",
   "    weather_mesh.radius = 0.13",
   "    weather_mesh.height = 0.24",
   "    sky_particles.mesh = weather_mesh",
   "    add_child(sky_particles)",
   "    sky_particles.emitting = true",
   "    var trunk_material := StandardMaterial3D.new()",
   "    trunk_material.albedo_color = Color(0.60, 0.86, 0.96)" if weather_snow else "    trunk_material.albedo_color = Color(0.17, 0.13, 0.12)",
   "    var crown_material := StandardMaterial3D.new()",
   "    crown_material.albedo_color = Color(0.72, 0.94, 1.0)" if weather_snow else "    crown_material.albedo_color = Color(1.0, 0.28, 0.04)",
   "    crown_material.emission_enabled = true",
   "    crown_material.emission = crown_material.albedo_color",
   "    crown_material.emission_energy_multiplier = 0.6",
   "    var branch_mesh := CylinderMesh.new()",
   "    branch_mesh.top_radius = 0.10",
   "    branch_mesh.bottom_radius = 0.40",
   "    branch_mesh.height = 4.5",
   "    var crown_mesh := CylinderMesh.new()",
   "    crown_mesh.top_radius = 0.0",
   "    crown_mesh.bottom_radius = 1.9",
   "    crown_mesh.height = 4.5",
   "    crown_mesh.radial_segments = 7",
   "    for i in range(22):",
   "        var px: float = 7.0 + float((i * 37 + 19) % 112)",
   "        var pz: float = 7.0 + float((i * 43 + 23) % 112)",
   "        var route_x: float = 63.0 + 16.0 * sin(pz * 0.036)",
   "        if abs(px - route_x) < 12.0 or Vector2(px - 63.0, pz - 106.0).length() < 27.0:",
   "            continue",
   "        var tree := MeshInstance3D.new()",
   '        tree.name = "IceTree_%02d" % i' if weather_snow else '        tree.name = "FireTree_%02d" % i',
   "        tree.mesh = branch_mesh",
   "        tree.material_override = trunk_material",
   "        tree.position = Vector3(px, _height_at(px, pz) + 2.25, pz)",
   "        add_child(tree)",
   "        var crown := MeshInstance3D.new()",
   "        crown.mesh = crown_mesh",
   "        crown.material_override = crown_material",
   "        crown.position = Vector3(px, _height_at(px, pz) + 5.2, pz)",
   "        add_child(crown)",
  ])
  if not weather_snow:
   extra.extend([
    "    var lava_material := StandardMaterial3D.new()",
    "    lava_material.albedo_color = Color(0.95, 0.19, 0.02)",
    "    lava_material.emission_enabled = true",
    "    lava_material.emission = Color(1.0, 0.23, 0.02)",
    "    lava_material.emission_energy_multiplier = 1.8",
    "    var volcano := MeshInstance3D.new()",
    '    volcano.name = "VolcanoCone"',
    "    var cone := CylinderMesh.new()",
    "    cone.top_radius = 2.0",
    "    cone.bottom_radius = 13.0",
    "    cone.height = 19.0",
    "    cone.radial_segments = 16",
    "    volcano.mesh = cone",
    "    volcano.material_override = trunk_material",
    "    volcano.position = Vector3(16.0, _height_at(16.0, 20.0) + 9.5, 20.0)",
    "    add_child(volcano)",
    "    var crater := MeshInstance3D.new()",
    '    crater.name = "LavaCrater"',
    "    var disk := CylinderMesh.new()",
    "    disk.top_radius = 2.0",
    "    disk.bottom_radius = 2.0",
    "    disk.height = 0.2",
    "    crater.mesh = disk",
    "    crater.material_override = lava_material",
    "    crater.position = volcano.position + Vector3(0.0, 9.6, 0.0)",
    "    add_child(crater)",
   ])
  script=script.replace("    _scatter_grassland_props()","    _scatter_grassland_props()\\n    _add_elemental_environment()")
  script+="\\n".join(extra)+"\\n"
 # Make object distribution vary deterministically by biome ID.
 seed_offset=int(region["terrain"]["seed"]) % 101
 script=script.replace("(i * 37 + 13)",f"(i * 37 + {13+seed_offset})")
 script=script.replace("(i * 53 + 17)",f"(i * 53 + {17+seed_offset})")
 script=script.replace("(i * 41 + 21)",f"(i * 41 + {21+seed_offset})")
 script=script.replace("(i * 47 + 29)",f"(i * 47 + {29+seed_offset})")
 script=script.replace('res://terrain_data',f'res://terrain_data/{key}')
 script=script.replace('GRASLAND_',f'{key.upper()}_')
 script=script.replace("res://textures/terrain/",f"res://textures/terrain/{key}/")
 (scripts/f"{key}_setup.gd").write_text(script,encoding="utf-8")
 scene_text=base_scene.replace("res://scripts/grasland_setup.gd",f"res://scripts/{key}_setup.gd")
 scene_text=scene_text.replace('name="Grasland"',f'name="{key}"')
 scene_text=scene_text.replace('res://terrain_data',f'res://terrain_data/{key}')
 (root/"scenes"/f"{key}_terrain3d.tscn").write_text(scene_text,encoding="utf-8")
 (root/"terrain_data"/key).mkdir(parents=True,exist_ok=True)
(root/"regions.json").write_text(json.dumps(region_config,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
print("REGIONS_GENERATED:",len(regions))

# Bundle seamless, reproducible terrain textures so Android users do not have
# to copy PNG files into every newly downloaded test project.
import math,random,struct,zlib
texture_dir=root/"textures"/"terrain"
texture_dir.mkdir(parents=True,exist_ok=True)
def write_png(filename, base, seed, grain):
 size=256
 rng=random.Random(seed)
 # Periodic low-frequency variations blend perfectly at tile edges.
 phases=[rng.uniform(0,math.tau) for _ in range(4)]
 pixels=bytearray()
 for y in range(size):
  pixels.append(0)
  for x in range(size):
   u=math.tau*x/size;v=math.tau*y/size
   wave=(math.sin(u*3+phases[0])*math.cos(v*3+phases[1])*0.45+
         math.sin(u*9+phases[2])*math.cos(v*9+phases[3])*0.25)
   speck=rng.uniform(-1,1)*grain
   shade=wave*24+speck
   for ch in base:
    pixels.append(max(0,min(255,int(ch+shade))))
 def chunk(kind,data):
  return struct.pack(">I",len(data))+kind+data+struct.pack(">I",zlib.crc32(kind+data)&0xffffffff)
 png=b"\x89PNG\r\n\x1a\n"+chunk(b"IHDR",struct.pack(">IIBBBBB",size,size,8,2,0,0,0))+chunk(b"IDAT",zlib.compress(bytes(pixels),6))+chunk(b"IEND",b"")
 (texture_dir/filename).write_bytes(png)
write_png("gras_albedo.png",(89,149,57),11,29)
write_png("erde_albedo.png",(117,84,54),22,25)
write_png("weg_albedo.png",(168,128,82),33,18)
write_png("fels_albedo.png",(116,119,116),44,31)
print("Bundled four tileable terrain PNGs in textures/terrain")
# Give each biome its own deterministic terrain textures, including path and stone.
for region in regions:
 key=region["key"]
 biome_dir=texture_dir/key
 biome_dir.mkdir(parents=True,exist_ok=True)
 palette=region["terrain"]
 for filename,color_name,offset,grain in [
  ("gras_albedo.png","grass_color",1,22),
  ("erde_albedo.png","path_color",2,24),
  ("weg_albedo.png","path_color",3,16),
  ("fels_albedo.png","rock_color",4,27),
 ]:
  color=palette[color_name].lstrip("#")
  rgb=tuple(int(color[i:i+2],16) for i in (0,2,4))
  # write_png writes into texture_dir; copy its reproducible result into biome directory.
  write_png(filename,rgb,int(palette["seed"])+offset,grain)
  shutil.copyfile(texture_dir/filename,biome_dir/filename)
  # Restore base grassland texture after biome variants are written.
# Keep the shared grassland set unchanged for the original scene.
write_png("gras_albedo.png",(89,149,57),11,29)
write_png("erde_albedo.png",(117,84,54),22,25)
write_png("weg_albedo.png",(168,128,82),33,18)
write_png("fels_albedo.png",(116,119,116),44,31)
print("BIOME_TEXTURES_READY",len(regions)*4)

