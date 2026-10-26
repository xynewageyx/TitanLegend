extends SceneTree

const PANEL = preload("res://scripts/equipment_panel_214.gd")

func _initialize() -> void:
	var panel := Control.new()
	panel.set_script(PANEL)
	root.add_child(panel)
	await process_frame
	assert(panel._grid != null, "Equipment grid must exist")
	assert(panel._grid.get_child_count() == 8, "Eight equipment slots expected")
	assert(panel.gold == GameManager.current_gold, "Gold must match GameManager")
	panel.hero_index = 1
	panel.refresh_from_game()
	assert(panel.equipment.has("Waffe"), "Hero weapon must be visible")
	assert(int(panel.equipment["Waffe"]["level"]) == GameManager.weapon_levels[1], "Weapon level must match hero")
	print("PASS: Update 214 equipment panel smoke test")
	quit()
