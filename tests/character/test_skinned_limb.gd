extends SceneTree
## godot --headless --path . --script res://tests/character/test_skinned_limb.gd

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var rig := TitanHumanoidRigBuilder.new()
    root.add_child(rig)
    var skeleton := Skeleton3D.new()
    skeleton.name = "Skeleton3D"
    rig.add_child(skeleton)
    if not rig.build_rig(skeleton):
        push_error("Cannot build rig")
        quit(1)
        return
    var limb := TitanSkinnedLimb.new()
    rig.add_child(limb)
    if not limb.build_limb(skeleton, "upper_arm_l", "lower_arm_l"):
        push_error("Cannot create skinned limb")
        quit(1)
        return
    var surface := limb.mesh_instance.mesh as ArrayMesh
    var arrays := surface.surface_get_arrays(0)
    var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
    if vertices.size() != 56 or weights.size() != vertices.size() * 4:
        push_error("Invalid skinned mesh vertex/weight count")
        quit(1)
        return
    if limb.build_limb(skeleton, "head", "foot_l"):
        push_error("Non-parent chain should be rejected")
        quit(1)
        return
    print("PASS: weighted two-bone mesh and skin bindings")
    quit(0)
