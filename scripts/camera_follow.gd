extends Camera3D

# Portrait-friendly third-person view: the team stays visible and boss fights
# widen the framing to include the full elemental Titan silhouette.
@export var target_path: NodePath = NodePath("../TeamFormation")
@export var battle_manager_path: NodePath = NodePath("../BattleManager")
@export var enemy_spawn_path: NodePath = NodePath("../EnemySpawn")
@export var camera_offset: Vector3 = Vector3(0.0, 10.8, 15.0)
@export var look_ahead: Vector3 = Vector3(0.0, 1.2, -5.0)
@export var smoothing: float = 3.0
@export var aim_smoothing: float = 4.0
var _smoothed_focus: Vector3 = Vector3.ZERO

@onready var target: Node3D = get_node_or_null(target_path) as Node3D
@onready var battle_manager: Node = get_node_or_null(battle_manager_path)
@onready var enemy_spawn: Node3D = get_node_or_null(enemy_spawn_path) as Node3D

func _ready() -> void:
 current = true
 fov = 58.0
 if target != null:
  var view: Dictionary = _desired_view()
  global_position = view["position"]
  _smoothed_focus = view["focus"]
  look_at(_smoothed_focus, Vector3.UP)

func _process(delta: float) -> void:
 if target == null or not is_instance_valid(target):
  return
 var view: Dictionary = _desired_view()
 var alpha: float = 1.0 - exp(-maxf(smoothing, 0.0) * maxf(delta, 0.0))
 global_position = global_position.lerp(view["position"], alpha)
 # Smooth the aim as well as camera position to avoid snapping at boss spawn.
 var desired_focus: Vector3 = view["focus"]
 var aim_alpha: float = 1.0 - exp(-maxf(aim_smoothing, 0.0) * maxf(delta, 0.0))
 _smoothed_focus = _smoothed_focus.lerp(desired_focus, aim_alpha)
 if global_position.distance_squared_to(_smoothed_focus) > 0.01:
  look_at(_smoothed_focus, Vector3.UP)

func _desired_view() -> Dictionary:
 var team_position: Vector3 = target.global_position
 var focus: Vector3 = team_position + look_ahead
 var offset: Vector3 = camera_offset
 var boss_active: bool = false
 if battle_manager != null and is_instance_valid(battle_manager):
  boss_active = bool(battle_manager.get("battle_active")) and bool(battle_manager.get("is_boss"))
 if boss_active and enemy_spawn != null and is_instance_valid(enemy_spawn):
  var boss_position: Vector3 = enemy_spawn.global_position
  # Frame the space between the heroes and the enemy, with extra headroom.
  focus = (team_position + boss_position) * 0.5 + Vector3(0.0, 2.2, 0.0)
  # Use horizontal battlefield separation; vertical boss placement should not zoom the camera.
  var flat_separation: float = Vector2(team_position.x - boss_position.x, team_position.z - boss_position.z).length()
  var framing_distance: float = flat_separation
  offset = Vector3(0.0, clampf(framing_distance * 1.05, 12.5, 22.0), clampf(framing_distance * 1.65, 19.0, 34.0))
 return {"position": focus + offset, "focus": focus}
