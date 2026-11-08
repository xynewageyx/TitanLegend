extends SceneTree
## godot --headless --path . --script res://tests/character/test_full_body_prototype.gd

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var hero := TitanFullBodyPrototype.new()
    hero.animate = false
    root.add_child(hero)
    await process_frame
    if hero.skeleton == null:
        push_error("Missing skeleton")
        quit(1)
        return
    var group := hero.get_node_or_null("WeightedLimbs")
    if group == null or group.get_child_count() != 4:
        push_error("Expected four weighted limb sections")
        quit(1)
        return
    for child in group.get_children():
        if not (child is TitanSkinnedLimb) or child.mesh_instance == null:
            push_error("Invalid weighted limb")
            quit(1)
            return
    var torso := hero.get_node_or_null("WeightedTorso") as TitanSkinnedTorso
    if torso == null or torso.mesh_instance == null:
        push_error("Weighted torso was not integrated")
        quit(1)
        return
    var rigid_torso := hero.skeleton.get_node_or_null("Attach_Torso") as BoneAttachment3D
    if rigid_torso == null or rigid_torso.visible:
        push_error("Rigid torso should be hidden")
        quit(1)
        return
    for part_name in ["UpperArm_l", "UpperArm_r", "Forearm_l", "Forearm_r", "Thigh_l", "Thigh_r", "Shin_l", "Shin_r"]:
        var rigid := hero.skeleton.get_node_or_null("Attach_" + part_name) as BoneAttachment3D
        if rigid == null or rigid.visible:
            push_error("Rigid duplicate still visible: " + part_name)
            quit(1)
            return
    hero.motion = "run"
    hero.animate = true
    hero._process(0.1)
    print("PASS: full-body prototype with four weighted limb sections")
    quit(0)
