extends RefCounted
## Original chibi-fantasy face polish. Cosmetic only; no combat or role changes.
static func _orb(parent: Node3D, name_value: String, radius: float, pos: Vector3, tint: Color, shape: Vector3) -> MeshInstance3D:
 var mesh: MeshInstance3D = MeshInstance3D.new()
 mesh.name = name_value
 var sphere_mesh: SphereMesh = SphereMesh.new()
 sphere_mesh.radius = radius
 sphere_mesh.height = radius * 2.0
 sphere_mesh.radial_segments = 16
 sphere_mesh.rings = 10
 mesh.mesh = sphere_mesh
 mesh.position = pos
 mesh.scale = shape
 var material: StandardMaterial3D = StandardMaterial3D.new()
 material.albedo_color = tint
 material.roughness = 0.78
 mesh.material_override = material
 parent.add_child(mesh)
 return mesh

static func decorate(hero: Node3D, class_id: int, slot: int) -> void:
 var face: Node3D = Node3D.new()
 face.name = "StorybookFace"
 hero.add_child(face)
 var iris_colors: Array[Color] = [
  Color("#4d83b9"), Color("#a98034"), Color("#3eaa6b"),
  Color("#56a8b7"), Color("#6c9d42"), Color("#9c69b7"),
  Color("#557bd9"), Color("#a45dc7"), Color("#c48fcb"),
  Color("#5ca7a1"), Color("#b87942")
 ]
 var iris: Color = iris_colors[clampi(class_id, 0, iris_colors.size() - 1)]
 var eye_spacing: float = 0.115 + 0.005 * float(slot % 2)
 for side in [-1.0, 1.0]:
  var x: float = side * eye_spacing
  _orb(face, "EyeWhite", 0.080, Vector3(x, 1.965, -0.281), Color("#fff7eb"), Vector3(0.91, 1.14, 0.45))
  _orb(face, "Iris", 0.056, Vector3(x, 1.960, -0.321), iris, Vector3(0.87, 1.12, 0.45))
  _orb(face, "Pupil", 0.035, Vector3(x, 1.956, -0.345), Color("#162131"), Vector3(0.92, 1.14, 0.42))
  _orb(face, "EyeGlint", 0.018, Vector3(x - 0.016, 1.985, -0.360), Color("#ffffff"), Vector3(0.90, 1.0, 0.45))
  _orb(face, "Cheek", 0.052, Vector3(side * 0.232, 1.867, -0.236), Color("#ed9e91"), Vector3(1.10, 0.53, 0.38))
 _orb(face, "TinyNose", 0.021, Vector3(0, 1.873, -0.302), Color("#d58d78"), Vector3(0.90, 0.75, 0.60))
 _orb(face, "Smile", 0.031, Vector3(0, 1.828, -0.294), Color("#8b4f53"), Vector3(1.25, 0.33, 0.40))
