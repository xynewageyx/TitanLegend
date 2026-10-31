"""Isolated Rigify availability probe. Never modifies the production warrior rig."""
import bpy
from pathlib import Path
print("BLENDER_VERSION:", bpy.app.version_string)
try:
    bpy.ops.preferences.addon_enable(module="rigify")
    import rigify
    print("RIGIFY_AVAILABLE:", getattr(rigify, "bl_info", {}).get("version", "yes"))
except Exception as exc:
    print("RIGIFY_UNAVAILABLE:", type(exc).__name__, str(exc))
    raise SystemExit(1)
# Test the rig-generation API, not just whether the add-on can be imported.
try:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    bpy.ops.object.armature_human_metarig_add()
    metarig = bpy.context.object
    assert metarig and metarig.type == "ARMATURE"
    print("RIGIFY_METARIG_BONES:", len(metarig.data.bones))
    bpy.ops.pose.rigify_generate()
    generated = [obj for obj in bpy.data.objects if obj.type == "ARMATURE" and obj != metarig]
    assert generated, "Rigify generated no new armature"
    print("RIGIFY_GENERATED_RIG_BONES:", max(len(obj.data.bones) for obj in generated))
except Exception as exc:
    print("RIGIFY_GENERATION_FAILED:", type(exc).__name__, str(exc))
    raise SystemExit(2)
# Export only the isolated generated rig as a GLB for inspection.
# This is NOT a skinned production character; no existing warrior file is touched.
try:
    output = Path("build/rigify_probe.glb")
    output.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    for obj in generated:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = generated[0]
    bpy.ops.export_scene.gltf(
        filepath=str(output.resolve()),
        export_format="GLB",
        use_selection=True,
        export_animations=False,
    )
    assert output.is_file() and output.stat().st_size > 100, "GLB missing or empty"
    print("RIGIFY_PROBE_GLB_BYTES:", output.stat().st_size)
except Exception as exc:
    print("RIGIFY_EXPORT_FAILED:", type(exc).__name__, str(exc))
    raise SystemExit(3)
print("PRODUCTION_WARRIOR_UNCHANGED: true")
