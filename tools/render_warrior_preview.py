"""Render a quick visual QA thumbnail of the exported warrior in Blender."""
import bpy
import math
from pathlib import Path
from mathutils import Vector

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=str(Path("build/class_0.glb").resolve()))
scene = bpy.context.scene
scene.frame_set(1)

def point_at(obj, target):
    direction = Vector(target) - obj.location
    obj.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()

bpy.ops.object.camera_add(location=(5.2, -7.8, 4.0))
camera = bpy.context.object
point_at(camera, (0, 0, 1.25))
camera.data.type = "ORTHO"
camera.data.ortho_scale = 4.8
scene.camera = camera

for name, location, energy, size in (
    ("Key", (4, -5, 7), 1100, 5),
    ("Fill", (-4, -2, 3), 650, 4),
    ("Rim", (0, 4, 5), 1400, 3),
):
    bpy.ops.object.light_add(type="AREA", location=location)
    light = bpy.context.object
    light.name = name
    light.data.energy = energy
    light.data.shape = "DISK"
    light.data.size = size
    point_at(light, (0, 0, 1.3))

bpy.ops.mesh.primitive_plane_add(size=200, location=(0, 0, -0.035))
floor = bpy.context.object
floor.name = "PreviewFloor"
mat = bpy.data.materials.new("PreviewFloorMat")
mat.diffuse_color = (0.055, 0.075, 0.11, 1)
floor.data.materials.append(mat)

scene.render.engine = "BLENDER_EEVEE"
scene.render.resolution_x = 900
scene.render.resolution_y = 900
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = "PNG"
scene.render.filepath = str(Path("build/warrior_preview.png").resolve())
scene.world.color = (0.13, 0.13, 0.13)
scene.camera.data.lens = 50
bpy.ops.render.render(write_still=True)
print("Rendered", scene.render.filepath)

# Front orthographic reference exposes symmetry, sword visibility and armor proportions.
camera.location = (0, -8.5, 3.0)
point_at(camera, (0, 0, 1.35))
scene.render.filepath = str(Path("build/warrior_front.png").resolve())
bpy.ops.render.render(write_still=True)
print("Rendered", scene.render.filepath)

# Side view helps spot floating joints and overlapping armor layers.
camera.location = (8.5, 0, 3.0)
point_at(camera, (0, 0, 1.35))
scene.render.filepath = str(Path("build/warrior_side.png").resolve())
bpy.ops.render.render(write_still=True)
print("Rendered", scene.render.filepath)
