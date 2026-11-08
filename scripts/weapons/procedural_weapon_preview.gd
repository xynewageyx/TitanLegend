@tool
extends Node3D
## Titan Legends procedural weapon preview. Attach to an empty Node3D and run as a scene.
## Set weapon_type (0-11) and rarity (0-5) in the inspector.
@export_range(0, 11) var weapon_type: int = 0
@export_range(0, 5) var rarity: int = 0
const TYPES = ["sword", "greatsword", "axe", "hammer", "dagger", "spear", "bow", "crossbow", "staff", "healer", "shield", "claw"]
const TIERS = ["common", "uncommon", "rare", "epic", "legendary", "mythic"]
const COLORS = [Color(0.55,0.56,0.58),Color(0.18,0.7,0.29),Color(0.12,0.42,1),Color(1,0.75,0.12),Color(1,0.26,0.035),Color(0.62,0.14,1)]
func _ready() -> void:
    build()
func add_piece(pos: Vector3, size: Vector3, color: Color, glow: bool = false) -> void:
    var node := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.position = pos
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.metallic = 0.75
    mat.roughness = 0.28
    if glow:
        mat.emission_enabled = true
        mat.emission = color
        mat.emission_energy_multiplier = 1.8
    node.material_override = mat
    add_child(node)
func build() -> void:
    for child in get_children():
        child.queue_free()
    var accent: Color = COLORS[rarity]
    var metal := Color(0.16,0.18,0.22)
    var big := weapon_type in [1,3,5]
    var scale_factor := 1.0 + float(rarity) * 0.11
    var shaft := 1.8 if big else 1.0
    if weapon_type in [6,7]:
        add_piece(Vector3(-0.5,0,0),Vector3(0.13,2.2,0.15),metal)
        add_piece(Vector3(0.5,0,0),Vector3(0.13,2.2,0.15),metal)
        add_piece(Vector3(0,0,0),Vector3(1.05,0.05,0.06),accent,rarity>=2)
    elif weapon_type == 10:
        add_piece(Vector3.ZERO,Vector3(1.3,1.7,0.22),metal)
        add_piece(Vector3.ZERO,Vector3(0.9,1.3,0.27),accent,rarity>=2)
    elif weapon_type == 11:
        for side in [-1,1]:
            add_piece(Vector3(side*0.2,0.5,0),Vector3(0.16,1.3,0.18),metal)
            add_piece(Vector3(side*0.2,1.2,0),Vector3(0.12,0.7,0.12),accent,rarity>=2)
    else:
        add_piece(Vector3(0,-0.5,0),Vector3(0.15,shaft,0.15),metal)
        if weapon_type in [2,3]:
            add_piece(Vector3(0,0.7,0),Vector3(1.0*scale_factor,0.7,0.2),accent,rarity>=2)
        elif weapon_type in [8,9]:
            add_piece(Vector3(0,shaft*0.55,0),Vector3(0.45,0.45,0.45),accent,rarity>=2)
        else:
            add_piece(Vector3(0,shaft*0.6,0),Vector3(0.3*scale_factor,1.45*scale_factor,0.12),accent,rarity>=2)
        add_piece(Vector3(0,0.0,0),Vector3(0.65,0.12,0.2),metal)
    # High-quality weapons gain a sharper, more threatening cartoon silhouette.
    # These accents are purely visual and do not affect combat statistics.
    if rarity >= 2:
        var ornament_count := rarity - 1
        for i in range(ornament_count):
            var side := -1.0 if i % 2 == 0 else 1.0
            var y := 0.45 + float(i / 2) * 0.24
            add_piece(Vector3(side * (0.36 + float(rarity) * 0.025), y, 0.0),
                Vector3(0.15 + float(rarity) * 0.025, 0.19 + float(rarity) * 0.035, 0.14),
                accent, rarity >= 4)
    if rarity >= 5:
        # Mythic weapons carry an oversized glowing crest.
        add_piece(Vector3(0, 1.45 if big else 1.1, 0),
            Vector3(0.25, 0.34, 0.25), accent, true)
    if rarity >= 3:
        for i in range(rarity-1):
            var y := 0.25 + float(i)*0.32
            add_piece(Vector3(-0.24,y,0),Vector3(0.23,0.12,0.15),accent,true)
            add_piece(Vector3(0.24,y,0),Vector3(0.23,0.12,0.15),accent,true)
