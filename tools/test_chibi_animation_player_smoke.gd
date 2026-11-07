extends SceneTree
## Exercises AnimationPlayer bone rotation on Chibi rigs using synthetic clips.
## This does not verify imported Unity/Ulala animations.
const HEROES := ["brawler", "druid", "hunter", "mage", "paladin", "priest", "rogue", "shaman", "summoner", "warlock", "warrior"]
const CLIPS := {"idle": {"bone": "Spine", "angle": 0.08}, "run": {"bone": "Leg_L", "angle": 0.35}, "attack": {"bone": "Arm_R", "angle": 0.5}}


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
        for clip_id in CLIPS:
            var spec: Dictionary = CLIPS[clip_id]
            var bone_name: String = spec["bone"]
            var amplitude: float = spec["angle"]
            var bone_id := skeleton.find_bone(bone_name)
            if bone_id < 0:
                failures.append("%s: %s missing" % [hero_id, bone_name])
                continue
            var original := skeleton.get_bone_pose_rotation(bone_id)
            var animation := Animation.new()
            animation.length = 1.0
            var track := animation.add_track(Animation.TYPE_ROTATION_3D)
            animation.track_set_path(track, NodePath("%s:%s" % [str(root.get_path_to(skeleton)), bone_name]))
            animation.rotation_track_insert_key(track, 0.0, original)
            animation.rotation_track_insert_key(track, 0.5, original * Quaternion(Vector3.RIGHT, amplitude))
            animation.rotation_track_insert_key(track, 1.0, original)
            var player := AnimationPlayer.new()
            player.name = "Smoke_" + clip_id
            root.add_child(player)
            player.root_node = NodePath("..")
            var library := AnimationLibrary.new()
            library.add_animation(clip_id, animation)
            player.add_animation_library("smoke", library)
            player.play("smoke/" + clip_id)
            player.seek(0.5, true)
            var middle := skeleton.get_bone_pose_rotation(bone_id)
            if abs(middle.angle_to(original) - amplitude) > 0.05:
                failures.append("%s: %s midpoint pose mismatch" % [hero_id, clip_id])
            else:
                player.seek(1.0, true)
                if skeleton.get_bone_pose_rotation(bone_id).angle_to(original) > 0.05:
                    failures.append("%s: %s did not restore pose" % [hero_id, clip_id])
                else:
                    passed += 1
            player.stop()
            skeleton.set_bone_pose_rotation(bone_id, original)
            player.queue_free()
        root.queue_free()
    print("Chibi AnimationPlayer smoke test: %d/%d passed" % [passed, HEROES.size() * CLIPS.size()])
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
