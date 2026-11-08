extends SceneTree
## Godot runtime check: original humanoid rest skeleton and bone-mounted sockets.

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var builder := TitanHumanoidRigBuilder.new()
    var skeleton := Skeleton3D.new()
    root.add_child(skeleton)
    if not builder.build_rig(skeleton):
        push_error("Original 18-bone humanoid rig could not be built")
        quit(1)
        return
    if skeleton.get_bone_count() != 18:
        push_error("Unexpected humanoid bone count: %d" % skeleton.get_bone_count())
        quit(1)
        return
    var issues := builder.validate_rig(skeleton)
    if not issues.is_empty():
        push_error("Rig validation issues: " + "; ".join(issues))
        quit(1)
        return
    if builder.build_rig(skeleton):
        push_error("Builder should not overwrite an existing rig")
        quit(1)
        return
    print("RIG SMOKE PASSED: 18 original bones, 19 bone-mounted sockets, no overwrite")
    # Release the prototype builder and attached scene nodes before headless exit.
    builder.free()
    skeleton.queue_free()
    await process_frame
    quit(0)
