"""Deterministic, mobile-friendly stylized forest route for Titan Legends."""
import bpy
import math
import random

rng = random.Random(42)
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)

def material(name, rgb):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*rgb, 1.0)
    m.use_nodes = True
    m.node_tree.nodes.get("Principled BSDF").inputs["Base Color"].default_value = (*rgb, 1.0)
    return m

grass = material("Soft meadow green", (.25, .58, .19))
grass_light = material("Meadow highlights", (.40, .70, .23))
path = material("Warm sandy path", (.74, .55, .30))
bark = material("Warm tree bark", (.38, .23, .13))
leaves = [material("Canopy green", (.17, .49, .20)), material("Canopy lime", (.37, .69, .23)), material("Canopy deep", (.12, .38, .20))]
leaves_sun = material("Sunlit canopy tips", (.52, .76, .30))
rock = material("Soft sandstone", (.61, .58, .50))
water = material("River turquoise", (.12, .54, .72))
water_highlight = material("River glimmer", (.48, .82, .87))
meadow_shadow = material("Meadow lowlands", (.19, .45, .18))
flower_colors = [material("Flower pink", (.95, .39, .58)), material("Flower cream", (.98, .85, .51)), material("Flower lavender", (.63, .49, .85))]

def mesh_obj(name, verts, faces, mat):
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(mat)
    return obj

def box(name, loc, dimensions, mat, bevel=0):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    o = bpy.context.object
    o.name = name
    o.dimensions = dimensions
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel:
        modifier = o.modifiers.new("Soft edges", "BEVEL")
        modifier.width = bevel
        modifier.segments = 2
        o.modifiers.new("Weighted normals", "WEIGHTED_NORMAL")
    o.data.materials.append(mat)
    return o

def ico(name, loc, scale, mat, subdivisions=1):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=subdivisions, radius=1, location=loc)
    o = bpy.context.object
    o.name = name
    o.scale = scale
    o.data.materials.append(mat)
    return o

def trunk(name, x, y, height, radius):
    bpy.ops.mesh.primitive_cone_add(vertices=9, radius1=radius, radius2=radius * .72, depth=height, location=(x,y,height/2))
    o = bpy.context.object
    o.name = name
    o.data.materials.append(bark)

def route_x(y):
    return math.sin((y + 32) * .17) * 1.15

# Keep the continuous travel corridor free of blocking props.
box("Continuous meadow ground", (0,-7,-.65), (24,58,1.3), grass, .65)
# Gentle meadow banks remain outside the movement corridor.
for i in range(12):
    side = -1 if i % 2 else 1
    y = -29 + i * 4.4
    x = side * (10.2 + (i % 3) * .65)
    ico("Rolling meadow bank %02d" % i, (x, y, -.15), (3.8, 3.1, .65),
        grass_light if i % 3 == 0 else meadow_shadow, 2)

for i in range(55):
    y = -33 + i * .95
    ico("Path segment %03d" % i, (route_x(y),y,.025), (2.4,.85,.045), path, 1)

for i in range(44):
    y = rng.uniform(-32,15)
    side = rng.choice((-1,1))
    x = side * rng.uniform(5.2,10.7)
    height = rng.uniform(2.2,3.7)
    trunk("Tree trunk %03d" % i,x,y,height,.24 + height*.04)
    # Layered asymmetric crowns with a brighter upper canopy.
    crown_width = rng.uniform(1.0, 1.35)
    for j in range(3):
        offset = (j-1)*.58
        ico("Tree foliage %03d-%d" % (i,j),
            (x+offset,y+rng.uniform(-.30,.30),height+(.52 if j!=1 else 1.0)),
            (crown_width,1.15+rng.random()*.3,.85+rng.random()*.3),
            leaves[(i+j)%3],2)
    ico("Sunlit crown %03d" % i,(x-.2,y-.12,height+1.55),
        (.77,.85,.42),leaves_sun,2)

for i in range(65):
    y = rng.uniform(-32,16)
    x = rng.choice((-1,1))*rng.uniform(3.8,11.2)
    ico("Stone %03d" % i,(x,y,.18),(.25+rng.random()*.55,.25+rng.random()*.45,.20+rng.random()*.35),rock,1)

# Small accents are kept outside the central character movement lane.
for i in range(170):
    y = rng.uniform(-32,15)
    x = rng.choice((-1,1))*rng.uniform(3.1,11.2)
    height = rng.uniform(.12,.36)
    ico("Grass tuft %03d" % i,(x,y,height*.5),(.09,.15,height),grass_light,1)
for i in range(75):
    y = rng.uniform(-32,15)
    x = rng.choice((-1,1))*rng.uniform(3.2,11)
    ico("Flower %03d" % i,(x,y,.16),(.13,.13,.15),flower_colors[i%3],1)

box("River", (0,19,-.03), (23,3,.08),water,.15)
# Simple river glimmers use unlit-looking bright material.
for i in range(8):
    x = -10 + i * 2.8
    box("Water shimmer %02d" % i, (x, 19 + (i % 3 - 1) * .55, .025),
        (1.1, .07, .012), water_highlight)

for i in range(10):
    box("Bridge plank %02d" % i,(0,17+i*.42,.24),(4.8,.36,.23),bark,.055)

# Combat arenas are spawned only by the battle system, never baked into exploration terrain.
trunk("Ancient tree trunk",0,32,5.8,1.0)
for i in range(7):
    a = math.tau*i/7
    ico("Ancient tree crown %02d" % i,(math.cos(a)*1.8,32+math.sin(a)*1.8,6.6),(2.0,1.9,1.5),leaves[i%3],2)

bpy.ops.object.select_all(action="SELECT")
bpy.ops.export_scene.gltf(filepath="/tmp/grasland.glb",export_format="GLB",use_selection=True)
print("GLB exported: stylized forest route")
