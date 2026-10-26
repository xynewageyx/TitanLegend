extends Control
@export var team_formation: Node3D
var panel: PanelContainer
var slot_selector: OptionButton
var class_selector: OptionButton
var description: Label
var role_selector: OptionButton
var pet_species_selector: OptionButton
var pet_element_selector: OptionButton
const PET_SPECIES := ["Fuchs", "Schildkroete", "Hirsch", "Eule", "Drache"]
const PET_ELEMENTS := ["Feuer", "Wasser", "Natur", "Licht", "Schatten", "Wind", "Eis", "Blitz", "Erde", "Chaos"]
var bonus_label: Label
const CLASS_ROLES := ["Tank / DD", "Tank / DD / Heilung", "Tank / DD / Heilung", "Tank / DD / Heilung", "DD", "DD", "DD", "DD", "DD", "Heilung / DD", "DD"]
func _ready() -> void:
 visible = false
 mouse_filter = Control.MOUSE_FILTER_STOP
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var dim := ColorRect.new()
 dim.color = Color(0.02, 0.04, 0.06, 0.88)
 dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(dim)
 panel = PanelContainer.new()
 panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 panel.offset_left = 24.0
 panel.offset_top = 95.0
 panel.offset_right = -24.0
 panel.offset_bottom = -95.0
 panel.custom_minimum_size = Vector2.ZERO
 add_child(panel)
 var scroll := ScrollContainer.new()
 scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
 scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
 panel.add_child(scroll)
 var v := VBoxContainer.new()
 v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 v.add_theme_constant_override("separation", 10)
 scroll.add_child(v)
 var title := Label.new()
 title.text = "TEAM & KLASSEN"
 title.add_theme_font_size_override("font_size", 25)
 v.add_child(title)
 slot_selector = OptionButton.new()
 for i in range(4):
  slot_selector.add_item("Held " + str(i + 1), i)
 v.add_child(slot_selector)
 class_selector = OptionButton.new()
 for i in range(team_formation.CLASS_NAMES.size()):
  class_selector.add_item(team_formation.CLASS_NAMES[i], i)
 v.add_child(class_selector)
 role_selector = OptionButton.new()
 v.add_child(role_selector)
 var pet_heading := Label.new()
 pet_heading.text = "PASSIVER BEGLEITER"
 pet_heading.add_theme_font_size_override("font_size", 21)
 v.add_child(pet_heading)
 pet_species_selector = OptionButton.new()
 for i in range(PET_SPECIES.size()):
  pet_species_selector.add_item(PET_SPECIES[i], i)
 v.add_child(pet_species_selector)
 pet_element_selector = OptionButton.new()
 for i in range(PET_ELEMENTS.size()):
  pet_element_selector.add_item(PET_ELEMENTS[i], i)
 v.add_child(pet_element_selector)
 bonus_label = Label.new()
 bonus_label.add_theme_font_size_override("font_size", 22)
 bonus_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 v.add_child(bonus_label)
 description = Label.new()
 description.add_theme_font_size_override("font_size", 22)
 description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 v.add_child(description)
 var apply := Button.new()
 apply.text = "Klasse, Rolle und Begleiter uebernehmen"
 apply.custom_minimum_size.y = 60
 v.add_child(apply)
 var close := Button.new()
 close.text = "Schliessen"
 close.custom_minimum_size.y = 55
 v.add_child(close)
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
 pet_species_selector.select(team_formation.pet_species_ids[slot_selector.selected])
 pet_element_selector.select(team_formation.pet_element_ids[slot_selector.selected])
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
 description.text = "Rollen: " + CLASS_ROLES[selected_class] + "\nBegleiter bleiben passiv. Gleiche Arten und Elemente sind erlaubt."
 bonus_label.text = "Teambonus +5%: " + ("AKTIV" if team_formation.has_formation_bonus() else "INAKTIV")
func _apply() -> void:
 var chosen_role: int = role_selector.get_selected_id()
 var slot: int = slot_selector.selected
 if chosen_role == 0:
  for i in range(4):
   if i != slot and team_formation.role_ids[i] == 0:
    description.text = "Tankplatz belegt. Der bisherige Tank behaelt seine Rolle."
    return
 team_formation.set_class(slot, class_selector.selected)
 if not team_formation.set_role(slot, chosen_role):
  description.text = "Rollenwechsel abgelehnt: Tankplatz bereits belegt."
  return
 team_formation.set_pet_species(slot, pet_species_selector.get_selected_id())
 team_formation.set_pet_element(slot, pet_element_selector.get_selected_id())
 _refresh_description()
