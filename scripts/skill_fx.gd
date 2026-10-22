class_name SkillFX
extends RefCounted

# Lightweight procedural effects for Godot 4.x / Android.
# Pets never cast or deal damage.
static func _orb(parent: Node3D, radius: float, color: Color, at: Vector3) -> MeshInstance3D:
 var sphere := SphereMesh.new()
 sphere.radius = radius
 sphere.height = radius * 2.0
 sphere.radial_segments = 8
 sphere.rings = 4
 var node := MeshInstance3D.new()
 node.mesh = sphere
 var mat := StandardMaterial3D.new()
 mat.albedo_color = color
 mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
 mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
 mat.emission_enabled = true
 mat.emission = Color(color.r, color.g, color.b)
 mat.emission_energy_multiplier = 1.8
 node.material_override = mat
 parent.add_child(node)
 node.global_position = at
 return node

static func _launch(parent: Node3D, start: Vector3, target: Vector3, color: Color, radius: float, duration: float) -> void:
 var projectile := _orb(parent, radius, color, start)
 var tween := parent.create_tween()
 tween.tween_property(projectile, "global_position", target, duration).set_trans(Tween.TRANS_SINE)
 tween.tween_callback(projectile.queue_free)

static func _pulse(parent: Node3D, at: Vector3, color: Color, radius: float = 0.45) -> void:
 var orb := _orb(parent, radius, color, at)
 var tween := parent.create_tween().set_parallel(true)
 tween.tween_property(orb, "scale", Vector3.ONE * 2.3, 0.45)
 tween.tween_property(orb, "transparency", 1.0, 0.45)
 tween.chain().tween_callback(orb.queue_free)

# Update 57: role-aware procedural spell signatures (visuals only).
static func _pillar(parent: Node3D, at: Vector3, color: Color, height: float = 0.9) -> void:
 var marker := _orb(parent, 0.14, color, at + Vector3(0, height * 0.5, 0))
 marker.scale = Vector3(0.85, height * 3.0, 0.85)
 var tween := parent.create_tween()
 tween.tween_property(marker, "scale", Vector3(0.12, 0.12, 0.12), 0.85)
 tween.tween_callback(marker.queue_free)

static func _totems(parent: Node3D, at: Vector3, role: int) -> void:
 var tint := Color(0.38, 0.92, 0.88, 0.9) if role == 2 else Color(0.95, 0.62, 0.28, 0.9)
 for offset in [-0.62, 0.62]:
  _pillar(parent, at + Vector3(offset, 0, 0.18), Color(0.42, 0.28, 0.16, 0.9), 0.95)
  _pulse(parent, at + Vector3(offset, 1.1, 0.18), tint, 0.13)

static func _garden(parent: Node3D, at: Vector3) -> void:
 for offset in [-0.65, -0.24, 0.25, 0.68]:
  _pillar(parent, at + Vector3(offset, 0, -0.25), Color(0.23, 0.83, 0.34, 0.85), 0.55 + absf(offset) * 0.4)
 _pulse(parent, at + Vector3(0, 0.25, 0), Color(0.28, 0.96, 0.39, 0.65), 0.48)

static func _holy_light(parent: Node3D, at: Vector3) -> void:
 _pillar(parent, at, Color(1.0, 0.88, 0.42, 0.85), 1.8)
 _pulse(parent, at + Vector3(0, 1.2, 0), Color(1.0, 0.96, 0.68, 0.75), 0.43)

static func _shadow(parent: Node3D, start: Vector3, target: Vector3) -> void:
 _launch(parent, start, target, Color(0.47, 0.17, 0.77, 0.95), 0.25, 0.3)
 _pulse(parent, target, Color(0.35, 0.13, 0.55, 0.65), 0.32)

static func cast(parent: Node3D, team: Node3D, target: Node3D, tick: int) -> void:
 if team == null or target == null:
  return
 var heroes: Array = team.get("heroes")
 var classes: Array = team.get("class_ids")
 var roles: Array = team.get("role_ids")
 var target_point := target.global_position + Vector3(0, 1.2, 0)
 for i in range(mini(4, heroes.size())):
  var hero: Node3D = heroes[i]
  if not is_instance_valid(hero):
   continue
  var start := hero.global_position + Vector3(0, 1.5, -0.4)
  var class_id: int = int(classes[i])
  var role: int = int(roles[i])
  # Healing roles receive class-specific visual identities, but still
  # retain their existing damage skills and combat calculations.
  if role == 2 and tick % 3 == 0:
   match class_id:
    2: _garden(parent, hero.global_position)
    3: _totems(parent, hero.global_position, role)
    1, 9: _holy_light(parent, hero.global_position)
    _: _pulse(parent, hero.global_position + Vector3(0, 1.0, 0), Color(0.3, 1.0, 0.5, 0.65), 0.65)
   continue
  if class_id == 3 and tick % 2 == 0:
   _totems(parent, hero.global_position, role)
  if role == 0 and tick % 3 == 0:
   _pulse(parent, hero.global_position + Vector3(0, 1.3, 0), Color(0.3, 0.65, 1.0, 0.5), 0.55)
  if class_id == 9 and role == 1:
   _shadow(parent, start, target_point)
   continue
  match class_id:
   4: # Hunter: fast arrow
    _launch(parent, start, target_point, Color(0.95, 0.82, 0.38, 1), 0.09, 0.22)
   6, 8: # Mage and summoner
    _launch(parent, start, target_point, Color(0.25, 0.75, 1.0, 0.95), 0.23, 0.34)
   7: # Warlock
    _launch(parent, start, target_point, Color(0.72, 0.25, 0.95, 0.95), 0.23, 0.34)
   2: # Druid: offensive thorn magic
    _launch(parent, start, target_point, Color(0.32, 0.95, 0.48, 0.95), 0.19, 0.32)
   3: # Shaman: lightning and elemental totems
    _launch(parent, start, target_point, Color(0.32, 0.83, 1.0, 0.95), 0.19, 0.32)
   9: # Priest tank/other fallback: holy glow
    _launch(parent, start, target_point, Color(1.0, 0.93, 0.45, 0.95), 0.19, 0.3)
   0, 1, 5, 10: # Melee strike flash
    _pulse(parent, target_point + Vector3(randf_range(-0.35, 0.35), 0, 0), Color(1.0, 0.82, 0.4, 0.65), 0.18)
