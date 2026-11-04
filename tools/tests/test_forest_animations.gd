extends SceneTree

const ENEMIES := [
    "forest_01_mooshuepfer", "forest_02_pilzling",
    "forest_03_wurzelkrabbler", "forest_04_blattfuchs",
    "forest_05_dorneneber", "forest_06_rankenwerfer",
    "forest_elite_01_rindenwaechter", "forest_elite_02_moosbestie",
    "forest_boss_01_wurzelkoenig"
]
const CLIPS := ["idle", "attack", "hit", "death"]

func _initialize() -> void:
    # The SceneTree root is not fully initialized inside _initialize().
    # Defer the test so child _ready() callbacks can load their GLB models.
    call_deferred("_run_tests")

func _run_tests() -> void:
    var failures: Array[String] = []
    var tested := 0
    for enemy in ENEMIES:
        var path := "res://assets/enemies/forest/%s.glb" % enemy
        var scene := load(path) as PackedScene
        if scene == null:
            failures.append("%s: cannot load scene" % enemy)
            continue
        var instance := scene.instantiate()
        if instance == null:
            failures.append("%s: cannot instantiate scene" % enemy)
            continue
        root.add_child(instance)
        var mesh_count := _count_meshes(instance)
        if mesh_count < 8:
            failures.append("%s: too few visible mesh nodes (%d)" % [enemy, mesh_count])
        var player := _find_player(instance)
        if player == null:
            failures.append("%s: missing AnimationPlayer" % enemy)
            instance.free()
            continue
        for clip in CLIPS:
            if not player.has_animation(clip):
                failures.append("%s: missing %s (found %s)" % [enemy, clip, str(player.get_animation_list())])
                continue
            var animation := player.get_animation(clip)
            if animation == null or animation.get_track_count() == 0:
                failures.append("%s: empty %s" % [enemy, clip])
                continue
            if animation.length <= 0.0:
                failures.append("%s: %s has zero duration" % [enemy, clip])
                continue
            var has_transform_track := false
            var has_keyframes := false
            for track in animation.get_track_count():
                if animation.track_get_type(track) in [Animation.TYPE_POSITION_3D, Animation.TYPE_ROTATION_3D, Animation.TYPE_SCALE_3D]:
                    has_transform_track = true
                    if animation.track_get_key_count(track) >= 2:
                        has_keyframes = true
            if not has_transform_track:
                failures.append("%s: %s has no 3D motion tracks" % [enemy, clip])
                continue
            if not has_keyframes:
                failures.append("%s: %s has no animated 3D keyframe sequence" % [enemy, clip])
                continue
            var has_actual_motion := false
            for track in animation.get_track_count():
                if animation.track_get_type(track) not in [Animation.TYPE_POSITION_3D, Animation.TYPE_ROTATION_3D, Animation.TYPE_SCALE_3D]:
                    continue
                if animation.track_get_key_count(track) < 2:
                    continue
                var first_value: Variant = animation.track_get_key_value(track, 0)
                for key_index in range(1, animation.track_get_key_count(track)):
                    if animation.track_get_key_value(track, key_index) != first_value:
                        has_actual_motion = true
                        break
                if has_actual_motion:
                    break
            if not has_actual_motion:
                failures.append("%s: %s has identical 3D poses in all keyframes" % [enemy, clip])
                continue
            player.play(clip)
            player.advance(0.0)
            player.seek(minf(animation.length * 0.5, animation.length - 0.0001), true)
            player.advance(0.0)
            player.stop()
            tested += 1
        instance.free()
    # Exercise the presenter actually used by BattleManager.
    var presenter_script := load("res://scripts/forest_enemy_visual.gd") as GDScript
    if presenter_script == null:
        failures.append("BattleManager forest presenter script cannot load")
    else:
        for index in range(ENEMIES.size()):
            var presenter := presenter_script.new() as Node3D
            root.add_child(presenter)
            var short_id: String = ENEMIES[index].get_slice("_", 0) + "_" + ENEMIES[index].get_slice("_", 1)
            if index >= 6:
                short_id = "forest_elite_01" if index == 6 else ("forest_elite_02" if index == 7 else "forest_boss_01")
            if not presenter.call("show_enemy", short_id):
                failures.append("%s: BattleManager presenter cannot load model" % ENEMIES[index])
            else:
                for clip in CLIPS:
                    if not presenter.call("play_clip", clip):
                        failures.append("%s: BattleManager presenter cannot play %s" % [ENEMIES[index], clip])
                # Death is terminal: late hit/attack events must not resurrect a mob.
                if presenter.call("play_clip", "attack"):
                    failures.append("%s: dead presenter accepted attack" % ENEMIES[index])
                if presenter.call("play_clip", "idle"):
                    failures.append("%s: dead presenter accepted idle" % ENEMIES[index])
                # Reusing the presenter for a new spawn must reset death state.
                if not presenter.call("show_enemy", short_id):
                    failures.append("%s: presenter cannot respawn" % ENEMIES[index])
                elif not presenter.call("play_clip", "attack"):
                    failures.append("%s: respawned presenter remains dead" % ENEMIES[index])
            presenter.free()
    var controller_script := load("res://scripts/enemies/forest_enemy_visual.gd") as GDScript
    if controller_script == null:
        failures.append("ForestEnemyVisual controller script cannot load")
    else:
        for enemy in ENEMIES:
            var visual := controller_script.new() as Node3D
            if visual == null:
                failures.append("%s: cannot instantiate visual controller" % enemy)
                continue
            visual.set("enemy_id", enemy)
            visual.set("autoplay_idle", false)
            root.add_child(visual)
            var loaded_model: Variant = visual.get("model")
            var loaded_player: Variant = visual.get("animation_player")
            if loaded_model == null or loaded_player == null:
                failures.append("%s: visual controller did not load model and animation player" % enemy)
            else:
                visual.call("play_idle")
                visual.call("play_attack")
                visual.call("play_hit")
                visual.call("play_death")
                if visual.get("is_dead") != true:
                    failures.append("%s: visual controller death state not set" % enemy)
            visual.free()
    if not failures.is_empty():
        for failure in failures:
            printerr("FOREST ANIMATION TEST FAILED: ", failure)
        quit(1)
        return
    print("FOREST ANIMATION TEST PASSED: %d clips on %d enemies" % [tested, ENEMIES.size()])
    quit(0)

func _find_player(node: Node) -> AnimationPlayer:
    if node is AnimationPlayer:
        return node as AnimationPlayer
    for child in node.get_children():
        var found := _find_player(child)
        if found != null:
            return found
    return null

func _count_meshes(node: Node) -> int:
    var count := 1 if node is MeshInstance3D and (node as MeshInstance3D).mesh != null else 0
    for child in node.get_children():
        count += _count_meshes(child)
    return count
