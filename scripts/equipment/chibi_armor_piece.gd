extends Node3D
## Original layered cartoon armor; local geometry follows existing animated sockets.
## Each rarity tier changes silhouette progressively without third-party assets.
@export_enum("HeadSocket","ChestSocket","BackSocket","ShoulderLeftSocket","ShoulderRightSocket","ArmLeftSocket","ArmRightSocket","GloveLeftSocket","GloveRightSocket","LegLeftSocket","LegRightSocket","BootLeftSocket","BootRightSocket") var slot_index: int = 0
@export_range(0,5) var rarity: int = 0
@export_range(0,11) var class_id: int = 0

const COLORS := [Color("#9aa2ae"),Color("#65c46b"),Color("#4b9eff"),Color("#f5ca55"),Color("#f18a3b"),Color("#b878f8")]
const SIZES := [Vector3(0.58,0.30,0.57),Vector3(0.66,0.55,0.41),Vector3(0.46,0.55,0.10),Vector3(0.30,0.22,0.35),Vector3(0.30,0.22,0.35),Vector3(0.20,0.32,0.23),Vector3(0.20,0.32,0.23),Vector3(0.23,0.20,0.24),Vector3(0.23,0.20,0.24),Vector3(0.25,0.42,0.28),Vector3(0.25,0.42,0.28),Vector3(0.30,0.22,0.39),Vector3(0.30,0.22,0.39)]

func _material(color: Color, metallic: float = 0.2) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.48
    mat.metallic = metallic
    if rarity >= 4:
        mat.emission_enabled = true
        mat.emission = color * 0.25
        mat.emission_energy_multiplier = 0.22
    return mat

func _box(pos: Vector3, size: Vector3, color: Color) -> void:
    var node := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.position = pos
    node.material_override = _material(color)
    add_child(node)

func _rounded(pos: Vector3, size: Vector3, color: Color) -> void:
    var node := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = 0.5
    mesh.height = 1.0
    mesh.radial_segments = 16
    mesh.rings = 8
    node.mesh = mesh
    node.position = pos
    node.scale = size
    node.material_override = _material(color)
    add_child(node)

func _ready() -> void:
    var scale_factor := 1.0 + float(rarity) * 0.055
    var base_size: Vector3 = SIZES[clampi(slot_index, 0, SIZES.size() - 1)] * scale_factor
    var primary: Color = COLORS[clampi(rarity, 0, COLORS.size() - 1)]
    var shadow: Color = primary.darkened(0.32)
    var trim: Color = Color("#d8c49a") if class_id % 3 == 0 else Color("#d3dce6")
    # Distinct layered silhouettes replace the former single ellipsoid.
    match slot_index:
        0: # Helmet: crown, brow, and crest
            _rounded(Vector3.ZERO, base_size, primary)
            _box(Vector3(0, -0.09, -0.26), Vector3(0.56, 0.09, 0.13), shadow)
            _box(Vector3(0, 0.20, 0), Vector3(0.11, 0.22, 0.42), trim)
        1: # Chest: breastplate, side plates, and central emblem
            _rounded(Vector3.ZERO, base_size, primary)
            _box(Vector3(0, -0.19, -0.19), Vector3(0.47, 0.12, 0.10), shadow)
            _box(Vector3(0, 0.04, -0.22), Vector3(0.13, 0.31, 0.08), trim)
        2: # Cape/backplate
            _box(Vector3(0, -0.09, 0), base_size, shadow)
            _box(Vector3(0, 0.15, -0.02), Vector3(0.43, 0.10, 0.16), trim)
        3, 4: # Shoulder pauldrons
            _rounded(Vector3.ZERO, base_size, primary)
            _box(Vector3(0, -0.09, -0.10), Vector3(0.28, 0.08, 0.26), trim)
        5, 6, 9, 10: # Segmented arm/leg plates
            _rounded(Vector3.ZERO, base_size, primary)
            _box(Vector3(0, 0.10, -0.12), Vector3(0.19, 0.07, 0.09), trim)
            _box(Vector3(0, -0.12, -0.12), Vector3(0.19, 0.07, 0.09), shadow)
        7, 8: # Gauntlets
            _rounded(Vector3.ZERO, base_size, primary)
            _box(Vector3(0, 0.08, -0.10), Vector3(0.21, 0.07, 0.13), trim)
        11, 12: # Armored boots
            _rounded(Vector3.ZERO, base_size, primary)
            _box(Vector3(0, -0.06, -0.13), Vector3(0.27, 0.08, 0.25), shadow)
            _box(Vector3(0, 0.09, -0.09), Vector3(0.24, 0.07, 0.11), trim)

    _rarity_details(base_size, primary, trim)


func _spike(pos: Vector3, height: float, radius: float, color: Color, angle: float = 0.0) -> void:
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.0
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.radial_segments = 8
    var node := MeshInstance3D.new()
    node.mesh = mesh
    node.position = pos
    node.rotation.z = angle
    node.material_override = _material(color, 0.35)
    add_child(node)


func _rarity_details(base_size: Vector3, primary: Color, trim: Color) -> void:
    # A gradually more threatening silhouette: accents -> spikes -> horns.
    # Only a small number of added meshes per piece for Android performance.
    if rarity < 2:
        return
    var z_front := -base_size.z * 0.48
    var highlight := trim.lightened(0.12)
    _box(Vector3(0.0, 0.0, z_front), Vector3(base_size.x * 0.4, 0.045, 0.065), highlight)

    if rarity >= 3:
        var spike_height := 0.13 + 0.035 * float(rarity - 3)
        var spike_x := base_size.x * 0.29
        _spike(Vector3(spike_x, base_size.y * 0.43, z_front + 0.02),
            spike_height, 0.064, primary.lightened(0.22), -0.23)
        if slot_index in [0, 1, 3, 4]:
            _spike(Vector3(-spike_x, base_size.y * 0.43, z_front + 0.02),
                spike_height, 0.064, primary.lightened(0.22), 0.23)

    if rarity >= 4:
        # Glowing original rune/jewel detail; rarity 4 and 5 only.
        _rounded(Vector3(0.0, 0.06, z_front - 0.05),
            Vector3(0.13, 0.15, 0.10), trim.lightened(0.35))

    if rarity >= 5 and slot_index in [0, 1, 3, 4]:
        # Final-quality armor gains imposing outward horns.
        _spike(Vector3(base_size.x * 0.50, base_size.y * 0.45, 0.0),
            0.30, 0.085, highlight, -0.65)
        _spike(Vector3(-base_size.x * 0.50, base_size.y * 0.45, 0.0),
            0.30, 0.085, highlight, 0.65)
