extends Node3D
class_name TitanArmorTierGallery
## Instantiates six original 3D characters for side-by-side rarity review.
## Attach this script to an empty Node3D in a scene.

@export_enum("warrior", "paladin", "druid", "shaman", "hunter", "rogue", "mage", "warlock", "summoner", "priest", "brawler", "death_knight")
var hero_class: String = "death_knight"
@export var spacing: float = 2.0

const QUALITIES := ["white", "green", "blue", "yellow", "orange", "purple"]

func _ready() -> void:
    build_gallery()

func build_gallery() -> bool:
    if not TitanModularCharacter.CLASSES.has(hero_class) or spacing <= 0.0:
        return false
    var previous := get_node_or_null("Characters")
    if previous != null:
        remove_child(previous)
        previous.free()
    var group := Node3D.new()
    group.name = "Characters"
    add_child(group)
    for index in range(QUALITIES.size()):
        var hero := TitanFullBodyPrototype.new()
        hero.name = "Tier_" + QUALITIES[index]
        hero.hero_class = hero_class
        hero.armor_quality = QUALITIES[index]
        hero.motion = "idle"
        hero.animate = false
        hero.position.x = (float(index) - float(QUALITIES.size() - 1) / 2.0) * spacing
        group.add_child(hero)
    return true
