extends RefCounted
# Lightweight original creature silhouettes, built once per companion.
# Purely visual: no attacks, collision, timers or damage.
static func decorate(pet: Node3D, element: int, slot: int) -> void:
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
 if slot % 2 == 1:
  muzzle.scale.x *= 1.12
