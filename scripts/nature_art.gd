class_name NatureArt
extends RefCounted
# Procedural, lightweight Android-friendly silhouettes. No external assets.
static func mob(parent: Node3D, variant: int) -> void:
 var bark := Color("#4d392c")
 var leaf := Color("#4a9b50")
 if variant % 3 == 0: # Forest wolf: snout, ears, tail
  VisualFactory.box(parent, Vector3(0.75, 0.35, 0.95), Vector3(0, 0.57, 0.18), Color("#687d59"))
  VisualFactory.box(parent, Vector3(0.4, 0.28, 0.55), Vector3(0, 0.7, -0.56), Color("#899c72"))
  for side in [-1.0, 1.0]:
   VisualFactory.box(parent, Vector3(0.18, 0.4, 0.18), Vector3(side * 0.27, 1.17, -0.34), bark)
  VisualFactory.box(parent, Vector3(0.2, 0.2, 0.65), Vector3(0, 0.82, 0.87), leaf)
 elif variant % 3 == 1: # Living stump: crown, roots
  VisualFactory.cylinder(parent, 1.1, 0.42, Vector3(0, 0.8, 0), bark)
  for side in [-1.0, 1.0]:
   VisualFactory.box(parent, Vector3(0.48, 0.2, 0.25), Vector3(side * 0.52, 0.2, 0), bark)
  VisualFactory.sphere(parent, 0.62, Vector3(0, 1.6, 0), leaf)
 else: # Thorn creature
  for side in [-1.0, 1.0]:
   var thorn := VisualFactory.cylinder(parent, 0.9, 0.16, Vector3(side * 0.48, 1.2, 0), Color("#8eac55"))
   thorn.rotation.z = side * 0.55
  VisualFactory.sphere(parent, 0.3, Vector3(0, 1.42, 0), Color("#c5db73"))

static func titan(parent: Node3D) -> void:
 # The Ancient Grove Guardian: bark armor, branching antlers and bright nature core.
 var bark := Color("#48382d")
 var moss := Color("#41794a")
 var glow := Color("#b8f27c")
 VisualFactory.cylinder(parent, 3.7, 1.0, Vector3(0, 2.1, 0), bark)
 VisualFactory.sphere(parent, 1.18, Vector3(0, 4.3, 0), moss)
 VisualFactory.sphere(parent, 0.55, Vector3(0, 2.9, -1.65), glow)
 for side in [-1.0, 1.0]:
  var antler := VisualFactory.cylinder(parent, 2.2, 0.24, Vector3(side * 0.92, 5.75, 0), bark)
  antler.rotation.z = side * 0.45
  VisualFactory.sphere(parent, 0.56, Vector3(side * 1.6, 6.5, 0), moss)
  VisualFactory.box(parent, Vector3(0.8, 1.5, 0.95), Vector3(side * 2.05, 2.25, 0), bark)
  VisualFactory.sphere(parent, 0.37, Vector3(side * 0.5, 4.4, -0.94), glow)

static func forest(parent: Node3D) -> void:
 # Decoration deliberately outside the walkable central corridor.
 var rng := RandomNumberGenerator.new()
 rng.seed = 20261020
 for i in range(28):
  var side := -1.0 if i % 2 == 0 else 1.0
  var x := side * rng.randf_range(4.6, 14.0)
  var z := rng.randf_range(-39.0, 13.0)
  var grass := VisualFactory.cylinder(parent, rng.randf_range(0.3, 0.75), 0.12, Vector3(x, 0.25, z), Color("#62a44d"))
  grass.rotation.z = rng.randf_range(-0.3, 0.3)
  if i % 4 == 0:
   VisualFactory.sphere(parent, 0.22, Vector3(x + 0.3, 0.35, z), Color("#f2c969"))
  if i % 7 == 0:
   VisualFactory.box(parent, Vector3(0.8, 0.18, 0.75), Vector3(x - 0.7, 0.07, z + 0.6), Color("#817963"))
