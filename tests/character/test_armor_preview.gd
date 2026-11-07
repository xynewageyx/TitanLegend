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
