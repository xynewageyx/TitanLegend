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
    hero.motion = "run"
    hero.animate = true
    hero._process(0.1)
    print("PASS: full-body prototype with four weighted limb sections")
    quit(0)
