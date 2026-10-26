extends RefCounted
# Lightweight original creature silhouettes, built once per companion.
# Purely visual: no attacks, collision, timers or damage.
static func decorate(pet: Node3D, element: int, species: int) -> void:
 var palette: Array[Color] = [
  Color("#f27d43"), Color("#54bce2"), Color("#ae966d"),
  Color("#72c46c"), Color("#f3d87b"), Color("#9876cf"),
  Color("#8ddce0"), Color("#b1e7f0"), Color("#6b9cf0"), Color("#db70bc")
 ]
 var tint: Color = palette[clampi(element, 0, 9)]
 var body: MeshInstance3D = VisualFactory.sphere(pet, 0.33, Vector3(0, 0.43, 0.10), tint)
 body.scale = Vector3(0.94, 0.82, 1.38)
 var muzzle: MeshInstance3D = VisualFactory.sphere(pet, 0.20, Vector3(0, 0.69, -0.29), tint.lightened(0.24))
 muzzle.scale = Vector3(1.05, 0.68, 1.45)
 for side in [-1.0, 1.0]:
  var foot: MeshInstance3D = VisualFactory.sphere(pet, 0.13, Vector3(side * 0.24, 0.15, -0.13), tint.darkened(0.22))
  foot.scale = Vector3(1.1, 0.68, 1.35)
  var horn: MeshInstance3D = VisualFactory.cylinder(pet, 0.34, 0.105, Vector3(side * 0.20, 0.99, 0.04), tint.lightened(0.35))
  horn.rotation.z = side * 0.32
  VisualFactory.sphere(pet, 0.048, Vector3(side * 0.11, 0.78, -0.46), Color("#16242c"))
 var tail: MeshInstance3D = VisualFactory.sphere(pet, 0.19, Vector3(0, 0.46, 0.53), tint.darkened(0.14))
 tail.scale = Vector3(0.65, 0.65, 1.85)
 # Elemental dorsal crests are silhouettes rather than active skills.
 for i in range(3):
  var crest: MeshInstance3D = VisualFactory.sphere(pet, 0.14 - float(i) * 0.02, Vector3(0, 0.80 - float(i) * 0.10, 0.24 + float(i) * 0.20), tint.lightened(0.4))
  crest.scale = Vector3(0.62, 1.5, 0.60)
 # Distinct animal profiles: fox, turtle, stag, owl and drake families.
 # All anatomy is static geometry; elemental affinity remains passive.
 match clampi(species, 0, 4):
  0: # Fox: pointed ears, long snout and a full tail.
   for side in [-1.0, 1.0]:
    var ear := VisualFactory.cylinder(pet, 0.38, 0.13, Vector3(side * 0.22, 1.12, -0.19), tint.darkened(0.12))
    ear.rotation.z = side * 0.25
   var fox_tail := VisualFactory.sphere(pet, 0.25, Vector3(0.0, 0.58, 0.70), tint.lightened(0.20))
   fox_tail.scale = Vector3(0.78, 0.84, 1.7)
  1: # Turtle: low oval shell and four visible feet.
   var shell := VisualFactory.sphere(pet, 0.43, Vector3(0, 0.52, 0.18), tint.darkened(0.28))
   shell.scale = Vector3(1.25, 0.55, 1.22)
   for side in [-1.0, 1.0]:
    VisualFactory.sphere(pet, 0.14, Vector3(side * 0.34, 0.15, 0.43), tint)
  2: # Stag: forked antlers and narrow muzzle.
   for side in [-1.0, 1.0]:
    var antler := VisualFactory.cylinder(pet, 0.53, 0.065, Vector3(side * 0.24, 1.23, -0.08), tint.lightened(0.38))
    antler.rotation.z = side * 0.38
    var branch := VisualFactory.cylinder(pet, 0.24, 0.048, Vector3(side * 0.40, 1.36, -0.08), tint.lightened(0.38))
    branch.rotation.z = -side * 0.48
  3: # Owl: round facial disk, wings and feather tufts.
   for side in [-1.0, 1.0]:
    var wing := VisualFactory.sphere(pet, 0.25, Vector3(side * 0.33, 0.55, 0.13), tint.darkened(0.18))
    wing.scale = Vector3(0.52, 1.3, 0.82)
    VisualFactory.sphere(pet, 0.16, Vector3(side * 0.14, 0.80, -0.35), tint.lightened(0.44))
    VisualFactory.sphere(pet, 0.07, Vector3(side * 0.14, 0.81, -0.47), Color("#1c2731"))
   var beak := VisualFactory.sphere(pet, 0.10, Vector3(0, 0.66, -0.48), Color("#e5ba67"))
   beak.scale = Vector3(0.64, 1.18, 1.1)
  4: # Drake: broad side wings and a ridged tail.
   for side in [-1.0, 1.0]:
    var wing := VisualFactory.sphere(pet, 0.32, Vector3(side * 0.43, 0.65, 0.19), tint.darkened(0.24))
    wing.scale = Vector3(1.45, 0.24, 0.95)
    wing.rotation.z = side * 0.23
   for ridge in range(3):
    var spine := VisualFactory.cylinder(pet, 0.20, 0.09, Vector3(0, 0.89, 0.34 + float(ridge) * 0.19), tint.lightened(0.36))
    spine.rotation.x = -0.30
