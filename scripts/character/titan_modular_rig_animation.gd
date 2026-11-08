extends AnimationPlayer
## Original lightweight bone tracks for Titan Legends' 18-bone modular preview.
## This is an optional preview controller; it never writes combat, skills or inventory.
## All content is authored for Titan Legends (no reference-game animations).
const MOTIONS := {
    "idle": {
        "upper_arm_l": [0.03, -0.06, 0.03],
        "upper_arm_r": [-0.03, 0.06, -0.03],
        "spine": [0.0, 0.025, 0.0]
    },
    "run": {
        "upper_arm_l": [-0.42, 0.42, -0.42],
        "upper_arm_r": [0.42, -0.42, 0.42],
        "upper_leg_l": [0.48, -0.48, 0.48],
        "upper_leg_r": [-0.48, 0.48, -0.48]
    },
    "attack": {
        "upper_arm_r": [-0.15, -1.05, 0.35],
        "spine": [0.0, -0.2, 0.04],
        "upper_arm_l": [0.0, 0.2, 0.0]
    },
    "cast": {
        "upper_arm_l": [-0.1, -0.95, -0.2],
        "upper_arm_r": [-0.1, -0.95, -0.2],
        "head": [0.0, -0.12, 0.0]
    },
    "hit": {
        "spine": [0.0, 0.24, 0.0],
        "head": [0.0, -0.1, 0.0]
    }
}
const DURATIONS := {
    "idle": 1.2,
    "run": 0.65,
    "attack": 0.60,
    "cast": 0.85,
    "hit": 0.40
}

func setup_rig(skeleton: Skeleton3D) -> bool:
    if skeleton == null or get_parent() != skeleton or skeleton.get_bone_count() == 0:
        return false
    # Do not overwrite hand-authored animations or imported animation libraries.
    if get_animation_library("titan") != null:
        return true
    for motion_name in MOTIONS:
        for bone_name in MOTIONS[motion_name]:
            if skeleton.find_bone(bone_name) < 0:
                push_warning("Titan modular animation missing bone: " + bone_name)
                return false
    root_node = NodePath("..")
    var library := AnimationLibrary.new()
    for motion_name in MOTIONS:
        var clip := Animation.new()
        clip.length = float(DURATIONS[motion_name])
        clip.loop_mode = Animation.LOOP_LINEAR if motion_name in ["idle", "run"] else Animation.LOOP_NONE
        for bone_name in MOTIONS[motion_name]:
            var values: Array = MOTIONS[motion_name][bone_name]
            var track := clip.add_track(Animation.TYPE_ROTATION_3D)
            clip.track_set_path(track, NodePath(".:" + bone_name))
            for key_idx in range(values.size()):
                var at_time := clip.length * float(key_idx) / float(values.size() - 1)
                clip.rotation_track_insert_key(track, at_time, Quaternion(Vector3.RIGHT, float(values[key_idx])))
        if library.add_animation(motion_name, clip) != OK:
            return false
    return add_animation_library("titan", library) == OK

func play_motion(motion_name: String) -> bool:
    var animation_name := "titan/" + motion_name
    if not has_animation(animation_name):
        return false
    play(animation_name)
    return true
