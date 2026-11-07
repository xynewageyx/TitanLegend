@tool
extends Node3D
## Standalone inspection rig for modular equipment; does not replace game hero rigs.
const EQUIPMENT = preload("res://scripts/equipment/hero_equipment_sockets.gd")
@export_range(0, 5) var rarity: int = 4
@export_range(0, 10) var hero_class: int = 0
@export_range(0, 2) var hairstyle: int = 1
@export var hair_color: Color = Color("#694333")

func _ready() -> void:
    rebuild()

func rebuild() -> void:
    var previous := get_node_or_null("PreviewRig")
    if previous != null:
        remove_child(previous)
        previous.queue_free()
    var rig := Node3D.new()
    rig.name = "PreviewRig"
    rig.set_script(EQUIPMENT)
    add_child(rig)
    var anchors := {
        "HeadSocket": Vector3(0, 1.68, 0),
        "ChestSocket": Vector3(0, 1.0, 0),
        "BackSocket": Vector3(0, 1.0, 0.23),
        "ShoulderLeftSocket": Vector3(-0.43, 1.22, 0),
        "ShoulderRightSocket": Vector3(0.43, 1.22, 0),
        "ArmLeftSocket": Vector3(-0.43, 0.89, 0),
        "ArmRightSocket": Vector3(0.43, 0.89, 0),
        "GloveLeftSocket": Vector3(-0.43, 0.64, 0),
        "GloveRightSocket": Vector3(0.43, 0.64, 0),
        "LegLeftSocket": Vector3(-0.17, 0.42, 0),
        "LegRightSocket": Vector3(0.17, 0.42, 0),
        "BootLeftSocket": Vector3(-0.17, 0.14, -0.07),
        "BootRightSocket": Vector3(0.17, 0.14, -0.07),
        "RightHandSocket": Vector3(0.64, 0.65, -0.04),
        "LeftHandSocket": Vector3(-0.64, 0.65, -0.04)
    }
    for key in anchors:
        var marker := Marker3D.new()
        marker.name = key
        marker.position = anchors[key]
        rig.add_child(marker)
    for slot in ["ChestSocket", "BackSocket", "ShoulderLeftSocket", "ShoulderRightSocket", "ArmLeftSocket", "ArmRightSocket", "GloveLeftSocket", "GloveRightSocket", "LegLeftSocket", "LegRightSocket", "BootLeftSocket", "BootRightSocket"]:
        rig.equip_armor_slot(slot, hero_class, rarity)
    rig.equip_hairstyle(hairstyle, hair_color)
    rig.equip_weapon(0, rarity)
