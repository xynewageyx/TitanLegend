extends RefCounted
class_name TitanElementImpactFX

# Lightweight procedural impacts: no imported textures or particle shaders.
const ELEMENT_COLORS: Array[Color] = [
 Color("#ff643d"), Color("#4fc8ff"), Color("#bd945a"),
 Color("#58e184"), Color("#ffe98b"), Color("#a678f7"),
 Color("#c1f5e9"), Color("#91dfff"), Color("#f6db4d"), Color("#ff64d9")
]

static func show_hit(target: Node3D, element_id: int, critical: bool, boss: bool) -> void:
 if not is_instance_valid(target) or not target.is_inside_tree():
  return
 var tint: Color = ELEMENT_COLORS[clampi(element_id, 0, ELEMENT_COLORS.size() - 1)]
 var effect: Node3D = Node3D.new()
 effect.name = "ElementHitFX"
 target.add_child(effect)
 effect.position = Vector3(0, 2.7 if boss else 0.75, -0.8 if boss else -0.4)
 var core: MeshInstance3D = VisualFactory.sphere(effect, 0.32 if boss else 0.19, Vector3.ZERO, tint)
 var core_mat: StandardMaterial3D = core.material_override as StandardMaterial3D
 core_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
 core_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
 core_mat.emission_enabled = true
 core_mat.emission = tint
 core_mat.emission_energy_multiplier = 1.8
 var ring: MeshInstance3D = VisualFactory.cylinder(effect, 0.055, 0.75 if boss else 0.42, Vector3.ZERO, tint.lightened(0.3))
 var ring_mat: StandardMaterial3D = ring.material_override as StandardMaterial3D
 ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
 ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
 effect.scale = Vector3.ONE * 0.35
 var grow: Tween = effect.create_tween().set_parallel(true)
 grow.tween_property(effect, "scale", Vector3.ONE * (1.6 if critical else 1.2), 0.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
 grow.tween_property(core_mat, "albedo_color:a", 0.0, 0.4)
 grow.tween_property(ring_mat, "albedo_color:a", 0.0, 0.4)
 grow.chain().tween_callback(effect.queue_free)
 # Element-specific silhouettes: sparks, icy shards, or rising embers.
 var fragment_count: int = 5 if critical else 3
 for i in range(fragment_count):
  var angle: float = TAU * float(i) / float(fragment_count)
  var shard: MeshInstance3D = VisualFactory.box(effect, Vector3(0.10, 0.30 if element_id == 7 else 0.13, 0.10), Vector3.ZERO, tint.lightened(0.2))
  var destination: Vector3 = Vector3(cos(angle) * 0.85, (0.75 if element_id == 0 else 0.15) + sin(float(i) * 2.1) * 0.35, sin(angle) * 0.55)
  grow.tween_property(shard, "position", destination, 0.3)

# Update 150: prioritize critical damage without allowing unlimited floating labels.
static func show_damage_label(parent: Node3D, target: Node3D, scene: PackedScene, amount: int, critical: bool, boss: bool) -> void:
 if not is_instance_valid(parent) or not parent.is_inside_tree() or not is_instance_valid(target) or not target.is_inside_tree():
  return
 var nearby: Array[Label3D] = []
 var radius: float = 6.0 if boss else 3.0
 for child in parent.get_children():
  if child is Label3D and child.get_script() == preload("res://scripts/floating_text.gd"):
   var active_label: Label3D = child as Label3D
   if not active_label.is_queued_for_deletion() and active_label.global_position.distance_to(target.global_position) < radius:
    nearby.append(active_label)
 var limit: int = 5 if boss else 3
 if nearby.size() >= limit:
  if not critical:
   return
  # A critical hit may replace one normal popup, but never adds beyond the cap.
  var replaced: bool = false
  for old_label in nearby:
   if not old_label.critical:
    old_label.queue_free()
    nearby.erase(old_label)
    replaced = true
    break
  if not replaced:
   return
 var label: Label3D = scene.instantiate() as Label3D
 if label == null:
  return
 label.damage_amount = amount
 label.critical = critical
 label.lane_index = nearby.size()
 parent.add_child(label)
 label.global_position = target.global_position + Vector3(0.0, 3.65 if boss else 1.9, 0.0)
