extends SceneTree
## Functional headless Godot smoke for the original hairstyle and sibling sockets.

func _initialize() -> void:
    call_deferred("_run")

func _fail(reason: String) -> void:
    push_error(reason)
    quit(1)

func _run() -> void:
    var hero := Node3D.new()
    var head := Marker3D.new()
    head.name = "HeadSocket"
    hero.add_child(head)
    var chest := Marker3D.new()
    chest.name = "ChestSocket"
    hero.add_child(chest)
    var controller := Node3D.new()
    controller.set_script(load("res://scripts/equipment/hero_equipment_sockets.gd"))
    hero.add_child(controller)
    root.add_child(hero)
    await process_frame

    if not bool(controller.call("equip_hairstyle", 1, Color("#2a6aaf"))):
        _fail("Cannot equip hair through sibling HeadSocket")
        return
    if head.get_child_count() != 1:
        _fail("Hair did not attach to the right head socket")
        return
    var hair := head.get_child(0)
    if hair.get_child_count() < 3 or int(hair.get("style")) != 1:
        _fail("Hairstyle meshes were not built")
        return
    if hair.get("hair_color") != Color("#2a6aaf"):
        _fail("Selected hair color was not preserved")
        return

    if not bool(controller.call("equip_armor_slot", "ChestSocket", 11, 4)):
        _fail("Twelfth playable class cannot equip chest armor")
        return
    if chest.get_child_count() != 1 or int(chest.get_child(0).get("class_id")) != 11:
        _fail("Twelfth class armor settings not preserved")
        return

    if not bool(controller.call("equip_hairstyle", 2, Color("#a0522d"))):
        _fail("Cannot change hairstyle")
        return
    await process_frame
    if head.get_child_count() != 1 or int(head.get_child(0).get("style")) != 2:
        _fail("Previous hairstyle was not removed")
        return

    controller.call("unequip", "hair")
    await process_frame
    if head.get_child_count() != 0:
        _fail("Unequip left a hairstyle mesh on the character")
        return

    var orphan := Node3D.new()
    orphan.set_script(load("res://scripts/equipment/hero_equipment_sockets.gd"))
    root.add_child(orphan)
    if bool(orphan.call("equip_hairstyle", 0, Color.WHITE)):
        _fail("Missing HeadSocket should be handled safely")
        return
    print("HAIR SOCKET SMOKE PASSED: three styles, replacement, color, class twelve")
    quit(0)
