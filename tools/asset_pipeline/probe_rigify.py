"""Isolated Rigify availability probe. Never modifies the production warrior rig."""
import bpy
import importlib.util
print("BLENDER_VERSION:", bpy.app.version_string)
try:
    bpy.ops.preferences.addon_enable(module="rigify")
    import rigify
    print("RIGIFY_AVAILABLE:", getattr(rigify, "bl_info", {}).get("version", "yes"))
except Exception as exc:
    print("RIGIFY_UNAVAILABLE:", type(exc).__name__, str(exc))
    raise SystemExit(1)
print("PRODUCTION_WARRIOR_UNCHANGED: true")
