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

func _ready() -> void:
 team = get_parent()
 var open_button := Button.new()
 open_button.text = "Talente +"
 open_button.custom_minimum_size = Vector2(130, 52)
 open_button.position = Vector2(12, 140)
 add_child(open_button)
 open_button.pressed.connect(_toggle)
 panel = PanelContainer.new()
 panel.visible = false
 panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 panel.offset_left = 16
 panel.offset_top = 220
 panel.offset_right = -16
 panel.offset_bottom = -24
 add_child(panel)
 var scroll := ScrollContainer.new()
 panel.add_child(scroll)
 var column := VBoxContainer.new()
 column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 scroll.add_child(column)
 var close_button := Button.new()
 close_button.text = "Schliessen"
 column.add_child(close_button)
 close_button.pressed.connect(_toggle)
 hero_picker = OptionButton.new()
 for i in range(4):
  hero_picker.add_item("Held " + str(i + 1), i)
 column.add_child(hero_picker)
 hero_picker.item_selected.connect(func(index: int) -> void:
  selected_hero = index
  _refresh()
 )
 branch_picker = OptionButton.new()
 for i in range(3):
  branch_picker.add_item(["Angriff", "Schutz", "Heilung"][i], i)
 column.add_child(branch_picker)
 branch_picker.item_selected.connect(func(index: int) -> void:
  selected_branch = index
  _refresh()
 )
 points_label = Label.new()
 column.add_child(points_label)
 bonus_label = Label.new()
 column.add_child(bonus_label)
 talent_grid = GridContainer.new()
 talent_grid.columns = 3
 column.add_child(talent_grid)
 _refresh()

func _toggle() -> void:
 panel.visible = not panel.visible
 if panel.visible:
  _refresh()

func _refresh() -> void:
 if team == null or not team.has_method("get_talent_build_v2"):
  return
 var level: int = GameManager.character_level
 var build: Array = team.get_talent_build_v2(selected_hero)
 points_label.text = "Level %d | Verfuegbar: %d" % [level, TREES.available_points(level, build)]
 var bonus: Dictionary = ADAPTER.bonuses(int(team.class_ids[selected_hero]), level, build)
 bonus_label.text = "ATK +%.1f%%  Schutz +%.1f%%  Heilung +%.1f%%" % [float(bonus["attack"]) * 100.0, float(bonus["defense"]) * 100.0, float(bonus["healing"]) * 100.0]
 for child in talent_grid.get_children():
  talent_grid.remove_child(child)
  child.queue_free()
 for talent_index in range(15):
  var button := Button.new()
  button.custom_minimum_size = Vector2(88, 58)
  button.text = "Talent %d\n%d/5" % [talent_index + 1, int(build[selected_branch][talent_index])]
  button.disabled = not TREES.can_upgrade(level, build, selected_branch, talent_index)
  talent_grid.add_child(button)
  button.pressed.connect(_upgrade.bind(talent_index))

func _upgrade(talent_index: int) -> void:
 var level: int = GameManager.character_level
 var build: Array = team.get_talent_build_v2(selected_hero)
 if not TREES.upgrade(level, build, selected_branch, talent_index):
  return
 if team.set_talent_build_v2(selected_hero, level, build):
  SaveManager.save_game()
 _refresh()
