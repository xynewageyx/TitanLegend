extends Control
# Update 21: touchfreundlicher, verzweigter Talentbaum mit Rang-Meilensteinen.
@export var team_formation: Node3D
@export var battle_manager: Node3D

var slot_picker: OptionButton
var summary: Label
var tree_cards: Array[VBoxContainer] = []
var rank_labels: Array[Label] = []
var progress_bars: Array[ProgressBar] = []
var milestone_labels: Array[Label] = []
var ability_labels: Array[Label] = []
var invest_buttons: Array[Button] = []
var branch_buttons: Array[Array] = []
var path_diagrams: Array[Control] = []
var message_label: Label
var reset_button: Button
var reset_confirm: ConfirmationDialog

func _ready() -> void:
 visible = false
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 mouse_filter = Control.MOUSE_FILTER_STOP
 var shade := ColorRect.new()
 shade.color = Color(0.025, 0.04, 0.075, 0.98)
 shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(shade)
 var margin := MarginContainer.new()
 margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 margin.add_theme_constant_override("margin_left", 18)
 margin.add_theme_constant_override("margin_right", 18)
 margin.add_theme_constant_override("margin_top", 20)
 margin.add_theme_constant_override("margin_bottom", 20)
 add_child(margin)
 var outer := VBoxContainer.new()
 outer.add_theme_constant_override("separation", 12)
 margin.add_child(outer)
 var top := HBoxContainer.new()
 outer.add_child(top)
 var heading := Label.new()
 heading.text = "TALENTBAEUME"
 heading.add_theme_font_size_override("font_size", 28)
 heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 top.add_child(heading)
 var close := Button.new()
 close.text = "X"
 close.custom_minimum_size = Vector2(70, 65)
 close.pressed.connect(func(): visible = false)
 top.add_child(close)
 slot_picker = OptionButton.new()
 slot_picker.custom_minimum_size.y = 64
 for slot in range(4):
  slot_picker.add_item("Held " + str(slot + 1), slot)
 slot_picker.item_selected.connect(func(_index: int): _refresh())
 outer.add_child(slot_picker)
 summary = Label.new()
 summary.add_theme_font_size_override("font_size", 22)
 summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 outer.add_child(summary)
 var scroll := ScrollContainer.new()
 scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
 outer.add_child(scroll)
 var stack := VBoxContainer.new()
 stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 stack.add_theme_constant_override("separation", 20)
 scroll.add_child(stack)
 for tree in range(3):
  _create_tree_card(stack, tree)
 reset_button = Button.new()
 reset_button.custom_minimum_size.y = 68
 reset_button.add_theme_font_size_override("font_size", 21)
 reset_button.pressed.connect(_request_reset)
 outer.add_child(reset_button)
 reset_confirm = ConfirmationDialog.new()
 reset_confirm.title = "Talente zuruecksetzen"
 reset_confirm.confirmed.connect(_confirm_reset)
 add_child(reset_confirm)
 message_label = Label.new()
 message_label.add_theme_font_size_override("font_size", 19)
 message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 outer.add_child(message_label)
 _refresh()

func _create_tree_card(stack: VBoxContainer, tree: int) -> void:
 var panel := PanelContainer.new()
 stack.add_child(panel)
 var card := VBoxContainer.new()
 card.add_theme_constant_override("separation", 10)
 panel.add_child(card)
 tree_cards.append(card)
 var title := Label.new()
 title.add_theme_font_size_override("font_size", 24)
 title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 card.add_child(title)
 rank_labels.append(title)
 var progress := ProgressBar.new()
 progress.custom_minimum_size.y = 24
 progress.max_value = 100
 progress.show_percentage = false
 card.add_child(progress)
 progress_bars.append(progress)
 var milestones := Label.new()
 milestones.add_theme_font_size_override("font_size", 19)
 milestones.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 card.add_child(milestones)
 milestone_labels.append(milestones)
 var ability := Label.new()
 ability.add_theme_font_size_override("font_size", 19)
 ability.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 card.add_child(ability)
 ability_labels.append(ability)
 var invest_row := HBoxContainer.new()
 card.add_child(invest_row)
 var buttons_for_tree: Array[Button] = []
 for amount in [1, 5, 10]:
  var invest := Button.new()
  invest.text = "+" + str(amount) + " Punkte"
  invest.custom_minimum_size.y = 62
  invest.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  invest.add_theme_font_size_override("font_size", 18)
  invest.pressed.connect(_invest.bind(tree, amount))
  invest_row.add_child(invest)
  buttons_for_tree.append(invest)
 # Drei Buttons pro Baum; der Zustand wird in _refresh() gesetzt.
 for invest in buttons_for_tree:
  invest_buttons.append(invest)
 var diagram := Control.new()
 diagram.set_script(preload("res://scripts/talent_path_diagram.gd"))
 diagram.custom_minimum_size = Vector2(240, 195)
 card.add_child(diagram)
 path_diagrams.append(diagram)
 var branch_row := HBoxContainer.new()
 card.add_child(branch_row)
 var pair: Array[Button] = []
 for branch in range(2):
  var choice := Button.new()
  choice.custom_minimum_size.y = 92
  choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
  choice.add_theme_font_size_override("font_size", 18)
  choice.pressed.connect(_select_branch.bind(tree, branch))
  branch_row.add_child(choice)
  pair.append(choice)
 branch_buttons.append(pair)

func open_menu() -> void:
 visible = true
 _refresh()

func _refresh() -> void:
 if team_formation == null:
  return
 var slot: int = maxi(0, slot_picker.selected)
 var ranks: Array = team_formation.talent_ranks[slot]
 var used: int = 0
 for rank in ranks:
  used += int(rank)
 var total: int = TitanTalentSystem.points_available(GameManager.character_level)
 var free: int = maxi(0, total - used)
 var class_id: int = int(team_formation.class_ids[slot])
 var class_label: String = str(team_formation.CLASS_NAMES[class_id])
 summary.text = class_label + " | Level " + str(GameManager.character_level) + "\n" + str(free) + " freie Talentpunkte (3 pro Levelaufstieg)"
 reset_button.text = "Talente zuruecksetzen (" + str(team_formation.talent_reset_cost()) + " Gold)"
 reset_button.disabled = used <= 0 or GameManager.current_gold < team_formation.talent_reset_cost()
 for tree in range(3):
  var rank: int = int(ranks[tree])
  rank_labels[tree].text = TitanTalentSystem.tree_title(class_label, tree) + "   Rang " + str(rank) + "/" + str(TitanTalentSystem.MAX_RANK)
  progress_bars[tree].value = minf(100.0, float(rank))
  var steps: Array[String] = []
  for i in range(TitanTalentSystem.MILESTONE_RANKS.size()):
   var required: int = int(TitanTalentSystem.MILESTONE_RANKS[i])
   var mark: String = "[OK]" if rank >= required else "[ ]"
   steps.append(mark + " " + str(required))
  milestone_labels[tree].text = "Meilensteine: " + "  ".join(steps) + "\n" + TitanTalentSystem.description_for_class(class_id, tree, rank)
  var unlocked: bool = rank >= TitanTalentAbilities.UNLOCK_RANK
  ability_labels[tree].text = ("AKTIV: " if unlocked else "Ab Rang 10: ") + TitanTalentAbilities.ability_name(class_id, tree)
  for index in range(3):
   var amount: int = [1, 5, 10][index]
   invest_buttons[tree * 3 + index].disabled = free <= 0 or rank >= TitanTalentSystem.MAX_RANK
   invest_buttons[tree * 3 + index].tooltip_text = "Investiert bis zu " + str(amount) + " verfuegbare Punkte"
  var current: int = int(team_formation.talent_branches[slot][tree])
  path_diagrams[tree].set_progress(rank, current)
  for branch in range(2):
   var button: Button = branch_buttons[tree][branch]
   button.disabled = rank < TitanTalentSystem.BRANCH_UNLOCK_RANK
   var label: String = str(TitanTalentSystem.BRANCH_NAMES[branch])
   var selected: String = " [GEWAEHLT]" if current == branch else ""
   button.text = label + selected + "\n" + TitanTalentSystem.branch_description(tree, branch)
   if rank < TitanTalentSystem.BRANCH_UNLOCK_RANK:
    button.text = "Ab Rang 25\n" + label

func _invest(tree: int, amount: int) -> void:
 var slot: int = maxi(0, slot_picker.selected)
 var invested: int = 0
 for _i in range(amount):
  if not team_formation.spend_talent(slot, tree, TitanTalentSystem.points_available(GameManager.character_level)):
   break
  invested += 1
 message_label.text = str(invested) + " Talentpunkt(e) verteilt."
 _refresh()

func _select_branch(tree: int, branch: int) -> void:
 var slot: int = maxi(0, slot_picker.selected)
 if team_formation.select_talent_branch(slot, tree, branch):
  message_label.text = "Spezialisierung gewaehlt und gespeichert."
 else:
  message_label.text = "Dieser Pfad wird erst ab Rang 25 freigeschaltet."
 _refresh()

func _request_reset() -> void:
 var slot: int = maxi(0, slot_picker.selected)
 var cost: int = team_formation.talent_reset_cost()
 reset_confirm.dialog_text = "Alle Talente von Held " + str(slot + 1) + " zuruecksetzen?\nKosten: " + str(cost) + " Gold.\nAlle investierten Punkte werden erstattet."
 reset_confirm.popup_centered()

func _confirm_reset() -> void:
 var slot: int = maxi(0, slot_picker.selected)
 if team_formation.reset_hero_talents(slot):
  message_label.text = "Talentpunkte erstattet. Gold wurde abgezogen."
 else:
  message_label.text = "Zuruecksetzen nicht moeglich: zu wenig Gold oder keine Punkte verteilt."
 _refresh()
