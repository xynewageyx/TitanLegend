extends SceneTree
## Headless scene smoke test for all six rarity tiers.

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed := load("res://scenes/character/titan_armor_tier_gallery.tscn") as PackedScene
    if packed == null:
        push_error("Armor tier gallery scene failed to load")
        quit(1)
        return
    var gallery := packed.instantiate() as TitanArmorTierGallery
    root.add_child(gallery)
    await process_frame
    var characters := gallery.get_node_or_null("Characters")
    if characters == null or characters.get_child_count() != 6:
        push_error("Expected six rarity previews")
        quit(1)
        return
    for tier in TitanArmorTierGallery.QUALITIES:
        var hero := characters.get_node_or_null("Tier_" + tier) as TitanFullBodyPrototype
        if hero == null or hero.armor_quality != tier:
            push_error("Missing or incorrect tier: " + tier)
            quit(1)
            return
        if hero.get_node_or_null("ArmorPreview") == null:
            push_error("Missing generated armor: " + tier)
            quit(1)
            return
    print("PASS: six armor rarity previews generated")
    quit(0)
