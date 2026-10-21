extends RefCounted
class_name TalentVisualFX

# Android-friendly, procedural talent visuals. No particles, textures or pet attacks.
const CLASS_COLORS := [
 Color("#f4a04c"), Color("#ffe18a"), Color("#70d78c"),
 Color("#58c9ed"), Color("#b9e77d"), Color("#9c7be8"),
 Color("#75b8ff"), Color("#b56bea"), Color("#6bd8d0"),
 Color("#fff1b0"), Color("#f26f60")
]

static func _ball(parent: Node3D, where: Vector3, color: Color, radius: float) -> MeshInstance3D:
 var mesh := SphereMesh.new()
 mesh.radius = radius
 mesh.height = radius * 2.0
 mesh.radial_segments = 8
 mesh.rings = 4
 var mat := StandardMaterial3D.new()
 mat.albedo_color = color
 mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
 mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
 mat.emission_enabled = true
 mat.emission = color
 mat.emission_energy_multiplier = 1.6
 var node := MeshInstance3D.new()
 node.mesh = mesh
 node.material_override = mat
 parent.add_child(node)
 node.global_position = where
 return node

static func _fade(node: MeshInstance3D, seconds: float) -> void:
 var tw := node.create_tween().set_parallel(true)
 tw.tween_property(node, "transparency", 1.0, seconds)
 tw.tween_property(node, "scale", Vector3.ONE * 0.12, seconds)
 tw.chain().tween_callback(node.queue_free)

static func play(parent: Node3D, hero: Node3D, target: Node3D, class_id: int, tree: int, branch: int) -> void:
 if not is_instance_valid(hero):
  return
 var color: Color = CLASS_COLORS[clampi(class_id, 0, CLASS_COLORS.size() - 1)]
 var origin: Vector3 = hero.global_position + Vector3(0, 1.35, 0)
 match tree:
  0: # Offensive talent: moving magical projectile / impact.
   if not is_instance_valid(target):
    return
   var destination: Vector3 = target.global_position + Vector3(0, 1.25, 0)
   var shot := _ball(parent, origin, color, 0.22 if branch == 0 else 0.16)
   var travel := shot.create_tween()
   travel.tween_property(shot, "global_position", destination, 0.32)
   travel.tween_property(shot, "scale", Vector3.ONE * 1.8, 0.10)
   travel.tween_callback(shot.queue_free)
  1: # Defense: expanding protective aura around the hero.
   var guard := _ball(parent, origin, color.lightened(0.25), 0.48)
   guard.scale = Vector3.ONE * 0.6
   var grow := guard.create_tween().set_parallel(true)
   grow.tween_property(guard, "scale", Vector3.ONE * (2.5 if branch == 0 else 2.0), 0.5)
   grow.tween_property(guard, "transparency", 1.0, 0.5)
   grow.chain().tween_callback(guard.queue_free)
  2: # Support: rising light motes; the actual heal is calculated by BattleManager.
   for i in range(3):
    var offset := Vector3(float(i - 1) * 0.48, 0, float(i % 2) * 0.25)
    var mote := _ball(parent, origin + offset, color.lightened(0.3), 0.14)
    var tw := mote.create_tween().set_parallel(true)
    tw.tween_property(mote, "global_position", mote.global_position + Vector3(0, 1.25, 0), 0.65)
    tw.tween_property(mote, "transparency", 1.0, 0.65)
    tw.chain().tween_callback(mote.queue_free)
