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
    # Rotate the head bone and ensure the attached equipment follows it.
    var head_idx := skeleton.find_bone("head")
    if head_idx < 0:
        push_error("Missing head bone")
        quit(1)
        return
    var attachment := resolved as BoneAttachment3D
    var visual := Node3D.new()
    attachment.add_child(visual)
    skeleton.force_update_all_bone_transforms()
    var initial_transform := visual.global_transform
    skeleton.set_bone_pose_rotation(head_idx, Quaternion(Vector3.UP, deg_to_rad(35.0)))
    skeleton.force_update_all_bone_transforms()
    var animated_transform := visual.global_transform
    if initial_transform.basis.is_equal_approx(animated_transform.basis):
        push_error("Equipment did not rotate with the animated head bone")
        quit(1)
        return
    skeleton.set_bone_pose_rotation(head_idx, Quaternion.IDENTITY)
    skeleton.force_update_all_bone_transforms()
    if not visual.global_transform.basis.is_equal_approx(initial_transform.basis):
        push_error("Equipment did not return to the original orientation")
        quit(1)
        return
    print("BONE EQUIPMENT SOCKET SMOKE PASSED")
    quit(0)
