extends SceneTree
## Exercises actual AnimationPlayer playback on imported Chibi Skeleton3D rigs.
## Uses synthetic animation, not Unity/Ulala animation assets.

const CLIPS := {"idle": {"bone": "Spine", "angle": 0.08}, "run": {"bone": "Leg_L", "angle": 0.35}, "attack": {"bone": "Arm_R", "angle": 0.5}}
const HEROES := ["brawler", "druid", "hunter", "mage", "paladin", "priest", "rogue", "shaman", "summoner", "warlock", "warrior"]


func _initialize() -> void:
    call_deferred("_run")


func _run() -> void:
    var failures: Array[String] = []
    var passed := 0
    for hero_id in HEROES:
        var packed := load("res://assets/heroes/chibi/%s.glb" % hero_id) as PackedScene
        if packed == null:
            failures.append("%s: scene missing" % hero_id)
            continue
        var root := packed.instantiate()
        get_root().add_child(root)
        var skeleton := _find_skeleton(root)
        if skeleton == null:
            failures.append("%s: Skeleton3D missing" % hero_id)
            root.queue_free()
    print("Chibi AnimationPlayer smoke test: %d/%d passed" % [passed, HEROES.size() * CLIPS.size()])
    for failure in failures:
        push_error(failure)
    quit(0 if failures.is_empty() else 1)


func _find_skeleton(node: Node) -> Skeleton3D:
    if node is Skeleton3D:
        return node as Skeleton3D
    for child in node.get_children():
        var found := _find_skeleton(child)
        if found != null:
            return found
    return null
