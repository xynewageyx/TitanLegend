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

def leaf_mesh(name, center, length, width, mat, bend=0.0):
    """Hand-built pointed, curved leaf silhouette with a raised central vein."""
    cx, cy, cz = center
    vertices = [
        (cx,cy,cz),
        (cx-width*.72,cy-.035,cz+length*.35),
        (cx,cy-.10-bend*.25,cz+length*.48),
        (cx+width*.72,cy-.035,cz+length*.35),
        (cx-width*.46,cy+.02,cz+length*.70),
        (cx,cy-.09-bend*.55,cz+length*.79),
        (cx+width*.46,cy+.02,cz+length*.70),
        (cx+bend,cy-.04,cz+length),
    ]
    faces = [(0,1,2),(0,2,3),(1,4,5,2),(2,5,6,3),(4,7,5),(5,7,6)]
    mesh=bpy.data.meshes.new(name+"_mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    obj=bpy.data.objects.new(name,mesh)
    bpy.context.collection.objects.link(obj)
    mesh.materials.append(mat)
    for face in mesh.polygons:
        face.use_smooth=True
    return obj

def leaf_fox():
    fur=material("fox_fur",(.73,.44,.18));leaf=material("fox_leaf",(.23,.67,.28))
    cream=material("fox_cream",(.97,.86,.62));dark=material("fox_dark",(.09,.10,.08))
    sphere("fox_body",(0,.20,.81),(.52,.81,.44),fur)
    sphere("fox_head",(0,-.48,1.13),(.55,.48,.51),fur)
    for x in (-.38,.38):
        leaf_mesh("sculpted_leaf_ear", (x,-.42,1.42), .72, .31, leaf, bend=x*.35)
        for y in (-.38,.61):
            sphere("fox_paw",(x,y,.30),(.17,.22,.33),fur)
    sphere("tail_base",(0,1.07,1.08),(.26,.48,.20),fur)
    leaf_mesh("tail_leaf_blade", (0,1.10,.95), .91, .48, leaf, bend=.25)
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


def bark_guardian():
    bark=material("guardian_bark",(.39,.25,.14));moss=material("guardian_moss",(.20,.53,.22))
    gold=material("guardian_eyes",(.98,.75,.21));dark=material("guardian_pupil",(.08,.08,.05))
    sphere("massive_torso",(0,0,1.60),(.94,.62,1.05),bark)
    sphere("shoulder_canopy",(0,0,2.48),(1.10,.73,.35),moss)
    sphere("head",(0,-.20,2.43),(.56,.50,.55),bark)
    for x in (-1.08,1.08):
        sphere("heavy_arm",(x,0,1.64),(.35,.40,.75),bark)
        sphere("fist",(x,-.10,.98),(.43,.44,.39),bark)
    for x in (-.48,.48):
        sphere("root_leg",(x,.12,.54),(.35,.42,.62),bark)
        sphere("eye",(x*.51,-.68,2.50),(.16,.075,.18),gold)
    sphere("nose",(0,-.70,2.24),(.19,.15,.18),dark)

def moss_beast():
    fur=material("beast_moss",(.24,.48,.25));bark=material("beast_bark",(.36,.24,.15))
    eye=material("beast_eye",(.95,.82,.32))
    sphere("hulking_body",(0,.25,1.20),(1.03,1.28,.80),fur)
    sphere("broad_head",(0,-.80,1.37),(.80,.66,.67),bark)
    sphere("muzzle",(0,-1.35,1.08),(.53,.29,.33),fur)
    for x in (-.77,.77):
        for y in (-.50,.95):
            sphere("thick_leg",(x,y,.55),(.33,.38,.62),bark)
        sphere("glowing_eye",(x*.56,-1.35,1.55),(.15,.07,.18),eye)
    for x in (-.55,0,.55):
        cone("moss_spike",(x,.18,2.03),.28,0,.63,fur)

def root_king():
    bark=material("king_bark",(.34,.22,.13));wood=material("king_wood",(.49,.32,.17))
    leaf=material("king_leaves",(.17,.55,.24));eye=material("king_eyes",(.96,.82,.29))
    sphere("ancient_trunk",(0,0,2.50),(1.18,.87,1.75),bark)
    sphere("face_plate",(0,-.72,3.02),(.79,.30,.84),wood)
    for x in (-1.48,1.48):
        sphere("root_arm",(x,0,2.22),(.48,.55,1.15),bark)
        sphere("giant_fist",(x,-.18,1.27),(.60,.61,.50),wood)
        sphere("root_leg",(x*.49,.12,.73),(.52,.61,.90),bark)
        sphere("eye",(x*.29,-1.04,3.22),(.19,.09,.21),eye)
    sphere("crown",(0,0,4.26),(1.65,1.20,.75),leaf)
    for x,y,z in ((-1.10,-.20,4.68),(.95,-.08,4.80),(0,.68,4.75)):
        sphere("leaf_cluster",(x,y,z),(.75,.66,.56),leaf)
    sphere("mouth",(0,-1.05,2.66),(.35,.11,.11),bark)
    king_bark_details()

def forest_surface_details(creature):
    """Add distinct lightweight sculptural accents without external asset licenses."""
    leaf = material("detail_leaf", (.19, .48, .17))
    bark = material("detail_bark", (.30, .18, .09))
    cream = material("detail_cream", (.94, .84, .59))
    if creature == "forest_01_mooshuepfer":
        for i in range(11):
            a = 2*math.pi*i/11
            sphere("moss_curl", (.56*math.cos(a), .43*math.sin(a), 1.38+.14*math.sin(i*2)),
                   (.16,.13,.12), leaf, 12, 8)
    elif creature == "forest_02_pilzling":
        for i in range(12):
            a = 2*math.pi*i/12
            sphere("cap_rim_scallop", (.83*math.cos(a), .63*math.sin(a), 1.56),
                   (.20,.15,.095), cream, 12, 8)
    elif creature == "forest_03_wurzelkrabbler":
        for side in (-1,1):
            for j in range(2):
                branching_root("crawler_root_horn", [(side*.30,0,1.14),
                    (side*(.45+j*.16),.02,1.42),
                    (side*(.60+j*.20),.08,1.68)], .13, bark)
    elif creature == "forest_04_blattfuchs":
        for side in (-1,1):
            for j in range(3):
                sphere("cheek_fur_tuft", (side*(.40+j*.075),-.73+j*.07,1.03+j*.07),
                       (.18,.12,.09), cream, 12, 8)
    elif creature == "forest_05_dorneneber":
        for side in (-1,1):
            for j in range(3):
                branching_root("boar_curved_tusk", [(side*.31,-1.08,.72),
                    (side*(.41+j*.05),-1.18,.85),
                    (side*(.48+j*.05),-1.16,1.05)], .11, cream)
    elif creature == "forest_06_rankenwerfer":
        for side in (-1,1):
            branching_root("thrower_vine", [(side*.35,0,.93),
                (side*.68,-.06,1.11),
                (side*.84,-.16,1.45),
                (side*.70,-.20,1.65)], .11, leaf)
    elif creature == "forest_elite_01_rindenwaechter":
        for side in (-1,1):
            for j in range(3):
                branching_root("guardian_shoulder_branch", [(side*.65,.0,2.20),
                    (side*(.93+j*.12),.05,2.48),
                    (side*(1.02+j*.18),.08,2.80)], .16, bark)
    elif creature == "forest_elite_02_moosbestie":
        for side in (-1,1):
            for j in range(4):
                sphere("beast_moss_shag", (side*(.45+j*.12),-.35+j*.22,1.85),
                       (.19,.21,.25), leaf, 12, 8)

def expressive_details():
    """Distinct facial highlights and small sculptural accents for every creature."""
    iris = material("iris_highlight", (.96, .99, .92))
    for obj in list(bpy.context.scene.objects):
        if obj.type != "MESH" or not (obj.name.startswith("pupil") or obj.name.startswith("glowing_eye")):
            continue
        center = obj.location.copy()
        # Small eye glints stay parented with the creature's animation root.
        sphere("eye_glint", (center.x - .035, center.y - .055, center.z + .055),
               (.035, .018, .041), iris, 12, 8)

def sculpted_face_features(creature):
    """Add dimensional brows and cheek forms to improve expression in game camera."""
    dark = material("expression_shadow", (.16, .19, .10))
    blush = material("expression_warm", (.72, .42, .25))
    if creature == "forest_01_mooshuepfer":
        for side in (-1, 1):
            brow = sphere("arched_brow", (side*.31, -.555, 1.44), (.22,.085,.075), dark, 16, 10)
            brow.rotation_euler[1] = -side*.22
            sphere("soft_cheek", (side*.49,-.49,.98),(.20,.12,.15),blush,16,10)
    elif creature == "forest_02_pilzling":
        for side in (-1, 1):
            sphere("round_cheek", (side*.35,-.405,.83),(.15,.075,.11),blush,16,10)
            brow = sphere("mushroom_brow", (side*.22,-.465,1.30),(.17,.06,.055),dark,16,10)
            brow.rotation_euler[1] = side*.12
    elif creature == "forest_boss_01_wurzelkoenig":
        for side in (-1, 1):
            brow = sphere("king_heavy_brow", (side*.43,-1.02,3.49),(.40,.16,.13),dark,16,10)
            brow.rotation_euler[1] = side*.22
            sphere("king_cheek_plate", (side*.61,-.92,2.88),(.24,.17,.32),dark,16,10)

def sculpt_organic_silhouettes():
    """Non-destructive-to-rig vertex sculpting: asymmetry without new dependencies."""
    body_terms = ("body", "torso", "trunk", "head", "cap", "muzzle", "snout",
                  "canopy", "tail", "shoulder", "fist", "leg")
    excluded = ("eye", "pupil", "mouth", "spot", "glint")
    for obj in bpy.context.scene.objects:
        if obj.type != "MESH" or not any(t in obj.name.lower() for t in body_terms):
            continue
        if any(t in obj.name.lower() for t in excluded):
            continue
        if len(obj.data.vertices) < 24:
            continue
        # Vertex offsets are local to each mesh and therefore export cleanly to GLB.
        for vertex in obj.data.vertices:
            x, y, z = vertex.co
            ripple = (math.sin(3.1*x + 2.3*z) * math.cos(2.7*y - 1.4*z)
                      + .45*math.sin(5.2*y + 1.8*x))
            strength = .035 if "head" in obj.name.lower() else .065
            vertex.co *= 1.0 + strength * ripple
        obj.data.update()

def organic_finish():
    """Export-safe organic shading and bevels, no runtime add-on dependency."""
    for obj in list(bpy.context.scene.objects):
        if obj.type != "MESH":
            continue
        if obj.name.startswith(("eye", "pupil", "mouth", "smile")):
            continue
        for polygon in obj.data.polygons:
            polygon.use_smooth = True
        if obj.type == "MESH" and len(obj.data.vertices) > 6:
            bevel = obj.modifiers.new("soft_sculpted_edges", "BEVEL")
            bevel.width = 0.045
            bevel.segments = 2
            try:
                bpy.context.view_layer.objects.active = obj
                bpy.ops.object.modifier_apply(modifier=bevel.name)
            except (RuntimeError, AttributeError):
                obj.modifiers.remove(bevel)

def branching_root(name, points, radius, mat, sides=9):
    """Continuous tapered branch mesh; substantially more organic than stacked cones."""
    vertices, faces = [], []
    for i, point in enumerate(points):
        center = Vector(point)
        direction = Vector(points[min(i + 1, len(points)-1)]) - Vector(points[max(i-1, 0)])
        if direction.length < 1e-5:
            direction = Vector((0, 0, 1))
        direction.normalize()
        axis = direction.cross(Vector((0, 1, 0)))
        if axis.length < 1e-5:
            axis = direction.cross(Vector((1, 0, 0)))
        axis.normalize()
        other = direction.cross(axis).normalized()
        taper = max(.10, 1.0 - .84 * i / (len(points) - 1))
        for j in range(sides):
            a = 2 * math.pi * j / sides
            offset = radius * taper * (axis * math.cos(a) + other * math.sin(a))
            vertices.append(tuple(center + offset))
        if i:
            for j in range(sides):
                a = (i-1)*sides+j
                b = (i-1)*sides+(j+1)%sides
                c = i*sides+(j+1)%sides
                d = i*sides+j
                faces.append((a,b,c,d))
    faces.extend([tuple(reversed(range(sides))), tuple((len(points)-1)*sides+j for j in range(sides))])
    mesh = bpy.data.meshes.new(name + "_mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(mat)
    return obj

def king_bark_details():
    """Sculptural raised bark ridges and root-like branching, not a flat trunk."""
    bark = material("king_bark_ridges", (.22, .13, .075))
    highlight = material("king_bark_edges", (.57, .37, .19))
    for i in range(14):
        angle = 2 * math.pi * i / 14
        x = math.cos(angle) * 1.08
        y = math.sin(angle) * .82
        z = 1.35 + (i % 5) * .49
        ridge = sphere("raised_bark_ridge", (x, y, z), (.10, .11, .43), bark, 12, 8)
        ridge.rotation_euler[1] = .18 * math.sin(angle * 3)
    for side in (-1, 1):
        for i in range(3):
            x = side * (1.0 + i * .32)
            z = 3.8 + i * .29
            branching_root("forked_branch", [(side*.78,.12,3.42),
                (side*(1.08+i*.12),.10,3.88),
                (side*(1.36+i*.22),.08,4.30+i*.10),
                (side*(1.51+i*.27),.03,4.72+i*.16)], .22, highlight)
        for i in range(4):
            x = side * (.35 + i * .31)
            branching_root("curved_ground_root", [(side*.43,-.05,1.02),
                (side*(.48+i*.12),-.20,.60),
                (x,-.34,.20),
                (side*(.56+i*.39),-.47,.08)], .20, bark)

def animate_creature():
    """Export four distinct clips with body motion and articulated secondary parts.

    Actions live on NLA tracks so Blender's glTF exporter keeps each named clip.
    The animation stays lightweight enough for the Android GL Compatibility renderer.
    """
    root = bpy.data.objects.new("CreatureRoot", None)
    bpy.context.collection.objects.link(root)
    meshes = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    for obj in meshes:
        obj.parent = root
        obj.matrix_parent_inverse = root.matrix_world.inverted()

    clips = {
        "idle": [(1,0,0,0,1),(9,0,.035,.035,1.035),(17,0,0,-.025,1.075),(25,0,-.025,0,1)],
        "attack": [(1,0,0,0,1),(5,0,.20,-.12,.92),(9,0,-.36,.15,1.12),(14,0,-.17,-.07,1.03),(22,0,0,0,1)],
        "hit": [(1,0,0,0,1),(4,0,.22,-.18,.91),(8,0,-.09,.10,1.04),(14,0,0,0,1)],
        "death": [(1,0,0,0,1),(7,0,.11,.20,.88),(15,0,.34,.90,.43),(24,0,.38,1.20,.12)],
    }
    for clip, frames in clips.items():
        root.animation_data_create()
        action = bpy.data.actions.new(name=clip)
        root.animation_data.action = action
        for frame, x, y, tilt, stretch in frames:
            root.location = (x,y,0)
            root.rotation_euler = (tilt, 0, 0)
            root.scale = (1.0 / math.sqrt(stretch), 1.0 / math.sqrt(stretch), stretch)
            root.keyframe_insert(data_path="location", frame=frame)
            root.keyframe_insert(data_path="rotation_euler", frame=frame)
            root.keyframe_insert(data_path="scale", frame=frame)
        track = root.animation_data.nla_tracks.new()
        track.name = clip
        strip = track.strips.new(clip, 1, action)
        strip.action_frame_start = 1
        strip.action_frame_end = frames[-1][0]
        root.animation_data.action = None

    # Mesh-local animation makes paws, fists, ears, leaves and tails move
    # independently rather than merely scaling the entire creature.
    moving_tokens = ("arm", "fist", "paw", "leg", "foot", "ear", "tail",
                     "leaf", "vine", "tendril", "antenna", "horn", "crown")
    candidates = [o for o in meshes if any(t in o.name.lower() for t in moving_tokens)]
    for idx, obj in enumerate(candidates[:36]):
        baseline = obj.rotation_euler.copy()
        phase = -1 if idx % 2 else 1
        intensity = .08 if ("leg" in obj.name.lower() or "foot" in obj.name.lower()) else .16
        for clip, keyframes in (
            ("idle", [(1,0),(9,1),(17,-1),(25,0)]),
            ("attack", [(1,0),(5,-1),(9,1.7),(14,-.4),(22,0)]),
            ("hit", [(1,0),(4,-1.5),(8,.65),(14,0)]),
            ("death", [(1,0),(7,-.4),(15,1.4),(24,1.8)]),
        ):
            obj.animation_data_create()
            action = bpy.data.actions.new(name=clip + "_" + obj.name)
            obj.animation_data.action = action
            for frame, amount in keyframes:
                obj.rotation_euler = baseline.copy()
                obj.rotation_euler[0] += phase * amount * intensity
                obj.rotation_euler[1] += amount * intensity * .35
                obj.keyframe_insert(data_path="rotation_euler", frame=frame)
            track = obj.animation_data.nla_tracks.new()
            track.name = clip
            strip = track.strips.new(clip, 1, action)
            strip.action_frame_start = 1
            strip.action_frame_end = keyframes[-1][0]
            obj.animation_data.action = None
        obj.rotation_euler = baseline
    root.location = (0,0,0)
    root.rotation_euler = (0,0,0)
    root.scale = (1,1,1)
    return root

def storybook_creature_finish(creature):
    """Original expressive chibi finish: large readable eyes, layered color and clear silhouettes."""
    palettes = {
        "forest_01_mooshuepfer": (1.14, -.54, .30, (.48,.82,.35)),
        "forest_02_pilzling": (.99, -.46, .23, (.98,.66,.34)),
        "forest_03_wurzelkrabbler": (.94, -.54, .30, (.67,.84,.39)),
        "forest_04_blattfuchs": (1.23, -.89, .23, (.97,.75,.40)),
        "forest_05_dorneneber": (1.18, -1.07, .31, (.88,.57,.40)),
        "forest_06_rankenwerfer": (1.51, -.58, .25, (.89,.62,.78)),
        "forest_elite_01_rindenwaechter": (2.50, -.67, .31, (.71,.89,.48)),
        "forest_elite_02_moosbestie": (1.55, -1.32, .39, (.84,.94,.45)),
        "forest_boss_01_wurzelkoenig": (3.22, -1.08, .43, (.96,.83,.43)),
    }
    z, front, spread, tint = palettes[creature]
    scl = 1.35 if "boss" in creature else (1.15 if "elite" in creature else 1.0)
    ivory = material("storybook_eye_ivory", (.99,.96,.87))
    iris = material("storybook_iris", (.15,.26,.20))
    pupil = material("storybook_pupil", (.035,.055,.065))
    shine = material("storybook_eye_shine", (1.0,1.0,.96))
    cheek = material("storybook_cheek", tint)
    # A forward-facing eye layer makes expression legible from the portrait game camera.
    for side in (-1, 1):
        x = side * spread
        sphere("storybook_eye_sclera", (x,front-.025,z), (.155*scl,.095*scl,.20*scl), ivory,24,16)
        sphere("storybook_iris", (x-side*.018,front-.111*scl,z-.012*scl),
               (.103*scl,.045*scl,.145*scl),iris,20,14)
        sphere("storybook_pupil", (x-side*.018,front-.145*scl,z-.013*scl),
               (.067*scl,.027*scl,.108*scl),pupil,20,14)
        sphere("storybook_catchlight", (x-side*.052,front-.173*scl,z+.055*scl),
               (.034*scl,.018*scl,.045*scl),shine,12,8)
        sphere("storybook_cheek_patch", (side*(spread+.20*scl),front+.025,z-.23*scl),
               (.15*scl,.048*scl,.09*scl),cheek,16,10)
    # Distinct small leaf badges give each creature a cohesive forest-fantasy identity.
    if "boss" not in creature:
        leaf = material("storybook_leaf_badge", (.28,.72,.43))
        for side in (-1,1):
            badge = sphere("storybook_leaf_badge", (side*(spread+.33*scl),front+.12,z+.30*scl),
                           (.09*scl,.045*scl,.18*scl),leaf,14,10)
            badge.rotation_euler[1] = side*.48

def creature_silhouette_upgrade(creature):
    """Species-specific, readable shapes instead of interchangeable sphere creatures."""
    cream = material("silhouette_cream", (.98,.88,.67))
    leaf = material("silhouette_leaf", (.27,.67,.34))
    dark = material("silhouette_wood", (.37,.24,.16))
    coral = material("silhouette_coral", (.96,.54,.35))
    if creature == "forest_01_mooshuepfer":
        for side in (-1,1):
            sphere("springy_ear", (side*.63,-.04,1.50), (.20,.18,.40),leaf,20,14).rotation_euler[1] = side*.45
            sphere("padded_toe", (side*.42,-.37,.19),(.22,.23,.14),cream,16,10)
    elif creature == "forest_02_pilzling":
        for side in (-1,1):
            sphere("cap_hanging_frill", (side*.77,-.28,1.48),(.27,.26,.17),coral,20,14)
            sphere("tiny_hand", (side*.51,-.31,.85),(.16,.17,.21),cream,16,10)
    elif creature == "forest_03_wurzelkrabbler":
        for side in (-1,1):
            branching_root("swept_antler",[(side*.34,.04,1.30),(side*.53,.03,1.56),
                (side*.74,.07,1.70),(side*.88,.08,1.66)],.12,dark)
            sphere("root_knuckle", (side*.72,-.29,.38),(.21,.22,.17),dark,16,10)
    elif creature == "forest_04_blattfuchs":
        for side in (-1,1):
            sphere("fluffy_cheek", (side*.48,-.71,1.03),(.24,.19,.20),cream,20,14)
            leaf_mesh("swept_ear_tip",(side*.37,-.41,1.58),.52,.25,leaf,bend=side*.18)
        sphere("tail_pom", (0,1.42,1.17),(.36,.32,.34),cream,20,14)
    elif creature == "forest_05_dorneneber":
        for side in (-1,1):
            sphere("drooping_ear",(side*.63,-.61,1.36),(.30,.14,.24),coral,20,14).rotation_euler[1]=side*.38
            sphere("split_hoof",(side*.54,-.60,.17),(.24,.29,.15),dark,16,10)
    elif creature == "forest_06_rankenwerfer":
        for side in (-1,1):
            leaf_mesh("wide_petal",(side*.41,-.13,1.44),.75,.37,coral,bend=side*.2)
            branching_root("curling_tendril",[(side*.48,-.08,.96),(side*.72,-.19,1.02),
                (side*.89,-.23,1.23),(side*.79,-.27,1.39)],.09,leaf)
    elif creature == "forest_elite_01_rindenwaechter":
        for side in (-1,1):
            sphere("armored_shoulder",(side*1.01,-.04,2.03),(.49,.47,.43),dark,20,14)
            leaf_mesh("shoulder_leaf",(side*.96,-.27,2.27),.73,.37,leaf,bend=side*.17)
    elif creature == "forest_elite_02_moosbestie":
        for side in (-1,1):
            sphere("heavy_brow",(side*.43,-1.30,1.78),(.33,.17,.16),dark,20,14)
            sphere("massive_paw",(side*.83,-.76,.24),(.36,.42,.25),cream,20,14)
    elif creature == "forest_boss_01_wurzelkoenig":
        for side in (-1,1):
            leaf_mesh("crown_side_leaf",(side*.91,-.12,4.24),1.22,.56,leaf,bend=side*.27)
            sphere("royal_bark_brow",(side*.42,-1.07,3.48),(.40,.18,.18),dark,20,14)
        sphere("heartwood_core",(0,-.88,2.14),(.37,.15,.48),coral,24,16)

def export(name,fn,out):
    clear();fn();forest_surface_details(name);sculpted_face_features(name);expressive_details();storybook_creature_finish(name);creature_silhouette_upgrade(name);sculpt_organic_silhouettes();organic_finish();animate_creature()
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
    export("forest_elite_01_rindenwaechter",bark_guardian,out)
    export("forest_elite_02_moosbestie",moss_beast,out)
    export("forest_boss_01_wurzelkoenig",root_king,out)

if __name__=="__main__":main()
