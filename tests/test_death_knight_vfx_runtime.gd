extends SceneTree

const VFX = preload("res://scripts/skill_vfx_3d_v1.gd")

func _initialize() -> void:
 call_deferred("_run")

func _run() -> void:
 var visual: Node3D = VFX.new()
 root.add_child(visual)
 visual.max_active_effects = 4
 var ids: Array[String] = [
  "interrupt_death_knight",
  "death_knight_cleave",
  "death_knight_storm",
  "death_knight_guard"
 ]
 for id in ids:
  visual.play_skill(id, Vector3.ZERO)
 assert(visual.get_child_count() == 4, "All four Death Knight VFX should spawn")
 visual.play_skill("death_knight_cleave", Vector3.ZERO)
 assert(visual.get_child_count() == 4, "Android VFX cap must be respected")
 await create_timer(1.0).timeout
 assert(visual.get_child_count() == 0, "VFX nodes must be freed after tween")
 visual.queue_free()
 print("Death Knight VFX runtime passed")
 quit()
