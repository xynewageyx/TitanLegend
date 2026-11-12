@tool
extends Node3D
## Procedural visual armor prototype for Titan Legends.
## Attach to Node3D. Units assume a humanoid ~1.8 m tall, origin at feet.
## Visual only: stats, save data, skinning and equipment inventory are separate.
@export_enum("Tank", "Warrior", "Assassin", "Mage", "Paladin", "Healer") var armor_class: int = 0
@export_enum("Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic") var rarity: int = 0
@export var show_helmet := true
@export var show_chest := true
@export var show_shoulders := true
@export var show_arms := true
@export var show_gloves := true
@export var show_legs := true
@export var show_boots := true
@export var show_back := true
const TIER_COLORS := [Color("#777b80"), Color("#328e48"), Color("#317bd9"), Color("#e7bb48"), Color("#f16b22"), Color("#9e45ef")]
const METAL := Color("#292d37")
const CLOTH := Color("#242532")
func _ready() -> void:
    rebuild()
func piece(p: Vector3, dimensions: Vector3, tint: Color, emissive: bool = false) -> void:
    var m := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = dimensions
    m.mesh = box
    m.position = p
    var material := StandardMaterial3D.new()
    material.albedo_color = tint
    material.metallic = 0.65 if armor_class <= 1 or armor_class == 4 else 0.2
    material.roughness = 0.35
    if emissive:
        material.emission_enabled = true
        material.emission = tint
        material.emission_energy_multiplier = 1.2
    m.material_override = material
    add_child(m)
func rebuild() -> void:
    for c in get_children():
        remove_child(c)
        c.queue_free()
    var tint: Color = TIER_COLORS[rarity]
    var bulk := 1.0 + float(rarity) * 0.09
    var heavy := armor_class == 0 or armor_class == 1 or armor_class == 4
    var width := 0.6 * bulk if heavy else 0.46 * bulk
    if show_chest:
        piece(Vector3(0,1.28,0),Vector3(width,0.62,0.29),METAL if heavy else CLOTH)
        piece(Vector3(0,1.38,-0.17),Vector3(width*0.76,0.32,0.08),tint,rarity>=2)
    if show_helmet:
        piece(Vector3(0,1.78,0),Vector3(0.38*bulk,0.33,0.37),METAL if heavy else CLOTH)
        piece(Vector3(0,1.79,-0.2),Vector3(0.28,0.055,0.045),tint,rarity>=2)
    for side in [-1.0,1.0]:
        if show_shoulders:
            piece(Vector3(side*width*0.62,1.51,0),Vector3(0.29*bulk,0.22*bulk,0.39),tint)
        if show_arms:
            piece(Vector3(side*0.43,1.17,0),Vector3(0.18,0.42,0.23),METAL if heavy else CLOTH)
        if show_gloves:
            piece(Vector3(side*0.43,0.87,0),Vector3(0.2,0.2,0.24),tint)
        if show_legs:
            piece(Vector3(side*0.17,0.52,0),Vector3(0.25,0.7,0.29),METAL if heavy else CLOTH)
        if show_boots:
            piece(Vector3(side*0.17,0.13,-0.07),Vector3(0.27,0.26,0.42),tint)
        if rarity >= 3 and show_shoulders:
            piece(Vector3(side*(width*0.7+0.09),1.72,0),Vector3(0.12,0.34+0.06*rarity,0.14),tint,rarity>=4)
    if show_back:
        piece(Vector3(0,1.32,0.23),Vector3(0.38,0.55,0.08),tint,rarity>=4)
    if rarity >= 4:
        piece(Vector3(0,1.35,-0.24),Vector3(0.16,0.18,0.08),tint,true)
        if material_override != null and material_override is StandardMaterial3D:
            (material_override as StandardMaterial3D).emission_energy_multiplier = 1.0 + float(rarity) * 0.5
    if rarity == 5:
        for side in [-1.0,1.0]:
            piece(Vector3(side*0.57,1.9,0),Vector3(0.1,0.32,0.1),tint,true)
