extends Node3D
# Update 145: reduced-dependency combat animation controller.
# Provides the same public methods as the previous version and retains
# basic class-based attacks, hit reactions and tank visual status effects.
# Original 144 implementation is archived in project root for comparison.

var class_id: int = 0
var elapsed: float = 0.0
var attack_remaining: float = 0.0
var hit_remaining: float = 0.0
var hit_duration: float = 0.25
var hit_critical: bool = false
var dodge_remaining: float = 0.0
var dodge_duration: float = 0.30
var dodge_direction: float = 1.0
var element_remaining: float = 0.0
var element_id: int = -1
var defense_kind: int = -1
var defense_remaining: float = 0.0
var defense_persistent: bool = false
var left_arm: Node3D
var right_arm: Node3D
var left_leg: Node3D
var right_leg: Node3D
var magic_flash: MeshInstance3D
var attack_duration: float = 0.42
var attack_variant: int = 0
# Visual-only secondary motion (no new meshes or combat timers).
var stride_blend: float = 0.0
var attack_lean: float = 0.0
var skill_cast_remaining: float = 0.0
var skill_cast_role: int = -1
var skill_flash_remaining: float = 0.0
var skill_flash_duration: float = 0.55
var skill_flash: MeshInstance3D
var defense_ring: Node3D
var defense_segments: Array[MeshInstance3D] = []
var class_fx_color: Color = Color("#f8d98e")
var class_fx_size: float = 0.24
var face_parts: Array[MeshInstance3D] = []
var face_base_scales: Array[Vector3] = []
var face_scan_complete: bool = false


func _part(parent: Node3D, part_name: String, at: Vector3) -> Node3D:
 var part: Node3D = Node3D.new()
 part.name = part_name
 part.position = at
 parent.add_child(part)
 return part

func configure(hero_class: int) -> void:
 class_id = hero_class
 # Distinct, lightweight visual cues by class group.
 if class_id == 11:
  class_fx_color = Color("#9c6ae3") # Death Knight: spectral shadow
  class_fx_size = 0.32
 elif class_id in [0, 1, 10]:
  class_fx_color = Color("#f0aa5c") # frontline impact
  class_fx_size = 0.28
 elif class_id in [2, 4]:
  class_fx_color = Color("#8de0a3") # agile ranged
  class_fx_size = 0.19
 elif class_id in [3, 6]:
  class_fx_color = Color("#80e8c8") # support
  class_fx_size = 0.25
 else:
  class_fx_color = Color("#b99aff") # magic
  class_fx_size = 0.27
 left_arm = _part(self, "AnimatedLeftArm", Vector3(-0.46, 1.50, 0.0))
 right_arm = _part(self, "AnimatedRightArm", Vector3(0.46, 1.50, 0.0))
 left_leg = _part(self, "AnimatedLeftLeg", Vector3(-0.20, 0.60, 0.0))
 right_leg = _part(self, "AnimatedRightLeg", Vector3(0.20, 0.60, 0.0))
 var sleeve_color: Color = Color("#516b91")
 if class_id == 11:
  sleeve_color = Color("#34334b")
 elif class_id in [0, 1, 10]:
  sleeve_color = Color("#9d8e77")
 elif class_id in [2, 4]:
  sleeve_color = Color("#5caa72")
 elif class_id in [5, 7, 8]:
  sleeve_color = Color("#8063ac")
 # Unified rounded limb meshes are parented to animated joints, not static hero roots.
 for arm in [left_arm, right_arm]:
  var upper := MeshInstance3D.new()
  upper.name = "SculptedAnimatedArm"
  var arm_shape := CapsuleMesh.new()
  arm_shape.radius = 0.18
  arm_shape.height = 0.67
  arm_shape.radial_segments = 16
  arm_shape.rings = 6
  upper.mesh = arm_shape
  upper.position = Vector3(0.0, -0.27, 0.0)
  var arm_surface := StandardMaterial3D.new()
  arm_surface.albedo_color = sleeve_color
  arm_surface.roughness = 0.82
  upper.material_override = arm_surface
  arm.add_child(upper)
 for leg in [left_leg, right_leg]:
  var shin := MeshInstance3D.new()
  shin.name = "SculptedAnimatedLeg"
  var leg_shape := CapsuleMesh.new()
  leg_shape.radius = 0.19
  leg_shape.height = 0.74
  leg_shape.radial_segments = 16
  leg_shape.rings = 6
  shin.mesh = leg_shape
  shin.position = Vector3(0.0, -0.31, 0.0)
  var leg_surface := StandardMaterial3D.new()
  leg_surface.albedo_color = Color("#354050")
  leg_surface.roughness = 0.88
  shin.material_override = leg_surface
  leg.add_child(shin)
 # Equipment remains attached to the animated right arm.
 HeroWeapons47.equip(right_arm, class_id)
 var flash_root: Node3D = _part(self, "AttackFlash", Vector3(0.0, 1.45, -0.7))
 magic_flash = VisualFactory.sphere(flash_root, class_fx_size, Vector3.ZERO, class_fx_color)
 magic_flash.visible = false
 skill_flash = VisualFactory.sphere(flash_root, 0.45, Vector3(0.0, 0.18, -0.15), Color("#ffe59a"))
 skill_flash.visible = false
 skill_flash.material_override = StandardMaterial3D.new()
 (skill_flash.material_override as StandardMaterial3D).shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
 defense_ring = _part(self, "TankDefenseRing", Vector3(0.0, 0.8, 0.0))
 for i in range(10):
  var angle: float = float(i) * TAU / 10.0
  var segment: MeshInstance3D = VisualFactory.box(defense_ring, Vector3(0.16, 0.08, 0.16), Vector3(cos(angle) * 0.95, 0.0, sin(angle) * 0.95), Color("#64bbff"))
  defense_segments.append(segment)
 defense_ring.visible = false

func play_attack() -> void:
 attack_variant = (attack_variant + 1) % 2
 attack_duration = 0.58 if class_id == 11 else (0.34 if class_id in [2, 4, 10] else (0.52 if class_id in [0, 1] else 0.42))
 attack_remaining = attack_duration

func play_skill_cast(role: int, choice: int) -> void:
 # Distinct skill pulse; passive pets never cast or attack.
 skill_flash_remaining = skill_flash_duration
 play_attack()
 skill_cast_remaining = attack_duration
 skill_cast_role = role
 if skill_flash == null:
  return
 var tint := Color("#f3ba62")
 if role == 2:
  tint = Color("#65e9a7")
 elif role == 1:
  tint = Color("#b498ff")
 if role == 0 and choice == 9:
  tint = Color("#5cbaff")
 elif role == 0 and choice == 8:
  tint = Color("#ff9650")
 # Interrupts use the same class element color as their 3D VFX.
 if choice == 7:
  match class_id:
   0: tint = Color("#d9d9f2") # Warrior: steel
   1, 9: tint = Color("#ffd245") # Paladin / Priest: holy
   2, 4: tint = Color("#4dff80") # Druid / Hunter: nature
   3, 8: tint = Color("#73b3ff") # Shaman / Summoner: storm
   5, 7: tint = Color("#ad59ff") # Rogue / Warlock: shadow
   6: tint = Color("#59d6ff") # Mage: frost
   10: tint = Color("#ff4d1a") # Brawler: fire
   11: tint = Color("#ad65eb") # Death Knight: spectral shadow
 var material: StandardMaterial3D = skill_flash.material_override as StandardMaterial3D
 if material != null:
  material.albedo_color = tint

func play_hit(critical: bool = false) -> void:
 hit_critical = critical
 hit_duration = 0.36 if critical else 0.25
 hit_remaining = hit_duration

func play_dodge() -> void:
 # Visual-only evasion; combat damage and dodge chances are unchanged.
 dodge_direction *= -1.0
 dodge_remaining = dodge_duration
 hit_remaining = 0.0

func play_elemental_hit(element: int) -> void:
 element_id = clampi(element, 0, 9)
 element_remaining = 0.38
 play_hit()

func play_tank_skill_fx(kind: int) -> void:
 defense_kind = kind
 defense_remaining = 1.25

func set_tank_defense_state(kind: int) -> void:
 # Persistent defense is controlled by the battle state, not a short timer.
 defense_kind = kind
 defense_persistent = kind >= 0
 if kind < 0:
  defense_remaining = 0.0

func _update_face_animation() -> void:
 # Cache only the expression layers; equipment and headgear are never touched.
 if not face_scan_complete:
  var owner_hero: Node = get_parent()
  var face: Node = owner_hero.get_node_or_null("StorybookFace") if owner_hero != null else null
  if face == null:
   return
  for child in face.get_children():
   if child is MeshInstance3D and child.name in ["EyeWhite", "Iris", "Pupil", "EyeGlint"]:
    face_parts.append(child)
    face_base_scales.append(child.scale)
  face_scan_complete = true
 # Periodic quick blink plus a brief flinch when receiving damage.
 var cycle: float = fposmod(elapsed + float(class_id) * 0.29, 4.1)
 var blink: float = 1.0 - 0.88 * smoothstep(0.0, 0.07, cycle) * (1.0 - smoothstep(0.13, 0.23, cycle))
 var flinch: float = 0.55 if hit_remaining > 0.0 else 1.0
 var eye_open: float = maxf(0.12, blink * flinch)
 for index in range(face_parts.size()):
  if is_instance_valid(face_parts[index]):
   var original: Vector3 = face_base_scales[index]
   face_parts[index].scale = Vector3(original.x, original.y * eye_open, original.z)

func _process(delta: float) -> void:
 if left_arm == null or right_arm == null:
  return
 elapsed += delta
 _update_face_animation()
 attack_remaining = maxf(0.0, attack_remaining - delta)
 skill_cast_remaining = maxf(0.0, skill_cast_remaining - delta)
 hit_remaining = maxf(0.0, hit_remaining - delta)
 dodge_remaining = maxf(0.0, dodge_remaining - delta)
 element_remaining = maxf(0.0, element_remaining - delta)
 defense_remaining = maxf(0.0, defense_remaining - delta)
 skill_flash_remaining = maxf(0.0, skill_flash_remaining - delta)
 if skill_flash != null:
  skill_flash.visible = skill_flash_remaining > 0.0
  if skill_flash.visible:
   var pulse: float = skill_flash_remaining / skill_flash_duration
   skill_flash.scale = Vector3.ONE * (0.8 + (1.0 - pulse) * 2.2)
 var walking: bool = false
 var hero: Node = get_parent()
 if hero != null:
  var formation: Node = hero.get_parent()
  if formation != null:
   walking = bool(formation.get("is_walking"))
 # Smoothly ease between idle and walk to avoid snapping limbs on transitions.
 stride_blend = move_toward(stride_blend, 1.0 if walking else 0.0, delta * 5.0)
 var step_strength: float = stride_blend
 var speed: float = 8.0
 if class_id == 11:
  speed = 5.4
 elif class_id in [0, 1]:
  speed = 6.0
 elif class_id in [4, 5, 10]:
  speed = 10.0
 # Tanks march with shorter, heavier steps; agile heroes run wider.
 # Support casters use restrained arm swings to keep spell poses readable.
 var leg_swing: float = 0.36 if class_id == 11 else (0.40 if class_id in [0, 1] else (0.58 if class_id in [4, 5, 10] else 0.46))
 var arm_swing: float = 0.14 if class_id == 11 else (0.17 if class_id in [3, 6, 7, 8, 9] else (0.31 if class_id in [4, 5, 10] else 0.24))
 var foot_height: float = 0.045 if class_id == 11 else (0.05 if class_id in [0, 1] else (0.09 if class_id in [4, 5, 10] else 0.07))
 var step: float = sin(elapsed * speed)
 # Foot lift follows the planted leg, reducing the sliding impression.
 # Independent gait phases and gentle idle sway avoid mechanical mirror motion.
 var idle_weight: float = 1.0 - step_strength
 var idle_phase: float = elapsed * (1.75 + float(class_id % 3) * 0.13)
 left_leg.rotation.x = step * leg_swing * step_strength
 right_leg.rotation.x = -step * leg_swing * step_strength
 left_arm.rotation.x = -step * arm_swing * step_strength + sin(idle_phase) * 0.045 * idle_weight
 right_arm.rotation.x = step * arm_swing * step_strength - sin(idle_phase + 0.35) * 0.04 * idle_weight
 left_leg.rotation.z = -0.025 * idle_weight
 right_leg.rotation.z = 0.025 * idle_weight
 var foot_lift: float = maxf(0.0, step) * foot_height * step_strength
 left_leg.position.y = 0.60 + foot_lift
 right_leg.position.y = 0.60 + maxf(0.0, -step) * foot_height * step_strength
 if attack_remaining > 0.0:
  var progress: float = clampf(1.0 - attack_remaining / attack_duration, 0.0, 1.0)
  # Short anticipation, fast strike and eased follow-through.
  var windup: float = smoothstep(0.0, 0.22, progress)
  var strike: float = smoothstep(0.22, 0.48, progress)
  var recovery: float = 1.0 - smoothstep(0.48, 1.0, progress)
  var swing: float = strike * recovery
  var alternate: float = -1.0 if attack_variant == 0 else 1.0
  # Visual archetypes: heavy melee, quick strikes, ranged release, and casting.
  if class_id == 11:
   # Death Knight: deliberate overhead spectral greatblade cleave.
   right_arm.rotation.x = 0.95 * windup * (1.0 - strike) - 2.45 * swing
   left_arm.rotation.x = -0.55 * windup * recovery
   right_arm.rotation.z = alternate * 0.48 * swing
  elif class_id in [0, 1, 10]:
   right_arm.rotation.x = 0.42 * windup * (1.0 - strike) - 1.85 * swing
   left_arm.rotation.x = -0.40 * swing
   right_arm.rotation.z = alternate * 0.36 * swing
  elif class_id in [4, 5]:
   right_arm.rotation.x = -1.20 * swing
   left_arm.rotation.x = -0.90 * swing
   right_arm.rotation.z = alternate * 0.22 * swing
  else:
   right_arm.rotation.x = -0.78 * swing
   left_arm.rotation.x = -1.15 * swing
   right_arm.rotation.z = alternate * 0.12 * swing
  # Equipped skills use their own casting silhouette instead of a basic swing.
  if skill_cast_remaining > 0.0:
   if class_id == 11:
    # Shadow ritual: raise the off-hand, then cut downward with the weapon.
    left_arm.rotation.x = -1.45 * windup * recovery
    right_arm.rotation.x = 0.80 * windup * (1.0 - strike) - 2.25 * swing
    right_arm.rotation.z = alternate * 0.52 * swing
   elif skill_cast_role == 0:
    # Frontline: brace, then deliver a heavy shield or weapon impact.
    left_arm.rotation.x = -0.85 * windup * recovery
    right_arm.rotation.x = 0.55 * windup * (1.0 - strike) - 2.05 * swing
    right_arm.rotation.z = alternate * 0.42 * swing
   elif skill_cast_role == 1:
    # Damage dealers: draw back, release forward, recover quickly.
    left_arm.rotation.x = -0.75 * windup * recovery
    right_arm.rotation.x = -1.55 * swing
    right_arm.rotation.z = alternate * 0.18 * swing
   else:
    # Healers: lift both arms and channel without a weapon strike.
    left_arm.rotation.x = -1.30 * windup * recovery
    right_arm.rotation.x = -1.30 * windup * recovery
    right_arm.rotation.z = 0.12 * swing
  # Weight transfer during windup and strike makes attacks less rigid.
  left_leg.rotation.x += 0.15 * windup * (1.0 - strike)
  right_leg.rotation.x -= 0.22 * swing
  left_arm.rotation.z = -0.12 * swing
  attack_lean = swing
  magic_flash.visible = true
  var fx_strength: float = 0.75 if class_id in [2, 4] else (1.25 if class_id in [0, 1, 10] else 1.0)
  magic_flash.scale = Vector3.ONE * (0.65 + 1.55 * swing * fx_strength)
  # Keep the impact flash close to the weapon for melee, but project
  # ranged and spell effects slightly forward for better portrait readability.
  magic_flash.position.z = (-0.55 if class_id in [4, 5] else (-0.42 if class_id in [2, 3, 6, 7, 8, 9] else -0.22)) * swing
  magic_flash.position.y = (0.18 if class_id in [3, 6, 7, 8, 9] else (0.08 if class_id in [2, 4, 5] else 0.0)) * swing
 else:
  magic_flash.visible = false
  magic_flash.position.z = 0.0
  magic_flash.position.y = 0.0
  right_arm.rotation.z = 0.0
  attack_lean = move_toward(attack_lean, 0.0, delta * 7.0)
 var recoil: float = hit_remaining / hit_duration
 var hit_power: float = 1.55 if hit_critical else 1.0
 rotation.x = -recoil * 0.10 * hit_power + attack_lean * 0.06
 rotation.z = sin(elapsed * 22.0) * recoil * 0.09 * hit_power
 if hit_remaining > 0.0:
  left_arm.rotation.z = -0.32 * recoil * hit_power
  right_arm.rotation.z += 0.32 * recoil * hit_power
 else:
  # Preserve the attack follow-through; clear the arm only outside an attack.
  if attack_remaining <= 0.0:
   left_arm.rotation.z = 0.0
 if element_remaining > 0.0 and element_id == 8:
  rotation.z += sin(elapsed * 42.0) * 0.06
 # Brief sideways lean and step, then automatically return to the anchor.
 var dodge_progress: float = 1.0 - dodge_remaining / dodge_duration
 var dodge_amount: float = sin(dodge_progress * PI) if dodge_remaining > 0.0 else 0.0
 rotation.z += dodge_direction * dodge_amount * 0.24
 position.x = dodge_direction * dodge_amount * 0.22
 position.y = sin(elapsed * 2.1) * 0.015 + absf(step) * 0.045 * step_strength
 defense_ring.visible = (defense_persistent or defense_remaining > 0.0) and defense_kind >= 0
 if defense_ring.visible:
  defense_ring.rotation.y += delta * (4.8 if defense_remaining > 0.0 else 2.5)
  # Taunt (8) uses a warm, fast ring; interception (9) a broad blue shield.
  var intercepting: bool = defense_kind == 9
  var base_radius: float = 1.18 if intercepting else 0.90
  var pulse: float = 0.13 if defense_remaining > 0.0 else 0.06
  defense_ring.scale = Vector3.ONE * (base_radius + pulse * sin(elapsed * (6.0 if intercepting else 9.0)))
  for segment in defense_segments:
   if segment == null:
    continue
   var mesh_material: StandardMaterial3D = segment.get_active_material(0) as StandardMaterial3D
   if mesh_material != null:
    # Duplicate on first use to avoid recoloring unrelated shared meshes.
    if not segment.has_meta("tank_fx_material_unique"):
     mesh_material = mesh_material.duplicate() as StandardMaterial3D
     segment.material_override = mesh_material
     segment.set_meta("tank_fx_material_unique", true)
    mesh_material.albedo_color = Color("#58baff") if intercepting else Color("#ffae58")
