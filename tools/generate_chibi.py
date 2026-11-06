"""Generate twelve original chibi base GLBs with Blender 4.x; no third-party assets."""
import bpy, math, os
OUT=os.path.abspath("assets/heroes/chibi")
os.makedirs(OUT,exist_ok=True)
NAMES="warrior paladin druid shaman hunter rogue mage warlock summoner priest brawler death_knight".split()
COLORS=[(.2,.12,.1),(.7,.5,.2),(.2,.4,.2),(.1,.3,.5),(.4,.25,.1),(.2,.15,.3),(.1,.2,.6),(.4,.2,.5),(.6,.4,.7),(.8,.7,.4),(.5,.2,.1),(.16,.22,.27)]
def material(name,color):
 m=bpy.data.materials.new(name);m.diffuse_color=(*color,1);return m
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
 arm.data.edit_bones.remove(arm.data.edit_bones[0])
 specs=[
  ("Root",None,(0,0,.1),(0,0,.5)),
  ("Hips","Root",(0,0,.5),(0,0,1.0)),
  ("Spine","Hips",(0,0,1.0),(0,0,1.34)),
  ("Chest","Spine",(0,0,1.34),(0,0,1.50)),
  ("Neck","Chest",(0,0,1.50),(0,0,1.60)),
  ("Head","Neck",(0,0,1.60),(0,0,2.12)),
  ("Arm_L","Chest",(-.3,0,1.40),(-.38,0,1.19)),
  ("Shoulder_L","Arm_L",(-.38,0,1.19),(-.40,0,1.13)),
  ("UpperArm_L","Shoulder_L",(-.40,0,1.13),(-.44,0,1.03)),
  ("Forearm_L","UpperArm_L",(-.44,0,1.03),(-.47,0,.96)),
  ("Hand_L","Forearm_L",(-.47,0,.96),(-.47,0,.86)),
  ("Arm_R","Chest",(.3,0,1.40),(.38,0,1.19)),
  ("Shoulder_R","Arm_R",(.38,0,1.19),(.40,0,1.13)),
  ("UpperArm_R","Shoulder_R",(.40,0,1.13),(.44,0,1.03)),
  ("Forearm_R","UpperArm_R",(.44,0,1.03),(.47,0,.96)),
  ("Hand_R","Forearm_R",(.47,0,.96),(.47,0,.86)),
  ("Leg_L","Hips",(-.18,0,.66),(-.18,0,.55)),
  ("UpperLeg_L","Leg_L",(-.18,0,.55),(-.19,0,.40)),
  ("LowerLeg_L","UpperLeg_L",(-.19,0,.40),(-.19,0,.25)),
  ("Foot_L","LowerLeg_L",(-.19,0,.25),(-.19,-.10,.18)),
  ("Leg_R","Hips",(.18,0,.66),(.18,0,.55)),
  ("UpperLeg_R","Leg_R",(.18,0,.55),(.19,0,.40)),
  ("LowerLeg_R","UpperLeg_R",(.19,0,.40),(.19,0,.25)),
  ("Foot_R","LowerLeg_R",(.19,0,.25),(.19,-.10,.18))]
 for name,parent,head,tail in specs:
  bone=arm.data.edit_bones.new(name);bone.head=head;bone.tail=tail
  if parent:bone.parent=arm.data.edit_bones[parent]
 bpy.ops.object.mode_set(mode="OBJECT")
 for obj in list(bpy.context.scene.objects):
  if obj.type!="MESH":continue
  name=obj.name
  target=("Head" if any(t in name for t in ("Head","Hair","Eye","Iris","Ear","Nose","Mouth")) else
          "Hand_L" if name=="Hand_L" else
          "Hand_R" if name=="Hand_R" else
          "Foot_L" if name=="Foot_L" else
          "Foot_R" if name=="Foot_R" else "Spine")
  if name=="SculptedNeck":
   # Blend the neck into the chest at its base and the head at its top.
   chest_group=obj.vertex_groups.new(name="Chest")
   neck_group=obj.vertex_groups.new(name="Neck")
   head_group=obj.vertex_groups.new(name="Head")
   for vertex in obj.data.vertices:
    z=vertex.co.z
    chest_weight=max(0.0,min(1.0,(1.53-z)/.10))
    head_weight=max(0.0,min(1.0,(z-1.59)/.10))
    neck_weight=max(0.0,1.0-chest_weight-head_weight)
    total=chest_weight+neck_weight+head_weight
    for group,weight in ((chest_group,chest_weight),(neck_group,neck_weight),(head_group,head_weight)):
     if weight>0:
      group.add([vertex.index],weight/total,"REPLACE")
  elif name=="SculptedBody":
   # Blend weights across the torso instead of moving the entire body rigidly.
   hips=obj.vertex_groups.new(name="Hips")
   spine=obj.vertex_groups.new(name="Spine")
   chest=obj.vertex_groups.new(name="Chest")
   for vertex in obj.data.vertices:
    z=vertex.co.z
    chest_weight=max(0.0,min(1.0,(z-1.12)/.34))
    hips_weight=max(0.0,min(1.0,(.94-z)/.40))
    spine_weight=max(0.0,1.0-chest_weight-hips_weight)
    total=hips_weight+spine_weight+chest_weight
    for group,weight in ((hips,hips_weight),(spine,spine_weight),(chest,chest_weight)):
     if weight>0:group.add([vertex.index],weight/total,"REPLACE")
  else:
   group=obj.vertex_groups.new(name=target)
   group.add(list(range(len(obj.data.vertices))),1.0,"REPLACE")
  mod=obj.modifiers.new("Skin","ARMATURE");mod.object=arm
 clips={"Idle":(1,32),"Walk":(40,63),"Attack":(70,91),"Hit":(100,113),"Dodge":(120,139)}
 for clip,(start,end) in clips.items():
  action=bpy.data.actions.new(name=clip)
  arm.animation_data_create();arm.animation_data.action=action
  for frame in (start,(start+end)//2,end):
   phase=(frame-start)/max(1,end-start)
   for bone in arm.pose.bones:
    bone.rotation_mode="XYZ";bone.rotation_euler=(0,0,0)
    if clip=="Idle" and bone.name=="Head":bone.rotation_euler.z=.06*math.sin(phase*math.tau)
    if clip=="Walk" and bone.name in ("UpperLeg_L","UpperLeg_R","Arm_L","Arm_R"):
     sign=1 if bone.name.endswith("L") else -1
     if bone.name.startswith("Arm"):sign=-sign
     bone.rotation_euler.x=.48*sign*math.sin(phase*math.tau)
    if clip=="Attack" and bone.name=="UpperArm_R":bone.rotation_euler.x=-1.1*math.sin(phase*math.pi)
    if clip=="Hit" and bone.name=="Spine":bone.rotation_euler.x=.25*math.sin(phase*math.pi)
    if clip=="Dodge" and bone.name=="Spine":bone.rotation_euler.y=.35*math.sin(phase*math.pi)
    bone.keyframe_insert(data_path="rotation_euler",frame=frame,group=bone.name)
  track=arm.animation_data.nla_tracks.new();track.name=clip
  track.strips.new(clip,start,action)
 arm.animation_data.action=None
 return arm

# Distinct class silhouettes without changing shared bone positions or animation clips.
# Width/depth only: preserve rig alignment and equipment attachment heights.
SILHOUETTES = {
 "warrior": (1.02, 1.18, 1.12),
 "paladin": (1.00, 1.12, 1.08),
 "druid": (1.08, .94, .98),
 "shaman": (1.10, .90, 1.02),
 "hunter": (.98, .96, .92),
 "rogue": (.92, .84, .90),
 "mage": (1.12, .88, 1.04),
 "warlock": (1.10, .92, 1.06),
 "summoner": (1.08, .92, 1.00),
 "priest": (1.10, .90, .96),
 "brawler": (.96, 1.22, 1.14),
 "death_knight": (1.02, 1.20, 1.16),
}
FACE_STYLES = {
 "warrior": (.96, 1.00), "paladin": (1.00, 1.05),
 "druid": (1.12, 1.15), "shaman": (1.10, 1.12),
 "hunter": (1.03, .92), "rogue": (.88, .90),
 "mage": (1.16, 1.18), "warlock": (1.06, .94),
 "summoner": (1.12, 1.08), "priest": (1.12, 1.16),
 "brawler": (.94, .94), "death_knight": (.90, .82),
}
def silhouette_levels(levels, width, depth):
 return [(z, rx*width, ry*depth, front) for z,rx,ry,front in levels]

for idx,name in enumerate(NAMES):
 bpy.ops.object.select_all(action="SELECT");bpy.ops.object.delete(use_global=False)
 head_width,body_width,body_depth=SILHOUETTES[name]
 eye_width,eye_height=FACE_STYLES[name]
 skin=material("skin",(.72,.77,.82) if name=="death_knight" else (.92,.69,.51));hair=material("hair",COLORS[idx])
 white=material("white",(.72,.92,1.0) if name=="death_knight" else (1,.96,.89));dark=material("pupil",(.12,.75,1.0) if name=="death_knight" else (.05,.08,.12))
 loft("SculptedHead",silhouette_levels([(1.53,.02,.02,0),(1.65,.34,.29,0),(1.82,.49,.38,-.03),(2.02,.47,.40,-.02),(2.20,.29,.28,0),(2.27,.02,.02,0)],head_width,head_width),skin)
 loft("SculptedBody",silhouette_levels([(.45,.02,.02,0),(.60,.27,.22,0),(.95,.38,.29,0),(1.25,.34,.27,0),(1.52,.10,.11,0)],body_width,body_depth),skin)
 # Tapered neck bridge reduces the visible gap between the large chibi head
 # and torso. Keep its height aligned with the shared Neck bone.
 neck_width=.155*(.85+.15*body_width)
 loft("SculptedNeck",[(1.43,.14*body_width,.13*body_depth,0),
                      (1.50,neck_width,.145,0),
                      (1.60,neck_width*.96,.14,0),
                      (1.69,.20*head_width,.18*head_width,0)],skin)
 loft("HairCap",silhouette_levels([(2.04,.33,.32,.08),(2.17,.44,.37,.04),(2.29,.26,.24,.03),(2.34,.02,.02,.03)],head_width,head_width),hair)
 for side in (-1,1):
  x=side*.19*head_width
  face_front=-.37*head_width
  oval("EyeWhite",(x,face_front,1.90),(.13*eye_width,.035,.16*eye_height),white)
  oval("Iris",(x,face_front-.035,1.90),(.075*eye_width,.018,.11*eye_height),dark)
  oval("Ear",(side*.48*head_width,0,1.88),(.10,.08,.13),skin)
  oval("Hand_L" if side<0 else "Hand_R",(side*.47,-.02,.94),(.12,.12,.13),skin)
  oval("Foot_L" if side<0 else "Foot_R",(side*.19,-.1,.23),(.15,.23,.12),skin)
 # Hair is deliberately separate geometry for later modular customization.
 # Strand count, height and sweep differ by class; no armor or weapons generated.
 hair_profiles={
  "warrior":(5,.07,.00), "paladin":(5,.04,.00),
  "druid":(7,.12,-.04), "shaman":(6,.16,.06),
  "hunter":(6,.10,-.08), "rogue":(5,.06,.12),
  "mage":(7,.18,-.10), "warlock":(6,.14,.10),
  "summoner":(7,.16,-.06), "priest":(6,.08,.00),
  "brawler":(5,.03,.00), "death_knight":(7,.15,.14),
 }
 strand_count,extra_height,sweep=hair_profiles[name]
 for k in range(strand_count):
  x=(k-(strand_count-1)/2)*.15*head_width
  lock=loft("HairLock",[(2.04,.07,.08,-.29),
                         (2.17,.10,.11,-.26),
                         (2.29+extra_height*.5,.08,.08,-.18+sweep*.5),
                         (2.36+extra_height,.01,.01,-.12+sweep)],hair)
  lock.location.x=x
 # Class-specific soft cheek volumes and brow shapes are separate head-skinned
 # meshes, preserving the shared rig and keeping geometry Android-friendly.
 cheek_width = {
  "warrior":1.12,"paladin":1.06,"druid":1.10,"shaman":1.04,
  "hunter":.96,"rogue":.86,"mage":1.02,"warlock":.92,
  "summoner":1.03,"priest":1.08,"brawler":1.16,"death_knight":.82,
 }[name]
 brow_tint=material("brow_color",COLORS[idx] if name!="death_knight" else (.13,.18,.24))
 for side in (-1,1):
  cheek_x=side*.305*head_width
  oval("Cheek_L" if side<0 else "Cheek_R",
       (cheek_x,-.315*head_width,1.765),
       (.135*cheek_width,.060,.105),skin)
  oval("Brow_L" if side<0 else "Brow_R",
       (side*.19*head_width,-.402*head_width,2.075),
       (.14*eye_width,.025,.029 if name!="death_knight" else .043),brow_tint)
 oval("Nose",(0,-.42*head_width,1.78),(.04,.03,.03),skin)
 oval("Mouth",(0,-.40*head_width,1.71),(.10,.018,.02),dark)
 if name=="death_knight":
  # Original class-specific face sculpt: angular brow, sunken cheeks, icy eyes.
  shadow=material("death_knight_cheek_shadow",(.38,.46,.55))
  brow=material("death_knight_brow",(.13,.18,.24))
  for side in (-1,1):
   oval("DeathKnightCheekShadow_L" if side<0 else "DeathKnightCheekShadow_R",
        (side*.31,-.344,1.76),(.105,.018,.085),shadow)
   oval("DeathKnightAngularBrow_L" if side<0 else "DeathKnightAngularBrow_R",
        (side*.19,-.408,2.07),(.15,.035,.038),brow)
  oval("DeathKnightForeheadMark",(0,-.405,2.13),(.045,.02,.075),dark)
 rig_and_animate()
 bpy.ops.object.select_all(action="SELECT")
 bpy.ops.export_scene.gltf(filepath=os.path.join(OUT,name+".glb"),export_format="GLB",use_selection=True,export_animations=True,export_nla_strips=True)
 print("Generated",name)
