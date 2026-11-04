extends SceneTree
## Headless smoke test: verify imported Chibi rigs accept a temporary bone pose.
## This does NOT validate Unity animation retargeting.

const CLASSES := ["brawler", "druid", "hunter", "mage", "paladin", "priest", "rogue", "shaman", "summoner", "warlock", "warrior"]


func _initialize() -> void:
    var failures: Array[String] = []
    var tested := 0
    for class_name in CLASSES:
        var path := "res://assets/heroes/chibi/%s.glb" % class_name
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
        var head := skeleton.find_bone("Head")
        if head < 0:
            failures.append("%s: Head bone missing" % path)
            root.free()
            continue
        var original := skeleton.get_bone_pose_rotation(head)
        var delta := Quaternion(Vector3.UP, 0.2)
        skeleton.set_bone_pose_rotation(head, original * delta)
        var result := skeleton.get_bone_pose_rotation(head)
        if abs(result.angle_to(original) - 0.2) > 0.01:
            failures.append("%s: bone rotation did not apply" % path)
        else:
            tested += 1
        skeleton.set_bone_pose_rotation(head, original)
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
