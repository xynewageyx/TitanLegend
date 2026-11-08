extends SceneTree
## Verify the real imported chibi GLB skeletons can receive all equipment sockets.
const BUILDER = preload("res://scripts/equipment/chibi_bone_socket_builder.gd")
const CLASSES := ["warrior", "paladin", "druid", "shaman", "hunter", "rogue", "mage", "warlock", "summoner", "priest", "brawler"]

func _initialize() -> void:
    call_deferred("_run")

func _find_skeleton(node: Node) -> Skeleton3D:
    if node is Skeleton3D:
        return node as Skeleton3D
    for child in node.get_children():
        var found := _find_skeleton(child)
        if found != null:
            return found
    return null

func _run() -> void:
    var failures := 0
    for hero_name in CLASSES:
        var path: String = "res://assets/heroes/chibi/%s.glb" % String(hero_name)
        var packed := load(path) as PackedScene
        if packed == null:
            push_error("Missing GLB: " + path)
            failures += 1
            continue
        var model := packed.instantiate()
        root.add_child(model)
        var skeleton := _find_skeleton(model)
        if skeleton == null:
            push_error("Missing Skeleton3D: " + path)
            failures += 1
            model.queue_free()
            continue
        var missing: PackedStringArray = BUILDER.ensure_sockets(skeleton)
        if not missing.is_empty():
            push_error("%s: missing bones for %s" % [hero_name, ",".join(missing)])
            failures += 1
        var count := 0
        for socket_name in BUILDER.SOCKET_BONES:
            var marker := skeleton.find_child(socket_name, true, false)
            if marker == null or not marker is Marker3D:
                push_error("%s: missing marker %s" % [hero_name, socket_name])
                failures += 1
                continue
            if not marker.get_parent() is BoneAttachment3D:
                push_error("%s: marker not attached to bone %s" % [hero_name, socket_name])
                failures += 1
            else:
                var attachment := marker.get_parent() as BoneAttachment3D
                var expected_bone: String = BUILDER.SOCKET_BONES[socket_name]
                if attachment.bone_name != expected_bone:
                    push_error("%s: %s attached to %s instead of %s" % [hero_name, socket_name, attachment.bone_name, expected_bone])
                    failures += 1
                elif skeleton.find_bone(expected_bone) < 0:
                    push_error("%s: missing expected bone %s" % [hero_name, expected_bone])
                    failures += 1
                else:
                    count += 1
        # Exercise bone-following behavior, not just attachment naming.
        var right_marker := skeleton.find_child("RightHandSocket", true, false) as Marker3D
        if right_marker != null:
            var arm_index := skeleton.find_bone("Arm_R")
            if arm_index >= 0:
                var before := right_marker.global_transform.origin
                var original_pose := skeleton.get_bone_pose(arm_index)
                var changed_pose := original_pose.translated(Vector3(0.17, 0.0, 0.0))
                skeleton.set_bone_pose(arm_index, changed_pose)
                skeleton.force_update_all_bone_transforms()
                var after := right_marker.global_transform.origin
                if before.distance_to(after) < 0.01:
                    push_error("%s: RightHandSocket did not follow Arm_R pose" % hero_name)
                    failures += 1
                skeleton.set_bone_pose(arm_index, original_pose)
                skeleton.force_update_all_bone_transforms()
        print("Equipment sockets: %s -> %d/15" % [hero_name, count])
        model.queue_free()
    if failures > 0:
        quit(1)
    else:
        print("PASS: 11 imported chibi GLB rigs have 15 bone-mounted equipment sockets")
        quit(0)
