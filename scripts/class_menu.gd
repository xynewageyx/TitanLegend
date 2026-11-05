extends Control
const SKIN = preload("res://scripts/adventure_ui_theme.gd")
@export var team_formation: Node3D
var panel: PanelContainer
var slot_selector: OptionButton
var class_selector: OptionButton
var description: Label
var role_selector: OptionButton
var bonus_label: Label
const CLASS_ROLES := ["Tank / DD", "Tank / DD / Heilung", "Tank / DD / Heilung", "Tank / DD / Heilung", "DD", "DD", "DD", "DD", "DD", "Heilung / DD", "DD"]
func _ready() -> void:
 visible = false
 mouse_filter = Control.MOUSE_FILTER_STOP
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var dim := ColorRect.new()
 dim.color = SKIN.PAPER
 dim.mouse_filter = Control.MOUSE_FILTER_STOP
 dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(dim)
 panel = PanelContainer.new()
 panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 panel.offset_left = 14.0
 panel.offset_top = 18.0
 panel.offset_right = -14.0
 panel.offset_bottom = -18.0
 panel.custom_minimum_size = Vector2.ZERO
 panel.add_theme_stylebox_override("panel", SKIN.plaque(SKIN.PAPER, SKIN.WOOD, 20, 4))
 add_child(panel)
 var layout := VBoxContainer.new()
 layout.add_theme_constant_override("separation", 10)
 panel.add_child(layout)
 var header := HBoxContainer.new()
 layout.add_child(header)
 var title := Label.new()
 title.text = "✦ HELDEN & KLASSEN"
 title.add_theme_font_size_override("font_size", 26)
 title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 header.add_child(title)
 var header_close := Button.new()
 header_close.text = "✕"
 header_close.custom_minimum_size = Vector2(58, 56)
 header_close.pressed.connect(func(): visible = false)
 header.add_child(header_close)
 var scroll := ScrollContainer.new()
 scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
 scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
 layout.add_child(scroll)
 var v := VBoxContainer.new()
 v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 scroll.add_child(v)
 v.add_theme_constant_override("separation", 14)
 var hero_heading := Label.new()
 hero_heading.text = "◆ HELDENPLATZ"
 v.add_child(hero_heading)
 slot_selector = OptionButton.new()
 for i in range(4):
  slot_selector.add_item("Held " + str(i + 1), i)
 v.add_child(slot_selector)
 var class_heading := Label.new()
 class_heading.text = "⚔ KLASSE"
 v.add_child(class_heading)
 class_selector = OptionButton.new()
 for i in range(team_formation.CLASS_NAMES.size()):
  class_selector.add_item(team_formation.CLASS_NAMES[i], i)
 v.add_child(class_selector)
 var role_heading := Label.new()
 role_heading.text = "✦ KAMPFROLLE"
 v.add_child(role_heading)
 role_selector = OptionButton.new()
 v.add_child(role_selector)
 var formation_card := PanelContainer.new()
 formation_card.name = "FormationBonusCard"
 v.add_child(formation_card)
 var formation_body := VBoxContainer.new()
 formation_card.add_child(formation_body)
 var formation_heading := Label.new()
 formation_heading.text = "★ TEAMFORMATION"
 formation_body.add_child(formation_heading)
 bonus_label = Label.new()
 bonus_label.add_theme_font_size_override("font_size", 22)
 bonus_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 formation_body.add_child(bonus_label)
 var class_card := PanelContainer.new()
 class_card.name = "ClassDescriptionCard"
 v.add_child(class_card)
 description = Label.new()
 description.add_theme_font_size_override("font_size", 22)
 description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 class_card.add_child(description)
 var apply := Button.new()
 apply.text = "Klasse und Rolle uebernehmen"
 apply.custom_minimum_size.y = 75
 layout.add_child(apply)
 var close := Button.new()
 close.text = "Schliessen"
 close.custom_minimum_size.y = 65
 layout.add_child(close)
 SKIN.style_menu_tree(panel)
 formation_card.add_theme_stylebox_override("panel", SKIN.plaque(Color("#fff0c7"), SKIN.GOLD, 18, 3))
 class_card.add_theme_stylebox_override("panel", SKIN.plaque(Color("#fff0c7"), SKIN.GOLD, 18, 3))
 apply.pressed.connect(_apply)
 close.pressed.connect(func(): visible = false)
 class_selector.item_selected.connect(func(_id: int): _refresh_description())
 slot_selector.item_selected.connect(func(_id: int): _sync_slot())
 _sync_slot()
func open_menu() -> void:
 visible = true
 _sync_slot()
func _sync_slot() -> void:
 class_selector.select(team_formation.class_ids[slot_selector.selected])
 _refresh_description()
func _refresh_description() -> void:
 role_selector.clear()
 var selected_class: int = class_selector.selected
 var slot: int = slot_selector.selected
 for role in team_formation.ALLOWED_ROLES[selected_class]:
  role_selector.add_item(team_formation.ROLE_NAMES[role], role)
  if role == 0:
   var tank_taken: bool = false
   for i in range(4):
    if i != slot and team_formation.role_ids[i] == 0:
     tank_taken = true
   role_selector.set_item_disabled(role_selector.item_count - 1, tank_taken)
 var current_role: int = team_formation.role_ids[slot]
 for idx in range(role_selector.item_count):
  if role_selector.get_item_id(idx) == current_role:
   role_selector.select(idx)
   break
 if SaveManager.active_character_slot >= 0 and slot == 0:
  class_selector.disabled = true
  role_selector.disabled = true
  description.text = "Deine Klasse und Rolle sind dauerhaft festgelegt."
 else:
  class_selector.disabled = false
  role_selector.disabled = false
  description.text = "Moegliche Rollen: " + CLASS_ROLES[selected_class] + "\nBegleiter bleiben passiv."
 bonus_label.text = "Teambonus +5%: " + ("AKTIV" if team_formation.has_formation_bonus() else "INAKTIV")
func _apply() -> void:
 var chosen_role: int = role_selector.get_selected_id()
 var slot: int = slot_selector.selected
 if SaveManager.active_character_slot >= 0 and slot == 0:
  description.text = "Klasse und Rolle dieses Charakters wurden bei der Erstellung festgelegt."
  return
 if chosen_role == 0:
  for i in range(4):
   if i != slot and team_formation.role_ids[i] == 0:
    description.text = "Tankplatz belegt. Der bisherige Tank behaelt seine Rolle."
    return
 if not team_formation.set_class(slot, class_selector.selected):
  description.text = "Klassenwechsel abgelehnt."
  return
 if not team_formation.set_role(slot, chosen_role):
  description.text = "Rollenwechsel abgelehnt: Tankplatz bereits belegt."
  return
 _refresh_description()
