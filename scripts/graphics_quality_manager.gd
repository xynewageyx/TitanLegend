extends Node
## Titan Legends graphics preferences. Renderer changes require a restart/export configuration.
signal settings_changed(settings: Dictionary)
const SAVE_PATH := "user://graphics_settings.cfg"
const PRESETS := {
	"low": {"fps": 30, "scale": 0.65, "shadows": false, "effects": false},
	"medium": {"fps": 30, "scale": 0.80, "shadows": true, "effects": false},
	"high": {"fps": 60, "scale": 1.0, "shadows": true, "effects": true},
	"ultra": {"fps": 60, "scale": 1.0, "shadows": true, "effects": true}
}
var quality := "medium"
var target_fps := 30
var render_scale := 0.8
var shadows_enabled := true
var effects_enabled := false
var automatic_optimization := false

func _ready() -> void:
	load_settings()
	get_tree().scene_changed.connect(_on_scene_changed)
	apply_settings()

func set_preset(preset: String) -> void:
	if not PRESETS.has(preset):
		return
	quality = preset
	var data: Dictionary = PRESETS[preset]
	target_fps = data["fps"]
	render_scale = data["scale"]
	shadows_enabled = data["shadows"]
	effects_enabled = data["effects"]
	apply_settings()
	save_settings()

func set_custom(fps: int, scale: float, shadows: bool, effects: bool) -> void:
	quality = "custom"
	target_fps = clampi(fps, 30, 120)
	render_scale = clampf(scale, 0.5, 1.0)
	shadows_enabled = shadows
	effects_enabled = effects
	apply_settings()
	save_settings()

func apply_settings() -> void:
	Engine.max_fps = target_fps
	# The 3D scale applies to the root viewport. In Compatibility,
	# scaling support may vary; keep the control independent of the UI.
	get_tree().root.scaling_3d_scale = render_scale
	_apply_scene_quality()
	settings_changed.emit(get_settings())

func get_settings() -> Dictionary:
	return {
		"quality": quality,
		"fps": target_fps,
		"scale": render_scale,
		"shadows": shadows_enabled,
		"effects": effects_enabled,
		"automatic": automatic_optimization
	}

func save_settings() -> void:
	var config := ConfigFile.new()
	for key in get_settings():
		config.set_value("graphics", key, get_settings()[key])
	var err := config.save(SAVE_PATH)
	if err != OK:
		push_warning("Could not save graphics settings: %s" % err)

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	var preset := str(config.get_value("graphics", "quality", "medium"))
	quality = preset if PRESETS.has(preset) or preset == "custom" else "medium"
	target_fps = clampi(int(config.get_value("graphics", "fps", 30)), 30, 120)
	render_scale = clampf(float(config.get_value("graphics", "scale", 0.8)), 0.5, 1.0)
	shadows_enabled = bool(config.get_value("graphics", "shadows", true))
	effects_enabled = bool(config.get_value("graphics", "effects", false))
	automatic_optimization = bool(config.get_value("graphics", "automatic", false))

func _apply_scene_quality() -> void:
	# Only affect optional visual nodes; gameplay and hit detection stay unchanged.
	var root := get_tree().current_scene
	if root == null:
		return
	for node in root.find_children("*", "DirectionalLight3D", true, false):
		(node as DirectionalLight3D).shadow_enabled = shadows_enabled
	for node in root.find_children("*", "OmniLight3D", true, false):
		(node as OmniLight3D).shadow_enabled = shadows_enabled
	for node in root.find_children("*", "SpotLight3D", true, false):
		(node as SpotLight3D).shadow_enabled = shadows_enabled
	for node in root.find_children("*", "GPUParticles3D", true, false):
		(node as GPUParticles3D).amount_ratio = 1.0 if effects_enabled else 0.35

func _on_scene_changed(_scene: Node) -> void:
	_apply_scene_quality()
