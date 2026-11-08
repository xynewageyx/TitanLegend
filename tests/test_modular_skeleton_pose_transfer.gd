extends SceneTree
# Synthetic, non-proprietary Godot 4.7.2 Skeleton3D runtime test.
# Compare 64 shared bones in a 65-joint rig and a 66-joint rig.
const COMMON_BONES := 64
const TIMES := [0.0, 0.25, 0.5, 0.75, 1.0]

func _initialize() -> void:
    call_deferred("_run")

func _bone_name(i: int) -> String:
    return "CommonJoint_%02d" % i

func _make_rig(label: String, extras: PackedStringArray) -> Skeleton3D:
    var skeleton := Skeleton3D.new()
    skeleton.name = label
    root.add_child(skeleton)
    for i in range(COMMON_BONES):
        var idx := skeleton.add_bone(_bone_name(i))
        if i > 0:
            skeleton.set_bone_parent(idx, int((i - 1) / 2))
        var offset := Vector3(float(i % 3) * 0.025, 0.05 + float(i % 5) * 0.01, float(i % 2) * 0.015)
        skeleton.set_bone_rest(idx, Transform3D(Basis.IDENTITY, offset))
    for i in range(extras.size()):
        var idx := skeleton.add_bone(extras[i])
        skeleton.set_bone_parent(idx, 5 if i % 2 == 0 else 10)
        skeleton.set_bone_rest(idx, Transform3D(Basis.IDENTITY, Vector3(0, 0.07, 0)))
    return skeleton

func _run() -> void:
    var source := _make_rig("Source", PackedStringArray(["OptionalNeck"]))
    var target := _make_rig("Target", PackedStringArray(["OptionalClothA", "OptionalClothB"]))
    if source.get_bone_count() != 65 or target.get_bone_count() != 66:
        _fail("Incorrect rig bone counts")
        return
    if target.find_bone("OptionalNeck") >= 0 or source.find_bone("OptionalClothA") >= 0:
        _fail("Optional joints unexpectedly shared")
        return
    for phase in TIMES:
        for i in range(COMMON_BONES):
            var bone := source.find_bone(_bone_name(i))
            var angle := 0.3 * sin(phase * TAU + float(i) * 0.12)
            source.set_bone_pose_rotation(bone, Quaternion(Vector3.UP, angle))
            source.set_bone_pose_position(bone, Vector3(0, 0.01 * sin(phase * TAU + float(i)), 0))
        for i in range(COMMON_BONES):
            var src := source.find_bone(_bone_name(i))
            var dst := target.find_bone(_bone_name(i))
            if src < 0 or dst < 0:
                _fail("Shared joint is missing")
                return
            if source.get_bone_parent(src) != target.get_bone_parent(dst):
                _fail("Joint hierarchy differs")
                return
            if source.get_bone_rest(src) != target.get_bone_rest(dst):
                _fail("Joint rest transform differs")
                return
            target.set_bone_pose_rotation(dst, source.get_bone_pose_rotation(src))
            target.set_bone_pose_position(dst, source.get_bone_pose_position(src))
            var alignment := absf(source.get_bone_pose_rotation(src).dot(target.get_bone_pose_rotation(dst)))
            var distance := source.get_bone_pose_position(src).distance_to(target.get_bone_pose_position(dst))
            if alignment < 0.99999 or distance > 0.00001:
                _fail("Transferred pose differs")
                return
    print("MODULAR_RIG_POSE_TRANSFER_OK shared=64 source=65 target=66 samples=5")
    root.remove_child(source)
    root.remove_child(target)
    source.free()
    target.free()
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
