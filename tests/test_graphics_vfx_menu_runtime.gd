extends SceneTree

const MENU = preload("res://scripts/graphics_vfx_menu.gd")
const VFX = preload("res://scripts/skill_vfx_3d_v1.gd")

func _initialize() -> void:
 call_deferred("_run")

func _run() -> void:
 var menu: Control = MENU.new()
 root.add_child(menu)
 await process_frame
 assert(not menu.visible, "Graphics menu should start closed")
 var selector: OptionButton = menu.quality_selector
 assert(selector != null, "Graphics quality selector must exist")
 assert(selector.item_count == 4, "Low, Medium, High, Ultra must be available")
 for i in range(4):
  selector.select(i)
  assert(selector.selected == i, "All quality choices must be selectable")
 menu.open_menu()
 assert(menu.visible, "Graphics menu should open")
 var visual: Node3D = VFX.new()
 root.add_child(visual)
 for i in range(4):
  visual.set_effect_quality(i)
  assert(visual.max_active_effects == (i + 1) * 3, "Incorrect quality budget")
 menu.queue_free()
 visual.queue_free()
 await process_frame
 print("Graphics VFX menu runtime passed")
 quit()
