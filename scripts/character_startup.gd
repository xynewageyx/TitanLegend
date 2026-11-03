extends Control
## Character-first startup. Existing legacy saves remain on the old startup path.
const PROFILES = preload("res://scripts/character_profiles.gd")
const SELECTOR = preload("res://scripts/character_selection.gd")
const LEGACY = "user://save_data.json"
const GAME_SCENE = "res://scenes/main.tscn"
var selector: Control

func _ready() -> void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var registry: Dictionary = PROFILES.load_registry()
 var occupied: bool = false
 for character in registry.get("characters", []):
  if character is Dictionary:
   occupied = true
   break
 # Existing installations stay in legacy mode until migration is supported.
 if not occupied and (FileAccess.file_exists(LEGACY) or FileAccess.file_exists(LEGACY + ".bak")):
  SaveManager.use_legacy_save()
  SaveManager.begin_game_session()
  if not SaveManager.session_ready:
   push_error("Legacy session initialization failed.")
   return
  get_tree().call_deferred("change_scene_to_file", GAME_SCENE)
  return
 SaveManager.character_switching_enabled = true
 selector = SELECTOR.new()
 selector.character_selected.connect(_enter_game)
 add_child(selector)

func _enter_game(_slot: int) -> void:
 if SaveManager.active_character_slot < 0:
  return
 SaveManager.begin_game_session()
 if not SaveManager.session_ready:
  push_error("Character session initialization failed.")
  return
 get_tree().call_deferred("change_scene_to_file", GAME_SCENE)
