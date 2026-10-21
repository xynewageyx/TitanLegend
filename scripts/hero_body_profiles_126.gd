extends RefCounted
# Class-specific body proportions, cosmetic only. Built once when class changes.
static func decorate(hero: Node3D, class_id: int) -> void:
 var torso: MeshInstance3D = null
 var waist: MeshInstance3D = null
 var head: MeshInstance3D = null
 for child in hero.get_children():
  if child is MeshInstance3D:
   if torso == null:
    torso = child
   elif waist == null:
    waist = child
   elif head == null:
    head = child
    break
 if torso == null or waist == null or head == null:
  return
 var widths: Array[float] = [1.23, 1.17, 0.91, 0.96, 0.99, 0.82, 0.87, 0.90, 0.96, 0.92, 1.18]
 var heights: Array[float] = [1.07, 1.05, 1.03, 0.99, 1.06, 0.96, 1.10, 1.06, 1.03, 1.08, 0.96]
 var heads: Array[float] = [0.97, 0.99, 1.02, 1.05, 0.99, 1.00, 1.05, 1.02, 1.06, 1.02, 1.02]
 if class_id < 0 or class_id >= widths.size():
  return
 torso.scale.x *= widths[class_id]
 torso.scale.y *= heights[class_id]
 waist.scale.x *= lerpf(1.0, widths[class_id], 0.6)
 head.scale *= heads[class_id]
 var belt_color: Color = Color("#5a4639") if class_id in [0, 1, 10] else Color("#394355")
 var belt: MeshInstance3D = VisualFactory.sphere(hero, 0.33, Vector3(0, 0.91, -0.015), belt_color)
 belt.scale = Vector3(1.17 * widths[class_id], 0.17, 0.90)
