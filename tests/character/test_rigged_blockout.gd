extends SceneTree
## Run: godot --headless --path . --script res://tests/character/test_rigged_blockout.gd

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var hero := TitanRiggedBlockout.new()
    hero.animate = false
    root.add_child(hero)
    await process_frame
    for hero_class in TitanModularCharacter.CLASSES:
        hero.hero_class = hero_class
        if not hero.build_character():
            push_error("Build failed: " + hero_class)
            quit(1)
            return
        if hero.skeleton == null or hero.skeleton.get_bone_count() != TitanHumanoidRigBuilder.BONES.size():
            push_error("Invalid skeleton: " + hero_class)
            quit(1)
            return
        var attachments := 0
        for child in hero.skeleton.get_children():
            if child is BoneAttachment3D and child.name.begins_with("Attach_"):
                attachments += 1
        if attachments != 15:
            push_error("Expected 15 body attachments, got " + str(attachments))
            quit(1)
            return
    hero.motion = "attack"
    hero.animate = true
    hero._process(0.1)
    print("PASS: all twelve rigged blockouts and bone attachments")
    quit(0)
