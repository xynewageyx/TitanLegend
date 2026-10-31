"""Isolated, non-destructive MPFB headless compatibility probe for Titan Legends."""
import bpy
import json
import sys
import traceback
from pathlib import Path

src = Path(sys.argv[sys.argv.index("--") + 1])
out = Path(sys.argv[sys.argv.index("--") + 2])
out.mkdir(parents=True, exist_ok=True)
report = {"blender": bpy.app.version_string, "source": str(src), "registration": False,
          "human_created": False, "objects": [], "errors": []}
try:
    # MPFB 2 expects Blender extension package identity, not a bare import.
    import shutil
    import importlib
    import addon_utils
    extension_root = Path(bpy.utils.user_resource("EXTENSIONS", path="user_default", create=True))
    installed = extension_root / "mpfb"
    if installed.exists():
        shutil.rmtree(installed)
    shutil.copytree(src / "mpfb", installed)
    report["installed_path"] = str(installed)
    report["manifest_exists"] = (installed / "blender_manifest.toml").exists()
    importlib.invalidate_caches()
    addon_utils.modules(refresh=True)
    bpy.ops.preferences.addon_enable(module="bl_ext.user_default.mpfb")
    mpfb = importlib.import_module("bl_ext.user_default.mpfb")
    report["mpfb_module"] = str(mpfb.__file__)
    report["registration"] = True
    # Discover the available operators rather than guessing unstable API names.
    report["mpfb_operators"] = sorted(
        name for name in dir(bpy.ops) if "mpfb" in name.lower() or "makehuman" in name.lower()
    )
    report["registered_classes"] = sorted(
        cls.__name__ for cls in bpy.types.Operator.__subclasses__()
        if "mpfb" in cls.__module__.lower()
    )[:150]
    # MPFB's documented operator creates an actual MakeHuman base mesh.
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    report["create_operator_available"] = hasattr(bpy.ops.mpfb, "create_human")
    if not report["create_operator_available"]:
        raise RuntimeError("MPFB create_human operator was not registered")
    result = bpy.ops.mpfb.create_human()
    report["create_operator_result"] = sorted(result)
    meshes = [obj for obj in bpy.data.objects if obj.type == "MESH"]
    report["human_created"] = bool(meshes)
    report["mesh_stats"] = [{"name": obj.name, "vertices": len(obj.data.vertices),
                             "faces": len(obj.data.polygons)} for obj in meshes]
    if not meshes:
        raise RuntimeError("MPFB operator did not create a mesh")
    # Experimental chibi morph on a duplicated mesh; preserve the original base mesh.
    # Geometry-only proof of concept: no skeleton, face rig or clothing yet.
    from mathutils import Vector
    source = max(meshes, key=lambda obj: len(obj.data.vertices))
    chibi = source.copy()
    chibi.data = source.data.copy()
    chibi.name = "Titan_Chibi_Prototype"
    bpy.context.collection.objects.link(chibi)
    coords = [v.co.copy() for v in chibi.data.vertices]
    low = min(v.z for v in coords)
    high = max(v.z for v in coords)
    height = max(high - low, 0.001)
    # Use normalized vertical bands to retain facial topology and soften proportions.
    # Body height becomes shorter, while head grows in width and depth.
    for vertex in chibi.data.vertices:
        p = vertex.co
        t = (p.z - low) / height
        if t < 0.52:
            p.z = low + height * (t * 0.70)
        elif t < 0.78:
            p.z = low + height * (0.364 + (t - 0.52) * 0.88)
        else:
            p.z = low + height * (0.5928 + (t - 0.78) * 1.08)
            p.x *= 1.30
            p.y *= 1.30
    report["chibi_created"] = True
    report["chibi_vertices"] = len(chibi.data.vertices)
    report["chibi_note"] = "Experimental vertical-band morph; inspect visually before game use"
    # Render an Android-friendly front preview for visual proportion review.
    from mathutils import Vector
    bounds = [chibi.matrix_world @ Vector(corner) for corner in chibi.bound_box]
    center = sum(bounds, Vector()) / len(bounds)
    span = max((max(v.z for v in bounds) - min(v.z for v in bounds)), 0.1)
    bpy.ops.object.camera_add(location=(center.x, center.y - span * 2.5, center.z))
    camera = bpy.context.object
    camera.name = "MPFB_Chibi_Preview_Camera"
    direction = center - camera.location
    camera.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    camera.data.type = "ORTHO"
    camera.data.ortho_scale = span * 1.30
    scene = bpy.context.scene
    scene.camera = camera
    scene.render.engine = "BLENDER_WORKBENCH"
    scene.render.resolution_x = 720
    scene.render.resolution_y = 960
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.filepath = str(out / "mpfb_chibi_front.png")
    source.hide_render = True
    bpy.ops.render.render(write_still=True)
    source.hide_render = False
    report["preview_created"] = (out / "mpfb_chibi_front.png").stat().st_size > 1024
    report["preview_camera"] = "front orthographic workbench"
    # Also render a profile view to expose deformation artifacts invisible from front.
    camera.location = (center.x + span * 2.5, center.y, center.z)
    direction = center - camera.location
    camera.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    scene.render.filepath = str(out / "mpfb_chibi_side.png")
    bpy.ops.render.render(write_still=True)
    report["side_preview_created"] = (out / "mpfb_chibi_side.png").stat().st_size > 1024
    # The camera must not be selected for GLB export.
    bpy.ops.object.select_all(action="DESELECT")
    chibi.select_set(True)
    bpy.context.view_layer.objects.active = chibi
    bpy.ops.export_scene.gltf(filepath=str(out / "mpfb_chibi_prototype.glb"),
                              export_format="GLB", use_selection=True)
    report["chibi_glb_created"] = (out / "mpfb_chibi_prototype.glb").stat().st_size > 1024
    # Independent lightweight skinning experiment: three deformation bones.
    # Keep the static chibi export unchanged for comparison.
    rigged = chibi.copy()
    rigged.data = chibi.data.copy()
    rigged.name = "Titan_Chibi_Rigged_Prototype"
    bpy.context.collection.objects.link(rigged)
    arm_data = bpy.data.armatures.new("Titan_Chibi_Armature")
    arm = bpy.data.objects.new("Titan_Chibi_Rig", arm_data)
    bpy.context.collection.objects.link(arm)
    bpy.ops.object.select_all(action="DESELECT")
    arm.select_set(True)
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode="EDIT")
    specs = [
        ("Root", (0, 0, low), (0, 0, low + height * 0.36)),
        ("Torso", (0, 0, low + height * 0.36), (0, 0, low + height * 0.59)),
        ("Head", (0, 0, low + height * 0.59), (0, 0, low + height * 0.84)),
    ]
    for name, start, end in specs:
        bone = arm_data.edit_bones.new(name)
        bone.head = start
        bone.tail = end
        if name != "Root":
            bone.parent = arm_data.edit_bones["Root" if name == "Torso" else "Torso"]
            bone.use_connect = True
    bpy.ops.object.mode_set(mode="OBJECT")
    groups = {name: rigged.vertex_groups.new(name=name) for name, _, _ in specs}
    for vertex in rigged.data.vertices:
        t = (vertex.co.z - low) / height
        # Blend weights across the shoulder and neck bands.
        head_w = max(0.0, min(1.0, (t - 0.67) / 0.10))
        root_w = max(0.0, min(1.0, (0.43 - t) / 0.12))
        torso_w = max(0.0, 1.0 - root_w - head_w)
        weights = {"Root": root_w, "Torso": torso_w, "Head": head_w}
        total = sum(weights.values())
        for name, weight in weights.items():
            if weight > 0:
                groups[name].add([vertex.index], weight / total, "REPLACE")
    modifier = rigged.modifiers.new("ChibiSkin", "ARMATURE")
    modifier.object = arm
    rigged.parent = arm
    bpy.context.scene.frame_set(1)
    action = bpy.data.actions.new("idle")
    arm.animation_data_create()
    arm.animation_data.action = action
    for frame, angle in [(1, 0.0), (16, 0.045), (31, 0.0)]:
        arm.pose.bones["Torso"].rotation_mode = "XYZ"
        arm.pose.bones["Torso"].rotation_euler[1] = angle
        arm.pose.bones["Torso"].keyframe_insert(data_path="rotation_euler", frame=frame)
    bpy.context.scene.frame_end = 31
    bpy.context.scene.frame_set(1)
    bpy.ops.object.select_all(action="DESELECT")
    rigged.select_set(True)
    arm.select_set(True)
    bpy.context.view_layer.objects.active = arm
    bpy.ops.export_scene.gltf(filepath=str(out / "mpfb_chibi_rigged.glb"),
                              export_format="GLB", use_selection=True,
                              export_animations=True, export_skins=True)
    report["rigged_glb_created"] = (out / "mpfb_chibi_rigged.glb").stat().st_size > 1024
    report["rig_bones"] = [bone.name for bone in arm_data.bones]
    report["rig_note"] = "Experimental 3-bone skin with idle motion, not final hero rig"
    # Ten visually distinct material prototypes; not finished character designs.
    hero_palettes = [
        ("warrior", (0.60, 0.17, 0.12, 1)),
        ("rogue", (0.18, 0.18, 0.27, 1)),
        ("shaman", (0.12, 0.55, 0.54, 1)),
        ("hunter", (0.23, 0.43, 0.18, 1)),
        ("druid", (0.34, 0.57, 0.20, 1)),
        ("paladin", (0.83, 0.66, 0.22, 1)),
        ("priest", (0.84, 0.82, 0.75, 1)),
        ("mage", (0.25, 0.36, 0.80, 1)),
        ("warlock", (0.45, 0.20, 0.62, 1)),
        ("summoner", (0.70, 0.38, 0.67, 1)),
    ]
    report["hero_prototypes"] = []
    for hero_name, rgba in hero_palettes:
        variant = chibi.copy()
        variant.data = chibi.data.copy()
        variant.name = "Titan_" + hero_name.title() + "_Prototype"
        bpy.context.collection.objects.link(variant)
        mat = bpy.data.materials.new("Titan_" + hero_name + "_Color")
        mat.diffuse_color = rgba
        mat.use_nodes = True
        principled = mat.node_tree.nodes.get("Principled BSDF")
        if principled:
            principled.inputs["Base Color"].default_value = rgba
        variant.data.materials.clear()
        variant.data.materials.append(mat)
        equipment = []
        if hero_name == "warrior":
            # First unique class silhouette: helmet, shoulder armor, shield and sword.
            # Separate static accessories are intentionally not skinned yet.
            metal = bpy.data.materials.new("Warrior_Steel")
            metal.diffuse_color = (0.23, 0.36, 0.54, 1)
            metal.use_nodes = True
            gold = bpy.data.materials.new("Warrior_Gold")
            gold.diffuse_color = (0.95, 0.66, 0.15, 1)
            gold.use_nodes = True
            zhead = low + height * 0.81
            zshoulder = low + height * 0.60
            def accessory(name, location, scale, material, shape="CUBE"):
                if shape == "UV_SPHERE":
                    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=8, location=location)
                else:
                    bpy.ops.mesh.primitive_cube_add(size=1, location=location)
                obj = bpy.context.object
                obj.name = name
                obj.scale = scale
                if shape == "CUBE":
                    # Apply scale before bevel so the edge width is predictable.
                    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
                    bevel = obj.modifiers.new("Soft_Armor_Edges", "BEVEL")
                    bevel.width = max(0.002, min(abs(v) for v in scale) * 0.18)
                    bevel.segments = 3
                    bpy.context.view_layer.objects.active = obj
                    bpy.ops.object.modifier_apply(modifier=bevel.name)
                    for polygon in obj.data.polygons:
                        polygon.use_smooth = True
                    weighted = obj.modifiers.new("Weighted_Normals", "WEIGHTED_NORMAL")
                    bpy.ops.object.modifier_apply(modifier=weighted.name)
                else:
                    for polygon in obj.data.polygons:
                        polygon.use_smooth = True
                obj.data.materials.append(material)
                equipment.append(obj)
                return obj
            accessory("Warrior_Helmet_Crest", (0, 0, zhead + height * 0.18),
                      (height * 0.035, height * 0.12, height * 0.12), gold)
            for side in (-1, 1):
                accessory("Warrior_Pauldron_" + str(side),
                          (side * height * 0.19, 0, zshoulder),
                          (height * 0.13, height * 0.13, height * 0.085),
                          metal, "UV_SPHERE")
            accessory("Warrior_Shield", (-height * 0.29, -height * 0.12, low + height * 0.35),
                      (height * 0.22, height * 0.045, height * 0.28), metal)
            accessory("Warrior_Shield_Boss", (-height * 0.29, -height * 0.17, low + height * 0.35),
                      (height * 0.07, height * 0.035, height * 0.07), gold, "UV_SPHERE")
            accessory("Warrior_Sword_Blade", (height * 0.30, -height * 0.08, low + height * 0.42),
                      (height * 0.045, height * 0.025, height * 0.44), metal)
            accessory("Warrior_Sword_Guard", (height * 0.30, -height * 0.08, low + height * 0.22),
                      (height * 0.17, height * 0.055, height * 0.035), gold)
            accessory("Warrior_Sword_Grip", (height * 0.30, -height * 0.08, low + height * 0.15),
                      (height * 0.035, height * 0.04, height * 0.14), gold)
            # Original stylized dark-hair silhouette: rounded crown and asymmetric locks.
            hair = bpy.data.materials.new("Warrior_Deep_Navy_Hair")
            hair.diffuse_color = (0.055, 0.075, 0.14, 1)
            hair.use_nodes = True
            hair.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = hair.diffuse_color
            accessory("Warrior_Hair_Crown", (0, 0, zhead + height * 0.075),
                      (height * 0.22, height * 0.19, height * 0.115), hair, "UV_SPHERE")
            for side, offset in [(-1, 0.015), (1, -0.025)]:
                accessory("Warrior_Hair_Side_" + str(side),
                          (side * height * 0.16, -height * 0.035, zhead + height * offset),
                          (height * 0.065, height * 0.10, height * 0.12), hair, "UV_SPHERE")
            fringe = accessory("Warrior_Hair_Fringe",
                               (height * 0.055, -height * 0.18, zhead + height * 0.035),
                               (height * 0.11, height * 0.045, height * 0.075), hair, "UV_SPHERE")
            fringe.rotation_euler[1] = -0.30
            report["warrior_hair_parts"] = 4
            # Lightweight anime-style face overlays. Positioned relative to the
            # current procedural head; final placement requires visual QA.
            eye_white = bpy.data.materials.new("Warrior_Eye_White")
            eye_white.diffuse_color = (0.96, 0.95, 0.91, 1)
            eye_white.use_nodes = True
            iris = bpy.data.materials.new("Warrior_Iris_Amber")
            iris.diffuse_color = (0.64, 0.29, 0.065, 1)
            iris.use_nodes = True
            pupil = bpy.data.materials.new("Warrior_Pupil")
            pupil.diffuse_color = (0.018, 0.023, 0.042, 1)
            pupil.use_nodes = True
            for side in (-1, 1):
                x = side * height * 0.065
                accessory("Warrior_Eye_" + str(side),
                          (x, -height * 0.198, zhead - height * 0.012),
                          (height * 0.042, height * 0.014, height * 0.053),
                          eye_white, "UV_SPHERE")
                accessory("Warrior_Iris_" + str(side),
                          (x - side * height * 0.005, -height * 0.212, zhead - height * 0.017),
                          (height * 0.023, height * 0.009, height * 0.035),
                          iris, "UV_SPHERE")
                accessory("Warrior_Pupil_" + str(side),
                          (x - side * height * 0.005, -height * 0.221, zhead - height * 0.017),
                          (height * 0.012, height * 0.005, height * 0.023),
                          pupil, "UV_SPHERE")
                brow = accessory("Warrior_Eyebrow_" + str(side),
                          (x, -height * 0.208, zhead + height * 0.065),
                          (height * 0.057, height * 0.012, height * 0.014),
                          hair)
                brow.rotation_euler[1] = side * 0.14
            accessory("Warrior_Nose", (0, -height * 0.201, zhead - height * 0.080),
                      (height * 0.015, height * 0.012, height * 0.012),
                      gold, "UV_SPHERE")
            report["warrior_face_parts"] = 9

            report["warrior_equipment"] = [obj.name for obj in equipment]
        bpy.ops.object.select_all(action="DESELECT")
        variant.select_set(True)
        for obj in equipment:
            obj.select_set(True)
        bpy.context.view_layer.objects.active = variant
        filename = "hero_" + hero_name + "_prototype.glb"
        bpy.ops.export_scene.gltf(
            filepath=str(out / filename), export_format="GLB",
            use_selection=True, export_materials="EXPORT")
        # Independent mobile LOD: keep the detailed hero untouched.
        # Blender's collapse decimator targets approximately 9k body triangles.
        lod_objects = []
        try:
            lod_body = variant.copy()
            lod_body.data = variant.data.copy()
            lod_body.name = "Titan_" + hero_name.title() + "_Mobile_LOD"
            bpy.context.collection.objects.link(lod_body)
            bpy.ops.object.select_all(action="DESELECT")
            lod_body.select_set(True)
            bpy.context.view_layer.objects.active = lod_body
            # Shape keys prevent applying Decimate in Blender. The mobile
            # duplicate is static, so bake the Basis coordinates into its mesh
            # and remove keys ONLY from the duplicate.
            if lod_body.data.shape_keys:
                # Remove non-Basis keys first. Blender requires Basis to be
                # removed last, and shape_key_remove works on the active object.
                while lod_body.data.shape_keys:
                    key = lod_body.data.shape_keys.key_blocks[-1]
                    lod_body.shape_key_remove(key)
            assert lod_body.data.shape_keys is None, "LOD still has shape keys"
            body_triangles = sum(len(p.vertices) - 2 for p in lod_body.data.polygons)
            if body_triangles > 9000:
                modifier = lod_body.modifiers.new("Mobile_LOD_Decimate", "DECIMATE")
                modifier.ratio = min(1.0, 9000.0 / body_triangles)
                bpy.ops.object.modifier_apply(modifier=modifier.name)
            lod_objects.append(lod_body)
            for part in equipment:
                copy = part.copy()
                copy.data = part.data.copy()
                copy.name = part.name + "_LOD"
                bpy.context.collection.objects.link(copy)
                lod_objects.append(copy)
            bpy.ops.object.select_all(action="DESELECT")
            for obj in lod_objects:
                obj.select_set(True)
            bpy.context.view_layer.objects.active = lod_body
            lod_filename = "hero_" + hero_name + "_mobile_lod.glb"
            bpy.ops.export_scene.gltf(
                filepath=str(out / lod_filename), export_format="GLB",
                use_selection=True, export_materials="EXPORT")
            lod_triangles = sum(len(poly.vertices) - 2
                                for obj in lod_objects for poly in obj.data.polygons)
            report.setdefault("mobile_lod", []).append({
                "class": hero_name, "file": lod_filename,
                "triangles": lod_triangles,
                "body_triangles_before": body_triangles,
                "body_triangles_after": sum(len(p.vertices) - 2 for p in lod_body.data.polygons),
                "reduction_percent": round(100.0 * (1.0 - (
                    sum(len(p.vertices) - 2 for p in lod_body.data.polygons)
                    / max(1, body_triangles))), 1),
                "bytes": (out / lod_filename).stat().st_size,
                "note": "Static experimental LOD; inspect silhouettes and facial details",
            })
        finally:
            for obj in lod_objects:
                bpy.data.objects.remove(obj, do_unlink=True)
        # Mobile profiling: record actual exported triangle count and mesh objects.
        # The high-poly MPFB source is a prototype, not an Android-ready LOD.
        hero_triangles = sum(len(poly.vertices) - 2
                             for mesh_obj in [variant] + equipment
                             for poly in mesh_obj.data.polygons)
        hero_mesh_count = len(equipment) + 1
        report.setdefault("mobile_mesh_budget", []).append({
            "class": hero_name,
            "triangles": hero_triangles,
            "mesh_objects": hero_mesh_count,
            "target_triangles": 10000,
            "within_target": hero_triangles <= 10000,
        })
        report["hero_prototypes"].append({
            "class": hero_name, "file": filename,
            "bytes": (out / filename).stat().st_size,
            "note": ("Static armor, shield and sword prototype; full rig pending" if hero_name == "warrior" else "Color-only chibi base prototype; class equipment and full rig pending"),
        })
        if hero_name == "warrior":
            # Render the actual class-specific mesh, not the generic chibi body.
            hidden = {obj.name: obj.hide_render for obj in bpy.data.objects if obj.type == "MESH"}
            try:
                for obj in bpy.data.objects:
                    if obj.type == "MESH":
                        obj.hide_render = obj != variant and obj not in equipment
                camera.location = (center.x, center.y - span * 2.5, center.z)
                camera.rotation_euler = (center - camera.location).to_track_quat("-Z", "Y").to_euler()
                scene.render.filepath = str(out / "hero_warrior_front.png")
                bpy.ops.render.render(write_still=True)
                report["warrior_preview_created"] = (out / "hero_warrior_front.png").stat().st_size > 1024
                camera.location = (center.x + span * 2.5, center.y, center.z)
                camera.rotation_euler = (center - camera.location).to_track_quat("-Z", "Y").to_euler()
                scene.render.filepath = str(out / "hero_warrior_side.png")
                bpy.ops.render.render(write_still=True)
                report["warrior_side_preview_created"] = (out / "hero_warrior_side.png").stat().st_size > 1024
            finally:
                for obj in bpy.data.objects:
                    if obj.type == "MESH" and obj.name in hidden:
                        obj.hide_render = hidden[obj.name]
        bpy.data.objects.remove(variant, do_unlink=True)
        for obj in equipment:
            bpy.data.objects.remove(obj, do_unlink=True)
    bpy.ops.object.select_all(action="DESELECT")
    if bpy.context.object and bpy.context.object.mode != "OBJECT":
        bpy.ops.object.mode_set(mode="OBJECT")
    bpy.ops.object.select_all(action="DESELECT")
    for obj in meshes:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]
    bpy.ops.export_scene.gltf(filepath=str(out / "mpfb_basemesh.glb"),
                              export_format="GLB", use_selection=True)
    report["glb_created"] = (out / "mpfb_basemesh.glb").stat().st_size > 1024
except Exception:
    report["errors"].append(traceback.format_exc())
finally:
    report["objects"] = [o.name for o in bpy.data.objects]
    # Human-readable report for inspecting all ten mobile assets on Android.
    lines = ["# Titan Legends – MPFB Character Build", "",
             "Status: " + ("FAILED" if report.get("errors") else "Generated"),
             "", "| Class | Original triangles | LOD triangles | Body reduction | LOD size |",
             "|---|---:|---:|---:|---:|"]
    originals = {entry["class"]: entry for entry in report.get("mobile_mesh_budget", [])}
    for entry in report.get("mobile_lod", []):
        original = originals.get(entry["class"], {})
        lines.append("| {name} | {before:,} | {after:,} | {pct:.1f}% | {kb:.0f} KB |".format(
            name=entry["class"], before=original.get("triangles", 0),
            after=entry["triangles"], pct=entry.get("reduction_percent", 0),
            kb=entry["bytes"] / 1024))
    lines.extend(["", "LOD models are static prototypes; rigging and visual QA remain pending.",
                  "", "## Errors", ""])
    lines.extend(report.get("errors") or ["None reported"])
    (out / "BUILD_SUMMARY.md").write_text("\\n".join(lines) + "\\n", encoding="utf-8")
    (out / "report.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    print("MPFB_PROBE_REPORT:", json.dumps(report))
required_outputs = (
    "human_created", "glb_created", "chibi_glb_created",
    "rigged_glb_created", "warrior_preview_created",
    "warrior_side_preview_created",
)
if (report.get("errors")
        or any(not report.get(field) for field in required_outputs)
        or len(report.get("hero_prototypes", [])) != 10
        or len(report.get("mobile_lod", [])) != 10):
    raise SystemExit("MPFB humanoid creation/export failed; see uploaded report.json")
