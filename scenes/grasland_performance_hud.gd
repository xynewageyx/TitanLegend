extends CanvasLayer
## Live performance HUD for the isolated forest preview (desktop and Android).
## The small toggle remains accessible when metrics are hidden.
var _label: Label
var _toggle: Button
var _elapsed := 0.0
var _battle_active := false
var _battle_button: Button

func _ready() -> void:
    var panel := PanelContainer.new()
    panel.name = "PerformancePanel"
    panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
    panel.position = Vector2(12, 24)
    add_child(panel)

    var stack := VBoxContainer.new()
    panel.add_child(stack)

    _toggle = Button.new()
    _toggle.text = "FPS / Hide"
    _toggle.custom_minimum_size = Vector2(160, 48)
    _toggle.pressed.connect(_toggle_metrics)
    stack.add_child(_toggle)

    _label = Label.new()
    _label.name = "PerformanceLabel"
    _label.add_theme_color_override("font_color", Color.WHITE)
    _label.add_theme_color_override("font_shadow_color", Color.BLACK)
    _label.add_theme_constant_override("shadow_offset_x", 1)
    _label.add_theme_constant_override("shadow_offset_y", 1)
    stack.add_child(_label)

    _battle_button = Button.new()
    _battle_button.text = "Start battle (test)"
    _battle_button.custom_minimum_size = Vector2(160, 48)
    _battle_button.pressed.connect(_toggle_battle)
    stack.add_child(_battle_button)
    _refresh()

func _process(delta: float) -> void:
    _elapsed += delta
    if _elapsed >= 0.5:
        _elapsed = 0.0
        if _label.visible:
            _refresh()

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3:
        _toggle_metrics()

func _toggle_metrics() -> void:
    _label.visible = not _label.visible
    _toggle.text = "FPS / Hide" if _label.visible else "FPS / Show"
    if _label.visible:
        _refresh()

func _toggle_battle() -> void:
    var controller := get_parent().get_node_or_null("BattleArenaController")
    if controller == null:
        return
    if _battle_active:
        controller.end_battle()
    else:
        controller.start_battle()
    _battle_active = not _battle_active
    _battle_button.text = "End battle (test)" if _battle_active else "Start battle (test)"

func _refresh() -> void:
    var fps := Engine.get_frames_per_second()
    var draw_calls := Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
    var primitives := Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
    _label.text = "Titan Legends | Forest Preview\nFPS: %d\nDraw calls: %d\nPrimitives: %d" % [fps, int(draw_calls), int(primitives)]
