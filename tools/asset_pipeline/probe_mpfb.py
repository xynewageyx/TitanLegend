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
if not report["human_created"] or not report.get("glb_created"):
    raise SystemExit("MPFB humanoid creation/export failed; see uploaded report.json")
