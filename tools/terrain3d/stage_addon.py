#!/usr/bin/env python3
"""Prepare isolated Godot Terrain3D addon test project from pinned official release."""
import io,json,pathlib,urllib.request,zipfile,shutil
tag="v1.0.2-stable"
root=pathlib.Path("terrain3d-preview")
root.mkdir(exist_ok=True)
headers={"User-Agent":"TitanLegends-CI","Accept":"application/vnd.github+json"}
with urllib.request.urlopen(urllib.request.Request(f"https://api.github.com/repos/TokisanGames/Terrain3D/releases/tags/{tag}",headers=headers),timeout=30) as r: release=json.load(r)
assets=[a for a in release["assets"] if a["name"].lower().endswith(".zip") and "terrain3d" in a["name"].lower()]
if not assets: raise RuntimeError("No official Terrain3D zip")
asset=next((a for a in assets if "1.0.2" in a["name"]),assets[0])
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
(root/"project.godot").write_text('config_version=5\n\n[application]\nconfig/name="Titan Legends Terrain3D Test"\nrun/main_scene="res://scenes/terrain3d_test.tscn"\n\n[rendering]\nrenderer/rendering_method="gl_compatibility"\nrenderer/rendering_method.mobile="gl_compatibility"\n',encoding="utf-8")
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
