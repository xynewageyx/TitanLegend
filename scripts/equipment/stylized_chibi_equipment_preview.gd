@tool
extends Node3D
## Stylized chibi equipment display. Godot 4.x, mobile-friendly prototype.
## Attach to Node3D. Generates rounded primitive armor and one weapon.
@export_enum("Tank","Warrior","Assassin","Mage","Paladin","Healer") var hero_class: int = 0
@export_range(0,5) var rarity: int = 0
@export_enum("Sword","Greatsword","Axe","Hammer","Daggers","Spear","Bow","Crossbow","Staff","Scepter","Shield","Claws") var weapon: int = 0
@export var generate_on_ready := true
const COLORS := [Color("#aab0b5"),Color("#64c45c"),Color("#4aa8ff"),Color("#ffce54"),Color("#ff8840"),Color("#c47bff")]
const BASE := Color("#41465a")
const SKIN := Color("#f2bd8f")
func _ready() -> void:
    if generate_on_ready:
        rebuild()
func rounded(pos: Vector3, size: Vector3, tint: Color, shine: bool = false) -> void:
    var mesh := SphereMesh.new()
    mesh.radius = 0.5
    mesh.height = 1.0
    mesh.radial_segments = 12
    mesh.rings = 6
    var instance := MeshInstance3D.new()
    instance.mesh = mesh
    instance.position = pos
    instance.scale = size
    var material := StandardMaterial3D.new()
    material.albedo_color = tint
    material.roughness = 0.52
    material.metallic = 0.18
    if shine:
        material.emission_enabled = true
        material.emission = tint
        material.emission_energy_multiplier = 0.75
    instance.material_override = material
    add_child(instance)
func rebuild() -> void:
    for child in get_children():
        remove_child(child)
        child.queue_free()
    var color: Color = COLORS[rarity]
    var tank := hero_class == 0 or hero_class == 4
    var bulk := 1.12 if tank else 0.92
    # Chibi: oversized head, compact torso and limbs.
    rounded(Vector3(0,1.42,0),Vector3(0.65,0.67,0.61),SKIN)
    rounded(Vector3(0,0.92,0),Vector3(0.66*bulk,0.67,0.40),BASE)
    rounded(Vector3(0,1.0,-0.22),Vector3(0.52*bulk,0.40,0.16),color,rarity>=2)
    rounded(Vector3(0,1.77,0),Vector3(0.70,0.27,0.62),color)
    for side in [-1.0,1.0]:
        rounded(Vector3(side*0.41*bulk,1.13,0),Vector3(0.37+rarity*0.035,0.29,0.39),color)
        rounded(Vector3(side*0.42*bulk,0.81,0),Vector3(0.18,0.43,0.21),BASE)
        rounded(Vector3(side*0.42*bulk,0.60,-0.01),Vector3(0.22,0.19,0.24),color)
        rounded(Vector3(side*0.17,0.38,0),Vector3(0.27,0.54,0.29),BASE)
        rounded(Vector3(side*0.17,0.13,-0.09),Vector3(0.30,0.24,0.45),color)
        if rarity >= 3:
            rounded(Vector3(side*(0.52*bulk),1.33,0),Vector3(0.14,0.23+rarity*0.035,0.14),color,rarity>=4)
    rounded(Vector3(0,0.93,0.26),Vector3(0.36,0.52,0.09),color,rarity>=4)
    if rarity >= 4:
        rounded(Vector3(0,1.02,-0.33),Vector3(0.19,0.21,0.10),color,true)
    if rarity == 5:
        for side in [-1.0,1.0]:
            rounded(Vector3(side*0.54,1.67,0),Vector3(0.15,0.22,0.16),color,true)
    # Floating stylized equipment preview beside the hero, not a rigged attachment.
    var anchor := Vector3(1.05,0.8,0)
    if weapon == 10:
        rounded(anchor,Vector3(0.64,0.82,0.19),color,rarity>=2)
        rounded(anchor+Vector3(0,0,-0.13),Vector3(0.34,0.49,0.08),BASE)
    elif weapon in [6,7]:
        rounded(anchor,Vector3(0.68,0.94,0.12),color)
        rounded(anchor,Vector3(0.09,1.07,0.10),BASE)
    elif weapon == 11 or weapon == 4:
        for side in [-1.0,1.0]:
            rounded(anchor+Vector3(side*0.19,0.17,0),Vector3(0.16,0.65,0.15),color,rarity>=2)
    else:
        var long_weapon := weapon in [1,5,8,9]
        rounded(anchor+Vector3(0,-0.18,0),Vector3(0.16,0.62,0.16),BASE)
        rounded(anchor+Vector3(0,0.35,0),Vector3(0.30+rarity*0.04,1.0 if long_weapon else 0.72,0.17),color,rarity>=2)
        if weapon in [2,3]:
            rounded(anchor+Vector3(0,0.55,0),Vector3(0.64,0.37,0.19),color)
    if rarity >= 4:
        rounded(anchor+Vector3(0,0.55,-0.12),Vector3(0.12,0.16,0.12),color,true)
