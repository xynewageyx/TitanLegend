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

func _chest_shell(size: Vector3, color: Color) -> void:
    ## Eight-sided torso shell with a tapered waist and curved upper chest.
    ## 4 rings x 12 segments is mobile-friendly and avoids a flat box bib.
    var ring_profiles := [
        Vector3(-0.50, 0.68, 0.76),
        Vector3(-0.27, 0.91, 0.92),
        Vector3(0.18, 1.02, 1.00),
        Vector3(0.49, 0.72, 0.73)
    ]
    var ring_count := ring_profiles.size()
    var sectors := 12
    var vertices: Array[PackedVector3Array] = []
    for ring in range(ring_count):
        var profile: Vector3 = ring_profiles[ring]
        var loop := PackedVector3Array()
        for k in range(sectors):
            var angle: float = TAU * float(k) / float(sectors)
            loop.append(Vector3(
                cos(angle) * size.x * 0.5 * profile.y,
                size.y * profile.x,
                sin(angle) * size.z * 0.5 * profile.z
            ))
        vertices.append(loop)
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for ring in range(ring_count - 1):
        for k in range(sectors):
            var next: int = (k + 1) % sectors
            var low: Vector3 = vertices[ring][k]
            var high: Vector3 = vertices[ring + 1][k]
            var low_next: Vector3 = vertices[ring][next]
            var high_next: Vector3 = vertices[ring + 1][next]
            for v in [low, high, low_next, high, high_next, low_next]:
                tool.add_vertex(v)
    for k in range(sectors):
        var next: int = (k + 1) % sectors
        for v in [Vector3(0, size.y * ring_profiles[0].x, 0), vertices[0][k], vertices[0][next]]:
            tool.add_vertex(v)
        var top: int = ring_count - 1
        for v in [Vector3(0, size.y * ring_profiles[top].x, 0), vertices[top][next], vertices[top][k]]:
            tool.add_vertex(v)
    tool.generate_normals()
    var shell := MeshInstance3D.new()
    shell.name = "CurvedChestShell"
    shell.mesh = tool.commit()
    shell.material_override = _material(color, 0.38)
    add_child(shell)

func _ready() -> void:
    var scale_factor := 1.0 + float(rarity) * 0.055
    var base_size: Vector3 = SIZES[clampi(slot_index, 0, SIZES.size() - 1)] * scale_factor
    var primary: Color = COLORS[clampi(rarity, 0, COLORS.size() - 1)]
    var shadow: Color = primary.darkened(0.32)
    var trim: Color = Color("#d8c49a") if class_id % 3 == 0 else Color("#d3dce6")
    # Death Knight: keep the violet-tier identity, but replace glaring light
    # armor with battleworn dark steel and muted bone. This is purely visual.
    if class_id == 11:
        primary = Color("#303540").lerp(primary.darkened(0.36), 0.40 + float(rarity) * 0.09)
        shadow = primary.darkened(0.24)
        trim = Color("#a5a0b4")
    # Distinct layered silhouettes replace the former single ellipsoid.
    match slot_index:
        0: # Helmet: crown, brow, and crest
            _rounded(Vector3.ZERO, base_size, primary)
            _box(Vector3(0, -0.09, -0.26), Vector3(0.56, 0.09, 0.13), shadow)
            _box(Vector3(0, 0.20, 0), Vector3(0.11, 0.22, 0.42), trim)
        1: # Chest: tapered curved torso shell, softly layered ribs and emblem
            _chest_shell(base_size, primary)
            _rounded(Vector3(0, -base_size.y * 0.22, -base_size.z * 0.39),
                Vector3(base_size.x * 0.62, 0.09, 0.09), shadow)
            _rounded(Vector3(0, 0.04, -base_size.z * 0.48),
                Vector3(0.105, 0.25, 0.075), trim)
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
    # High-tier Death Knight breastplates receive a subdued carved skull
    # instead of the old featureless oversized purple square.
    if class_id == 11 and rarity >= 4 and slot_index == 1:
        var bone_tint: Color = Color("#ada5a5")
        _rounded(Vector3(0.0, 0.07, -base_size.z * 0.55), Vector3(0.20, 0.22, 0.095), bone_tint)
        _box(Vector3(-0.049, 0.085, -base_size.z * 0.62 - 0.045), Vector3(0.048, 0.038, 0.025), Color("#30303c"))
        _box(Vector3(0.049, 0.085, -base_size.z * 0.62 - 0.045), Vector3(0.048, 0.038, 0.025), Color("#30303c"))


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
