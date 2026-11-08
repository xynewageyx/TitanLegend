extends Node
## Reusable lightweight animation controller for Titan Legends character previews.
## Attach under a Node3D actor and assign its root through actor_path.
## Does not override gameplay skill selection or audio routing.
class_name TitanCharacterMotion

@export var actor_path: NodePath = NodePath("..")
@export var idle_bob_height: float = 0.035
@export var idle_frequency: float = 2.2
@export var attack_duration: float = 0.28
@export var hit_duration: float = 0.18

var _actor: Node3D
var _base_position: Vector3
var _base_rotation: Vector3
var _time: float = 0.0
var _action: StringName = &"idle"
var _remaining: float = 0.0

func _ready() -> void:
    _actor = get_node_or_null(actor_path) as Node3D
    if _actor == null:
        set_process(false)
        push_warning("TitanCharacterMotion: actor_path must point to Node3D")
        return
    _base_position = _actor.position
    _base_rotation = _actor.rotation

func _process(delta: float) -> void:
    _time += delta
    _remaining = maxf(0.0, _remaining - delta)
    if _remaining <= 0.0:
        _action = &"idle"
    var target_pos := _base_position
    var target_rot := _base_rotation
    match _action:
        &"attack":
            var phase := 1.0 - _remaining / maxf(attack_duration, 0.01)
            target_pos.z -= sin(phase * PI) * 0.12
            target_rot.x -= sin(phase * PI) * 0.12
        &"hit":
            var phase := 1.0 - _remaining / maxf(hit_duration, 0.01)
            target_pos.z += sin(phase * PI) * 0.08
            target_rot.z += sin(phase * PI * 2.0) * 0.06
        &"cast":
            target_pos.y += 0.045
            target_rot.y += sin(_time * 8.0) * 0.035
        _:
            target_pos.y += sin(_time * idle_frequency) * idle_bob_height
    var blend := clampf(delta * 18.0, 0.0, 1.0)
    _actor.position = _actor.position.lerp(target_pos, blend)
    _actor.rotation = _actor.rotation.lerp(target_rot, blend)

func play_attack() -> void:
    _action = &"attack"
    _remaining = attack_duration

func play_hit() -> void:
    _action = &"hit"
    _remaining = hit_duration

func play_cast(duration: float = 0.5) -> void:
    _action = &"cast"
    _remaining = maxf(duration, 0.01)

func reset_pose() -> void:
    _action = &"idle"
    _remaining = 0.0
    if _actor != null:
        _actor.position = _base_position
        _actor.rotation = _base_rotation
