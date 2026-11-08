extends SceneTree
## Headless smoke test for the standalone armor showcase scene.

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed := load("res://scenes/character/titan_armor_showcase.tscn") as PackedScene
    if packed == null:
        push_error("Unable to load armor showcase scene")
        quit(1)
        return
    var scene := packed.instantiate()
    root.add_child(scene)
    await process_frame
    var hero := scene.get_node_or_null("DeathKnight") as TitanFullBodyPrototype
    var camera := scene.get_node_or_null("Camera3D") as Camera3D
    if hero == null or camera == null or not camera.current:
        push_error("Showcase character or active camera missing")
        quit(1)
        return
    if hero.hero_class != "death_knight" or hero.armor_quality != "purple":
        push_error("Incorrect showcase character configuration")
        quit(1)
        return
    var armor := hero.get_node_or_null("ArmorPreview") as TitanArmorPreview
    if armor == null or hero.skeleton == null:
        push_error("Showcase armor not generated")
        quit(1)
        return
    var helmet := hero.skeleton.get_node_or_null("helmet")
    if helmet == null or helmet.get_node_or_null("EnergyGem") == null:
        push_error("Death knight helmet effects missing")
        quit(1)
        return
    print("PASS: death knight armor showcase scene")
    quit(0)
