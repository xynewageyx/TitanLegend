extends CanvasLayer
## Lightweight, optional performance HUD for the standalone landscape preview.
## Shows live FPS and rendered draw calls. Toggle with the F3 key on desktop.
var _label: Label
var _elapsed := 0.0

func _ready() -> void:
    _label = Label.new()
    _label.name = "PerformanceLabel"
    _label.position = Vector2(12, 12)
    _label.add_theme_color_override("font_color", Color.WHITE)
    _label.add_theme_color_override("font_shadow_color", Color.BLACK)
    _label.add_theme_constant_override("shadow_offset_x", 1)
    _label.add_theme_constant_override("shadow_offset_y", 1)
    add_child(_label)
    _refresh()

func _process(delta: float) -> void:
    _elapsed += delta
    if _elapsed >= 0.5:
        _elapsed = 0.0
        _refresh()

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3:
        _label.visible = not _label.visible

func _refresh() -> void:
    var fps := Engine.get_frames_per_second()
    var draw_calls := Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
    var vertices := Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
    _label.text = "Titan Legends | Grasland Preview\nFPS: %d\nDraw calls: %d\nPrimitives: %d" % [fps, int(draw_calls), int(vertices)]
