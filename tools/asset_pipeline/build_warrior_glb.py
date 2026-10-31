"""Blender 4.x headless: create an original rigged low-poly chibi warrior GLB.

Usage: blender -b --python tools/asset_pipeline/build_warrior_glb.py -- OUTPUT.glb
No third-party character assets required. This is a procedural prototype.
"""
import bpy
import math
import sys
from pathlib import Path
from mathutils import Vector

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)


def material(name, rgb):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*rgb, 1)
    # glTF exports Principled BSDF node colors, not viewport-only diffuse_color.
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get("Principled BSDF")
    if bsdf is not None:
        bsdf.inputs["Base Color"].default_value = (*rgb, 1)
        bsdf.inputs["Metallic"].default_value = 0.12
        bsdf.inputs["Roughness"].default_value = 0.72
    return m


skin = material("warm_skin", (0.89, 0.58, 0.40))
armor = material("steel_blue", (0.18, 0.35, 0.62))
trim = material("gold_trim", (0.92, 0.65, 0.17))
hair = material("dark_hair", (0.13, 0.09, 0.10))
leather = material("dark_leather", (0.24, 0.15, 0.12))
eye = material("eyes", (0.04, 0.08, 0.13))
eye_shine = material("eye_highlight", (0.98, 0.98, 1.0))
cheek = material("soft_cheek", (0.92, 0.43, 0.38))
silver = material("silver_blade", (0.73, 0.82, 0.91))


def cube(name, pos, scale, mat, bone):
    bpy.ops.mesh.primitive_cube_add(size=1, location=pos)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    # Apply a restrained bevel to replace toy-like sharp box silhouettes.
    bevel = obj.modifiers.new("Soft armor edges", "BEVEL")
    bevel.width = min(scale) * 0.14
    bevel.segments = 3
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.modifier_apply(modifier=bevel.name)
    # No weighted-normal modifier: keeps exported GLB mesh simple and portable.
    pieces.append((obj, bone))
    return obj


def sphere(name, pos, scale, mat, bone):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=16, radius=1, location=pos)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    for polygon in obj.data.polygons:
        polygon.use_smooth = True
    pieces.append((obj, bone))
    return obj


pieces = []
cube("torso_armor", (0, 0, 1.32), (0.75, 0.46, 0.72), armor, "spine")
sphere("head", (0, -0.02, 2.08), (0.52, 0.45, 0.50), skin, "head")
sphere("hair_cap", (0, 0.04, 2.43), (0.52, 0.44, 0.20), hair, "head")
# Distinctive swept fringe and rounded anime-style hair tufts, all head-weighted.
for i, (x, z) in enumerate([(-0.35, 2.36), (-0.15, 2.40), (0.08, 2.42), (0.30, 2.37)]):
    sphere("hair_fringe_%d" % i, (x, -0.35, z), (0.17, 0.16, 0.19), hair, "head")
sphere("nose", (0, -0.468, 1.98), (0.055, 0.045, 0.045), skin, "head")
sphere("mouth", (0, -0.462, 1.86), (0.12, 0.022, 0.026), leather, "head")
cube("chest_crest", (0, -0.254, 1.43), (0.24, 0.055, 0.31), trim, "spine")
for side, label in [(-1, "L"), (1, "R")]:
    sphere("eye_" + label, (side * 0.18, -0.424, 2.11), (0.105, 0.045, 0.14), eye, "head")
    sphere("eye_glint_" + label, (side * 0.18 - 0.028, -0.466, 2.17), (0.027, 0.013, 0.035), eye_shine, "head")
    sphere("cheek_" + label, (side * 0.32, -0.37, 1.96), (0.09, 0.025, 0.045), cheek, "head")
    sphere("shoulder_" + label, (side * 0.53, 0, 1.58), (0.27, 0.31, 0.27), trim, "upper_arm." + label)
    cube("arm_" + label, (side * 0.65, 0, 1.18), (0.27, 0.30, 0.55), armor, "upper_arm." + label)
    cube("glove_" + label, (side * 0.65, -0.02, 0.83), (0.32, 0.32, 0.27), leather, "upper_arm." + label)
    cube("leg_" + label, (side * 0.22, 0, 0.56), (0.30, 0.35, 0.70), leather, "leg." + label)
    cube("boot_" + label, (side * 0.22, -0.12, 0.17), (0.36, 0.56, 0.33), armor, "leg." + label)
# Layered armor silhouette with contrasting chest plates and side guards.
cube("breastplate_upper", (0, -0.258, 1.53), (0.63, 0.075, 0.22), armor, "spine")
cube("breastplate_lower", (0, -0.255, 1.25), (0.52, 0.07, 0.20), armor, "spine")
for side, label in [(-1, "L"), (1, "R")]:
    cube("pauldron_trim_" + label, (side * 0.55, -0.19, 1.67), (0.36, 0.11, 0.11), trim, "upper_arm." + label)
    cube("bracer_" + label, (side * 0.65, -0.175, 1.03), (0.30, 0.065, 0.20), trim, "upper_arm." + label)
    cube("knee_guard_" + label, (side * 0.22, -0.205, 0.54), (0.33, 0.085, 0.19), armor, "leg." + label)
    cube("boot_trim_" + label, (side * 0.22, -0.402, 0.24), (0.34, 0.055, 0.08), trim, "leg." + label)
    sphere("brow_" + label, (side * 0.18, -0.421, 2.28), (0.13, 0.035, 0.034), hair, "head")
cube("belt", (0, 0, 0.99), (0.78, 0.52, 0.16), leather, "spine")
cube("belt_buckle", (0, -0.28, 0.99), (0.20, 0.06, 0.16), trim, "spine")
cube("sword_grip", (0.65, -0.02, 0.51), (0.12, 0.12, 0.50), leather, "upper_arm.R")
cube("sword_blade", (0.65, -0.02, 0.03), (0.20, 0.075, 0.66), silver, "upper_arm.R")
cube("sword_guard", (0.65, -0.02, 0.30), (0.39, 0.15, 0.11), trim, "upper_arm.R")
cube("shield", (-0.65, -0.31, 1.00), (0.53, 0.16, 0.70), armor, "upper_arm.L")
sphere("shield_boss", (-0.65, -0.413, 1.02), (0.18, 0.075, 0.18), trim, "upper_arm.L")

bpy.ops.object.armature_add(enter_editmode=True, location=(0, 0, 0))
rig = bpy.context.object
rig.name = "WarriorRig"
eb = rig.data.edit_bones
eb.remove(eb[0])


def bone(name, head, tail, parent=None):
    b = eb.new(name)
    b.head, b.tail = head, tail
    if parent:
        b.parent = eb[parent]
    return b


bone("root", (0, 0, 0), (0, 0, 0.2))
bone("spine", (0, 0, 0.95), (0, 0, 1.80), "root")
bone("head", (0, 0, 1.80), (0, 0, 2.45), "spine")
for side, label in [(-1, "L"), (1, "R")]:
    bone("upper_arm." + label, (side * 0.48, 0, 1.62), (side * 0.67, 0, 0.83), "spine")
    bone("leg." + label, (side * 0.22, 0, 0.96), (side * 0.22, 0, 0.12), "root")
bpy.ops.object.mode_set(mode="OBJECT")

for obj, bone_name in pieces:
    vg = obj.vertex_groups.new(name=bone_name)
    vg.add(list(range(len(obj.data.vertices))), 1.0, "REPLACE")
    modifier = obj.modifiers.new("Armature", "ARMATURE")
    modifier.object = rig
    obj.parent = rig


def clip(name, frames, rotations):
    action = bpy.data.actions.new(name)
    rig.animation_data_create()
    rig.animation_data.action = action
    for frame in frames:
        for bone_name, axis, degrees in rotations(frame):
            pb = rig.pose.bones[bone_name]
            pb.rotation_mode = "XYZ"
            pb.rotation_euler[axis] = math.radians(degrees)
            pb.keyframe_insert(data_path="rotation_euler", frame=frame, group=bone_name)
    # Blender 5 stores F-curves in a slot channelbag (legacy Action.fcurves was removed).
    from bpy_extras import anim_utils
    slot = rig.animation_data.action_slot
    if slot is None:
        raise RuntimeError('Animation action has no rig slot: ' + name)
    channelbag = anim_utils.action_ensure_channelbag_for_slot(action, slot)
    for fc in channelbag.fcurves:
        for kp in fc.keyframe_points:
            kp.interpolation = "BEZIER"
            kp.handle_left_type = "AUTO_CLAMPED"
            kp.handle_right_type = "AUTO_CLAMPED"
    track = rig.animation_data.nla_tracks.new()
    track.name = name
    strip = track.strips.new(name, int(frames[0]), action)
    strip.action_frame_start, strip.action_frame_end = frames[0], frames[-1]
    rig.animation_data.action = None


clip("idle", [1, 13, 25], lambda f: [("spine", 0, 2 if f == 13 else 0)])
clip("walk", [1, 7, 13, 19, 25], lambda f: [
    ("leg.L", 0, 23 * math.sin((f - 1) * math.pi / 12)),
    ("leg.R", 0, -23 * math.sin((f - 1) * math.pi / 12)),
    ("upper_arm.L", 0, -14 * math.sin((f - 1) * math.pi / 12)),
    ("upper_arm.R", 0, 14 * math.sin((f - 1) * math.pi / 12)),
])
clip("attack", [1, 9, 17, 25], lambda f: [("upper_arm.R", 0, -70 if f == 9 else (45 if f == 17 else 0))])
clip("cast", [1, 12, 25], lambda f: [("upper_arm.L", 0, -65 if f == 12 else 0)])
clip("hit", [1, 6, 15], lambda f: [("spine", 0, -18 if f == 6 else 0)])
clip("dodge", [1, 7, 15], lambda f: [("spine", 1, 24 if f == 7 else 0)])

output = Path(sys.argv[sys.argv.index("--") + 1]) if "--" in sys.argv else Path("/tmp/titan_warrior.glb")
output.parent.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action="SELECT")
bpy.ops.export_scene.gltf(filepath=str(output), export_format="GLB", export_animations=True, export_nla_strips=True)
print("Exported prototype warrior:", output)
