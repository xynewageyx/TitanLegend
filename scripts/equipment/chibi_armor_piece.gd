extends Node3D
## Small local-space armor piece, designed for socket attachment on chibi heroes.
@export_enum("HeadSocket","ChestSocket","BackSocket","ShoulderLeftSocket","ShoulderRightSocket","ArmLeftSocket","ArmRightSocket","GloveLeftSocket","GloveRightSocket","LegLeftSocket","LegRightSocket","BootLeftSocket","BootRightSocket") var slot_index: int = 0
@export_range(0,5) var rarity: int = 0
@export_range(0,10) var class_id: int = 0
const COLORS := [Color("#9aa2ae"),Color("#65c46b"),Color("#4b9eff"),Color("#f5ca55"),Color("#f18a3b"),Color("#b878f8")]
const CLASS_ACCENTS := [Color("#a8b4c7"), Color("#e7c96b"), Color("#7f9c75"), Color("#b1a47e"), Color("#91a8e9"), Color("#e5d3a6"), Color("#9ebfba"), Color("#83bd7c"), Color("#b08bc9"), Color("#bda6df"), Color("#c7a18a")]
const SIZES := [Vector3(0.58,0.30,0.57),Vector3(0.66,0.55,0.41),Vector3(0.46,0.55,0.10),Vector3(0.30,0.22,0.35),Vector3(0.30,0.22,0.35),Vector3(0.20,0.32,0.23),Vector3(0.20,0.32,0.23),Vector3(0.23,0.20,0.24),Vector3(0.23,0.20,0.24),Vector3(0.25,0.42,0.28),Vector3(0.25,0.42,0.28),Vector3(0.30,0.22,0.39),Vector3(0.30,0.22,0.39)]
func _ready() -> void:
    var mesh := SphereMesh.new()
    mesh.radius = 0.5
    mesh.height = 1.0
    mesh.radial_segments = 12
    mesh.rings = 6
    var piece := MeshInstance3D.new()
    piece.mesh = mesh
    piece.scale = SIZES[slot_index] * (1.0 + float(rarity)*0.055)
    var mat := StandardMaterial3D.new()
    mat.albedo_color = _class_tinted_color()
    mat.roughness = 0.5
    mat.metallic = 0.2
    if rarity >= 4:
        mat.emission_enabled = true
        mat.emission = COLORS[rarity]
        mat.emission_energy_multiplier = 0.35
    piece.material_override = mat
    add_child(piece)
    _add_rarity_details()

## Add silhouette-defining original primitive details; keep FX optional on low-end.
func _add_rarity_details() -> void:
    if rarity < 1:
        return
    var accent: Color = _class_tinted_color()
    var width: float = SIZES[slot_index].x
    if rarity >= 2:
        _detail(Vector3(0, 0.08, 0.17), Vector3(width * 0.6, 0.14, 0.12), accent, false)
    if rarity >= 3 and slot_index in [0, 3, 4, 5, 6]:
        for side in [-1.0, 1.0]:
            var horn := MeshInstance3D.new()
            var mesh := CylinderMesh.new()
            mesh.top_radius = 0.0
            mesh.bottom_radius = 0.11
            mesh.height = 0.38 + 0.09 * float(rarity - 3)
            horn.mesh = mesh
            horn.position = Vector3(side * width * 0.55, 0.22, 0)
            horn.rotation.z = -side * 0.4
            var mat := StandardMaterial3D.new()
            mat.albedo_color = accent
            horn.material_override = mat
            add_child(horn)
    if rarity >= 4:
        _detail(Vector3(0, 0.0, 0.24), Vector3(width * 0.5, 0.22, 0.12), accent, true)
    if rarity >= 5 and slot_index in [0, 1, 2, 3, 4]:
        for side in [-1.0, 1.0]:
            _detail(Vector3(side * width * 0.75, 0.32, 0), Vector3(0.14, 0.32, 0.16), accent, true)

func _detail(pos: Vector3, size: Vector3, color: Color, glow: bool) -> void:
    var item := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    item.mesh = mesh
    item.position = pos
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    if glow:
        mat.emission_enabled = true
        mat.emission = color
        mat.emission_energy_multiplier = 0.35
    item.material_override = mat
    add_child(item)

## Class accent makes otherwise similar rarity tiers easier to identify in combat.
## The rarity hue remains dominant; class accents influence only 22% of color.
func _class_tinted_color() -> Color:
    var rarity_color: Color = COLORS[clampi(rarity, 0, 5)]
    var class_color: Color = CLASS_ACCENTS[clampi(class_id, 0, 10)]
    return rarity_color.lerp(class_color, 0.22)
