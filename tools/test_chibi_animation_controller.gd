extends SceneTree
## Integration smoke test: imported clips + ChibiAnimationController, all eleven heroes.
const ControllerScript = preload("res://scripts/animation/chibi_animation_controller.gd")
const HEROES := ["brawler", "druid", "hunter", "mage", "paladin", "priest", "rogue", "shaman", "summoner", "warlock", "warrior"]
const ACTIONS := ["Idle", "Walk", "Attack", "Hit", "Dodge"]


func _initialize() -> void:
    call_deferred("_run")


func _run() -> void:
    var failures: Array[String] = []
    var checked := 0
    for hero_id in HEROES:
        var packed := load("res://assets/heroes/chibi/%s.glb" % hero_id) as PackedScene
        if packed == null:
            failures.append("%s: missing scene" % hero_id)
            continue
        var hero := packed.instantiate()
        get_root().add_child(hero)
        var controller := ControllerScript.new()
        hero.add_child(controller)
        if not controller.configure(hero):
            failures.append("%s: no AnimationPlayer" % hero_id)
            hero.queue_free()
            continue
        var counts: Dictionary = controller.available_actions()
        for action in ACTIONS:
            if int(counts.get(action, 0)) < 1:
                failures.append("%s: missing %s clip" % [hero_id, action])
                continue
            if not controller.play_action(action):
                failures.append("%s: cannot play %s" % [hero_id, action])
                continue
            if not controller.animation_player.is_playing():
                failures.append("%s: %s playback not started" % [hero_id, action])
                continue
            checked += 1
        if not controller.set_moving(true):
            failures.append("%s: set_moving(true) failed" % hero_id)
        elif controller.active_action != "Walk":
            failures.append("%s: expected Walk while moving" % hero_id)
        if controller.play_action("Attack"):
            controller._on_animation_finished(StringName("Attack"))
            if controller.active_action != "Walk":
                failures.append("%s: attack did not restore Walk" % hero_id)
        if not controller.set_moving(false):
            failures.append("%s: set_moving(false) failed" % hero_id)
        elif controller.active_action != "Idle":
            failures.append("%s: expected Idle after stopping" % hero_id)
        if not controller.return_to_idle():
            failures.append("%s: return_to_idle failed" % hero_id)
        hero.queue_free()
    print("Chibi animation controller smoke: %d/%d actions started" % [checked, HEROES.size() * ACTIONS.size()])
    for failure in failures:
        push_error(failure)
    quit(1 if not failures.is_empty() else 0)
