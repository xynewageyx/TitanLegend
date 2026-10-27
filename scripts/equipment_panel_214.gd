extends Control
## Update 214: independent equipment overview, safe to embed in existing UI.
signal slot_selected(slot_id: String)
const SLOTS := ["Waffe", "Helm", "Brust", "Handschuhe", "Stiefel", "Ring", "Amulett", "Relikt"]
var equipment: Dictionary = {}
var gold: int = 0
var _gold_label: Label
var _grid: GridContainer
var hero_index: int = 0
var _hero_button: Button
var _upgrade_button: Button
var _notice: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(panel)
	var column := VBoxContainer.new()
	panel.add_child(column)
	var heading := Label.new()
	heading.text = "AUSRÜSTUNG"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(heading)
	_hero_button = Button.new()
	_hero_button.custom_minimum_size.y = 52
	_hero_button.pressed.connect(_next_hero)
	column.add_child(_hero_button)
	_gold_label = Label.new()
	column.add_child(_gold_label)
	_grid = GridContainer.new()
	_grid.columns = 2
	_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_grid)
	_upgrade_button = Button.new()
	_upgrade_button.custom_minimum_size.y = 56
	_upgrade_button.pressed.connect(_upgrade_weapon)
	column.add_child(_upgrade_button)
	_notice = Label.new()
	_notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_notice)
	refresh_from_game()

func set_equipment(data: Dictionary, available_gold: int) -> void:
	equipment = data.duplicate(true)
	gold = maxi(0, available_gold)
	if is_node_ready():
		refresh()

func refresh_from_game() -> void:
	var hero := clampi(hero_index, 0, 3)
	var data := {}
	data["Waffe"] = {"name": "Waffe", "level": GameManager.weapon_levels[hero], "stars": GameManager.weapon_rarities[hero]}
	for i in range(3):
		var item_id := int(GameManager.equipped_loot[hero][i])
		var item := GameManager.loot_item_by_id(item_id)
		var slot_name: String = ["Helm", "Brust", "Ring"][i]
		if not item.is_empty():
			data[slot_name] = {"name": GameManager.LOOT_SLOTS[i], "level": item.get("level", 0), "stars": item.get("rarity", 0)}
	set_equipment(data, GameManager.current_gold)

func refresh() -> void:
	if _grid == null:
		return
	_gold_label.text = "Gold: %d" % gold
	_hero_button.text = "Held %d von 4  ▶" % (hero_index + 1)
	var cost: int = GameManager.weapon_upgrade_cost(hero_index)
	_upgrade_button.disabled = cost <= 0 or gold < cost
	_upgrade_button.text = "Waffe verbessern: %d Gold" % cost if cost > 0 else "Waffe: Maximum erreicht"
	for child in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()
	for slot_id in SLOTS:
		var item: Dictionary = equipment.get(slot_id, {})
		var label := str(item.get("name", "Leer"))
		var level := maxi(0, int(item.get("level", 0)))
		var stars := clampi(int(item.get("stars", 0)), 0, 5)
		var button := Button.new()
		button.custom_minimum_size = Vector2(0, 92)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.text = "%s\n%s\nLv.%d  %s" % [slot_id, label, level, "★".repeat(stars)] if not item.is_empty() else "%s\n%s" % [slot_id, "Noch nicht verfügbar" if slot_id in ["Handschuhe", "Stiefel", "Amulett", "Relikt"] else "Leer"]
		button.pressed.connect(_select_slot.bind(slot_id))
		_grid.add_child(button)

func _select_slot(slot_id: String) -> void:
	slot_selected.emit(slot_id)

func _next_hero() -> void:
	hero_index = (hero_index + 1) % 4
	_notice.text = ""
	refresh_from_game()

func _upgrade_weapon() -> void:
	if GameManager.upgrade_weapon(hero_index):
		_notice.text = "Waffe erfolgreich verbessert."
	else:
		_notice.text = "Nicht genug Gold oder maximale Stufe erreicht."
	refresh_from_game()
