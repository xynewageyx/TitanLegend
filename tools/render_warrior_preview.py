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

# Update 281: compose the comparison using Blender's built-in image API.
# No Pillow dependency is required in the Blender runtime.
names = ("windup", "strike", "recovery")
images = [
    bpy.data.images.load(str(Path(f"build/warrior_attack_{name}.png").resolve()),
                         check_existing=False)
    for name in names
]
width, height = images[0].size
if any(tuple(img.size) != (width, height) for img in images):
    raise RuntimeError("Attack preview frames must have identical dimensions")
sheet = bpy.data.images.new(
    "WarriorAttackComparison", width=width * 3, height=height,
    alpha=True, float_buffer=False)
pixels = [0.0] * (width * 3 * height * 4)
for index, img in enumerate(images):
    source = list(img.pixels[:])
    for y in range(height):
        source_offset = y * width * 4
        target_offset = (y * width * 3 + index * width) * 4
        pixels[target_offset:target_offset + width * 4] = source[
            source_offset:source_offset + width * 4]
sheet.pixels.foreach_set(pixels)
sheet.filepath_raw = str(Path("build/warrior_attack_comparison.png").resolve())
sheet.file_format = "PNG"
sheet.save()
print("Saved attack comparison sheet", sheet.filepath_raw)

# Update 282: machine-readable QA report of the actual imported attack poses.
import json
report = {"clip": "RigRightArmAttackTest", "frames": []}
for frame, phase in ((5, "windup"), (9, "strike"), (13, "recovery")):
    scene.frame_set(frame)
    bpy.context.view_layer.update()
    bones = {}
    for bone_name in ("Root", "Spine", "UpperArm.R", "Forearm.R"):
        pose_bone = rig.pose.bones.get(bone_name)
        if pose_bone is None:
            raise RuntimeError(f"Attack QA missing bone: {bone_name}")
        bones[bone_name] = {
            "position": [round(float(v), 5) for v in pose_bone.matrix.translation],
            "rotation_quaternion": [
                round(float(v), 5) for v in pose_bone.matrix.to_quaternion()
            ],
        }
    report["frames"].append({"frame": frame, "phase": phase, "bones": bones})
report_path = Path("build/warrior_attack_qa.json")
report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
# Update 283: reject missing motion rather than accepting a named but static clip.
def pose_distance(a, b):
    return sum((x - y) ** 2 for x, y in zip(a, b)) ** 0.5

phases = report["frames"]
for bone_name in ("Spine", "UpperArm.R", "Forearm.R"):
    first = phases[0]["bones"][bone_name]["rotation_quaternion"]
    strike = phases[1]["bones"][bone_name]["rotation_quaternion"]
    if pose_distance(first, strike) < 0.005:
        raise RuntimeError(f"Attack QA: {bone_name} has no meaningful windup-to-strike rotation")
root_first = phases[0]["bones"]["Root"]["position"]
root_strike = phases[1]["bones"]["Root"]["position"]
if pose_distance(root_first, root_strike) < 0.005:
    raise RuntimeError("Attack QA: Root has no meaningful weight shift")
report["motion_validation"] = {
    "passed": True,
    "rotation_bones": ["Spine", "UpperArm.R", "Forearm.R"],
    "root_weight_shift": True,
    "minimum_pose_difference": 0.005,
}
report_path.write_text(json.dumps(report, indent=2) + "\\n", encoding="utf-8")
print("Saved attack pose QA report", report_path)
