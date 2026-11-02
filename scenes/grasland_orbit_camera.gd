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

func _ready() -> void:
    _update_camera()

func _unhandled_input(event: InputEvent) -> void:
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

func _update_camera() -> void:
    var yaw := deg_to_rad(yaw_degrees)
    var pitch := deg_to_rad(pitch_degrees)
    var offset := Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * distance
    global_position = target + offset
    look_at(target, Vector3.UP)
