extends SceneTree
## Verify that equipment resolves to animated skeleton attachments before static markers.

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var hero := Node3D.new()
    root.add_child(hero)
    var skeleton := Skeleton3D.new()
    skeleton.name = "Skeleton3D"
    hero.add_child(skeleton)
    var builder := TitanHumanoidRigBuilder.new()
    if not builder.build_rig(skeleton):
        push_error("Failed to create prototype rig")
        quit(1)
        return
    var controller := Node3D.new()
    controller.name = "EquipmentController"
    controller.set_script(load("res://scripts/equipment/hero_equipment_sockets.gd"))
    hero.add_child(controller)
    var static_marker := Marker3D.new()
    static_marker.name = "HeadSocket"
    controller.add_child(static_marker)
    var resolved: Node3D = controller.call("_socket", "HeadSocket")
    if not (resolved is BoneAttachment3D):
        push_error("Equipment did not prefer animated HeadSocket attachment")
        quit(1)
        return
    if resolved.get_parent() != skeleton:
        push_error("HeadSocket attachment is not bound to the skeleton")
        quit(1)
        return
    if controller.call("_socket", "NonexistentSocket") != null:
        push_error("Missing socket should not resolve")
        quit(1)
        return
    print("BONE EQUIPMENT SOCKET SMOKE PASSED")
    quit(0)
