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
var adaptive_scale := 1.0
var sample_seconds := 0.0
var low_samples := 0
var good_samples := 0
var startup_grace_seconds := 10.0
var last_effective_scale := -1.0

func _ready() -> void:
	load_settings()
	get_tree().scene_changed.connect(_on_scene_changed)
	get_tree().node_added.connect(_on_node_added)
	apply_settings()

func set_preset(preset: String) -> void:
	if not PRESETS.has(preset):
		return
	quality = preset
	var data: Dictionary = PRESETS[preset]
	target_fps = data["fps"]
	render_scale = data["scale"]
	adaptive_scale = 1.0
	_reset_adaptive_sampling()
	shadows_enabled = data["shadows"]
	effects_enabled = data["effects"]
	apply_settings()
	save_settings()

func set_custom(fps: int, scale: float, shadows: bool, effects: bool) -> void:
	quality = "custom"
	target_fps = clampi(fps, 30, 120)
	render_scale = clampf(scale, 0.5, 1.0)
	adaptive_scale = 1.0
	_reset_adaptive_sampling()
	shadows_enabled = shadows
	effects_enabled = effects
	apply_settings()
	save_settings()

func apply_settings() -> void:
	Engine.max_fps = target_fps
	# The 3D scale applies to the root viewport. In Compatibility,
	# scaling support may vary; keep the control independent of the UI.
	var effective_scale := clampf(render_scale * adaptive_scale, 0.5, 1.0)
	if not is_equal_approx(effective_scale, last_effective_scale):
		get_tree().root.scaling_3d_scale = effective_scale
		last_effective_scale = effective_scale
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
	var settings := get_settings()
	for key in settings:
		config.set_value("graphics", key, settings[key])
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
	adaptive_scale = 1.0

func _apply_scene_quality() -> void:
	var root := get_tree().current_scene
	if root == null:
		return
	_apply_visual_quality(root)
	for node in root.find_children("*", "Light3D", true, false):
		_apply_visual_quality(node)
	for node in root.find_children("*", "GPUParticles3D", true, false):
		_apply_visual_quality(node)

func _apply_visual_quality(node: Node) -> void:
	# Preserve each visual's authored settings, including intentionally disabled shadows.
	if node is Light3D:
		var light := node as Light3D
		if not light.has_meta("titan_original_shadow"):
			light.set_meta("titan_original_shadow", light.shadow_enabled)
		var allow_shadow := shadows_enabled
		# On weaker devices, only directional shadows are retained in Medium.
		if quality == "medium" and not (light is DirectionalLight3D):
			allow_shadow = false
		light.shadow_enabled = allow_shadow and bool(light.get_meta("titan_original_shadow"))
	elif node is GPUParticles3D:
		var particles := node as GPUParticles3D
		if not particles.has_meta("titan_original_amount_ratio"):
			particles.set_meta("titan_original_amount_ratio", particles.amount_ratio)
		var original_ratio := float(particles.get_meta("titan_original_amount_ratio"))
		var effect_multiplier := 1.0
		if not effects_enabled:
			effect_multiplier = 0.20 if quality == "low" else 0.35
		elif quality == "high":
			effect_multiplier = 0.75
		particles.amount_ratio = original_ratio * effect_multiplier

func _on_scene_changed(_scene: Node) -> void:
	_reset_adaptive_sampling()
	_apply_scene_quality()

func _reset_adaptive_sampling() -> void:
	startup_grace_seconds = 10.0
	sample_seconds = 0.0
	low_samples = 0
	good_samples = 0

func set_automatic(enabled: bool) -> void:
	automatic_optimization = enabled
	adaptive_scale = 1.0
	_reset_adaptive_sampling()
	apply_settings()
	save_settings()

func _process(delta: float) -> void:
	if not automatic_optimization:
		return
	if startup_grace_seconds > 0.0:
		startup_grace_seconds -= delta
		return
	sample_seconds += delta
	if sample_seconds < 5.0:
		return
	sample_seconds = 0.0
	var measured_fps := Engine.get_frames_per_second()
	if measured_fps <= 0:
		return
	if measured_fps < float(target_fps) * 0.80:
		low_samples += 1
		good_samples = 0
	elif measured_fps > float(target_fps) * 0.96:
		good_samples += 1
		low_samples = 0
	else:
		low_samples = 0
		good_samples = 0
	if low_samples >= 3:
		adaptive_scale = maxf(minf(1.0, 0.5 / render_scale), adaptive_scale - 0.1)
		low_samples = 0
		apply_settings()
	elif good_samples >= 6 and adaptive_scale < 1.0:
		adaptive_scale = minf(1.0, adaptive_scale + 0.05)
		good_samples = 0
		apply_settings()

func _on_node_added(node: Node) -> void:
	# Apply the selected profile to visuals spawned after the scene loads.
	_apply_visual_quality(node)
