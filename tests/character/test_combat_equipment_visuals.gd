extends SceneTree
## Headless runtime check: class weapons and rare armor appear on the combat hero's sockets.
## Does not change live inventory or gameplay state.
const ADAPTER = preload("res://scripts/equipment/formation_equipment_adapter.gd")

func _initialize() -> void:
    call_deferred("_run")

func _fail(reason: String) -> void:
    push_error(reason)
    quit(1)

func _run() -> void:
    if ADAPTER.CLASS_WEAPONS.size() != 12:
        _fail("Weapon mapping must cover all twelve classes")
        return
    if ADAPTER.weapon_type_for_class(11) != 1:
        _fail("Death Knight must equip a greatsword, not the Brawler claws")
        return
    for class_id in range(12):
        var hero := Node3D.new()
        hero.name = "Hero_%d" % class_id
        root.add_child(hero)
        var controller: Node3D = ADAPTER.install(hero)
        if controller == null:
            _fail("No equipment controller for class %d" % class_id)
            return
        var weapon_type: int = ADAPTER.weapon_type_for_class(class_id)
        if weapon_type < 0 or weapon_type > 11:
            _fail("Invalid weapon type for class %d" % class_id)
            return
        if not controller.call("equip_weapon", weapon_type, 5):
            _fail("Could not equip weapon for class %d" % class_id)
            return
        if not controller.call("equip_armor_slot", "ChestSocket", class_id, 5):
            _fail("Could not equip armor for class %d" % class_id)
            return
        var weapon_socket := controller.get_node_or_null("RightHandSocket") as Node3D
        var chest_socket := controller.get_node_or_null("ChestSocket") as Node3D
        if weapon_socket == null or chest_socket == null:
            _fail("Missing equipment sockets for class %d" % class_id)
            return
        if weapon_socket.get_child_count() != 1 or chest_socket.get_child_count() != 1:
            _fail("Equipment visuals missing or duplicated for class %d" % class_id)
            return
        var weapon_visual: Node = weapon_socket.get_child(0)
        var armor_visual: Node = chest_socket.get_child(0)
        if int(weapon_visual.get("weapon_type")) != weapon_type or int(armor_visual.get("class_id")) != class_id:
            _fail("Equipment class/type mismatch for class %d" % class_id)
            return
        if weapon_visual.get_child_count() == 0 or armor_visual.get_child_count() < 2:
            _fail("Empty weapon or armor geometry for class %d" % class_id)
            return
        hero.free()
    print("COMBAT_EQUIPMENT_VISUALS_OK: all 12 classes including Death Knight")
    quit(0)
