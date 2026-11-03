extends CanvasLayer
## Developer-only FPS diagnostic. Not part of player graphics settings.
## Requires a debug export with the custom feature tag "titan_developer".
var fps_label: Label
var reset_button: Button
var pause_button: Button
var measurement_paused := false
var elapsed := 0.0
var measurement_seconds := 0.0
var min_fps := 9999
var max_fps := 0
var sample_count := 0
var total_fps := 0

func _ready() -> void:
	if not (OS.has_feature("debug") and OS.has_feature("titan_developer")):
		set_process(false)
		return
	layer = 100
	fps_label = Label.new()
	fps_label.text = "FPS: --  Min: --  Max: --\nAvg: --  Zeit: --  Soll-Skalierung: --"
	fps_label.position = Vector2(12, 12)
	fps_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fps_label.add_theme_color_override("font_color", Color.WHITE)
	fps_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	fps_label.add_theme_constant_override("shadow_offset_x", 1)
	fps_label.add_theme_constant_override("shadow_offset_y", 1)
	add_child(fps_label)
	reset_button = Button.new()
	reset_button.text = "FPS Reset"
	reset_button.position = Vector2(12, 65)
	reset_button.custom_minimum_size = Vector2(110, 40)
	reset_button.pressed.connect(_reset_measurements)
	add_child(reset_button)
	pause_button = Button.new()
	pause_button.text = "FPS Pause"
	pause_button.position = Vector2(130, 65)
	pause_button.custom_minimum_size = Vector2(110, 40)
	pause_button.pressed.connect(_toggle_pause)
	add_child(pause_button)

func _toggle_pause() -> void:
	measurement_paused = not measurement_paused
	pause_button.text = "FPS Weiter" if measurement_paused else "FPS Pause"
	elapsed = 0.0

func _reset_measurements() -> void:
	min_fps = 9999
	max_fps = 0
	sample_count = 0
	total_fps = 0
	elapsed = 0.0
	measurement_seconds = 0.0
	measurement_paused = false
	pause_button.text = "FPS Pause"
	fps_label.text = "FPS: --  Min: --  Max: --\nAvg: --  Zeit: --  Soll-Skalierung: --"

func _process(delta: float) -> void:
	if measurement_paused:
		return
	measurement_seconds += delta
	elapsed += delta
	if elapsed >= 0.5 and is_instance_valid(fps_label):
		elapsed = 0.0
		var current_fps := Engine.get_frames_per_second()
		if current_fps > 0:
			min_fps = mini(min_fps, current_fps)
			max_fps = maxi(max_fps, current_fps)
			sample_count += 1
			total_fps += current_fps
		var average_fps := int(round(float(total_fps) / float(sample_count))) if sample_count > 0 else 0
		var requested_scale := get_tree().root.scaling_3d_scale
		fps_label.text = "FPS: %d  Min: %d  Max: %d\nAvg: %d  Zeit: %ds  Soll-Skalierung: %d%%" % [current_fps, min_fps if min_fps != 9999 else 0, max_fps, average_fps, int(measurement_seconds), int(round(requested_scale * 100.0))]
