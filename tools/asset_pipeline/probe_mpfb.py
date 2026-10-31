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
    sys.path.insert(0, str(src))
    import mpfb
    report["mpfb_module"] = str(mpfb.__file__)
    mpfb.register()
    report["registration"] = True
    # Discover the available operators rather than guessing unstable API names.
    report["mpfb_operators"] = sorted(
        name for name in dir(bpy.ops) if "mpfb" in name.lower() or "makehuman" in name.lower()
    )
    report["registered_classes"] = sorted(
        cls.__name__ for cls in bpy.types.Operator.__subclasses__()
        if "mpfb" in cls.__module__.lower()
    )[:150]
    # A reliable humanoid creation API requires a separate validated integration.
    # Never claim that a registered addon already generated a skinned GLB.
except Exception:
    report["errors"].append(traceback.format_exc())
finally:
    report["objects"] = [o.name for o in bpy.data.objects]
    (out / "report.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    print("MPFB_PROBE_REPORT:", json.dumps(report))
if not report["registration"]:
    raise SystemExit("MPFB registration failed; see uploaded report.json")
