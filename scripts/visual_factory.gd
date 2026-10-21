class_name VisualFactory
extends RefCounted
static func material(color: Color) -> StandardMaterial3D:
 var mat: StandardMaterial3D = StandardMaterial3D.new()
 mat.albedo_color = color
 mat.roughness = 0.85
 return mat
static func box(parent: Node3D, size: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
 var mesh: BoxMesh = BoxMesh.new()
 mesh.size = size
 var obj: MeshInstance3D = MeshInstance3D.new()
 obj.mesh = mesh
 obj.material_override = material(color)
 obj.position = at
 parent.add_child(obj)
 return obj
static func sphere(parent: Node3D, radius: float, at: Vector3, color: Color) -> MeshInstance3D:
 var mesh: SphereMesh = SphereMesh.new()
 mesh.radius = radius
 mesh.height = radius * 2.0
 var obj: MeshInstance3D = MeshInstance3D.new()
 obj.mesh = mesh
 obj.material_override = material(color)
 obj.position = at
 parent.add_child(obj)
 return obj
static func cylinder(parent: Node3D, height: float, radius: float, at: Vector3, color: Color) -> MeshInstance3D:
 var mesh: CylinderMesh = CylinderMesh.new()
 mesh.height = height
 mesh.top_radius = radius * 0.75
 mesh.bottom_radius = radius
 var obj: MeshInstance3D = MeshInstance3D.new()
 obj.mesh = mesh
 obj.material_override = material(color)
 obj.position = at
 parent.add_child(obj)
 return obj
