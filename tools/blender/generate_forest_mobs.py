"""Titan Legends forest creature procedural GLB generator.
Run: blender --background --python tools/blender/generate_forest_mobs.py -- --output assets/enemies/forest
"""
import bpy, math, os, sys, argparse
from mathutils import Vector

def material(name, rgba):
    m=bpy.data.materials.new(name); m.diffuse_color=(*rgba,1)
    m.use_nodes=True
    bs=m.node_tree.nodes.get("Principled BSDF")
    bs.inputs["Base Color"].default_value=(*rgba,1)
    bs.inputs["Roughness"].default_value=.83
    return m

def sphere(name, pos, scale, mat, segments=16, rings=10):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments,ring_count=rings,location=pos)
    o=bpy.context.object;o.name=name;o.scale=scale;o.data.materials.append(mat)
    return o

def cone(name,pos,r1,r2,depth,mat,verts=10):
    bpy.ops.mesh.primitive_cone_add(vertices=verts,radius1=r1,radius2=r2,depth=depth,location=pos)
    o=bpy.context.object;o.name=name;o.data.materials.append(mat);return o

def clear():
    bpy.ops.object.select_all(action="SELECT");bpy.ops.object.delete(use_global=False)

def eyes(z,offset,white,black):
    for x in (-offset,offset):
        sphere("eye_white",(x,-.48,z),(.20,.105,.23),white)
        sphere("pupil",(x,-.576,z),(.095,.05,.135),black)

def moss():
    green=material("moss_green",(.28,.66,.28));dark=material("leaf_dark",(.12,.42,.18))
    white=material("eye_white",(.96,.94,.82));black=material("pupil",(.055,.08,.07))
    sphere("round_body",(0,0,1.02),(.78,.60,.70),green)
    for x in (-.43,.43):
        sphere("foot",(x,-.06,.32),(.30,.35,.22),dark)
    for i in range(7):
        a=2*math.pi*i/7
        cone("moss_tuft",(math.cos(a)*.39,math.sin(a)*.32,1.70),.22,0,.45,dark)
    eyes(1.17,.31,white,black)
    sphere("smile",(0,-.598,.87),(.18,.035,.055),dark)

def mushroom():
    stem=material("cream_stem",(.89,.77,.56));cap=material("orange_cap",(.92,.34,.16))
    spot=material("cap_spot",(.99,.91,.73));white=material("eye_white",(.97,.96,.88))
    black=material("pupil",(.055,.06,.08))
    sphere("stem_body",(0,0,.91),(.49,.43,.68),stem)
    for x in (-.31,.31):
        sphere("foot",(x,-.02,.25),(.24,.31,.18),stem)
    sphere("mushroom_cap",(0,0,1.65),(1.03,.81,.37),cap)
    for x,y in ((-.47,-.42),(.39,-.43),(0,.12)):
        sphere("cap_spot",(x,y,1.94),(.16,.14,.045),spot)
    eyes(1.04,.22,white,black)
    sphere("mouth",(0,-.449,.73),(.12,.03,.055),black)


def root_crawler():
    bark=material("root_bark",(.36,.23,.13));leaf=material("root_leaves",(.22,.54,.20))
    white=material("root_eyes",(.96,.92,.75));dark=material("root_pupils",(.06,.08,.04))
    sphere("gnarled_body",(0,0,.88),(.82,.60,.48),bark)
    for x in (-.58,0,.58):
        for y in (-.37,.37):
            sphere("root_leg",(x,y,.32),(.19,.20,.37),bark)
    for x in (-.44,.44):
        cone("leaf_antenna",(x,0,1.45),.19,0,.52,leaf)
    eyes(.96,.31,white,dark)

def leaf_fox():
    fur=material("fox_fur",(.73,.44,.18));leaf=material("fox_leaf",(.23,.67,.28))
    cream=material("fox_cream",(.97,.86,.62));dark=material("fox_dark",(.09,.10,.08))
    sphere("fox_body",(0,.20,.81),(.52,.81,.44),fur)
    sphere("fox_head",(0,-.48,1.13),(.55,.48,.51),fur)
    for x in (-.38,.38):
        cone("pointed_ear",(x,-.42,1.69),.21,0,.54,leaf)
        for y in (-.38,.61):
            sphere("fox_paw",(x,y,.30),(.17,.22,.33),fur)
    sphere("leaf_tail",(0,1.07,1.08),(.34,.64,.24),leaf)
    sphere("snout",(0,-.90,.93),(.28,.16,.19),cream)
    for x in (-.23,.23):
        sphere("eye",(x,-.885,1.24),(.105,.06,.14),dark)
    sphere("nose",(0,-1.065,.96),(.12,.08,.08),dark)

def thorn_boar():
    brown=material("boar_brown",(.44,.28,.18));thorn=material("boar_thorn",(.22,.41,.18))
    ivory=material("boar_tusk",(.95,.88,.63));dark=material("boar_eye",(.07,.06,.05))
    sphere("barrel_body",(0,.14,.94),(.80,.94,.65),brown)
    sphere("big_head",(0,-.64,1.00),(.62,.55,.51),brown)
    sphere("snout",(0,-1.15,.82),(.39,.22,.27),brown)
    for x in (-.53,.53):
        for y in (-.40,.63):
            sphere("short_leg",(x,y,.31),(.25,.28,.32),brown)
        cone("tusk",(x*.78,-1.08,.74),.14,0,.38,ivory)
        sphere("eye",(x*.66,-1.055,1.18),(.10,.06,.12),dark)
    for x in (-.45,0,.45):
        for y in (-.35,.18,.65):
            cone("back_thorn",(x,y,1.59),.19,0,.47,thorn)

def vine_thrower():
    stalk=material("vine_stalk",(.23,.54,.22));bud=material("vine_bud",(.70,.32,.55))
    leaf=material("vine_leaf",(.39,.72,.25));dark=material("vine_eye",(.06,.08,.05))
    cone("stem",(0,0,.72),.26,.15,1.20,stalk)
    sphere("flower_head",(0,-.08,1.47),(.62,.53,.53),bud)
    for x in (-.50,.50):
        sphere("leaf_arm",(x,0,.84),(.52,.20,.18),leaf)
        sphere("eye",(x*.47,-.57,1.53),(.12,.07,.15),dark)
    for x in (-.35,.35):
        sphere("root_foot",(x,.03,.16),(.35,.31,.17),stalk)
    sphere("mouth",(0,-.58,1.25),(.25,.06,.10),dark)

def animate_creature():
    """Create simple object-level idle and attack clips for all mesh parts."""
    root=bpy.data.objects.new("CreatureRoot",None)
    bpy.context.collection.objects.link(root)
    meshes=[o for o in bpy.context.scene.objects if o.type=="MESH"]
    for obj in meshes:
        obj.parent=root
        obj.matrix_parent_inverse=root.matrix_world.inverted()
    # Distinct glTF actions are attached through NLA strips.
    for clip,frames in (
        ("idle",[(1,0.0,1.0),(13,0.0,1.07),(25,0.0,1.0)]),
        ("attack",[(1,0.0,1.0),(7,-0.22,0.92),(13,0.30,1.12),(22,0.0,1.0)]),
        ("hit",[(1,0.0,1.0),(5,-0.16,0.94),(12,0.0,1.0)]),
        ("death",[(1,0.0,1.0),(16,0.0,0.10)]),
    ):
        root.animation_data_clear()
        for frame,y,scale in frames:
            root.location=(0,y,0)
            root.scale=(1,1,scale)
            root.keyframe_insert(data_path="location",frame=frame)
            root.keyframe_insert(data_path="scale",frame=frame)
        action=root.animation_data.action
        action.name=clip
        track=root.animation_data.nla_tracks.new()
        track.name=clip
        strip=track.strips.new(clip,1,action)
        strip.action_frame_start=1
        strip.action_frame_end=frames[-1][0]
        root.animation_data.action=None
    return root

def export(name,fn,out):
    clear();fn();animate_creature()
    bpy.ops.object.select_all(action="SELECT")
    target=os.path.join(out,name+".glb")
    result=bpy.ops.export_scene.gltf(filepath=target,export_format="GLB",use_selection=True)
    if "FINISHED" not in result or not os.path.isfile(target) or os.path.getsize(target)<20:
        raise RuntimeError("GLB export failed: "+target)
    with open(target,"rb") as stream:
        if stream.read(4)!=b"glTF":
            raise RuntimeError("Invalid GLB magic: "+target)
    print("EXPORTED",name,os.path.getsize(target),"bytes")

def main():
    parser=argparse.ArgumentParser();parser.add_argument("--output",default="assets/enemies/forest")
    args=parser.parse_args(sys.argv[sys.argv.index("--")+1:] if "--" in sys.argv else [])
    out=os.path.abspath(args.output);os.makedirs(out,exist_ok=True)
    export("forest_01_mooshuepfer",moss,out)
    export("forest_02_pilzling",mushroom,out)
    export("forest_03_wurzelkrabbler",root_crawler,out)
    export("forest_04_blattfuchs",leaf_fox,out)
    export("forest_05_dorneneber",thorn_boar,out)
    export("forest_06_rankenwerfer",vine_thrower,out)

if __name__=="__main__":main()
