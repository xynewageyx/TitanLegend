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
    (out / "report.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    print("MPFB_PROBE_REPORT:", json.dumps(report))
if not report["human_created"] or not report.get("glb_created") or not report.get("chibi_glb_created") or not report.get("rigged_glb_created"):
    raise SystemExit("MPFB humanoid creation/export failed; see uploaded report.json")
