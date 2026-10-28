"""Blender 4.x: generate an original armored Titan Legends warrior GLB.
Run: blender -b --python tools/generate_warrior_glb.py
The asset is a static visual prototype; rigging/animations are a later step.
"""
import bpy
from math import radians
from pathlib import Path

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)

def material(name, rgb, metallic=0.0, roughness=0.48):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*rgb, 1)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*rgb, 1)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    return mat

steel = material("Midnight forged steel", (.09, .16, .25), .78)
edge = material("Silver armor edges", (.52, .67, .72), .85)
gold = material("Brass accents", (.72, .42, .13), .7)
leather = material("Worn brown leather", (.19, .095, .055))
cloth = material("Royal crimson cloth", (.35, .035, .075))
dark = material("Boot and glove leather", (.045, .05, .065))
glow = material("Arcane cyan gem", (.06, .75, .95), .25)

def cube(name, pos, scale, mat, bevel=0.045, rot=None):
    bpy.ops.mesh.primitive_cube_add(size=1, location=pos)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if rot:
        obj.rotation_euler = tuple(radians(v) for v in rot)
    obj.data.materials.append(mat)
    if bevel:
        mod = obj.modifiers.new("Forged bevel", "BEVEL")
        mod.width = bevel
        mod.segments = 2
        obj.modifiers.new("Weighted normals", "WEIGHTED_NORMAL")
    return obj

def sphere(name, pos, scale, mat, segments=16, rings=8):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=rings, location=pos)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    obj.data.materials.append(mat)
    bpy.ops.object.shade_smooth()
    return obj

# Forward is -Y; total height approximately 2.65 m.
cube("Breastplate", (0, 0, 1.62), (.85, .46, .85), steel, .12)
cube("Breastplate center ridge", (0, -.255, 1.69), (.13, .09, .72), edge)
cube("Chest heraldry", (0, -.312, 1.83), (.24, .07, .30), gold)
cube("Undershirt", (0, .01, 1.17), (.66, .38, .35), cloth)
cube("Armored belt", (0, -.03, 1.12), (.84, .49, .16), leather)
cube("Belt buckle", (0, -.305, 1.12), (.22, .08, .19), gold)
cube("Front tabard", (0, -.27, .79), (.43, .12, .67), cloth, .025)
cube("Tabard gold stripe", (0, -.342, .76), (.06, .02, .56), gold, .008)

for side, sign in (("L", -1), ("R", 1)):
    x = sign * .61
    sphere(side + " Pauldron", (x, 0, 1.91), (.38, .34, .25), steel)
    cube(side + " Shoulder rim", (x, -.20, 1.89), (.65, .11, .13), gold)
    cube(side + " Upper arm", (sign*.67, 0, 1.58), (.26, .30, .48), leather)
    cube(side + " Forearm plate", (sign*.70, -.04, 1.29), (.31, .35, .43), steel)
    cube(side + " Gauntlet", (sign*.71, -.05, 1.03), (.28, .30, .25), dark)
    cube(side + " Thigh", (sign*.24, 0, .83), (.36, .38, .60), steel)
    cube(side + " Knee cap", (sign*.24, -.21, .52), (.38, .17, .20), gold)
    cube(side + " Greave", (sign*.24, 0, .30), (.32, .37, .48), steel)
    cube(side + " Boot", (sign*.24, -.10, .10), (.38, .60, .21), dark)

sphere("Helmet crown", (0, 0, 2.26), (.34, .32, .39), steel)
cube("Helmet faceplate", (0, -.29, 2.24), (.48, .13, .43), steel)
cube("Helmet brow", (0, -.37, 2.46), (.65, .15, .12), gold)
cube("Helmet central crest", (0, -.04, 2.66), (.12, .27, .30), gold)
cube("Helmet eye slit", (0, -.365, 2.27), (.41, .03, .065), glow, .008)
cube("Helmet nose guard", (0, -.395, 2.17), (.09, .10, .27), edge)

# Distinct broad sword and left arm shield, geometry only.
cube("Sword grip", (.72, -.12, .80), (.09, .11, .40), leather)
cube("Sword pommel", (.72, -.12, .57), (.17, .17, .15), gold)
cube("Sword guard", (.72, -.12, 1.04), (.48, .16, .11), gold)
cube("Sword blade", (.72, -.12, 1.48), (.19, .075, .83), edge, .025)
cube("Sword fuller", (.72, -.165, 1.50), (.045, .014, .61), steel, .005)
cube("Shield face", (-.82, -.32, 1.28), (.68, .16, .89), steel, .11)
cube("Shield boss", (-.82, -.44, 1.29), (.25, .10, .30), gold)
cube("Shield center stripe", (-.82, -.42, 1.29), (.085, .04, .69), gold)

# Apply modifiers to make the exported GLB independent of Blender.
bpy.ops.object.select_all(action="SELECT")
for obj in list(bpy.context.selected_objects):
    if obj.type == "MESH":
        bpy.context.view_layer.objects.active = obj
        for mod in list(obj.modifiers):
            try:
                bpy.ops.object.modifier_apply(modifier=mod.name)
            except RuntimeError:
                pass
# Prototype object-level clips (not yet a skinned Skeleton3D).
# Parent meshes under one pivot, preserving their world-space positions.
bpy.ops.object.empty_add(type="PLAIN_AXES", location=(0, 0, 0))
pivot = bpy.context.object
pivot.name = "WarriorMotionRoot"
for obj in list(bpy.data.objects):
    if obj.type == "MESH":
        obj.parent = pivot
        obj.matrix_parent_inverse.identity()

# Articulated prototype: each limb has its own transform pivot. This is
# rigid-part animation (not a deforming skinned armature yet).
limb_groups = {
    "LeftArm": ([-.61, 0, 1.85], ("L Pauldron", "L Shoulder rim", "L Upper arm", "L Forearm plate", "L Gauntlet", "Shield")),
    "RightArm": ([.61, 0, 1.85], ("R Pauldron", "R Shoulder rim", "R Upper arm", "R Forearm plate", "R Gauntlet", "Sword")),
    "LeftLeg": ([-.24, 0, 1.04], ("L Thigh", "L Knee cap", "L Greave", "L Boot")),
    "RightLeg": ([.24, 0, 1.04], ("R Thigh", "R Knee cap", "R Greave", "R Boot")),
}
limbs = {}
for group, (location, prefixes) in limb_groups.items():
    bpy.ops.object.empty_add(type="PLAIN_AXES", location=location)
    joint = bpy.context.object
    joint.name = group + "Pivot"
    joint.parent = pivot
    joint.matrix_parent_inverse.identity()
    for obj in list(bpy.data.objects):
        if obj.type == "MESH" and obj.name.startswith(prefixes):
            world = obj.matrix_world.copy()
            obj.parent = joint
            obj.matrix_world = world
    limbs[group] = joint

# Secondary elbow and knee joints add articulation beyond rigid limb swing.
# They pivot forearm/shin meshes while preserving their current world transforms.
secondary_specs = {
    "LeftElbow": ([-.70, 0, 1.45], ("L Forearm plate", "L Gauntlet", "Shield")),
    "RightElbow": ([.70, 0, 1.45], ("R Forearm plate", "R Gauntlet", "Sword")),
    "LeftKnee": ([-.24, 0, .58], ("L Greave", "L Boot")),
    "RightKnee": ([.24, 0, .58], ("R Greave", "R Boot")),
}
secondary = {}
for joint_name, (position, prefixes) in secondary_specs.items():
    bpy.ops.object.empty_add(type="PLAIN_AXES", location=position)
    joint = bpy.context.object
    joint.name = joint_name + "Pivot"
    primary = limbs["LeftArm" if joint_name == "LeftElbow" else
                    "RightArm" if joint_name == "RightElbow" else
                    "LeftLeg" if joint_name == "LeftKnee" else "RightLeg"]
    joint.parent = primary
    joint.matrix_parent_inverse = primary.matrix_world.inverted()
    for obj in list(bpy.data.objects):
        if obj.type == "MESH" and obj.name.startswith(prefixes):
            world = obj.matrix_world.copy()
            obj.parent = joint
            obj.matrix_world = world
    secondary[joint_name] = joint

secondary_motion = {
    "Idle": [(1, 0, 0, 0, 0), (16, .035, .035, .015, .015), (31, 0, 0, 0, 0)],
    "Run": [(1, .12, .40, .06, .58), (4, .22, .28, .20, .32),
            (7, .40, .12, .58, .06), (10, .28, .22, .32, .20),
            (13, .12, .40, .06, .58), (16, .22, .28, .20, .32),
            (19, .40, .12, .58, .06), (22, .28, .22, .32, .20),
            (25, .12, .40, .06, .58)],
    "Attack": [(1, .08, .18, .05, .05), (4, .12, 1.18, .08, .08),
               (7, .16, 1.38, .12, .10), (10, .22, .12, .14, .12),
               (13, .26, .18, .10, .12), (19, .08, .18, .05, .05)],
    "Hit": [(1, 0, 0, 0, 0), (5, .35, .35, .16, .16), (13, 0, 0, 0, 0)],
    "Defeat": [(1, 0, 0, 0, 0), (20, .72, .72, .48, .48)],
}
for clip_name, frames in secondary_motion.items():
    for index, joint_name in enumerate(("LeftElbow", "RightElbow", "LeftKnee", "RightKnee")):
        joint = secondary[joint_name]
        joint.animation_data_create()
        action = bpy.data.actions.new(clip_name + "_" + joint_name)
        joint.animation_data.action = action
        for frame, *angles in frames:
            joint.rotation_euler.x = angles[index]
            joint.keyframe_insert(data_path="rotation_euler", frame=frame)
        track = joint.animation_data.nla_tracks.new()
        track.name = clip_name
        strip = track.strips.new(clip_name, int(frames[0][0]), action)
        strip.action_frame_end = frames[-1][0]
        joint.animation_data.action = None
        joint.rotation_euler.x = 0

# Arm/leg swing in radians, keyed independently for each clip.
limb_motion = {
    "Idle": [(1, 0, 0, 0, 0), (16, .025, -.025, .015, -.015), (31, 0, 0, 0, 0)],
    "Run": [(1, -.45, .45, .55, -.55), (7, .45, -.45, -.55, .55),
            (13, -.45, .45, .55, -.55), (19, .45, -.45, -.55, .55),
            (25, -.45, .45, .55, -.55)],
    "Attack": [(1, 0, 0, 0, 0), (6, -.15, -1.05, -.20, .20),
               (11, .20, .90, .15, -.15), (19, 0, 0, 0, 0)],
    "Hit": [(1, 0, 0, 0, 0), (5, -.28, -.28, -.12, -.12), (13, 0, 0, 0, 0)],
    "Defeat": [(1, 0, 0, 0, 0), (20, .55, .55, -.35, -.35)],
}
for clip_name, frames in limb_motion.items():
    for index, limb_name in enumerate(("LeftArm", "RightArm", "LeftLeg", "RightLeg")):
        joint = limbs[limb_name]
        joint.animation_data_create()
        action = bpy.data.actions.new(clip_name + "_" + limb_name)
        joint.animation_data.action = action
        for frame, *angles in frames:
            joint.rotation_euler.x = angles[index]
            joint.keyframe_insert(data_path="rotation_euler", frame=frame)
        track = joint.animation_data.nla_tracks.new()
        track.name = clip_name
        strip = track.strips.new(clip_name, int(frames[0][0]), action)
        strip.action_frame_end = frames[-1][0]
        joint.animation_data.action = None
        joint.rotation_euler.x = 0

# Separate NLA tracks export as distinct glTF animation clips.
# Each clip has its own Action, so Godot can play it by name.
clips = {
    "Idle": [(1, 0.0, 0.0), (16, 0.025, 0.018), (31, 0.0, 0.0)],
    "Run": [(1, 0.0, -0.06), (7, 0.09, 0.08), (13, 0.0, -0.06), (19, 0.09, 0.08), (25, 0.0, -0.06)],
    "Attack": [(1, 0.0, 0.0), (6, -0.10, 0.32), (11, 0.10, -0.42), (19, 0.0, 0.0)],
    "Hit": [(1, 0.0, 0.0), (5, -0.12, 0.20), (13, 0.0, 0.0)],
    "Defeat": [(1, 0.0, 0.0), (20, -0.65, 1.12)],
}
pivot.animation_data_create()
for name, keys in clips.items():
    action = bpy.data.actions.new(name)
    pivot.animation_data.action = action
    for frame, z, pitch in keys:
        pivot.location.z = z
        pivot.rotation_euler.x = pitch
        pivot.keyframe_insert(data_path="location", frame=frame, group="Movement")
        pivot.keyframe_insert(data_path="rotation_euler", frame=frame, group="Movement")
    track = pivot.animation_data.nla_tracks.new()
    track.name = name
    strip = track.strips.new(name, int(keys[0][0]), action)
    strip.action_frame_start = keys[0][0]
    strip.action_frame_end = keys[-1][0]
    pivot.animation_data.action = None
pivot.location.z = 0.0
pivot.rotation_euler.x = 0.0

output = Path("build/class_0.glb")
output.parent.mkdir(parents=True, exist_ok=True)
bpy.ops.export_scene.gltf(filepath=str(output), export_format="GLB", export_apply=True, export_animation_mode="NLA_TRACKS")
print("Exported", output, output.stat().st_size, "bytes")
