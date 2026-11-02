extends Control
## Standalone character selection/creation screen. The game must connect
## character_selected before enabling entry into the world.
const PROFILES = preload("res://scripts/character_profiles.gd")
const SAVE_SLOTS = preload("res://scripts/character_save_slots.gd")
signal character_selected(slot: int)
var registry: Dictionary = {}
var list_container: VBoxContainer
var name_input: LineEdit
var class_input: OptionButton
var role_input: OptionButton
var message_label: Label
var creation_slot: int = -1

func _ready() -> void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 mouse_filter = Control.MOUSE_FILTER_STOP
 registry = PROFILES.load_registry()
 var background := ColorRect.new()
 background.color = Color("#182334")
 background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(background)
 var margin := MarginContainer.new()
 margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 margin.add_theme_constant_override("margin_left", 20)
 margin.add_theme_constant_override("margin_right", 20)
 margin.add_theme_constant_override("margin_top", 28)
 margin.add_theme_constant_override("margin_bottom", 28)
 add_child(margin)
 var scroll := ScrollContainer.new()
 scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
 margin.add_child(scroll)
 var content := VBoxContainer.new()
 content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 content.add_theme_constant_override("separation", 12)
 scroll.add_child(content)
 var title := Label.new()
 title.text = "TITAN LEGENDS · CHARAKTERE"
 title.add_theme_font_size_override("font_size", 24)
 content.add_child(title)
 var hint := Label.new()
 hint.text = "Bis zu 5 getrennte Charaktere. Klasse und Rolle sind nach der Erstellung fest."
 hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 content.add_child(hint)
 list_container = VBoxContainer.new()
 list_container.add_theme_constant_override("separation", 8)
 content.add_child(list_container)
 var creator := PanelContainer.new()
 content.add_child(creator)
 var fields := VBoxContainer.new()
 fields.add_theme_constant_override("separation", 8)
 creator.add_child(fields)
 var creator_title := Label.new()
 creator_title.text = "NEUEN CHARAKTER ERSTELLEN"
 fields.add_child(creator_title)
 name_input = LineEdit.new()
 name_input.placeholder_text = "Charaktername (1–24 Zeichen)"
 name_input.custom_minimum_size.y = 52
 fields.add_child(name_input)
 class_input = OptionButton.new()
 class_input.custom_minimum_size.y = 52
 for i in range(PROFILES.CLASS_NAMES.size()):
  class_input.add_item(PROFILES.CLASS_NAMES[i], i)
 fields.add_child(class_input)
 role_input = OptionButton.new()
 role_input.custom_minimum_size.y = 52
 fields.add_child(role_input)
 class_input.item_selected.connect(func(_index: int): _refresh_roles())
 _refresh_roles()
 var create_button := Button.new()
 create_button.text = "Charakter erstellen"
 create_button.custom_minimum_size.y = 60
 create_button.pressed.connect(_create)
 fields.add_child(create_button)
 message_label = Label.new()
 message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 fields.add_child(message_label)
 _refresh_slots()

func _refresh_roles() -> void:
 role_input.clear()
 var class_id: int = class_input.get_selected_id()
 if class_id < 0:
  return
 for role_id in PROFILES.ALLOWED_ROLES[class_id]:
  role_input.add_item(PROFILES.ROLE_NAMES[role_id], role_id)

func _refresh_slots() -> void:
 for child in list_container.get_children():
  child.queue_free()
 creation_slot = -1
 var characters: Array = registry.get("characters", [])
 if characters.size() != PROFILES.MAX_CHARACTERS:
  return
 for slot in range(PROFILES.MAX_CHARACTERS):
  var button := Button.new()
  button.custom_minimum_size.y = 74
  var profile: Variant = characters[slot]
  if profile is Dictionary:
   var class_id: int = int(profile.get("class_id", 0))
   var role_id: int = int(profile.get("role_id", 1))
   class_id = clampi(class_id, 0, PROFILES.CLASS_NAMES.size() - 1)
   role_id = clampi(role_id, 0, PROFILES.ROLE_NAMES.size() - 1)
   button.text = "%d · %s · Level %d · %s / %s" % [slot + 1, str(profile.get("name", "")), int(profile.get("level", 1)), PROFILES.CLASS_NAMES[class_id], PROFILES.ROLE_NAMES[role_id]]
   button.pressed.connect(_select.bind(slot))
  else:
   button.text = "%d · Freier Charakterplatz" % (slot + 1)
   button.pressed.connect(_choose_empty.bind(slot))
   if creation_slot == -1:
    creation_slot = slot
  list_container.add_child(button)

func _choose_empty(slot: int) -> void:
 creation_slot = slot
 message_label.text = "Charakterplatz %d ausgewählt." % (slot + 1)
 name_input.grab_focus()

func _create() -> void:
 if creation_slot < 0:
  message_label.text = "Alle fünf Charakterplätze sind belegt."
  return
 var candidate: Dictionary = registry.duplicate(true)
 if not PROFILES.create_character(candidate, creation_slot, name_input.text, class_input.get_selected_id(), role_input.get_selected_id()):
  message_label.text = "Bitte gültigen Namen, Klasse und Rolle auswählen."
  return
 var save_error: Error = SAVE_SLOTS.create_slot_save(candidate, creation_slot)
 if save_error != OK:
  message_label.text = "Spielstand konnte nicht erstellt werden (%d)." % save_error
  return
 var result: Error = PROFILES.save_registry(candidate)
 if result != OK:
  message_label.text = "Charakterliste konnte nicht gespeichert werden (%d). Spielstand bleibt zur Wiederherstellung erhalten." % result
  _refresh_slots()
  return
 registry = candidate
 name_input.clear()
 message_label.text = "Charakter erstellt. Wähle ihn zum Spielen aus."
 _refresh_slots()

func _select(slot: int) -> void:
 var character_save: Dictionary = SAVE_SLOTS.load_slot(registry, slot)
 if character_save.is_empty():
  message_label.text = "Spielstand fehlt oder ist beschädigt. Charakterwechsel abgebrochen."
  return
 var profile: Dictionary = registry["characters"][slot]
 if int(character_save.get("class_id", -1)) != int(profile.get("class_id", -2)) or int(character_save.get("role_id", -1)) != int(profile.get("role_id", -2)):
  message_label.text = "Klasse oder Rolle stimmen nicht mit dem Charakterprofil überein."
  return
 var candidate: Dictionary = registry.duplicate(true)
 # The save file is authoritative for progression; the registry only caches
 # level/XP for the character selection screen.
 var updated_profile: Dictionary = candidate["characters"][slot]
 updated_profile["level"] = maxi(1, int(character_save.get("character_level", 1)))
 updated_profile["xp"] = maxi(0, int(character_save.get("character_xp", 0)))
 updated_profile["reincarnation"] = maxi(0, int(character_save.get("reincarnation", 0)))
 candidate["characters"][slot] = updated_profile
 if not PROFILES.select_character(candidate, slot):
  return
 # Do not persist a new active slot while the running game still uses
 # another character's data. The startup coordinator must authorize switching.
 if not SaveManager.character_switching_enabled:
  message_label.text = "Charakterwechsel ist während einer aktiven Spielsitzung gesperrt."
  return
 var switch_error: Error = SaveManager.configure_character_save(slot)
 if switch_error != OK:
  message_label.text = "Spielstandwechsel fehlgeschlagen (%d)." % switch_error
  return
 var result: Error = PROFILES.save_registry(candidate)
 if result != OK:
  SaveManager.use_legacy_save()
  message_label.text = "Charakterauswahl konnte nicht gespeichert werden (%d)." % result
  return
 registry = candidate
 character_selected.emit(slot)
