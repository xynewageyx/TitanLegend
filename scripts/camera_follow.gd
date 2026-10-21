extends Camera3D

@export var target_path: NodePath = NodePath("../TeamFormation")
@export var camera_offset: Vector3 = Vector3(0.0, 11.8, 16.5)
@export var look_ahead: Vector3 = Vector3(0.0, 1.2, -5.5)
@export var smoothing: float = 3.0

@onready var target: Node3D = get_node_or_null(target_path) as Node3D

func _ready() -> void:
	current = true
	fov = 58.0
	if target != null:
		global_position = target.global_position + camera_offset
		look_at(target.global_position + look_ahead, Vector3.UP)

func _process(delta: float) -> void:
	if target == null:
		return
	var desired_position: Vector3 = target.global_position + camera_offset
	global_position = global_position.lerp(desired_position, clampf(delta * smoothing, 0.0, 1.0))
	look_at(target.global_position + look_ahead, Vector3.UP)
