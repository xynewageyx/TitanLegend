extends SceneTree
## Run: godot --headless --path . --script res://tests/character/test_humanoid_rig.gd

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var builder := TitanHumanoidRigBuilder.new()
    var skeleton := Skeleton3D.new()
    root.add_child(builder)
    builder.add_child(skeleton)
    if not builder.build_rig(skeleton):
        push_error("Rig generation failed")
        quit(1)
        return
    var issues := builder.validate_rig(skeleton)
    if not issues.is_empty():
        push_error("; ".join(issues))
        quit(1)
        return
    if builder.build_rig(skeleton):
        push_error("Overwriting existing skeleton must be rejected")
        quit(1)
        return
    print("PASS: humanoid rig bones, parents, anchors and overwrite guard")
    quit(0)
