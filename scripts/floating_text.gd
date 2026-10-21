extends Label3D

# Update 141: distinct readable normal/critical damage popups for mobile.
var damage_amount: int = 0
var critical: bool = false
var heal: bool = false
var lane_index: int = 0

func _ready() -> void:
 call_deferred("_animate")

func _animate() -> void:
 billboard = BaseMaterial3D.BILLBOARD_ENABLED
 no_depth_test = true
 fixed_size = false
 font_size = 30 if critical else (23 if heal else 24)
 outline_size = 5 if critical else 4
 pixel_size = 0.0026 if critical else 0.0024
 text = ("+" if heal else "") + str(damage_amount)
 if critical and not heal:
  text = "KRIT! " + text
 modulate = Color("#67f0a0") if heal else (Color("#ffe16a") if critical else Color("#ffb76b"))
 var base_scale: Vector3 = Vector3.ONE * (1.08 if critical else 1.0)
 scale = base_scale * (0.65 if critical else 1.0)
 var lane: int = lane_index % 5
 var horizontal: float = float(lane - 2) * (0.10 if heal else 0.16)
 var vertical: float = float(lane_index / 5.0) * 0.10
 position += Vector3(horizontal, vertical, 0.0)
 var target_pos: Vector3 = position + Vector3(horizontal * 0.20, 0.46 if critical else 0.36, 0.0)
 var movement: Tween = create_tween().set_parallel(true)
 movement.tween_property(self, "position", target_pos, 0.70 if critical else 0.62).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
 movement.tween_property(self, "modulate:a", 0.0, 0.70 if critical else 0.62).set_delay(0.18 if critical else 0.12)
 if critical:
  var pop: Tween = create_tween()
  pop.tween_property(self, "scale", base_scale * 1.28, 0.11).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
  pop.tween_property(self, "scale", base_scale, 0.16).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
 movement.chain().tween_callback(queue_free)
