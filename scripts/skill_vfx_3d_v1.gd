extends Node3D
## Lightweight 3D skill VFX for Godot GL Compatibility / Android.
## Attach to the battle scene and call play_skill() after skill resolution.
const COLORS := {
 "shield": Color(0.25, 0.72, 1.0, 0.65),
 "holy": Color(1.0, 0.82, 0.26, 0.72),
 "fire": Color(1.0, 0.30, 0.10, 0.72),
 "frost": Color(0.35, 0.84, 1.0, 0.70),
 "nature": Color(0.30, 1.0, 0.50, 0.70),
 "shadow": Color(0.68, 0.35, 1.0, 0.72),
 "storm": Color(0.45, 0.70, 1.0, 0.72),
 "steel": Color(0.85, 0.85, 0.95, 0.72)
}
const SKILL_STYLE := {
 "shield_bash": "shield", "group_guard": "shield",
 "divine_judgment": "holy", "holy_light": "holy",
 "meteor_rain": "fire", "frost_nova": "frost",
 "arrow_rain": "nature", "precision_shot": "nature",
 "healing_wave": "nature", "blessing": "holy",
 "shadow_step": "shadow", "blade_storm": "shadow",
 "interrupt_warrior": "steel", "interrupt_paladin": "holy",
 "interrupt_druid": "nature", "interrupt_shaman": "storm",
 "interrupt_hunter": "nature", "interrupt_rogue": "shadow",
 "interrupt_mage": "frost", "interrupt_warlock": "shadow",
 "interrupt_summoner": "storm", "interrupt_priest": "holy",
 "interrupt_brawler": "fire"
}
@export var max_active_effects: int = 12
var _effects: Array[Node3D] = []

func play_skill(skill_id: String, world_position: Vector3) -> void:
 if _effects.size() >= max_active_effects:
  return
 var style: String = str(SKILL_STYLE.get(skill_id, "holy"))
 var tint: Color = COLORS[style]
 var effect := Node3D.new()
 add_child(effect)
 effect.global_position = world_position
 _effects.append(effect)
 var ring := MeshInstance3D.new()
 var mesh := CylinderMesh.new()
 mesh.top_radius = 0.8
 mesh.bottom_radius = 0.8
 mesh.height = 0.045
 ring.mesh = mesh
 var material := StandardMaterial3D.new()
 material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
 material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
 material.albedo_color = tint
 material.emission_enabled = true
 material.emission = Color(tint.r, tint.g, tint.b)
 ring.material_override = material
 effect.add_child(ring)
 ring.position.y = 0.12
 ring.scale = Vector3(0.2, 1.0, 0.2)
 var tween: Tween = create_tween()
 tween.set_parallel(true)
 tween.tween_property(ring, "scale", Vector3(2.2, 1.0, 2.2), 0.42)
 tween.tween_property(material, "albedo_color:a", 0.0, 0.42)
 # Class-specific motion silhouettes reuse cheap primitive meshes on Android.
 if skill_id.begins_with("interrupt_"):
  var accent := MeshInstance3D.new()
  var accent_mesh := SphereMesh.new()
  var destination := Vector3.ZERO
  match skill_id:
   "interrupt_warrior", "interrupt_brawler":
    accent_mesh.radius = 0.28
    accent_mesh.height = 0.56
    destination = Vector3(0.0, 1.15, -0.7)
   "interrupt_hunter", "interrupt_rogue":
    accent_mesh.radius = 0.12
    accent_mesh.height = 0.24
    destination = Vector3(0.0, 1.25, -2.0)
   "interrupt_druid", "interrupt_summoner":
    accent_mesh.radius = 0.35
    accent_mesh.height = 0.70
    destination = Vector3(0.0, 1.6, 0.0)
   "interrupt_mage", "interrupt_warlock", "interrupt_shaman":
    accent_mesh.radius = 0.24
    accent_mesh.height = 0.48
    destination = Vector3(0.0, 2.0, -0.5)
   _:
    accent_mesh.radius = 0.32
    accent_mesh.height = 0.64
    destination = Vector3(0.0, 1.8, 0.0)
  accent.mesh = accent_mesh
  var accent_material := StandardMaterial3D.new()
  accent_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
  accent_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
  accent_material.albedo_color = tint
  accent_material.emission_enabled = true
  accent_material.emission = Color(tint.r, tint.g, tint.b)
  accent.material_override = accent_material
  effect.add_child(accent)
  accent.position = Vector3(0.0, 0.4, 0.0)
  # Cheap, distinct silhouettes for every class; no extra particles or lights.
  match skill_id:
   "interrupt_warrior":
    accent.scale = Vector3(1.8, 0.55, 0.8)
   "interrupt_paladin":
    accent.scale = Vector3(1.0, 1.8, 1.0)
   "interrupt_druid":
    accent.scale = Vector3(1.5, 0.6, 1.5)
   "interrupt_shaman":
    accent.scale = Vector3(0.55, 2.0, 0.55)
   "interrupt_hunter":
    accent.scale = Vector3(0.5, 0.5, 2.5)
   "interrupt_rogue":
    accent.scale = Vector3(0.35, 0.35, 3.0)
   "interrupt_mage":
    accent.scale = Vector3(1.4, 1.4, 1.4)
   "interrupt_warlock":
    accent.scale = Vector3(0.7, 2.2, 0.7)
   "interrupt_summoner":
    accent.scale = Vector3(1.7, 0.8, 1.7)
   "interrupt_priest":
    accent.scale = Vector3(1.0, 2.0, 1.0)
   "interrupt_brawler":
    accent.scale = Vector3(2.2, 0.7, 0.7)
  tween.tween_property(accent, "position", destination, 0.42)
  tween.tween_property(accent_material, "albedo_color:a", 0.0, 0.42)
 tween.chain().tween_callback(func() -> void:
  _effects.erase(effect)
  effect.queue_free()
 )
