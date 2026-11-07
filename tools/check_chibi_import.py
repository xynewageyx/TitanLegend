"""Round-trip import each generated chibi GLB in Blender and verify animation data."""
import bpy, os
NAMES="warrior paladin druid shaman hunter rogue mage warlock summoner priest brawler death_knight".split()
for name in NAMES:
 path=os.path.abspath("assets/heroes/chibi/"+name+".glb")
 bpy.ops.object.select_all(action="SELECT")
 bpy.ops.object.delete(use_global=False)
 bpy.ops.import_scene.gltf(filepath=path)
 armatures=[o for o in bpy.context.scene.objects if o.type=="ARMATURE"]
 meshes=[o for o in bpy.context.scene.objects if o.type=="MESH"]
 if not armatures or not meshes:
  raise RuntimeError(name+": missing armature or meshes after round-trip")
 arm=armatures[0]
 if len(arm.data.bones)<8:
  raise RuntimeError(name+": insufficient skeleton bones")
 if not any(o.modifiers and any(m.type=="ARMATURE" for m in o.modifiers) for o in meshes):
  raise RuntimeError(name+": no skinned mesh")
 expected={"Root","Hips","Spine","Head","Arm_L","Arm_R","Leg_L","Leg_R"}
 if not expected.issubset({b.name for b in arm.data.bones}):
  raise RuntimeError(name+": required animation bones missing")
 for side in ("Arm_L","Arm_R","Leg_L","Leg_R"):
  if not any(side in o.vertex_groups for o in meshes):
   raise RuntimeError(name+": no skin weights for "+side)
 print("PASS",name,len(arm.data.bones),"bones",len(meshes),"meshes")
print("All twelve GLBs imported successfully")
