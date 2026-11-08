extends RefCounted
## Non-invasive helper for Titan Legends' existing four-hero formation.
## Call install(hero) after _decorate_class(). No combat, role or pet changes.
const SOCKETS := {
    "RightHandSocket": Vector3(0.49, 0.80, -0.04),
    "LeftHandSocket": Vector3(-0.49, 0.80, -0.04),
    "HeadSocket": Vector3(0, 1.52, 0),
    "ChestSocket": Vector3(0, 1.02, 0),
    "BackSocket": Vector3(0, 1.07, 0.25),
    "ShoulderLeftSocket": Vector3(-0.42, 1.16, 0),
    "ShoulderRightSocket": Vector3(0.42, 1.16, 0),
    "ArmLeftSocket": Vector3(-0.44, 0.84, 0),
    "ArmRightSocket": Vector3(0.44, 0.84, 0),
    "GloveLeftSocket": Vector3(-0.44, 0.61, 0),
    "GloveRightSocket": Vector3(0.44, 0.61, 0),
    "LegLeftSocket": Vector3(-0.17, 0.38, 0),
    "LegRightSocket": Vector3(0.17, 0.38, 0),
    "BootLeftSocket": Vector3(-0.17, 0.13, -0.07),
    "BootRightSocket": Vector3(0.17, 0.13, -0.07)
}
const BONE_SOCKETS := {
    "RightHandSocket": "Hand_R",
    "LeftHandSocket": "Hand_L",
    "HeadSocket": "Head",
    "ChestSocket": "Chest",
    "BackSocket": "Chest",
    "ShoulderLeftSocket": "Shoulder_L",
    "ShoulderRightSocket": "Shoulder_R",
    "ArmLeftSocket": "Forearm_L",
    "ArmRightSocket": "Forearm_R",
    "GloveLeftSocket": "Hand_L",
    "GloveRightSocket": "Hand_R",
    "LegLeftSocket": "LowerLeg_L",
    "LegRightSocket": "LowerLeg_R",
    "BootLeftSocket": "Foot_L",
    "BootRightSocket": "Foot_R"
}
const CLASS_WEAPONS := [1,0,9,8,6,4,8,8,8,9,11,1] # 12 classes; Death Knight uses greatsword.
static func weapon_type_for_class(class_id: int) -> int:
    return CLASS_WEAPONS[clampi(class_id, 0, CLASS_WEAPONS.size() - 1)]

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
    return controller.call("equip_weapon", weapon_type, rarity) if controller != null else false
static func apply_chest(hero: Node3D, armor_class: int, rarity: int) -> bool:
    var controller := install(hero)
    return controller.call("equip_armor_slot", "ChestSocket", armor_class, rarity) if controller != null else false

static func apply_full_armor(hero: Node3D, class_id: int, rarity: int) -> int:
    var controller := install(hero)
    if controller == null:
        return 0
    var count := 0
    for slot in SOCKETS.keys():
        if slot == "RightHandSocket" or slot == "LeftHandSocket":
            continue
        if controller.call("equip_armor_slot", slot, class_id, rarity):
            count += 1
    return count
