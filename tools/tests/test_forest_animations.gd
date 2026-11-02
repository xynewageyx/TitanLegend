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
            for track in animation.get_track_count():
                if animation.track_get_type(track) in [Animation.TYPE_POSITION_3D, Animation.TYPE_ROTATION_3D, Animation.TYPE_SCALE_3D]:
                    has_transform_track = true
                    break
            if not has_transform_track:
                failures.append("%s: %s has no 3D motion tracks" % [enemy, clip])
                continue
            player.play(clip)
            player.advance(0.0)
            player.seek(minf(animation.length * 0.5, animation.length - 0.0001), true)
            player.advance(0.0)
            player.stop()
            tested += 1
        instance.free()
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
