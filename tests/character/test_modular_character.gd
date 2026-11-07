extends SceneTree
## Validate twelve-class modular character scene, bone sockets, and equipment.
func _initialize() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error(message)
    quit(1)

func _run() -> void:
    var scene := load("res://scenes/character/titan_modular_character.tscn") as PackedScene
    if scene == null:
        _fail("Missing modular character scene")
        return
    var hero := scene.instantiate() as TitanModularCharacter
    if hero == null:
        _fail("Unexpected modular character root")
        return
    root.add_child(hero)
    await process_frame
    var problems := hero.validate_character()
    if not problems.is_empty():
        _fail("Character validation: " + ", ".join(problems))
        return
    var skeleton := hero.get_node_or_null("Skeleton3D") as Skeleton3D
    if skeleton == null or skeleton.get_bone_count() != 18:
        _fail("Character must contain 18 original bones")
        return
    for hero_type in TitanModularCharacter.CLASSES:
        hero.hero_class = hero_type
        if not hero.validate_character().is_empty():
            _fail("Hero class did not validate: " + hero_type)
            return
    if not hero.equip_socket_hairstyle(2, Color("#b56c3a")):
        _fail("Cannot equip hairstyle to head bone")
        return
    if not hero.equip_socket_armor("ChestSocket", 11, 5):
        _fail("Cannot equip legendary armor for death knight")
        return
    await process_frame
    var head := skeleton.get_node_or_null("HeadSocket") as BoneAttachment3D
    var chest := skeleton.get_node_or_null("ChestSocket") as BoneAttachment3D
    if head == null or chest == null or head.get_child_count() != 1 or chest.get_child_count() != 1:
        _fail("Bone sockets did not receive costume pieces")
        return
    if int(chest.get_child(0).get("class_id")) != 11:
        _fail("Death knight class ID lost in bone attachment")
        return
    if hero.equip_scene("invalid_slot", scene):
        _fail("Accepted invalid logical equipment slot")
        return
    print("MODULAR RIG SCENE PASSED: 12 classes, 18 bones, hair and armor anchors")
    quit(0)
