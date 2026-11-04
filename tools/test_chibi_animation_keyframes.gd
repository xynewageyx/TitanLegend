extends SceneTree
## Headless animation playback smoke test for the eleven imported Chibi rigs.
## Procedural placeholder clips; NOT converted Unity animation data.

const HEROES := ["brawler", "druid", "hunter", "mage", "paladin", "priest", "rogue", "shaman", "summoner", "warlock", "warrior"]
const CLIPS := ["idle", "run", "attack"]


func _initialize() -> void:
    var failures: Array[String] = []
    var tested := 0
    for hero_id in HEROES:
        var scene_path := "res://assets/heroes/chibi/%s.glb" % hero_id
        var packed := load(scene_path) as PackedScene
        if packed == null:
            failures.append("%s: load failed" % scene_path)
            continue
        var root := packed.instantiate()
        var skeleton := _find_skeleton(root)
        if skeleton == null:
            failures.append("%s: Skeleton3D missing" % scene_path)
            root.free()
            continue
        for clip_id in CLIPS:
            var bone_name := "Spine" if clip_id == "idle" else ("Leg_L" if clip_id == "run" else "Arm_R")
            var bone_id := skeleton.find_bone(bone_name)
            if bone_id < 0:
                failures.append("%s: %s missing" % [scene_path, bone_name])
                continue
            var original := skeleton.get_bone_pose_rotation(bone_id)
            var clip := Animation.new()
            clip.length = 0.6
            var track := clip.add_track(Animation.TYPE_ROTATION_3D)
            clip.track_set_path(track, NodePath(".:%s" % bone_name))
            var amplitude := 0.08 if clip_id == "idle" else (0.35 if clip_id == "run" else 0.7)
            clip.rotation_track_insert_key(track, 0.0, original)
            clip.rotation_track_insert_key(track, 0.3, original * Quaternion(Vector3.RIGHT, amplitude))
            clip.rotation_track_insert_key(track, 0.6, original)
            var middle := clip.rotation_track_interpolate(track, 0.3)
            if abs(middle.angle_to(original) - amplitude) > 0.02:
                failures.append("%s: %s keyframe interpolation failed" % [scene_path, clip_id])
            else:
                tested += 1
        root.free()
    print("Chibi procedural animation keyframe test: %d/%d passed" % [tested, HEROES.size() * CLIPS.size()])
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
