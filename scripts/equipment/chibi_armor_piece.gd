extends Node3D
## Small local-space armor piece, designed for socket attachment on chibi heroes.
@export_enum("HeadSocket","ChestSocket","BackSocket","ShoulderLeftSocket","ShoulderRightSocket","ArmLeftSocket","ArmRightSocket","GloveLeftSocket","GloveRightSocket","LegLeftSocket","LegRightSocket","BootLeftSocket","BootRightSocket") var slot_index: int = 0
@export_range(0,5) var rarity: int = 0
@export_range(0,10) var class_id: int = 0
const COLORS := [Color("#9aa2ae"),Color("#65c46b"),Color("#4b9eff"),Color("#f5ca55"),Color("#f18a3b"),Color("#b878f8")]
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
    mat.albedo_color = COLORS[rarity]
    mat.roughness = 0.5
    mat.metallic = 0.2
    if rarity >= 4:
        mat.emission_enabled = true
        mat.emission = COLORS[rarity]
        mat.emission_energy_multiplier = 0.35
    piece.material_override = mat
    add_child(piece)
