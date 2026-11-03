extends Camera3D
## Touch-friendly orbit camera for the isolated forest preview.
## One-finger drag rotates, two-finger pinch zooms. No gameplay dependencies.
@export var target := Vector3(0.0, 0.0, 0.0)
@export var distance := 27.0
@export var min_distance := 12.0
@export var max_distance := 48.0
@export var yaw_degrees := 25.0
@export var pitch_degrees := 28.0

var _touches: Dictionary = {}
var _last_pinch_distance := 0.0
var _mouse_dragging := false
var _battle_mode := false
var _saved_view: Dictionary = {}
var _camera_tween: Tween

func _ready() -> void:
    _update_camera()

func _unhandled_input(event: InputEvent) -> void:
    if _battle_mode:
        return
    if event is InputEventScreenTouch:
        if event.pressed:
            _touches[event.index] = event.position
        else:
            _touches.erase(event.index)
        _last_pinch_distance = 0.0
    elif event is InputEventScreenDrag:
        if not _touches.has(event.index):
            return
        _touches[event.index] = event.position
        if _touches.size() == 1:
            yaw_degrees -= event.relative.x * 0.22
            pitch_degrees = clampf(pitch_degrees + event.relative.y * 0.15, 12.0, 70.0)
        elif _touches.size() == 2:
            var positions := _touches.values()
            var pinch_distance: float = positions[0].distance_to(positions[1])
            if _last_pinch_distance > 0.0:
                distance = clampf(distance * _last_pinch_distance / maxf(pinch_distance, 1.0), min_distance, max_distance)
            _last_pinch_distance = pinch_distance
        _update_camera()
    elif event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            _mouse_dragging = event.pressed
        elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
            distance = clampf(distance - 2.0, min_distance, max_distance)
            _update_camera()
        elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            distance = clampf(distance + 2.0, min_distance, max_distance)
            _update_camera()
    elif event is InputEventMouseMotion and _mouse_dragging:
        yaw_degrees -= event.relative.x * 0.22
        pitch_degrees = clampf(pitch_degrees + event.relative.y * 0.15, 12.0, 70.0)
        _update_camera()

func focus_battle(arena_target: Vector3) -> void:
    if _battle_mode:
        return
    _saved_view = {"target": target, "distance": distance, "yaw": yaw_degrees, "pitch": pitch_degrees}
    _battle_mode = true
    _animate_view(arena_target, 18.0, 0.0, 35.0)

func restore_exploration() -> void:
    if not _battle_mode:
        return
    _battle_mode = false
    _animate_view(_saved_view["target"], _saved_view["distance"], _saved_view["yaw"], _saved_view["pitch"])

func _animate_view(new_target: Vector3, new_distance: float, new_yaw: float, new_pitch: float) -> void:
    if is_instance_valid(_camera_tween):
        _camera_tween.kill()
    _camera_tween = create_tween()
    _camera_tween.set_parallel(true)
    _camera_tween.set_trans(Tween.TRANS_SINE)
    _camera_tween.set_ease(Tween.EASE_IN_OUT)
    _camera_tween.tween_property(self, "target", new_target, 0.6)
    _camera_tween.tween_property(self, "distance", new_distance, 0.6)
    _camera_tween.tween_property(self, "yaw_degrees", new_yaw, 0.6)
    _camera_tween.tween_property(self, "pitch_degrees", new_pitch, 0.6)

func _process(_delta: float) -> void:
    if _camera_tween != null and _camera_tween.is_running():
        _update_camera()

func _update_camera() -> void:
    var yaw := deg_to_rad(yaw_degrees)
    var pitch := deg_to_rad(pitch_degrees)
    var offset := Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * distance
    global_position = target + offset
    look_at(target, Vector3.UP)
