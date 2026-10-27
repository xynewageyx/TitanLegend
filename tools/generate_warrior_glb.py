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
output = Path("build/class_0.glb")
output.parent.mkdir(parents=True, exist_ok=True)
bpy.ops.export_scene.gltf(filepath=str(output), export_format="GLB", export_apply=True)
print("Exported", output, output.stat().st_size, "bytes")
