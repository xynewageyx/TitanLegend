extends SceneTree
## Runtime smoke test for the actual Godot equipment socket script.
const CONTROLLER_SCRIPT = preload("res://scripts/equipment/hero_equipment_sockets.gd")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var controller := Node3D.new()
    controller.set_script(CONTROLLER_SCRIPT)
    root.add_child(controller)
    var skeleton := Skeleton3D.new()
    controller.add_child(skeleton)
    skeleton.add_bone("RightHand")
    var attachment := BoneAttachment3D.new()
    attachment.bone_name = "RightHand"
    skeleton.add_child(attachment)
    var right_hand := Marker3D.new()
    right_hand.name = "RightHandSocket"
    attachment.add_child(right_hand)

    var failures := 0
    if not controller.is_socket_bone_attached("RightHandSocket"):
        push_error("RightHandSocket must be recognized as bone attached")
        failures += 1
    if controller.is_socket_bone_attached("LeftHandSocket"):
        push_error("Missing offhand socket incorrectly recognized")
        failures += 1
    var report: Dictionary = controller.equipment_socket_diagnostics()
    if not report["missing"].has("LeftHandSocket"):
        push_error("Missing offhand not reported")
        failures += 1
    if report["not_bone_attached"].has("RightHandSocket"):
        push_error("Bone-mounted hand reported as unbound")
        failures += 1
    if not controller.equip_weapon(12, 5):
        push_error("Death Knight runeblade did not equip")
        failures += 1
    if not controller.equipped_nodes.has("mainhand"):
        push_error("Equipped runeblade not registered")
        failures += 1
    var chest := Marker3D.new()
    chest.name = "ChestSocket"
    controller.add_child(chest)
    if not controller.equip_armor_slot("ChestSocket", 11, 5):
        push_error("Death Knight armor did not equip")
        failures += 1
    if controller.is_socket_bone_attached("ChestSocket"):
        push_error("Unbound chest marker incorrectly recognized as bone mounted")
        failures += 1
    controller.queue_free()
    if failures > 0:
        quit(1)
    else:
        print("PASS: animated equipment sockets and Death Knight previews")
        quit(0)
