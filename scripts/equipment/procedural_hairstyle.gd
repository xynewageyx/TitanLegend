extends Node3D
## Original procedural stylized hairstyle for Titan Legends.
## Attach under HeadSocket; no third-party game assets.
@export_range(0, 2) var style: int = 0
@export var hair_color: Color = Color("#694333")

func _ready() -> void:
    _build()

func _piece(position: Vector3, size: Vector3, color: Color) -> void:
    var mesh := SphereMesh.new()
    mesh.radius = 0.5
    mesh.height = 1.0
    mesh.radial_segments = 12
    mesh.rings = 8
    var part := MeshInstance3D.new()
    part.mesh = mesh
    part.position = position
    part.scale = size
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.85
    part.material_override = material
    add_child(part)

func _build() -> void:
    _piece(Vector3(0.0, 0.18, 0.0), Vector3(0.66, 0.30, 0.60), hair_color)
    match style:
        0:
            for i in range(5):
                var x := (float(i) - 2.0) * 0.12
                _piece(Vector3(x, 0.12, -0.27), Vector3(0.14, 0.24, 0.15), hair_color)
        1:
            for side in [-1.0, 1.0]:
                _piece(Vector3(side * 0.30, -0.04, 0.03), Vector3(0.18, 0.50, 0.22), hair_color)
            _piece(Vector3(0.0, 0.32, 0.12), Vector3(0.35, 0.36, 0.35), hair_color)
        2:
            for i in range(7):
                var angle := TAU * float(i) / 7.0
                _piece(Vector3(cos(angle) * 0.24, 0.31, sin(angle) * 0.22), Vector3(0.20, 0.28, 0.20), hair_color)
