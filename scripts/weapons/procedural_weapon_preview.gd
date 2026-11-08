@tool
extends Node3D
## Titan Legends original low-poly weapon shapes for Godot 4.7.2 / Android.
## 12 types, six progressive rarities. No textures, shaders or borrowed assets.
@export_range(0, 11) var weapon_type: int = 0
@export_range(0, 5) var rarity: int = 0

const TYPES := ["sword", "greatsword", "axe", "hammer", "dagger", "spear", "bow", "crossbow", "staff", "healer", "shield", "claw"]
const TIERS := ["common", "uncommon", "rare", "epic", "legendary", "mythic"]
const ACCENTS := [
    Color("#88939e"), Color("#5c9474"), Color("#4f80b1"),
    Color("#c4a268"), Color("#c66b41"), Color("#8c6cba")
]
const METAL := Color("#303846")
const OBSIDIAN := Color("#242631")
const BONE := Color("#b4a5a0")
const LEATHER := Color("#5c423b")

func _ready() -> void:
    build()

func _material(color: Color, metalness: float = 0.25, emissive: bool = false) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.metallic = metalness
    mat.roughness = 0.49
    if emissive and rarity >= 3:
        mat.emission_enabled = true
        mat.emission = color.darkened(0.16)
        mat.emission_energy_multiplier = 0.20 if rarity < 5 else 0.32
    return mat

func _mesh(mesh: Mesh, where: Vector3, mat: Material, tag: String) -> MeshInstance3D:
    var part := MeshInstance3D.new()
    part.name = tag
    part.mesh = mesh
    part.position = where
    part.material_override = mat
    add_child(part)
    return part

func _box(where: Vector3, size: Vector3, color: Color, tag: String, emissive: bool = false) -> void:
    var cube := BoxMesh.new()
    cube.size = size
    _mesh(cube, where, _material(color, 0.5, emissive), tag)

func _rod(where: Vector3, height: float, radius: float, color: Color, tag: String, angle_z: float = 0.0) -> void:
    var rod := CylinderMesh.new()
    rod.height = height
    rod.top_radius = radius
    rod.bottom_radius = radius
    rod.radial_segments = 8
    var item := _mesh(rod, where, _material(color), tag)
    item.rotation.z = angle_z

func _spike(where: Vector3, height: float, radius: float, color: Color, tag: String, angle: float = 0.0) -> void:
    var point := CylinderMesh.new()
    point.height = height
    point.top_radius = 0.0
    point.bottom_radius = radius
    point.radial_segments = 6
    var item := _mesh(point, where, _material(color, 0.4), tag)
    item.rotation.z = angle

func _orb(where: Vector3, radius: float, color: Color, tag: String, emissive: bool = false) -> void:
    var orb := SphereMesh.new()
    orb.radius = radius
    orb.height = radius * 2.0
    orb.radial_segments = 10
    orb.rings = 6
    _mesh(orb, where, _material(color, 0.2, emissive), tag)

func _extrude(outline: PackedVector2Array, thickness: float, color: Color, tag: String, offset: Vector3 = Vector3.ZERO) -> void:
    ## One two-sided beveled silhouette instead of many glaring, flat boxes.
    var triangles: PackedInt32Array = Geometry2D.triangulate_polygon(outline)
    if triangles.is_empty():
        push_error("Titan weapon silhouette triangulation failed: " + tag)
        return
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    var near_z := thickness * 0.5
    for face in range(0, triangles.size(), 3):
        for idx in [triangles[face], triangles[face + 1], triangles[face + 2]]:
            var v: Vector2 = outline[idx]
            tool.add_vertex(Vector3(v.x, v.y, near_z))
        for idx in [triangles[face + 2], triangles[face + 1], triangles[face]]:
            var v: Vector2 = outline[idx]
            tool.add_vertex(Vector3(v.x, v.y, -near_z))
    for i in range(outline.size()):
        var p: Vector2 = outline[i]
        var q: Vector2 = outline[(i + 1) % outline.size()]
        for v in [
            Vector3(p.x, p.y, near_z), Vector3(q.x, q.y, near_z), Vector3(q.x, q.y, -near_z),
            Vector3(p.x, p.y, near_z), Vector3(q.x, q.y, -near_z), Vector3(p.x, p.y, -near_z)
        ]:
            tool.add_vertex(v)
    tool.generate_normals()
    var solid: ArrayMesh = tool.commit()
    _mesh(solid, offset, _material(color, 0.72), tag)

func _blade_outline(height: float, half_width: float) -> PackedVector2Array:
    var points := PackedVector2Array()
    var teeth: int = maxi(0, rarity - 2)
    for i in range(8):
        var t := float(i) / 8.0
        var taper: float = lerpf(1.0, 0.24, t)
        var serration: float = 1.0 + (0.17 * float(teeth) if teeth > 0 and i in [2, 4, 6] else 0.0)
        points.append(Vector2(-half_width * taper * serration, 0.18 + height * t))
    points.append(Vector2(0.0, 0.18 + height))
    for i in range(7, -1, -1):
        var t := float(i) / 8.0
        var taper: float = lerpf(1.0, 0.24, t)
        var serration: float = 1.0 + (0.17 * float(teeth) if teeth > 0 and i in [2, 4, 6] else 0.0)
        points.append(Vector2(half_width * taper * serration, 0.18 + height * t))
    return points

func _hilt(accent: Color, broad: bool) -> void:
    _rod(Vector3(0, -0.21, 0), 0.55, 0.082 if broad else 0.064, LEATHER, "LeatherGrip")
    _box(Vector3(0, 0.125, 0), Vector3(0.56 if broad else 0.37, 0.095, 0.14), METAL, "Crossguard")
    _orb(Vector3(0, -0.50, 0), 0.105, accent.darkened(0.15), "Pommel")
    if rarity >= 3:
        _spike(Vector3(-0.26 if broad else -0.18, 0.16, 0), 0.26, 0.075, accent, "LeftGuardHorn", -0.65)
        _spike(Vector3(0.26 if broad else 0.18, 0.16, 0), 0.26, 0.075, accent, "RightGuardHorn", 0.65)

func _crest(accent: Color, at: Vector3) -> void:
    if rarity >= 2:
        _orb(at, 0.085, accent.lightened(0.14), "EmbeddedRune", rarity >= 4)
    if rarity >= 4:
        _spike(at + Vector3(-0.16, 0.08, 0), 0.20, 0.06, BONE, "LeftFang", -0.65)
        _spike(at + Vector3(0.16, 0.08, 0), 0.20, 0.06, BONE, "RightFang", 0.65)
    if rarity >= 5:
        _orb(at + Vector3(0, 0.17, 0), 0.10, OBSIDIAN, "ObsidianSkull")
        _orb(at + Vector3(-0.035, 0.18, 0.07), 0.023, accent, "LeftRuneEye", true)
        _orb(at + Vector3(0.035, 0.18, 0.07), 0.023, accent, "RightRuneEye", true)

func build() -> void:
    for old in get_children():
        remove_child(old)
        old.queue_free()
    var quality: int = clampi(rarity, 0, 5)
    var accent: Color = ACCENTS[quality]
    var base: Color = OBSIDIAN if weapon_type == 1 else METAL
    var width_factor: float = 1.0 + 0.12 * float(quality)
    match weapon_type:
        0, 1, 4: # Sword / brutal two-handed sword / dagger
            var large: bool = weapon_type == 1
            var length: float = (1.20 if large else 0.76 if weapon_type == 4 else 0.98) * width_factor
            var half_width: float = (0.29 if large else 0.11 if weapon_type == 4 else 0.17) * width_factor
            _hilt(accent, large)
            _extrude(_blade_outline(length, half_width), 0.12 if large else 0.075, base.lightened(0.14), "FacetedJaggedBlade")
            _crest(accent, Vector3(0, 0.37, 0.085))
        2: # Axe
            _rod(Vector3(0, 0.45, 0), 1.55, 0.075, LEATHER, "AxeHaft")
            var axe := PackedVector2Array([
                Vector2(-0.08, 0.42), Vector2(-0.57 * width_factor, 0.28),
                Vector2(-0.43 * width_factor, 0.68), Vector2(-0.58 * width_factor, 1.08),
                Vector2(-0.08, 0.87), Vector2(0.12, 0.87), Vector2(0.12, 0.42)
            ])
            _extrude(axe, 0.14, base.lightened(0.12), "AxeCurvedHead")
            _crest(accent, Vector3(-0.22, 0.68, 0.10))
        3: # Hammer
            _rod(Vector3(0, 0.44, 0), 1.65, 0.08, LEATHER, "HammerHandle")
            _box(Vector3(0, 1.05, 0), Vector3(0.65 * width_factor, 0.36 * width_factor, 0.33), base, "HeavyHammerHead")
            _crest(accent, Vector3(0, 1.05, 0.20))
        5: # Spear
            _rod(Vector3(0, 0.42, 0), 1.75, 0.065, LEATHER, "SpearShaft")
            _extrude(_blade_outline(0.78 * width_factor, 0.13 * width_factor), 0.09, base.lightened(0.1), "SpearTip", Vector3(0, 0.92, 0))
            _crest(accent, Vector3(0, 0.48, 0.10))
        6, 7: # Bow and compact crossbow
            _rod(Vector3(-0.23, 0.43, 0), 1.40, 0.065, LEATHER, "LeftCurvedLimb", -0.28)
            _rod(Vector3(0.23, 0.43, 0), 1.40, 0.065, LEATHER, "RightCurvedLimb", 0.28)
            _rod(Vector3(0, 0.43, 0), 1.64, 0.013, BONE.darkened(0.15), "Bowstring")
            if weapon_type == 7:
                _box(Vector3(0, 0.47, 0), Vector3(0.20, 0.22, 0.8), base, "CrossbowStock")
            _crest(accent, Vector3(0, 0.45, 0.15))
        8, 9: # Mage staff or healing staff
            _rod(Vector3(0, 0.46, 0), 1.70, 0.067, LEATHER, "StaffCore")
            _orb(Vector3(0, 1.42, 0), 0.20 if weapon_type == 8 else 0.26, accent, "StaffCrystal", quality >= 3)
            _crest(accent, Vector3(0, 1.13, 0.12))
        10: # Shield
            var outline := PackedVector2Array([
                Vector2(-0.52 * width_factor, 0.83), Vector2(-0.42 * width_factor, 1.29),
                Vector2(0.42 * width_factor, 1.29), Vector2(0.52 * width_factor, 0.83),
                Vector2(0, -0.18)
            ])
            _extrude(outline, 0.19, base, "KiteShield")
            _crest(accent, Vector3(0, 0.78, 0.14))
        11: # Brawler claws
            for side in [-1.0, 1.0]:
                _rod(Vector3(side * 0.19, -0.05, 0), 0.42, 0.06, LEATHER, "ClawGrip")
                _spike(Vector3(side * 0.21, 0.65, 0), 1.32 * width_factor, 0.11, base.lightened(0.23), "HookClaw", -0.18 * side)
            _crest(accent, Vector3(0, 0.14, 0.12))
    set_meta("design_rarity", quality)
    set_meta("design_family", TYPES[clampi(weapon_type, 0, TYPES.size() - 1)])
