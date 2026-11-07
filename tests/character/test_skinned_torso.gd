extends SceneTree
## godot --headless --path . --script res://tests/character/test_skinned_torso.gd

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var builder := TitanHumanoidRigBuilder.new()
    root.add_child(builder)
    var skeleton := Skeleton3D.new()
    skeleton.name = "Skeleton3D"
    builder.add_child(skeleton)
    if not builder.build_rig(skeleton):
        push_error("Rig generation failed")
        quit(1)
        return
    var torso := TitanSkinnedTorso.new()
    builder.add_child(torso)
    if not torso.build_torso(skeleton):
        push_error("Torso generation failed")
        quit(1)
        return
    var arrays := (torso.mesh_instance.mesh as ArrayMesh).surface_get_arrays(0)
    var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
    if vertices.size() != 108 or weights.size() != 432:
        push_error("Incorrect torso geometry dimensions")
        quit(1)
        return
    for vertex in range(vertices.size()):
        var start := vertex * 4
        var total := weights[start] + weights[start + 1] + weights[start + 2] + weights[start + 3]
        if absf(total - 1.0) > 0.001:
            push_error("Unnormalized torso skin weights")
            quit(1)
            return
    print("PASS: continuous weighted torso, 108 vertices, normalized weights")
    quit(0)
