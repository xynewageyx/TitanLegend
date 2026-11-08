extends SceneTree
## End-to-end runtime smoke test using Titan Legends' actual modular character
## scene and original procedural assets (not imported reference-game meshes).
const SCENE = preload("res://scenes/character/titan_modular_character.tscn")
const ADAPTER = preload("res://scripts/equipment/formation_equipment_adapter.gd")
const RARITIES := [0, 3, 5]

func _initialize() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error(message)
    quit(1)

func _run() -> void:
    var armor_checks := 0
    for class_id in range(TitanModularCharacter.CLASSES.size()):
        var hero := SCENE.instantiate() as TitanModularCharacter
        if hero == null:
            _fail("Cannot instantiate TitanModularCharacter")
            return
        hero.hero_class = TitanModularCharacter.CLASSES[class_id]
        hero.name = "HeroClass_%d" % class_id
        root.add_child(hero)
        await process_frame
        var skeleton := hero.get_node_or_null("Skeleton3D") as Skeleton3D
        var player := hero.get_node_or_null("Skeleton3D/TitanAnimations") as AnimationPlayer
        if skeleton == null or skeleton.get_bone_count() != 18 or player == null:
            _fail("Incorrect modular skeleton/animation player for class %d" % class_id)
            return
        for motion in ["idle", "run", "attack", "cast", "hit"]:
            if not player.has_animation("titan/" + motion):
                _fail("Missing bone animation %s for class %d" % [motion, class_id])
                return
        if not hero.validate_character().is_empty():
            _fail("Modular character failed validation for class %d" % class_id)
            return
        for rarity in RARITIES:
            if not hero.equip_visual_loadout(rarity):
                _fail("Failed to equip class %d at rarity %d" % [class_id, rarity])
                return
            await process_frame
            var armor_count := 0
            for socket_name in ADAPTER.SOCKETS:
                if socket_name in ["RightHandSocket", "LeftHandSocket"]:
                    continue
                var socket := skeleton.get_node_or_null(NodePath(socket_name)) as BoneAttachment3D
                if socket == null or socket.get_child_count() != 1:
                    _fail("Missing/duplicate armor on %s class=%d rarity=%d" % [socket_name, class_id, rarity])
                    return
                var armor := socket.get_child(0)
                if int(armor.get("class_id")) != class_id or int(armor.get("rarity")) != rarity:
                    _fail("Incorrect armor class/rarity at " + socket_name)
                    return
                if armor.get_child_count() == 0:
                    _fail("Missing armor geometry at " + socket_name)
                    return
                armor_count += 1
            if armor_count != 13:
                _fail("Expected 13 animated armor sockets")
                return
            armor_checks += armor_count
            var weapon_socket := skeleton.get_node_or_null("RightHandSocket") as BoneAttachment3D
            if weapon_socket == null or weapon_socket.get_child_count() != 1:
                _fail("Missing weapon socket or duplicated weapon for class %d" % class_id)
                return
            var weapon := weapon_socket.get_child(0)
            if int(weapon.get("weapon_type")) != ADAPTER.weapon_type_for_class(class_id):
                _fail("Incorrect class-specific weapon for class %d" % class_id)
                return
            if int(weapon.get("rarity")) != rarity or weapon.get_child_count() == 0:
                _fail("Invalid weapon quality/geometry for class %d" % class_id)
                return
        var equipped_weapon := (skeleton.get_node("RightHandSocket") as BoneAttachment3D).get_child(0) as Node3D
        var equipped_chest := (skeleton.get_node("ChestSocket") as BoneAttachment3D).get_child(0) as Node3D
        if not hero.play_preview_motion("attack"):
            _fail("Cannot play attack motion for class %d" % class_id)
            return
        player.seek(0.0, true)
        skeleton.force_update_all_bone_transforms()
        await process_frame
        var initial_weapon_basis := equipped_weapon.global_transform.basis
        var initial_chest_basis := equipped_chest.global_transform.basis
        player.seek(0.30, true)
        skeleton.force_update_all_bone_transforms()
        await process_frame
        if initial_weapon_basis.is_equal_approx(equipped_weapon.global_transform.basis):
            _fail("Weapon does not follow attack animation for class %d" % class_id)
            return
        if initial_chest_basis.is_equal_approx(equipped_chest.global_transform.basis):
            _fail("Chest armor does not follow spine animation for class %d" % class_id)
            return
        if hero.play_preview_motion("unknown"):
            _fail("Unknown motion must not be accepted")
            return
        hero.queue_free()
        await process_frame
    print("TITAN_12_CLASS_ANIMATED_EQUIPMENT_OK classes=12 rarities=3 armor_placements=%d" % armor_checks)
    quit(0)
