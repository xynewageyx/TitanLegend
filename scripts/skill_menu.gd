extends Control
@export var team_formation: Node3D
@export var battle_manager: Node3D
var hero_selector: OptionButton
var skill_selectors: Array[OptionButton] = []
var info: Label

func _ready() -> void:
 visible = false
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 mouse_filter = Control.MOUSE_FILTER_STOP
 var shade := ColorRect.new()
 shade.color = Color(0.02, 0.04, 0.08, 0.96)
 shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(shade)
 var margin := MarginContainer.new()
 margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 margin.add_theme_constant_override("margin_left", 24)
 margin.add_theme_constant_override("margin_right", 24)
 margin.add_theme_constant_override("margin_top", 105)
 margin.add_theme_constant_override("margin_bottom", 100)
 add_child(margin)
 var stack := VBoxContainer.new()
 stack.add_theme_constant_override("separation", 9)
 margin.add_child(stack)
 var title := Label.new()
 title.text = "SKILLS: PRIORITAET 1 BIS 4"
 title.add_theme_font_size_override("font_size", 27)
 stack.add_child(title)
 hero_selector = OptionButton.new()
 for i in range(4):
  hero_selector.add_item("Held " + str(i + 1), i)
 stack.add_child(hero_selector)
 for skill_slot in range(4):
  var selector := OptionButton.new()
  selector.custom_minimum_size.y = 55
  skill_selectors.append(selector)
  stack.add_child(selector)
 info = Label.new()
 info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 info.add_theme_font_size_override("font_size", 19)
 stack.add_child(info)
 var apply := Button.new()
 apply.text = "Vier Skills speichern"
 apply.custom_minimum_size.y = 65
 stack.add_child(apply)
 var close := Button.new()
 close.text = "Schliessen"
 close.custom_minimum_size.y = 65
 stack.add_child(close)
 apply.pressed.connect(_apply)
 close.pressed.connect(func(): visible = false)
 hero_selector.item_selected.connect(func(_idx: int): _refresh())
 _refresh()

func open_menu() -> void:
 visible = true
 _refresh()

func _refresh() -> void:
 var hero: int = hero_selector.selected
 var role: int = int(team_formation.role_ids[hero])
 var class_id: int = int(team_formation.class_ids[hero])
 for skill_slot in range(4):
  var selector: OptionButton = skill_selectors[skill_slot]
  selector.clear()
  for choice in range(10 if role == 0 else 8):
   var skill_name: String = TitanCrowdControl.ability_name(class_id) if choice == 7 else str(TitanSkillSystem.skill_for_role(role, choice)["name"])
   var hits: int = battle_manager._skill_hit_cost(role, choice)
   selector.add_item(str(skill_slot + 1) + ". " + skill_name + "  (" + str(hits) + " Treffer)", choice)
  selector.select(clampi(int(battle_manager.skill_loadouts[hero][skill_slot]), 0, 9 if role == 0 else 7))
 info.text = "Normale Treffer laden Skills auf (2 bis 5 Treffer).\nAlle 4 belegten Skills werden der Reihe nach automatisch genutzt.\nSpott und Gruppenschutz sind getrennte Tank-Skills.\nHeilung nur bei Bedarf; CC nur bei einem Boss-Cast."

func _apply() -> void:
 var hero: int = hero_selector.selected
 for skill_slot in range(4):
  battle_manager.set_skill_loadout(hero, skill_slot, skill_selectors[skill_slot].get_selected_id())
 info.text = "Vier Skills mit fester Prioritaet gespeichert!"
