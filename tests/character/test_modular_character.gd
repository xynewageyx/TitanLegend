extends SceneTree
## Run: godot --headless --path . --script res://tests/character/test_modular_character.gd

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var scene: PackedScene = load("res://scenes/character/titan_modular_character.tscn")
    if scene == null:
        push_error("Modular character scene failed to load")
        quit(1)
        return
    var hero := scene.instantiate() as TitanModularCharacter
    if hero == null:
        push_error("Scene root has wrong script type")
        quit(1)
        return
    root.add_child(hero)
    await process_frame
    var issues := hero.validate_character()
    if not issues.is_empty():
        push_error("Character validation: " + ", ".join(issues))
        quit(1)
        return
    if hero.equip_scene("invalid_slot", scene):
        push_error("Invalid equipment slot was accepted")
        quit(1)
        return
    for hero_class_name in TitanModularCharacter.CLASSES:
        hero.hero_class = hero_class_name
        if not hero.validate_character().is_empty():
            push_error("Class validation failed: " + hero_class_name)
            quit(1)
            return
    hero.clear_slot("hair")
    print("PASS: modular character scene, nine slots and twelve classes")
    quit(0)
