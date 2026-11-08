@tool
extends Node3D
class_name TitanCharacterPrototype
## Original blockout geometry for silhouette review, NOT a skinned production mesh.
## All geometry is generated in Godot and contains no third-party assets.

@export_enum("warrior", "paladin", "druid", "shaman", "hunter", "rogue", "mage", "warlock", "summoner", "priest", "brawler", "death_knight")
var hero_class: String = "warrior"

const HEAVY_CLASSES = ["warrior", "paladin", "brawler", "death_knight"]
const PALETTE = {
    "warrior": Color("#607c9b"), "paladin": Color("#dfc77b"),
    "druid": Color("#6caa72"), "shaman": Color("#77a7ad"),
    "hunter": Color("#9aab62"), "rogue": Color("#7b829b"),
    "mage": Color("#7184d0"), "warlock": Color("#80659c"),
    "summoner": Color("#b28bc7"), "priest": Color("#e6d9bd"),
    "brawler": Color("#bc785a"), "death_knight": Color("#514f67")
}

func build_preview() -> bool:
    if not PALETTE.has(hero_class):
        push_warning("Unknown hero class: " + hero_class)
        return false
    var old := get_node_or_null("GeneratedPreview")
    if old != null:
        remove_child(old)
        old.free()
    var group := Node3D.new()
    group.name = "GeneratedPreview"
    add_child(group)
    var heavy: bool = HEAVY_CLASSES.has(hero_class)
    var base: Color = PALETTE[hero_class]
    var head_scale := 0.39 if heavy else 0.36
    _sphere(group, "Head", Vector3(0, 1.65, 0), Vector3.ONE * head_scale, Color("#edc49c"))
    _sphere(group, "Hair", Vector3(0, 1.88, 0), Vector3(0.39, 0.16, 0.35), base.darkened(0.55))
    _sphere(group, "Torso", Vector3(0, 1.08, 0), Vector3(0.48 if heavy else 0.39, 0.46, 0.30), base)
    _sphere(group, "Belt", Vector3(0, 0.72, 0), Vector3(0.37, 0.12, 0.30), base.darkened(0.35))
    for side in [-1.0, 1.0]:
        _sphere(group, "Arm", Vector3(side * 0.48, 1.09, 0), Vector3(0.18 if heavy else 0.14, 0.39, 0.18), base.lightened(0.12))
        _sphere(group, "Hand", Vector3(side * 0.49, 0.72, 0), Vector3.ONE * 0.17, Color("#edc49c"))
        _sphere(group, "Leg", Vector3(side * 0.20, 0.39, 0), Vector3(0.18, 0.36, 0.20), base.darkened(0.18))
        _sphere(group, "Boot", Vector3(side * 0.20, 0.14, -0.07), Vector3(0.21, 0.15, 0.30), base.darkened(0.42))
    if hero_class == "death_knight":
        _sphere(group, "DarkShoulderL", Vector3(-0.53, 1.40, 0), Vector3(0.28, 0.20, 0.27), Color("#292635"))
        _sphere(group, "DarkShoulderR", Vector3(0.53, 1.40, 0), Vector3(0.28, 0.20, 0.27), Color("#292635"))
    return true

func _sphere(parent: Node3D, part_name: String, pos: Vector3, scale_value: Vector3, color: Color) -> void:
    var instance := MeshInstance3D.new()
    instance.name = part_name
    var mesh := SphereMesh.new()
    mesh.radius = 1.0
    mesh.height = 2.0
    instance.mesh = mesh
    instance.position = pos
    instance.scale = scale_value
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 1.0
    instance.material_override = material
    parent.add_child(instance)
