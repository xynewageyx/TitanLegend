extends CanvasLayer
## Mobile talent editor; attach as child of TeamFormation.
const TREES = preload("res://scripts/talent_tree_v2.gd")
const ADAPTER = preload("res://scripts/talent_combat_adapter_v2.gd")
var team: Node
var selected_hero: int = 0
var selected_branch: int = 0
var panel: PanelContainer
var hero_picker: OptionButton
var branch_picker: OptionButton
var points_label: Label
var bonus_label: Label
var talent_grid: GridContainer
var open_button: Button

func _ready() -> void:
 team = get_parent()
 open_button = Button.new()
 open_button.text = "Talente +"
 open_button.custom_minimum_size = Vector2(130, 52)
 open_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
 open_button.position = Vector2(12, 140)
 add_child(open_button)
 open_button.pressed.connect(_toggle)
 panel = PanelContainer.new()
 panel.visible = false
 panel.mouse_filter = Control.MOUSE_FILTER_STOP
 panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 panel.offset_left = 16
 panel.offset_top = 90
 panel.offset_right = -16
 panel.offset_bottom = -24
 add_child(panel)
 var frame := VBoxContainer.new()
 panel.add_child(frame)
 var header := HBoxContainer.new()
 frame.add_child(header)
 var heading := Label.new()
 heading.text = "Heldentalente"
 heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 header.add_child(heading)
 var close_button := Button.new()
 close_button.text = "Schliessen"
 close_button.custom_minimum_size = Vector2(110, 48)
 header.add_child(close_button)
 close_button.pressed.connect(_toggle)
 var scroll := ScrollContainer.new()
 scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
 scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
 scroll.follow_focus = true
 scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
 frame.add_child(scroll)
 var column := VBoxContainer.new()
 column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 column.custom_minimum_size = Vector2(270, 0)
 scroll.add_child(column)
 hero_picker = OptionButton.new()
 hero_picker.custom_minimum_size = Vector2(0, 52)
 for i in range(4):
  var hero_class_label: String = "Held"
  if team != null and i < team.class_ids.size():
   var class_index: int = int(team.class_ids[i])
   if class_index >= 0 and class_index < team.CLASS_NAMES.size():
    hero_class_label = str(team.CLASS_NAMES[class_index])
  hero_picker.add_item("Held %d - %s" % [i + 1, hero_class_label], i)
 column.add_child(hero_picker)
 hero_picker.item_selected.connect(func(index: int) -> void:
  selected_hero = index
  _refresh()
 )
 branch_picker = OptionButton.new()
 branch_picker.custom_minimum_size = Vector2(0, 52)
 for i in range(3):
  branch_picker.add_item(["Angriff", "Schutz", "Heilung"][i], i)
 column.add_child(branch_picker)
 branch_picker.item_selected.connect(func(index: int) -> void:
  selected_branch = index
  _refresh()
 )
 points_label = Label.new()
 points_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 column.add_child(points_label)
 bonus_label = Label.new()
 bonus_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 column.add_child(bonus_label)
 talent_grid = GridContainer.new()
 talent_grid.columns = 2
 talent_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 column.add_child(talent_grid)
 _refresh()

func _toggle() -> void:
 panel.visible = not panel.visible
 open_button.visible = not panel.visible
 if panel.visible:
  _refresh()

func _refresh() -> void:
 if team == null or not team.has_method("get_talent_build_v2"):
  return
 if team.class_ids.is_empty():
  return
 selected_hero = clampi(selected_hero, 0, mini(3, team.class_ids.size() - 1))
 selected_branch = clampi(selected_branch, 0, 2)
 var level: int = GameManager.character_level
 var build: Array = team.get_talent_build_v2(selected_hero)
 for hero_slot in range(hero_picker.item_count):
  var class_label: String = "Held"
  if hero_slot < team.class_ids.size():
   var class_index: int = int(team.class_ids[hero_slot])
   if class_index >= 0 and class_index < team.CLASS_NAMES.size():
    class_label = str(team.CLASS_NAMES[class_index])
  hero_picker.set_item_text(hero_slot, "Held %d - %s" % [hero_slot + 1, class_label])
 points_label.text = "Level %d | Frei: %d | Investiert: %d/225" % [level, TREES.available_points(level, build), TREES.spent_points(build)]
 if TREES.remaining_rank_capacity(build) == 0:
  points_label.text += " | Talentbaum voll"
 var bonus: Dictionary = ADAPTER.bonuses(int(team.class_ids[selected_hero]), level, build)
 bonus_label.text = "ATK +%.1f%%  Schutz +%.1f%%  Heilung +%.1f%%" % [float(bonus["attack"]) * 100.0, float(bonus["defense"]) * 100.0, float(bonus["healing"]) * 100.0]
 for child in talent_grid.get_children():
  talent_grid.remove_child(child)
  child.queue_free()
 for talent_index in range(15):
  var button := Button.new()
  button.custom_minimum_size = Vector2(112, 64)
  button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  var rank: int = int(build[selected_branch][talent_index])
  var row: int = int(talent_index / 3)
  button.text = "Talent %d\n%d/5" % [talent_index + 1, rank]
  button.tooltip_text = "Reihe %d | Rang %d/5" % [row + 1, rank]
  if rank >= TREES.MAX_RANK:
   button.tooltip_text += " | Maximalrang erreicht"
  elif row > 0:
   button.tooltip_text += " | Voraussetzung: %d Punkte in vorherigen Reihen" % (row * 5)
  button.disabled = not TREES.can_upgrade(level, build, selected_branch, talent_index)
  talent_grid.add_child(button)
  button.pressed.connect(_upgrade.bind(talent_index))

func _upgrade(talent_index: int) -> void:
 if team == null or not is_instance_valid(team):
  return
 if talent_index < 0 or talent_index >= 15:
  return
 if team.has_method("upgrade_talent_v2"):
  team.upgrade_talent_v2(selected_hero, selected_branch, talent_index)
 _refresh()
