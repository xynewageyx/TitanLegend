extends RefCounted
# Single draw-call-friendly forest trail with irregular edges and subtle soil tones.
# Geometry only; gameplay still uses the existing straight formation route.
static func create(parent: Node3D) -> void:
 var rng := RandomNumberGenerator.new()
 rng.seed = 20261029
 var surface := SurfaceTool.new()
 surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 var strips: int = 48
 var length: float = 160.0
 var z_start: float = -116.0
 var prev_left := Vector3.ZERO
 var prev_right := Vector3.ZERO
 var prev_tint := Color("#927d61")
 for i in range(strips + 1):
  var z: float = z_start + length * float(i) / float(strips)
  var center: float = sin(float(i) * 0.31) * 0.13
  var width: float = 3.5 + sin(float(i) * 0.71) * 0.22 + rng.randf_range(-0.12, 0.12)
  var left := Vector3(center - width, -0.038, z)
  var right := Vector3(center + width, -0.038, z)
  var tint: Color = Color("#a18a68").lerp(Color("#77654d"), rng.randf_range(0.05, 0.6))
  if i > 0:
   _triangle(surface, prev_left, prev_right, left, prev_tint, tint)
   _triangle(surface, left, prev_right, right, tint, prev_tint)
  prev_left = left
  prev_right = right
  prev_tint = tint
 surface.generate_normals()
 var trail := MeshInstance3D.new()
 trail.name = "OrganicForestTrail"
 trail.mesh = surface.commit()
 var material := StandardMaterial3D.new()
 material.vertex_color_use_as_albedo = true
 material.roughness = 0.96
 trail.material_override = material
 parent.add_child(trail)

static func _triangle(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, tint_a: Color, tint_b: Color) -> void:
 surface.set_color(tint_a)
 surface.add_vertex(a)
 surface.set_color(tint_a)
 surface.add_vertex(b)
 surface.set_color(tint_b)
 surface.add_vertex(c)
