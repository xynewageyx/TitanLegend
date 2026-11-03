extends CanvasLayer
## Developer-only FPS diagnostic. Not part of player graphics settings.
## Requires a debug export with the custom feature tag "titan_developer".
var fps_label: Label
var elapsed := 0.0

func _ready() -> void:
	if not (OS.has_feature("debug") and OS.has_feature("titan_developer")):
		set_process(false)
		return
	layer = 100
	fps_label = Label.new()
	fps_label.text = "FPS: --"
	fps_label.position = Vector2(12, 12)
	fps_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fps_label.add_theme_color_override("font_color", Color.WHITE)
	fps_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	fps_label.add_theme_constant_override("shadow_offset_x", 1)
	fps_label.add_theme_constant_override("shadow_offset_y", 1)
	add_child(fps_label)

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= 0.5 and is_instance_valid(fps_label):
		elapsed = 0.0
		fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
