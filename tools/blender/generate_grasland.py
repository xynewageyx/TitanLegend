import bpy, math, random
from mathutils import Vector
random.seed(42)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
def mat(name, color):
 m=bpy.data.materials.new(name); m.diffuse_color=(*color,1); return m
grass=mat("Grass",(.28,.66,.19)); dirt=mat("Warm earth",(.53,.34,.18)); stone=mat("Sandstone",(.67,.61,.49)); bark=mat("Bark",(.36,.22,.12)); leaf=mat("Canopy",(.16,.52,.22)); leaf2=mat("Light canopy",(.36,.72,.23)); water=mat("Water",(.16,.62,.86)); gold=mat("Path",(.83,.66,.38))
def cube(name,loc,scale,material,bevel=0):
 bpy.ops.mesh.primitive_cube_add(size=1,location=loc);o=bpy.context.object;o.name=name;o.dimensions=scale;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 if bevel: mod=o.modifiers.new("Rounded edges","BEVEL");mod.width=bevel;mod.segments=2;o.modifiers.new("Normals","WEIGHTED_NORMAL")
 o.data.materials.append(material);return o
def sphere(name,loc,scale,material):
 bpy.ops.mesh.primitive_uv_sphere_add(segments=12,ring_count=8,location=loc);o=bpy.context.object;o.name=name;o.scale=scale;o.data.materials.append(material);return o
def cylinder(name,loc,radius,depth,material,vertices=10):
 bpy.ops.mesh.primitive_cylinder_add(vertices=vertices,radius=radius,depth=depth,location=loc);o=bpy.context.object;o.name=name;o.data.materials.append(material);return o
cube("Meadow plateau",(0,-8,-.65),(24,56,1.3),grass,1.0)
for i in range(25):
 y=-32+i*2
 x=math.sin(i*.34)*1.1
 sphere("Winding trail %02d"%i,(x,y,.03),(2.25,1.5,.08),gold)
for i in range(28):
 x=random.choice([-1,1])*random.uniform(5,10);y=random.uniform(-32,15)
 cylinder("Tree trunk %02d"%i,(x,y,1.4),.35,2.8,bark)
 sphere("Canopy %02d"%i,(x,y,3.25),(1.8,1.65,.9),leaf if i%2 else leaf2)
for i in range(38):
 x=random.choice([-1,1])*random.uniform(3.8,11);y=random.uniform(-34,17)
 sphere("Rounded rock %02d"%i,(x,y,.25),(random.uniform(.3,1.0),.65,.48),stone)
cube("River",(0,19,-.02),(23,3,.09),water,.3)
for i in range(9):
 cube("Bridge plank %02d"%i,(0,16.8+i*.45,.26),(4.8,.37,.25),bark,.08)
for i in range(12):
 angle=math.tau*i/12
 cylinder("Boss stone %02d"%i,(math.cos(angle)*6,26+math.sin(angle)*6,.75),.7,1.5,stone)
cylinder("Boss arena",(0,26,.05),7,.25,stone,32)
cylinder("World tree trunk",(0,29,3),1.35,6,bark,12)
for i in range(7):
 a=math.tau*i/7
 sphere("World tree canopy %02d"%i,(math.cos(a)*2,29+math.sin(a)*2,7.1),(2.1,2.0,1.7),leaf2)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.gltf(filepath='/tmp/grasland.glb',export_format='GLB',use_selection=True)
print("GLB exported")
