"""Render front-view PNG previews of all generated GLBs for mobile visual QA."""
import bpy
import math
import os
from mathutils import Vector

SOURCE = os.path.abspath("assets/heroes/chibi")
OUTPUT = os.path.abspath("build/chibi_previews")
os.makedirs(OUTPUT, exist_ok=True)
names = "warrior paladin druid shaman hunter rogue mage warlock summoner priest brawler".split()

for name in names:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    bpy.ops.import_scene.gltf(filepath=os.path.join(SOURCE, name + ".glb"))
    # Imported meshes use their rest pose, so every class is compared consistently.
    bpy.ops.object.camera_add(location=(3.8, -6.5, 3.1))
    camera = bpy.context.object
    target = Vector((0, 0, 1.25))
    camera.rotation_euler = (target - camera.location).to_track_quat("-Z", "Y").to_euler()
    camera.data.type = "ORTHO"
    camera.data.ortho_scale = 3.35
    bpy.context.scene.camera = camera
    bpy.ops.object.light_add(type="AREA", location=(0, -3.0, 5.0))
    bpy.context.object.data.energy = 450
    bpy.context.object.data.shape = "DISK"
    bpy.context.object.data.size = 4.0
    bpy.context.scene.render.engine = "BLENDER_EEVEE_NEXT"
    world = bpy.context.scene.world
    if world is not None:
        world.use_nodes = True
        bg = world.node_tree.nodes.get("Background")
        if bg:
            bg.inputs["Color"].default_value = (.18, .20, .24, 1)
            bg.inputs["Strength"].default_value = .8
    scene = bpy.context.scene
    scene.render.resolution_x = 600
    scene.render.resolution_y = 800
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.film_transparent = False
    scene.render.filepath = os.path.join(OUTPUT, name + ".png")
    bpy.ops.render.render(write_still=True)
    print("Preview", name, scene.render.filepath)
