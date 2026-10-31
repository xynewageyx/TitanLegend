extends RefCounted
## Non-invasive helper for Titan Legends' existing four-hero formation.
## Call install(hero) after _decorate_class(). No combat, role or pet changes.
const SOCKETS := {
    "RightHandSocket": Vector3(0.49, 0.80, -0.04),
    "LeftHandSocket": Vector3(-0.49, 0.80, -0.04),
    "HeadSocket": Vector3(0, 1.52, 0),
    "ChestSocket": Vector3(0, 1.02, 0),
    "BackSocket": Vector3(0, 1.07, 0.25)
}
const CONTROLLER = preload("res://scripts/equipment/hero_equipment_sockets.gd")
static func install(hero: Node3D) -> Node3D:
    if hero == null:
        return null
    var existing := hero.get_node_or_null("EquipmentController")
    if existing is Node3D:
        return existing
    var controller := Node3D.new()
    controller.name = "EquipmentController"
    controller.set_script(CONTROLLER)
    hero.add_child(controller)
    for key in SOCKETS:
        var marker := Marker3D.new()
        marker.name = key
        marker.position = SOCKETS[key]
        controller.add_child(marker)
    return controller
static func apply_weapon(hero: Node3D, weapon_type: int, rarity: int) -> bool:
    var controller := install(hero)
    return controller.equip_weapon(weapon_type, rarity) if controller != null else false
static func apply_chest(hero: Node3D, armor_class: int, rarity: int) -> bool:
    var controller := install(hero)
    return controller.equip_armor_slot("ChestSocket", armor_class, rarity) if controller != null else false
