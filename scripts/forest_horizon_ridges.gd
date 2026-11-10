extends RefCounted
# Original low-poly distant forest ridges. Cosmetic only: no physics or imported assets.
# One combined vertex-colored mesh keeps the distant terrain cheap on Android.
static func create(parent: Node3D) -> void:
 var surface := SurfaceTool.new()
 surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 var rng := RandomNumberGenerator.new()
 rng.seed = 20261110
 var segments: int = 32
 var z_min: float = -111.0
 var z_length: float = 143.0
 for side in [-1.0, 1.0]:
  var previous: Array[Vector3] = []
  for i in range(segments + 1):
   var z: float = z_min + z_length * float(i) / float(segments)
   var ridge_height: float = 1.9 + sin(float(i) * 0.48 + side) * 0.68 + rng.randf_range(-0.3, 0.3)
   var row: Array[Vector3] = [
    Vector3(side * 11.8, -0.1, z),
    Vector3(side * 17.2, ridge_height, z),
    Vector3(side * 23.5, -0.12, z)
   ]
   if i > 0:
    for band in range(2):
     var color_a := Color("#456b49") if band == 0 else Color("#304f3a")
     var color_b := Color("#5f8154") if band == 0 else Color("#3a6146")
     if side < 0.0:
      _triangle(surface, previous[band], row[band], previous[band + 1], color_a)
      _triangle(surface, row[band], row[band + 1], previous[band + 1], color_b)
     else:
      _triangle(surface, previous[band + 1], row[band], previous[band], color_a)
      _triangle(surface, previous[band + 1], row[band + 1], row[band], color_b)
   previous = row
 surface.generate_normals()
 var ridge := MeshInstance3D.new()
 ridge.name = "ForestHorizonRidges"
 ridge.mesh = surface.commit()
 var material := StandardMaterial3D.new()
 material.vertex_color_use_as_albedo = true
 material.roughness = 1.0
 material.cull_mode = BaseMaterial3D.CULL_DISABLED
 ridge.material_override = material
 parent.add_child(ridge)

static func _triangle(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, tint: Color) -> void:
 surface.set_color(tint)
 surface.add_vertex(a)
 surface.set_color(tint)
 surface.add_vertex(b)
 surface.set_color(tint)
 surface.add_vertex(c)
