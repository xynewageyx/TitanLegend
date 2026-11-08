extends SceneTree
## Run: godot --headless --path . --script res://tests/character/test_character_prototype.gd

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var preview := TitanCharacterPrototype.new()
    root.add_child(preview)
    for hero_class in TitanModularCharacter.CLASSES:
        preview.hero_class = hero_class
        if not preview.build_preview():
            push_error("Preview generation failed for " + hero_class)
            quit(1)
            return
        var group := preview.get_node_or_null("GeneratedPreview")
        if group == null or group.get_child_count() < 10:
            push_error("Incomplete preview for " + hero_class)
            quit(1)
            return
    preview.hero_class = "invalid"
    if preview.build_preview():
        push_error("Invalid class accepted")
        quit(1)
        return
    var preserved := preview.get_node_or_null("GeneratedPreview")
    if preserved == null or preserved.get_child_count() < 10:
        push_error("Invalid class must preserve the last valid character preview")
        quit(1)
        return
    print("PASS: all twelve original character blockout silhouettes")
    quit(0)
