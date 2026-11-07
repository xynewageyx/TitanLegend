extends SceneTree
## Headless smoke test: verify imported Chibi rigs accept a temporary bone pose.
## This does NOT validate Unity animation retargeting.

const CLASSES := ["brawler", "druid", "hunter", "mage", "paladin", "priest", "rogue", "shaman", "summoner", "warlock", "warrior"]


func _initialize() -> void:
    var failures: Array[String] = []
    var tested := 0
    for hero_id in CLASSES:
        var path := "res://assets/heroes/chibi/%s.glb" % hero_id
        var packed := load(path) as PackedScene
        if packed == null:
            failures.append("%s: cannot load scene" % path)
            continue
        var root := packed.instantiate()
        var skeleton := _find_skeleton(root)
        if skeleton == null:
            failures.append("%s: Skeleton3D missing" % path)
            root.free()
            continue
        var pose_ok := true
        for bone_name in ["Head", "Arm_L", "Arm_R", "Leg_L", "Leg_R"]:
            var bone_id := skeleton.find_bone(bone_name)
            if bone_id < 0:
                failures.append("%s: %s bone missing" % [path, bone_name])
                pose_ok = false
                continue
            var original := skeleton.get_bone_pose_rotation(bone_id)
            var delta := Quaternion(Vector3.UP, 0.2)
            skeleton.set_bone_pose_rotation(bone_id, original * delta)
            var result := skeleton.get_bone_pose_rotation(bone_id)
            if abs(result.angle_to(original) - 0.2) > 0.01:
                failures.append("%s: %s rotation did not apply" % [path, bone_name])
                pose_ok = false
            skeleton.set_bone_pose_rotation(bone_id, original)
            if skeleton.get_bone_pose_rotation(bone_id).angle_to(original) > 0.001:
                failures.append("%s: %s pose did not restore" % [path, bone_name])
                pose_ok = false
        if pose_ok:
            tested += 1
        root.free()
    print("Chibi pose smoke test: %d/%d passed" % [tested, CLASSES.size()])
    for failure in failures:
        push_error(failure)
    quit(1 if not failures.is_empty() else 0)


func _find_skeleton(node: Node) -> Skeleton3D:
    if node is Skeleton3D:
        return node as Skeleton3D
    for child in node.get_children():
        var found := _find_skeleton(child)
        if found != null:
            return found
    return null
