extends SceneTree
## Exercises actual AnimationPlayer playback on imported Chibi Skeleton3D rigs.
## Uses synthetic animation, not Unity/Ulala animation assets.

const HEROES := ["brawler", "druid", "hunter", "mage", "paladin", "priest", "rogue", "shaman", "summoner", "warlock", "warrior"]


func _initialize() -> void:
    call_deferred("_run")


func _run() -> void:
    var failures: Array[String] = []
    var passed := 0
    for hero_id in HEROES:
        var packed := load("res://assets/heroes/chibi/%s.glb" % hero_id) as PackedScene
        if packed == null:
            failures.append("%s: scene missing" % hero_id)
            continue
        var root := packed.instantiate()
        get_root().add_child(root)
        var skeleton := _find_skeleton(root)
        if skeleton == null:
            failures.append("%s: Skeleton3D missing" % hero_id)
            root.queue_free()
            continue
        var bone_id := skeleton.find_bone("Arm_R")
        if bone_id < 0:
            failures.append("%s: Arm_R missing" % hero_id)
            root.queue_free()
            continue
        var original := skeleton.get_bone_pose_rotation(bone_id)
        var animation := Animation.new()
        animation.length = 1.0
        var track := animation.add_track(Animation.TYPE_ROTATION_3D)
        var player := AnimationPlayer.new()
        player.name = "ProceduralAnimationSmoke"
        root.add_child(player)
        player.root_node = NodePath("..")
        animation.track_set_path(track, NodePath("%s:Arm_R" % str(root.get_path_to(skeleton))))
        animation.rotation_track_insert_key(track, 0.0, original)
        animation.rotation_track_insert_key(track, 0.5, original * Quaternion(Vector3.RIGHT, 0.5))
        animation.rotation_track_insert_key(track, 1.0, original)
        var library := AnimationLibrary.new()
        library.add_animation("attack_smoke", animation)
        player.add_animation_library("smoke", library)
        player.play("smoke/attack_smoke")
        player.seek(0.5, true)
        var middle := skeleton.get_bone_pose_rotation(bone_id)
        if abs(middle.angle_to(original) - 0.5) > 0.05:
            failures.append("%s: AnimationPlayer did not pose Arm_R" % hero_id)
        else:
            player.seek(1.0, true)
            if skeleton.get_bone_pose_rotation(bone_id).angle_to(original) > 0.05:
                failures.append("%s: animation did not restore Arm_R" % hero_id)
            else:
                passed += 1
        skeleton.set_bone_pose_rotation(bone_id, original)
        root.queue_free()
    print("Chibi AnimationPlayer smoke test: %d/%d passed" % [passed, HEROES.size()])
    for failure in failures:
        push_error(failure)
    quit(0 if failures.is_empty() else 1)


func _find_skeleton(node: Node) -> Skeleton3D:
    if node is Skeleton3D:
        return node as Skeleton3D
    for child in node.get_children():
        var found := _find_skeleton(child)
        if found != null:
            return found
    return null
