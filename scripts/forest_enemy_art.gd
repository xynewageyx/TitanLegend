extends RefCounted
# Three distinct woodland enemies; visual-only meshes built at spawn time.
static func decorate(mob: Node3D, variant: int, tint: Color) -> void:
 var bark := Color("#694b34")
 match variant:
  0: # Rootling: tall walking stump with roots and leafy branching crown.
   var trunk := VisualFactory.cylinder(mob, 1.25, 0.31, Vector3(0, 0.76, 0), bark)
   trunk.scale.z = 0.82
   for side in [-1.0, 1.0]:
    var root := VisualFactory.cylinder(mob, 0.62, 0.14, Vector3(side * 0.29, 0.31, 0.06), bark.darkened(0.15))
    root.rotation.z = side * 0.35
    var branch := VisualFactory.cylinder(mob, 0.88, 0.095, Vector3(side * 0.44, 1.15, 0), bark)
    branch.rotation.z = -side * 0.55
    VisualFactory.sphere(mob, 0.27, Vector3(side * 0.56, 1.56, 0.02), tint.lightened(0.24))
   var crown := VisualFactory.sphere(mob, 0.49, Vector3(0, 1.63, 0), tint.lightened(0.13))
   crown.scale = Vector3(1.16, 0.73, 0.9)
   _eyes(mob, 1.17, -0.29, 0.18, Color("#f7db82"))
  1: # Moss fox: low quadruped, ears, snout and large sweeping tail.
   var body := VisualFactory.sphere(mob, 0.45, Vector3(0, 0.56, 0.10), tint.lightened(0.14))
   body.scale = Vector3(0.83, 0.65, 1.58)
   var head := VisualFactory.sphere(mob, 0.34, Vector3(0, 0.84, -0.46), Color("#86c98b"))
   head.scale = Vector3(0.95, 0.82, 1.08)
   var snout := VisualFactory.sphere(mob, 0.17, Vector3(0, 0.71, -0.78), Color("#c5e3aa"))
   snout.scale.z = 1.4
   for side in [-1.0, 1.0]:
    var ear := VisualFactory.cylinder(mob, 0.40, 0.115, Vector3(side * 0.21, 1.22, -0.48), tint)
    ear.rotation.z = side * 0.18
    for z in [-0.23, 0.40]:
     var paw := VisualFactory.sphere(mob, 0.15, Vector3(side * 0.29, 0.17, z), tint.darkened(0.2))
     paw.scale.y = 0.8
   var tail := VisualFactory.sphere(mob, 0.29, Vector3(0, 0.78, 0.85), tint.lightened(0.28))
   tail.scale = Vector3(0.77, 0.85, 1.72)
   _eyes(mob, 0.88, -0.74, 0.15, Color("#22362b"))
  2: # Thorn beetle: armored shell, six legs and three dorsal spikes.
   var shell := VisualFactory.sphere(mob, 0.60, Vector3(0, 0.64, 0.05), Color("#447d46"))
   shell.scale = Vector3(1.08, 0.66, 1.25)
   var carapace := VisualFactory.sphere(mob, 0.48, Vector3(0, 0.88, 0.06), tint.darkened(0.22))
   carapace.scale = Vector3(0.94, 0.50, 1.12)
   for side in [-1.0, 1.0]:
    for n in range(3):
     var leg := VisualFactory.cylinder(mob, 0.54, 0.105, Vector3(side * 0.53, 0.37, -0.35 + float(n) * 0.38), bark)
     leg.rotation.z = side * 0.85
   for n in range(3):
    var thorn := VisualFactory.cylinder(mob, 0.39, 0.13, Vector3(0, 1.17, -0.37 + float(n) * 0.37), Color("#b5d67a"))
    thorn.rotation.x = -0.2
   _eyes(mob, 0.72, -0.57, 0.23, Color("#ffe3a2"))

static func _eyes(mob: Node3D, height: float, depth: float, spacing: float, color: Color) -> void:
 for side in [-1.0, 1.0]:
  var eye := VisualFactory.sphere(mob, 0.075, Vector3(side * spacing, height, depth), color)
  eye.scale.z = 0.55
