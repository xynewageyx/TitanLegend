extends CanvasLayer
## Player-facing graphics menu. UI is created at runtime for the portrait HUD.
var panel: PanelContainer
var preset: OptionButton
var fps: OptionButton
var scale_slider: HSlider
var shadows: CheckBox
var effects: CheckBox
var automatic: CheckBox
var updating := false

func _ready() -> void:
	layer = 20
	var open_button := Button.new()
	open_button.text = "Grafik"
	open_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	open_button.position = Vector2(-120, 80)
	open_button.custom_minimum_size = Vector2(110, 54)
	add_child(open_button)
	open_button.pressed.connect(_toggle)
	panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(70, 180)
	panel.custom_minimum_size = Vector2(580, 0)
	add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	panel.add_child(column)
	var title := Label.new()
	title.text = "Grafikeinstellungen"
	column.add_child(title)
	preset = OptionButton.new()
	for entry in ["Niedrig", "Mittel", "Hoch", "Ultra", "Benutzerdefiniert"]:
		preset.add_item(entry)
	column.add_child(preset)
	fps = OptionButton.new()
	for value in [30, 60, 120]:
		fps.add_item("%d FPS" % value)
	column.add_child(fps)
	var scale_label := Label.new()
	scale_label.text = "3D-Renderauflösung (50–100 %)"
	column.add_child(scale_label)
	scale_slider = HSlider.new()
	scale_slider.min_value = 50
	scale_slider.max_value = 100
	scale_slider.step = 5
	column.add_child(scale_slider)
	shadows = CheckBox.new()
	shadows.text = "Schatten"
	column.add_child(shadows)
	effects = CheckBox.new()
	effects.text = "Erweiterte Effekte"
	column.add_child(effects)
	automatic = CheckBox.new()
	automatic.text = "Automatische Optimierung (in Vorbereitung)"
	automatic.disabled = true
	column.add_child(automatic)
	var close_button := Button.new()
	close_button.text = "Schließen"
	column.add_child(close_button)
	close_button.pressed.connect(_toggle)
	preset.item_selected.connect(_preset_changed)
	fps.item_selected.connect(_custom_changed)
	scale_slider.value_changed.connect(_custom_changed)
	shadows.toggled.connect(_custom_changed)
	effects.toggled.connect(_custom_changed)
	panel.visible = false
	_refresh()

func _toggle() -> void:
	panel.visible = not panel.visible
	if panel.visible:
		_refresh()

func _refresh() -> void:
	updating = true
	var keys := ["low", "medium", "high", "ultra", "custom"]
	preset.select(maxi(0, keys.find(GraphicsQualityManager.quality)))
	fps.select(maxi(0, [30, 60, 120].find(GraphicsQualityManager.target_fps)))
	scale_slider.value = GraphicsQualityManager.render_scale * 100.0
	shadows.button_pressed = GraphicsQualityManager.shadows_enabled
	effects.button_pressed = GraphicsQualityManager.effects_enabled
	automatic.button_pressed = GraphicsQualityManager.automatic_optimization
	updating = false

func _preset_changed(index: int) -> void:
	if updating:
		return
	var keys := ["low", "medium", "high", "ultra", "custom"]
	if index < 4:
		GraphicsQualityManager.set_preset(keys[index])
		_refresh()

func _custom_changed(_value: Variant) -> void:
	if updating:
		return
	GraphicsQualityManager.set_custom(
		[30, 60, 120][fps.selected],
		scale_slider.value / 100.0,
		shadows.button_pressed,
		effects.button_pressed
	)
	_refresh()
