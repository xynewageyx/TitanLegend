extends SceneTree
## godot --headless --path . --script res://tests/character/test_armor_preview.gd

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var hero := TitanFullBodyPrototype.new()
    hero.animate = false
    hero.armor_quality = "purple"
    root.add_child(hero)
    await process_frame
    var armor := hero.get_node_or_null("ArmorPreview") as TitanArmorPreview
    if armor == null:
        push_error("Armor preview missing")
        quit(1)
        return
    if not _check_count(hero.skeleton, 8):
        quit(1)
        return
    if not armor.build_armor(hero.skeleton, "orange") or not _check_count(hero.skeleton, 8):
        quit(1)
        return
    if armor.build_armor(hero.skeleton, "invalid"):
        push_error("Invalid tier accepted")
        quit(1)
        return
    for hero_class in TitanModularCharacter.CLASSES:
        if not armor.build_armor(hero.skeleton, "purple", hero_class):
            push_error("Armor build failed for " + hero_class)
            quit(1)
            return
        if not _check_count(hero.skeleton, 8):
            quit(1)
            return
    if not armor.build_armor(hero.skeleton, "purple", "death_knight"):
        quit(1)
        return
    var helmet := hero.skeleton.get_node_or_null("helmet")
    if helmet == null or helmet.get_child_count() < 4:
        push_error("Death knight helmet spikes missing")
        quit(1)
        return
    var chest := hero.skeleton.get_node_or_null("chestplate")
    if chest == null or chest.get_node_or_null("ChestEmblem") == null:
        push_error("High-tier chest emblem missing")
        quit(1)
        return
    if helmet.get_node_or_null("EnergyGem") == null:
        push_error("High-tier helmet energy gem missing")
        quit(1)
        return
    if not armor.build_armor(hero.skeleton, "white", "death_knight"):
        quit(1)
        return
    var white_helmet := hero.skeleton.get_node_or_null("helmet")
    if white_helmet == null or white_helmet.get_node_or_null("EnergyGem") != null:
        push_error("Low-tier armor must not have energy gems")
        quit(1)
        return
    if armor.build_armor(hero.skeleton, "purple", "unknown_class"):
        push_error("Invalid class accepted")
        quit(1)
        return
    armor.clear_armor()
    if not _check_count(hero.skeleton, 0):
        quit(1)
        return
    print("PASS: eight modular armor pieces, rebuild and cleanup")
    quit(0)

func _check_count(skeleton: Skeleton3D, expected: int) -> bool:
    var count := 0
    for child in skeleton.get_children():
        if child is BoneAttachment3D and child.has_meta("titan_armor_preview"):
            count += 1
    if count != expected:
        push_error("Armor count: " + str(count) + " expected " + str(expected))
        return false
    return true
