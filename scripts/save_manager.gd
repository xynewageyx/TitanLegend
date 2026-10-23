extends Node
const SAVE_PATH: String = "user://save_data.json"
var timer: Timer
func _ready() -> void:
 load_game()
 timer = Timer.new()
 timer.wait_time = 60.0
 timer.autostart = true
 timer.timeout.connect(save_game)
 add_child(timer)
func save_game() -> void:
 var data: Dictionary = {
  "version": 1, "astral_floor": 1, "astral_marks": 0, "gold": GameManager.current_gold,
  "tickets": GameManager.reincarnation_tickets,
  "gems": ShopManager.gems, "unlocked_skins": ShopManager.unlocked_skins.duplicate(), "equipped_skins": ShopManager.equipped_skins.duplicate(),
  "reincarnation": GameManager.current_reincarnation_level,
  "character_level": GameManager.character_level,
  "jewel_level": GameManager.jewel_level,
  "weapon_levels": GameManager.weapon_levels.duplicate(),
  "ads_watched": AdManager.ads_watched_today,
  "ad_date": AdManager.last_watch_date,
  "stage": 1, "wave": 1, "skill_choices": [0, 0, 0, 0], "skill_loadouts": [[0,1,2,7],[0,1,2,7],[0,1,2,7],[0,1,2,7]], "talents": [[0,0,0],[0,0,0],[0,0,0],[0,0,0]], "talent_branches": [[-1,-1,-1],[-1,-1,-1],[-1,-1,-1],[-1,-1,-1]]
 }
 var battle: Node = get_tree().get_first_node_in_group("battle_manager")
 if battle != null:
  data["skill_choices"] = battle.skill_choices
  data["skill_loadouts"] = battle.skill_loadouts
  data["stage"] = battle.world_progress.x if battle.astral_active else battle.current_level
  data["wave"] = battle.world_progress.y if battle.astral_active else battle.current_wave
  data["astral_floor"] = battle.astral_floor
  data["astral_marks"] = battle.astral_marks
 var team: Node = get_tree().get_first_node_in_group("talent_team")
 if team != null:
  data["talents"] = team.talent_ranks
  data["talent_branches"] = team.talent_branches
 var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
 if file == null:
  push_warning("Save failed: " + str(FileAccess.get_open_error()))
  return
 file.store_string(JSON.stringify(data))
 file.close()
func load_game() -> void:
 if not FileAccess.file_exists(SAVE_PATH):
  return
 var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
 if file == null:
  return
 var parsed: Variant = JSON.parse_string(file.get_as_text())
 file.close()
 if not parsed is Dictionary:
  push_warning("Save file is invalid")
  return
 var data: Dictionary = parsed
 ShopManager.restore_state(data)
 GameManager.current_gold = maxi(0, int(data.get("gold", 10000)))
 GameManager.reincarnation_tickets = maxi(0, int(data.get("tickets", 500)))
 GameManager.current_reincarnation_level = clampi(int(data.get("reincarnation", 0)), 0, 5)
 GameManager.character_level = maxi(1, int(data.get("character_level", 1)))
 GameManager.jewel_level = maxi(1, int(data.get("jewel_level", 1)))
 var weapons: Variant = data.get("weapon_levels", [0, 0, 0, 0])
 GameManager.weapon_levels = [0, 0, 0, 0]
 if weapons is Array:
  for slot in range(mini(4, weapons.size())):
   GameManager.weapon_levels[slot] = clampi(int(weapons[slot]), 0, GameManager.MAX_WEAPON_LEVEL)
 AdManager.ads_watched_today = clampi(int(data.get("ads_watched", 0)), 0, 3)
 AdManager.last_watch_date = str(data.get("ad_date", ""))
 AdManager.check_daily_reset()
 GameManager.gold_changed.emit(GameManager.current_gold)
 GameManager.tickets_changed.emit(GameManager.reincarnation_tickets)
 GameManager.reincarnation_performed.emit(GameManager.current_reincarnation_level)
func get_saved_battle_progress() -> Vector2i:
 if not FileAccess.file_exists(SAVE_PATH):
  return Vector2i(1, 1)
 var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
 if file == null:
  return Vector2i(1, 1)
 var parsed: Variant = JSON.parse_string(file.get_as_text())
 file.close()
 if parsed is Dictionary:
  return Vector2i(maxi(1, int(parsed.get("stage", 1))), clampi(int(parsed.get("wave", 1)), 1, 10))
 return Vector2i(1, 1)
func _notification(what: int) -> void:
 if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
  save_game()

func get_saved_skill_choices() -> Array[int]:
 var choices: Array[int] = [0, 0, 0, 0]
 if not FileAccess.file_exists(SAVE_PATH):
  return choices
 var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
 if file == null:
  return choices
 var parsed: Variant = JSON.parse_string(file.get_as_text())
 file.close()
 if parsed is Dictionary:
  var saved: Variant = parsed.get("skill_choices", [])
  if saved is Array:
   for i in range(mini(4, saved.size())):
    choices[i] = clampi(int(saved[i]), 0, 1)
 return choices

func get_saved_talents() -> Array:
 var result: Array = [[0,0,0], [0,0,0], [0,0,0], [0,0,0]]
 if not FileAccess.file_exists(SAVE_PATH):
  return result
 var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
 if file == null:
  return result
 var parsed: Variant = JSON.parse_string(file.get_as_text())
 file.close()
 if not parsed is Dictionary:
  return result
 var saved: Variant = parsed.get("talents", [])
 if not saved is Array or saved.size() != 4:
  return result
 for slot in range(4):
  if saved[slot] is Array and saved[slot].size() == 3:
   for tree in range(3):
    result[slot][tree] = clampi(int(saved[slot][tree]), 0, TitanTalentSystem.MAX_RANK)
 return result

func get_saved_talent_branches() -> Array:
 var result: Array = [[-1,-1,-1],[-1,-1,-1],[-1,-1,-1],[-1,-1,-1]]
 if not FileAccess.file_exists(SAVE_PATH):
  return result
 var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
 if file == null:
  return result
 var parsed: Variant = JSON.parse_string(file.get_as_text())
 file.close()
 if not parsed is Dictionary:
  return result
 var saved: Variant = parsed.get("talent_branches", [])
 if not saved is Array or saved.size() != 4:
  return result
 for slot in range(4):
  if saved[slot] is Array and saved[slot].size() == 3:
   for tree in range(3):
    result[slot][tree] = clampi(int(saved[slot][tree]), -1, 1)
 return result

func get_saved_skill_loadouts() -> Array:
 var result: Array = [[0,1,2,7],[0,1,2,7],[0,1,2,7],[0,1,2,7]]
 if not FileAccess.file_exists(SAVE_PATH):
  return result
 var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
 if file == null:
  return result
 var parsed: Variant = JSON.parse_string(file.get_as_text())
 file.close()
 if not parsed is Dictionary:
  return result
 var saved: Variant = parsed.get("skill_loadouts", [])
 if saved is Array and saved.size() == 4:
  for hero in range(4):
   if saved[hero] is Array and saved[hero].size() == 4:
    for skill_slot in range(4):
     result[hero][skill_slot] = clampi(int(saved[hero][skill_slot]), 0, 10)
 return result

func get_saved_astral() -> Dictionary:
 if not FileAccess.file_exists(SAVE_PATH):
  return {"floor": 1, "marks": 0}
 var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
 if file == null:
  return {"floor": 1, "marks": 0}
 var parsed: Variant = JSON.parse_string(file.get_as_text())
 file.close()
 if parsed is Dictionary:
  return {"floor": maxi(1, int(parsed.get("astral_floor", 1))), "marks": maxi(0, int(parsed.get("astral_marks", 0)))}
 return {"floor": 1, "marks": 0}
