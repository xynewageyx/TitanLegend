extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var scene: PackedScene = load("res://ui/team/titan_team_hud.tscn")
    assert(scene != null, "Team HUD scene must load")
    var hud: TitanTeamHUD = scene.instantiate() as TitanTeamHUD
    assert(hud != null, "HUD script must instantiate")
    root.add_child(hud)
    await process_frame
    assert(hud.get_child_count() == 4, "Exactly four hero cards required")
    var heroes: Array[Dictionary] = [
        {"name":"Krieger", "level":20, "role":"Tank", "hp_ratio":0.5, "leader":true},
        {"name":"Magier", "level":20, "role":"DD", "hp_ratio":0.75},
        {"name":"Priester", "level":20, "role":"Heiler", "hp_ratio":1.0}
    ]
    hud.update_team(heroes)
    var first: TitanTeamCard = hud.get_child(0) as TitanTeamCard
    assert(first.hero_name == "Krieger")
    assert(is_equal_approx(first.health_fraction, 0.5))
    assert(first.is_leader)
    var fourth: TitanTeamCard = hud.get_child(3) as TitanTeamCard
    assert(not fourth.is_occupied)
    hud.size = Vector2(390, 240)
    await process_frame
    assert(hud.columns == 2, "Portrait layout must use two columns")
    hud.size = Vector2(800, 150)
    await process_frame
    assert(hud.columns == 4, "Wide layout must use four columns")
    print("TEAM_HUD_SMOKE_OK")
    quit(0)
