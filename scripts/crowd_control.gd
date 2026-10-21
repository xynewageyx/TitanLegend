extends RefCounted
class_name TitanCrowdControl

# Class ID follows TeamFormation.CLASS_NAMES. Automatic CC is reserved for boss casts.
const ABILITIES: Array[String] = [
 "Schildschlag", "Hammer der Gerechtigkeit", "Wurzelgriff", "Windstoß",
 "Unterbrechender Schuss", "Tritt", "Gegenzauber", "Schattenfessel",
 "Bannruf", "Stille", "Betäubender Hieb"
]
const COLORS: Array[Color] = [
 Color.SILVER, Color.GOLD, Color.FOREST_GREEN, Color.CYAN,
 Color.LIME_GREEN, Color.MEDIUM_PURPLE, Color.DODGER_BLUE,
 Color.PURPLE, Color.MAGENTA, Color.LIGHT_YELLOW, Color.ORANGE_RED
]

static func ability_name(class_id: int) -> String:
 return ABILITIES[clampi(class_id, 0, ABILITIES.size() - 1)]

static func cooldown_ticks(_class_id: int) -> int:
 return 18 # One class CC approximately every 9.9 seconds of active combat.

static func play_interrupt(parent: Node3D, hero: Node3D, boss: Node3D, class_id: int) -> void:
 if not is_instance_valid(parent) or not is_instance_valid(hero) or not is_instance_valid(boss):
  return
 var tint: Color = COLORS[clampi(class_id, 0, COLORS.size() - 1)]
 var orb := MeshInstance3D.new()
 var mesh := SphereMesh.new()
 mesh.radius = 0.32
 mesh.height = 0.64
 mesh.radial_segments = 8
 mesh.rings = 4
 orb.mesh = mesh
 var material := StandardMaterial3D.new()
 material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
 material.albedo_color = tint
 material.emission_enabled = true
 material.emission = tint
 material.emission_energy_multiplier = 2.0
 orb.material_override = material
 parent.add_child(orb)
 orb.global_position = hero.global_position + Vector3(0, 1.8, 0)
 var target: Vector3 = boss.global_position + Vector3(0, 2.5, 0)
 var tween := parent.create_tween()
 tween.tween_property(orb, "global_position", target, 0.2)
 tween.tween_property(orb, "scale", Vector3.ONE * 2.5, 0.12)
 tween.tween_property(orb, "scale", Vector3.ONE * 0.01, 0.14)
 tween.tween_callback(orb.queue_free)
