class_name TitanBossMotion
extends Node3D
# Compatibility implementation for Update 168 boss animation calls.
# Visual effects only: never modifies combat timing, damage, HP or skills.

const COLORS: Array[Color] = [
 Color("#ff632d"), Color("#40c8fa"), Color("#b59b70"),
 Color("#59bd68"), Color("#ffe18b"), Color("#9c65dc"),
 Color("#c4f4f6"), Color("#a9ecff"), Color("#6a8eff"),
 Color("#f03c76")
]
const STRIKE_DURATION: Array[float] = [
 0.43, 0.37, 0.58, 0.42, 0.35, 0.40, 0.29, 0.51, 0.25, 0.34
]
var boss: Node3D
var element_id: int = 0
var fusion: bool = false
var enraged: bool = false
var elapsed: float = 0.0
var windup_remaining: float = 0.0
var strike_remaining: float = 0.0
var recoil_remaining: float = 0.0
var recoil_strength: float = 1.0
var windup_duration: float = 0.42
var strike_duration: float = 0.42
var warning_ring: MeshInstance3D
var release_ring: MeshInstance3D
var release_material: StandardMaterial3D
var decorative_parts: Array[MeshInstance3D] = []
var base_positions: Array[Vector3] = []
var base_rotations: Array[Vector3] = []

func configure(target: Node3D, element: int, is_fusion: bool) -> void:
 boss = target
 element_id = clampi(element, 0, 9)
 fusion = is_fusion
 decorative_parts.clear()
 base_positions.clear()
 base_rotations.clear()
 for child in target.get_children():
  if child is MeshInstance3D and decorative_parts.size() < 12:
   decorative_parts.append(child as MeshInstance3D)
   base_positions.append(child.position)
   base_rotations.append(child.rotation)
 warning_ring = _make_ring("ElementalAttackWarning", 1.25 if fusion else 1.0)
 release_ring = _make_ring("ElementalReleaseRing", 0.85 if fusion else 0.6)
 release_material = release_ring.material_override as StandardMaterial3D
 release_ring.position.y = 0.2

func _make_ring(ring_name: String, radius: float) -> MeshInstance3D:
 var mesh := TorusMesh.new()
 mesh.inner_radius = radius
 mesh.outer_radius = radius + 0.13
 mesh.rings = 8
 mesh.ring_segments = 28
 var ring := MeshInstance3D.new()
 ring.name = ring_name
 ring.mesh = mesh
 var material := StandardMaterial3D.new()
 material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
 material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
 material.albedo_color = COLORS[element_id]
 ring.material_override = material
 ring.visible = false
 ring.position.y = 0.1
 add_child(ring)
 return ring

func set_enraged(value: bool) -> void:
 enraged = value

func attack_windup() -> void:
 windup_duration = [0.48, 0.40, 0.56, 0.44, 0.36, 0.42, 0.32, 0.50, 0.26, 0.38][element_id]
 windup_remaining = windup_duration
 if is_instance_valid(warning_ring):
  warning_ring.visible = true
  warning_ring.scale = Vector3.ONE

func attack_release() -> void:
 windup_remaining = 0.0
 strike_duration = STRIKE_DURATION[element_id] * (1.12 if fusion else 1.0)
 strike_remaining = strike_duration
 if is_instance_valid(warning_ring):
  warning_ring.visible = false
 if is_instance_valid(release_ring):
  release_ring.visible = true
  release_ring.scale = Vector3.ONE

func react_to_hit(critical: bool = false) -> void:
 recoil_strength = 1.65 if critical else 1.0
 recoil_remaining = 0.34 if critical else 0.24

func _process(delta: float) -> void:
 if not is_instance_valid(boss):
  return
 elapsed += delta
 windup_remaining = maxf(0.0, windup_remaining - delta)
 strike_remaining = maxf(0.0, strike_remaining - delta)
 recoil_remaining = maxf(0.0, recoil_remaining - delta)
 if is_instance_valid(warning_ring):
  warning_ring.visible = windup_remaining > 0.0
  if warning_ring.visible:
   var windup_progress: float = 1.0 - windup_remaining / maxf(0.01, windup_duration)
   warning_ring.scale = Vector3.ONE * (1.0 + 0.12 * sin(windup_progress * TAU * 3.0))
 if is_instance_valid(release_ring):
  release_ring.visible = strike_remaining > 0.0
  if release_ring.visible:
   var release_progress: float = 1.0 - strike_remaining / maxf(0.01, strike_duration)
   release_ring.scale = Vector3.ONE * (1.0 + release_progress * (3.1 if fusion else 2.5))
   var tint: Color = COLORS[element_id]
   tint.a = (1.0 - release_progress) * 0.8
   release_material.albedo_color = tint
 var speed: float = [1.30, 1.05, 0.68, 0.92, 1.18, 0.88, 1.85, 0.75, 2.20, 1.45][element_id]
 var multiplier: float = 1.55 if enraged else 1.0
 for i in range(decorative_parts.size()):
  var part: MeshInstance3D = decorative_parts[i]
  if not is_instance_valid(part):
   continue
  var wave: float = elapsed * speed + float(i) * 0.65
  part.position = base_positions[i] + Vector3(0.0, sin(wave) * 0.07 * multiplier, 0.0)
  part.rotation = base_rotations[i]
  if windup_remaining > 0.0:
   var charge: float = sin((1.0 - windup_remaining / maxf(windup_duration, 0.01)) * PI)
   part.position.y += charge * (0.20 if element_id != 2 else -0.20)
  if strike_remaining > 0.0:
   var impact: float = sin((1.0 - strike_remaining / maxf(strike_duration, 0.01)) * PI)
   part.position.z -= impact * 0.2
   part.rotation.x -= impact * 0.2
   if element_id in [1, 6, 8, 9]:
    part.position.x += impact * (0.15 if i % 2 == 0 else -0.15)
  if recoil_remaining > 0.0:
   var hit: float = sin((1.0 - recoil_remaining / (0.34 if recoil_strength > 1.0 else 0.24)) * PI)
   part.position.z += hit * 0.12 * recoil_strength
   part.rotation.z += hit * 0.06 * recoil_strength
