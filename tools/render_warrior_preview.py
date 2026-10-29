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

# Update 279: export three snapshots from the independent skeletal attack test.
# The old game Attack clip is intentionally not altered.
armatures = [obj for obj in bpy.data.objects if obj.type == "ARMATURE"]
rig = next((obj for obj in armatures if obj.name.startswith("WarriorDeformRigPrototype")), None)
if rig is None or rig.animation_data is None:
    raise RuntimeError("Imported deform rig missing for attack QA")
attack_tracks = [
    track for track in rig.animation_data.nla_tracks
    if track.name == "RigRightArmAttackTest"
]
if len(attack_tracks) != 1:
    raise RuntimeError("Expected exactly one imported RigRightArmAttackTest NLA track")
for track in rig.animation_data.nla_tracks:
    track.mute = track != attack_tracks[0]
camera.location = (5.2, -7.8, 4.0)
point_at(camera, (0, 0, 1.25))
for frame, label in ((5, "windup"), (9, "strike"), (13, "recovery")):
    scene.frame_set(frame)
    scene.render.filepath = str(Path(f"build/warrior_attack_{label}.png").resolve())
    bpy.ops.render.render(write_still=True)
    print("Rendered attack frame", frame, scene.render.filepath)

# Update 280: create a single comparison sheet for mobile QA.
# Pillow is bundled with Blender's Python on supported CI builds.
from PIL import Image, ImageDraw
names = ("windup", "strike", "recovery")
frames = [Image.open(Path(f"build/warrior_attack_{name}.png")).convert("RGB") for name in names]
thumb_width = 600
thumb_height = round(frames[0].height * thumb_width / frames[0].width)
sheet = Image.new("RGB", (thumb_width * 3, thumb_height + 70), (24, 28, 36))
draw = ImageDraw.Draw(sheet)
for index, (name, frame_image) in enumerate(zip(names, frames)):
    frame_image = frame_image.resize((thumb_width, thumb_height))
    sheet.paste(frame_image, (index * thumb_width, 70))
    draw.text((index * thumb_width + 22, 24), name.upper(), fill=(245, 245, 245))
sheet_path = Path("build/warrior_attack_comparison.png")
sheet.save(sheet_path)
print("Rendered attack comparison sheet", sheet_path)
