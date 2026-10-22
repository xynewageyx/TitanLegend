class_name BossPhaseFX
extends Node3D
# Visual-only boss phase effects. Damage, HP, cooldowns and HUD are unchanged.
const ELEMENT_COLORS: Array[Color] = [Color.ORANGE_RED, Color.DODGER_BLUE, Color.SANDY_BROWN, Color.LIME_GREEN, Color.GOLD, Color.MEDIUM_PURPLE, Color.SKY_BLUE, Color.LIGHT_CYAN, Color.YELLOW, Color.MAGENTA]
var boss: Node3D
var enraged: bool = false
var fusion: bool = false
var elapsed: float = 0.0
var halo: MeshInstance3D
var inner_halo: MeshInstance3D
var core: MeshInstance3D
var attack_marker: MeshInstance3D
var marker_time: float = 0.0
var tint: Color = Color.ORANGE_RED

func _make_ring(inner: float, outer: float, color: Color) -> MeshInstance3D:
 var ring := TorusMesh.new()
 ring.inner_radius = inner
 ring.outer_radius = outer
 ring.rings = 8
 ring.ring_segments = 28
 var instance := MeshInstance3D.new()
 instance.mesh = ring
 var mat := StandardMaterial3D.new()
 mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
 mat.albedo_color = Color(color.r, color.g, color.b, 0.68)
 mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
 mat.emission_enabled = true
 mat.emission = color
 mat.emission_energy_multiplier = 1.5
 instance.material_override = mat
 add_child(instance)
 return instance

func setup(target: Node3D, element_id: int, fusion_boss: bool) -> void:
 boss = target
 fusion = fusion_boss
 tint = ELEMENT_COLORS[clampi(element_id, 0, ELEMENT_COLORS.size() - 1)]
 halo = _make_ring(2.2 if fusion else 1.75, 2.5 if fusion else 2.0, tint)
 halo.position.y = 0.24
 halo.visible = false
 inner_halo = _make_ring(1.4 if fusion else 1.1, 1.57 if fusion else 1.27, tint.lightened(0.4))
 inner_halo.position.y = 0.29
 inner_halo.visible = false
 var sphere := SphereMesh.new()
 sphere.radius = 0.28
 sphere.height = 0.56
 sphere.radial_segments = 10
 sphere.rings = 6
 core = MeshInstance3D.new()
 core.mesh = sphere
 var mat := StandardMaterial3D.new()
 mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
 mat.albedo_color = tint
 mat.emission_enabled = true
 mat.emission = tint
 mat.emission_energy_multiplier = 2.0
 core.material_override = mat
 add_child(core)
 core.position = Vector3(0, 4.7, -1.0)
 core.visible = false
 attack_marker = _make_ring(2.0 if fusion else 1.6, 2.25 if fusion else 1.85, tint.lightened(0.25))
 attack_marker.position.y = 0.36
 attack_marker.visible = false

func _process(delta: float) -> void:
 if not is_instance_valid(boss):
  return
 elapsed += delta
 if is_instance_valid(halo):
  halo.rotation.y += delta * (2.3 if fusion else 1.5)
  if enraged:
   halo.scale = Vector3.ONE * (1.0 + 0.12 * sin(elapsed * 5.0))
 if is_instance_valid(inner_halo):
  inner_halo.rotation.y -= delta * (2.8 if fusion else 1.9)
  if enraged:
   inner_halo.scale = Vector3.ONE * (1.0 + 0.1 * sin(elapsed * 6.2))
 if is_instance_valid(core) and enraged:
  core.scale = Vector3.ONE * (1.0 + 0.22 * sin(elapsed * 6.0))
 if marker_time > 0.0:
  marker_time = maxf(0.0, marker_time - delta)
  if is_instance_valid(attack_marker):
   attack_marker.scale = Vector3.ONE * (1.0 + 0.22 * (1.0 - marker_time / 0.5))
   attack_marker.visible = marker_time > 0.0
 # Avoid changing the boss's X rotation while an attack telegraph tween runs.
 boss.rotation.z = sin(elapsed * (2.4 if enraged else 1.2)) * (0.075 if enraged else 0.025)

func set_health_ratio(ratio: float) -> void:
 if enraged or ratio > 0.35 or ratio <= 0.0:
  return
 enraged = true
 if is_instance_valid(halo):
  halo.visible = true
 if is_instance_valid(inner_halo):
  inner_halo.visible = true
 if is_instance_valid(core):
  core.visible = true
 # Pulse the core; leave the boss root scale unchanged for compatibility.
 var tween := create_tween()
 tween.tween_property(core, "scale", Vector3.ONE * 1.8, 0.22)
 tween.tween_property(core, "scale", Vector3.ONE, 0.35)

func telegraph_attack() -> void:
 if not is_instance_valid(boss):
  return
 marker_time = 0.5
 if is_instance_valid(attack_marker):
  attack_marker.scale = Vector3.ONE
  attack_marker.visible = true
 var tween := create_tween()
 tween.tween_property(boss, "rotation:x", -0.18 if fusion else -0.12, 0.15)
 tween.tween_property(boss, "rotation:x", 0.0, 0.23)

# Update 81: large elemental shockwave for the 60-second finisher.
func play_finisher_explosion() -> void:
 if not is_instance_valid(boss):
  return
 var shockwave: MeshInstance3D = _make_ring(0.6, 0.95, tint.lightened(0.5))
 shockwave.position = Vector3(0.0, 0.45, 0.0)
 shockwave.scale = Vector3(0.25, 1.0, 0.25)
 var blast: Tween = create_tween()
 blast.set_parallel(true)
 blast.tween_property(shockwave, "scale", Vector3(8.0 if fusion else 6.5, 1.0, 8.0 if fusion else 6.5), 0.85).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
 blast.tween_property(shockwave, "transparency", 1.0, 0.85)
 blast.finished.connect(shockwave.queue_free)
 if is_instance_valid(core):
  core.visible = true
  var pulse: Tween = create_tween()
  pulse.tween_property(core, "scale", Vector3.ONE * 3.2, 0.18)
  pulse.tween_property(core, "scale", Vector3.ONE, 0.5)
