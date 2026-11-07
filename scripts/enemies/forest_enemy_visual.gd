extends Node3D
## Runtime wrapper for the nine generated forest GLB enemies.
## Set enemy_id in the inspector, then call play_idle/attack/hit/death from combat.
class_name ForestEnemyVisual

@export_enum("forest_01_mooshuepfer", "forest_02_pilzling", "forest_03_wurzelkrabbler", "forest_04_blattfuchs", "forest_05_dorneneber", "forest_06_rankenwerfer", "forest_elite_01_rindenwaechter", "forest_elite_02_moosbestie", "forest_boss_01_wurzelkoenig")
var enemy_id: String = "forest_01_mooshuepfer"
@export var autoplay_idle := true

var animation_player: AnimationPlayer
var model: Node3D
var is_dead := false

func _ready() -> void:
    var scene := load("res://assets/enemies/forest/%s.glb" % enemy_id) as PackedScene
    if scene == null:
        push_error("ForestEnemyVisual: missing GLB for " + enemy_id)
        return
    model = scene.instantiate() as Node3D
    if model == null:
        push_error("ForestEnemyVisual: GLB root is not Node3D: " + enemy_id)
        return
    add_child(model)
    animation_player = _find_animation_player(model)
    if animation_player == null:
        push_error("ForestEnemyVisual: missing AnimationPlayer: " + enemy_id)
        return
    animation_player.animation_finished.connect(_on_animation_finished)
    if animation_player.has_animation("idle"):
        animation_player.get_animation("idle").loop_mode = Animation.LOOP_LINEAR
    if autoplay_idle:
        play_idle()

func play_idle() -> void:
    if not is_dead:
        _play("idle")

func play_attack() -> void:
    if not is_dead:
        _play("attack")

func play_hit() -> void:
    if not is_dead:
        _play("hit")

func play_death() -> void:
    if is_dead:
        return
    is_dead = true
    _play("death")

func _play(clip: String) -> void:
    if animation_player == null:
        return
    if not animation_player.has_animation(clip):
        push_warning("ForestEnemyVisual: animation missing: " + clip)
        return
    animation_player.stop()
    animation_player.play(clip)
    animation_player.advance(0.0)

func _on_animation_finished(clip: StringName) -> void:
    if is_dead:
        return
    if clip == &"attack" or clip == &"hit":
        play_idle()

func _find_animation_player(node: Node) -> AnimationPlayer:
    if node is AnimationPlayer:
        return node as AnimationPlayer
    for child in node.get_children():
        var found := _find_animation_player(child)
        if found != null:
            return found
    return null
