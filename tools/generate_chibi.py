"""Generate eleven original chibi base GLBs with Blender 4.x; no third-party assets."""
import bpy, math, os
OUT=os.path.abspath("assets/heroes/chibi")
os.makedirs(OUT,exist_ok=True)
NAMES="warrior paladin druid shaman hunter rogue mage warlock summoner priest brawler".split()
COLORS=[(.2,.12,.1),(.7,.5,.2),(.2,.4,.2),(.1,.3,.5),(.4,.25,.1),(.2,.15,.3),(.1,.2,.6),(.4,.2,.5),(.6,.4,.7),(.8,.7,.4),(.5,.2,.1)]
def material(name,color):
 m=bpy.data.materials.new(name);m.diffuse_color=(*color,1)
 m.use_nodes=True
 bsdf=m.node_tree.nodes.get('Principled BSDF')
 if bsdf:
  bsdf.inputs['Base Color'].default_value=(*color,1)
  bsdf.inputs['Metallic'].default_value=0.0
  bsdf.inputs['Roughness'].default_value=0.85
 return m
def loft(name,levels,mat):
 vertices=[];faces=[];n=24
 for z,rx,ry,front in levels:
  for k in range(n):
   a=k*math.tau/n;vertices.append((rx*math.cos(a),front+ry*math.sin(a),z))
 for j in range(len(levels)-1):
  for k in range(n):
   a=j*n+k;b=j*n+(k+1)%n;faces.append((a,b,b+n,a+n))
 faces.extend([tuple(reversed(range(n))),tuple((len(levels)-1)*n+k for k in range(n))])
 mesh=bpy.data.meshes.new(name);mesh.from_pydata(vertices,[],faces);mesh.update()
 obj=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(obj);mesh.materials.append(mat)
 for p in mesh.polygons:p.use_smooth=True
 return obj
def oval(name,pos,scale,mat):
 bpy.ops.mesh.primitive_uv_sphere_add(segments=16,ring_count=10,location=pos)
 o=bpy.context.object;o.name=name;o.scale=scale;o.data.materials.append(mat)
def rig_and_animate():
 """Lightweight rigid skinning with named bones and five reusable action clips."""
 bpy.ops.object.armature_add(enter_editmode=True,location=(0,0,0))
 arm=bpy.context.object;arm.name="ChibiRig"
 for initial_bone in list(arm.data.edit_bones):
  arm.data.edit_bones.remove(initial_bone)
 specs=[
  ("Root",None,(0,0,.1),(0,0,.5)),
  ("Hips","Root",(0,0,.5),(0,0,1.0)),
  ("Spine","Hips",(0,0,1.0),(0,0,1.53)),
  ("Head","Spine",(0,0,1.53),(0,0,2.12)),
  ("Arm_L","Spine",(-.3,0,1.40),(-.48,0,.92)),
  ("Arm_R","Spine",(.3,0,1.40),(.48,0,.92)),
  ("Leg_L","Hips",(-.18,0,.66),(-.19,0,.23)),
  ("Leg_R","Hips",(.18,0,.66),(.19,0,.23))]
 for name,parent,head,tail in specs:
  bone=arm.data.edit_bones.new(name);bone.head=head;bone.tail=tail
  if parent:bone.parent=arm.data.edit_bones[parent]
 bpy.ops.object.mode_set(mode="OBJECT")
 for obj in list(bpy.context.scene.objects):
  if obj.type!="MESH":continue
  name=obj.name
  # Blender adds .001 to repeated names; side is determined by world X, not suffix.
  center_x=sum((obj.matrix_world @ vertex.co).x for vertex in obj.data.vertices)/max(1,len(obj.data.vertices))
  if any(t in name for t in ("Head","Hair","Eye","Iris","Ear","Nose","Mouth")):
   target="Head"
  elif name.startswith(("Hand","Arm")):
   target="Arm_L" if center_x < 0 else "Arm_R"
  elif name.startswith(("Foot","Leg")):
   target="Leg_L" if center_x < 0 else "Leg_R"
  else:
   target="Spine"
  group=obj.vertex_groups.new(name=target)
  group.add(list(range(len(obj.data.vertices))),1.0,"REPLACE")
  mod=obj.modifiers.new("Skin","ARMATURE");mod.object=arm
  obj.parent=arm
  obj.matrix_parent_inverse=arm.matrix_world.inverted()
 clips={"Idle":(1,32),"Walk":(40,63),"Attack":(70,91),"Hit":(100,113),"Dodge":(120,139)}
 for clip,(start,end) in clips.items():
  action=bpy.data.actions.new(name=clip)
  arm.animation_data_create();arm.animation_data.action=action
  for frame in (start,(start+end)//2,end):
   phase=(frame-start)/max(1,end-start)
   for bone in arm.pose.bones:
    bone.rotation_mode="XYZ";bone.rotation_euler=(0,0,0)
    if clip=="Idle" and bone.name=="Head":bone.rotation_euler.z=.06*math.sin(phase*math.tau)
    if clip=="Walk" and bone.name in ("Leg_L","Leg_R","Arm_L","Arm_R"):
     sign=1 if bone.name.endswith("L") else -1
     if bone.name.startswith("Arm"):sign=-sign
     bone.rotation_euler.x=.48*sign*math.sin(phase*math.tau)
    if clip=="Attack" and bone.name=="Arm_R":bone.rotation_euler.x=-1.1*math.sin(phase*math.pi)
    if clip=="Hit" and bone.name=="Spine":bone.rotation_euler.x=.25*math.sin(phase*math.pi)
    if clip=="Dodge" and bone.name=="Spine":bone.rotation_euler.y=.35*math.sin(phase*math.pi)
    bone.keyframe_insert(data_path="rotation_euler",frame=frame,group=bone.name)
  # NLA strips must not keep an active action that overrides them.
  arm.animation_data.action=None
  track=arm.animation_data.nla_tracks.new();track.name=clip
  strip=track.strips.new(clip,start,action)
  strip.action_frame_start=start
  strip.action_frame_end=end
  strip.frame_end=start+(end-start)
  track.mute=False
 arm.animation_data.action=None
 return arm

for idx,name in enumerate(NAMES):
 bpy.ops.object.select_all(action="SELECT");bpy.ops.object.delete(use_global=False)
 skin=material("skin",(.92,.69,.51));hair=material("hair",COLORS[idx])
 white=material("white",(1,.96,.89));dark=material("pupil",(.05,.08,.12))
 loft("SculptedHead",[(1.53,.02,.02,0),(1.65,.34,.29,0),(1.82,.49,.38,-.03),(2.02,.47,.40,-.02),(2.20,.29,.28,0),(2.27,.02,.02,0)],skin)
 loft("SculptedBody",[(.45,.02,.02,0),(.60,.27,.22,0),(.95,.38,.29,0),(1.25,.34,.27,0),(1.52,.10,.11,0)],skin)
 loft("HairCap",[(2.04,.33,.32,.08),(2.17,.44,.37,.04),(2.29,.26,.24,.03),(2.34,.02,.02,.03)],hair)
 for side in (-1,1):
  x=side*.19
  oval("EyeWhite",(x,-.37,1.90),(.13,.035,.16),white)
  oval("Iris",(x,-.405,1.90),(.075,.018,.11),dark)
  oval("EyeGlint",(x-.027,-.423,1.952),(.026,.012,.035),white)
  oval("Eyebrow",(x,-.39,2.095),(.115,.027,.035),hair)
  oval("Ear",(side*.48,0,1.88),(.10,.08,.13),skin)
  oval("Arm",(side*.40,0,1.19),(.14,.16,.32),skin)
  oval("Hand",(side*.47,-.02,.94),(.15,.14,.15),skin)
  oval("Leg",(side*.19,0,.49),(.16,.17,.28),skin)
  oval("Foot",(side*.19,-.1,.23),(.19,.27,.15),skin)
 for k in range(5+idx%3):
  x=(k-2)*.15
  lock=loft("HairLock",[(2.04,.07,.08,-.29),(2.17,.10,.11,-.26),(2.29,.08,.08,-.18),(2.36,.01,.01,-.12)],hair)
  lock.location.x=x
  # Alternating length and lean gives each class a less uniform fringe.
  lock.scale.z=1.0+(idx%4)*.09+(k%2)*.06
  lock.rotation_euler.y=(k-2)*.065
 # Rounded rear hair volume avoids a flat silhouette from the side.
 oval("HairBack",(0,.21,2.09),(.37,.22,.30),hair)
 oval("Nose",(0,-.42,1.78),(.04,.03,.03),skin)
 oval("Mouth",(0,-.40,1.71),(.10,.018,.02),dark)
 # Original class-specific silhouettes, kept lightweight for Android GL Compatibility.
 cloth=material("class_cloth",tuple(min(.95,v*.7+.18) for v in COLORS[idx]))
 gold=material("class_trim",(.94,.70,.23))
 if name in ("warrior","paladin","brawler"):
  for side in (-1,1):
   oval("ArmPauldron",(side*.40,0,1.43),(.23,.24,.17),gold)
  oval("ChestCrest",(0,-.28,1.22),(.20,.07,.25),gold)
 if name in ("druid","shaman","priest"):
  oval("HeadCirclet",(0,-.03,2.16),(.42,.38,.065),gold)
  oval("ChestCharm",(0,-.29,1.12),(.13,.08,.18),cloth)
 if name in ("hunter","rogue"):
  for side in (-1,1):
   oval("ArmBracer",(side*.43,-.04,1.04),(.16,.17,.17),cloth)
  oval("ChestStrap",(0,-.30,1.19),(.10,.08,.36),gold)
 if name in ("mage","warlock","summoner"):
  oval("HeadGem",(0,-.37,2.14),(.12,.065,.16),gold)
  oval("ChestRune",(0,-.29,1.22),(.19,.07,.22),cloth)
 rig_and_animate()
 bpy.ops.object.select_all(action="SELECT")
 bpy.ops.export_scene.gltf(filepath=os.path.join(OUT,name+".glb"),export_format="GLB",use_selection=True,export_animations=True,export_nla_strips=True)
 print("Generated",name)
