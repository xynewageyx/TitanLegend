extends RefCounted
# Original stylized fantasy costume silhouettes; built once per hero.
# Purely cosmetic, with no physics or combat changes.
static func _taper(parent: Node3D, height: float, bottom: float, top: float, at: Vector3, color: Color) -> MeshInstance3D:
 var mesh := CylinderMesh.new()
 mesh.height = height
 mesh.bottom_radius = bottom
 mesh.top_radius = top
 mesh.radial_segments = 7
 var part := MeshInstance3D.new()
 part.mesh = mesh
 part.material_override = VisualFactory.material(color)
 part.position = at
 parent.add_child(part)
 return part

static func decorate(hero: Node3D, class_id: int, role_id: int, slot: int) -> void:
 var cloth: Color = Color("#345b86") if class_id in [6, 8] else (Color("#547a46") if class_id in [2, 4] else Color("#644d79"))
 var trim: Color = Color("#f2c970") if role_id == 2 else Color("#c4d0d7")
 # Shaped tunic and lower costume: more readable than a spherical torso alone.
 var coat := _taper(hero, 0.83, 0.57, 0.35, Vector3(0, 0.78, 0.03), cloth)
 coat.scale.z = 0.77
 for side in [-1.0, 1.0]:
  var sleeve := _taper(hero, 0.56, 0.17, 0.22, Vector3(side * 0.56, 1.24, 0), cloth.lightened(0.12))
  sleeve.rotation.z = side * 0.20
  _taper(hero, 0.39, 0.19, 0.16, Vector3(side * 0.23, 0.28, -0.03), cloth.darkened(0.24))
 # Class-specific headwear gives recognisable silhouettes from behind.
 match class_id:
  0, 1:
   var helm := _taper(hero, 0.42, 0.34, 0.23, Vector3(0, 2.15, 0), trim)
   helm.scale.z = 0.92
   for side in [-1.0, 1.0]:
    var crest := _taper(hero, 0.38, 0.10, 0.015, Vector3(side * 0.31, 2.31, 0), trim.lightened(0.12))
    crest.rotation.z = side * 0.35
  2, 3:
   var hood := _taper(hero, 0.58, 0.34, 0.015, Vector3(0, 2.23, 0.07), cloth)
   hood.scale.z = 1.05
  4, 5:
   var cowl := _taper(hero, 0.29, 0.35, 0.30, Vector3(0, 2.17, 0.04), cloth.darkened(0.2))
   cowl.scale.z = 0.92
  6, 7, 8:
   var hat := _taper(hero, 0.72, 0.36, 0.015, Vector3(0, 2.37, 0), cloth)
   hat.scale.z = 0.86
   VisualFactory.cylinder(hero, 0.06, 0.43, Vector3(0, 2.06, 0), trim)
  9:
   var crown := _taper(hero, 0.40, 0.32, 0.21, Vector3(0, 2.25, 0), Color("#f3e4c4"))
   crown.scale.z = 0.90
  10:
   for side in [-1.0, 1.0]:
    VisualFactory.sphere(hero, 0.17, Vector3(side * 0.37, 2.10, 0), cloth.darkened(0.35))
 # Small class emblem on the back, visible in the third-person camera.
 var emblem := VisualFactory.sphere(hero, 0.13, Vector3(0, 1.48, 0.47), trim)
 emblem.scale = Vector3(1.0, 1.25, 0.32)
