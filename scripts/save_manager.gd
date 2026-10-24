extends Node
const SAVE_FILE_STORE = preload("res://scripts/save_file_store.gd")
const OFFLINE_REWARDS = preload("res://scripts/offline_rewards.gd")
signal offline_rewards_received(gold: int, seconds: int)
var last_offline_gold: int = 0
var last_offline_seconds: int = 0
const SAVE_PATH: String = "user://save_data.json"
var timer: Timer
func _ready() -> void:
 load_game()
 timer = Timer.new()
 timer.wait_time = 30.0
 timer.autostart = true
 timer.timeout.connect(save_game)
 add_child(timer)
func save_game() -> void:
 var data: Dictionary = {
  "version": 1, "astral_floor": 1, "astral_marks": 0, "gold": GameManager.current_gold,
  "last_active_unix": int(Time.get_unix_time_from_system()),
  "tickets": GameManager.reincarnation_tickets,
  "gems": ShopManager.gems, "unlocked_skins": ShopManager.unlocked_skins.duplicate(), "equipped_skins": ShopManager.equipped_skins.duplicate(),
  "reincarnation": GameManager.current_reincarnation_level,
  "character_level": GameManager.character_level,
  "jewel_level": GameManager.jewel_level,
  "weapon_levels": GameManager.weapon_levels.duplicate(),
  "weapon_rarities": GameManager.weapon_rarities.duplicate(),
  "equipment_inventory": GameManager.equipment_inventory.duplicate(true),
  "equipped_loot": GameManager.equipped_loot.duplicate(true),
  "next_loot_id": GameManager.next_loot_id,
  "hardening_levels": GameManager.hardening_levels.duplicate(true),
  "hardening_attributes": GameManager.hardening_attributes.duplicate(true),
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
 var result: Error = SAVE_FILE_STORE.save_atomic(SAVE_PATH, data)
 if result != OK:
  push_warning("Automatic save failed (code " + str(result) + ")")
func load_game() -> void:
 var data: Dictionary = SAVE_FILE_STORE.load_latest(SAVE_PATH)
 if data.is_empty():
  return
 data = _claim_offline_rewards(data)
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
 var rarity_data: Variant = data.get("weapon_rarities", [])
 GameManager.weapon_rarities = [0, 0, 0, 0]
 if rarity_data is Array:
  for slot in range(mini(4, rarity_data.size())):
   var rarity: int = clampi(int(rarity_data[slot]), 0, GameManager.WEAPON_RARITIES.size() - 1)
   while rarity > 0 and GameManager.weapon_levels[slot] < int(GameManager.WEAPON_RARITY_LEVELS[rarity]):
    rarity -= 1
   GameManager.weapon_rarities[slot] = rarity
 # Validate old and modified saves. Unknown or duplicate IDs cannot be equipped.
 GameManager.equipment_inventory = []
 GameManager.equipped_loot = [[-1,-1,-1],[-1,-1,-1],[-1,-1,-1],[-1,-1,-1]]
 var known_ids: Dictionary = {}
 var inventory_data: Variant = data.get("equipment_inventory", [])
 var highest_id: int = 0
 if inventory_data is Array:
  for value in inventory_data:
   if not value is Dictionary or GameManager.equipment_inventory.size() >= GameManager.MAX_LOOT_ITEMS:
    continue
   var item_id: int = int(value.get("id", -1))
   var item_slot: int = int(value.get("slot", -1))
   if item_id <= 0 or known_ids.has(item_id) or item_slot < 0 or item_slot >= 3:
    continue
   known_ids[item_id] = true
   highest_id = maxi(highest_id, item_id)
   GameManager.equipment_inventory.append({"id":item_id, "slot":item_slot, "rarity":clampi(int(value.get("rarity", 0)), 0, 5), "level":clampi(int(value.get("level", 1)), 1, 1200)})
 GameManager.next_loot_id = maxi(highest_id + 1, 1)
 var equipment_data: Variant = data.get("equipped_loot", [])
 var worn: Dictionary = {}
 if equipment_data is Array:
  for hero in range(mini(4, equipment_data.size())):
   if not equipment_data[hero] is Array:
    continue
   for slot in range(mini(3, equipment_data[hero].size())):
    var item_id: int = int(equipment_data[hero][slot])
    if not known_ids.has(item_id) or worn.has(item_id):
     continue
    var found: Dictionary = GameManager.loot_item_by_id(item_id)
    if int(found.get("slot", -1)) != slot:
     continue
    GameManager.equipped_loot[hero][slot] = item_id
    worn[item_id] = true
 var saved_hardening: Variant = data.get("hardening_levels", [])
 GameManager.hardening_levels = [[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]]
 if saved_hardening is Array:
  for hero in range(mini(4, saved_hardening.size())):
   if saved_hardening[hero] is Array:
    for field in range(mini(4, saved_hardening[hero].size())):
     GameManager.hardening_levels[hero][field] = clampi(int(saved_hardening[hero][field]), 0, GameManager.character_level)
 var saved_attributes: Variant = data.get("hardening_attributes", [])
 GameManager.hardening_attributes = [[0,1,2,3],[0,1,2,3],[0,1,2,3],[0,1,2,3]]
 if saved_attributes is Array:
  for hero in range(mini(4, saved_attributes.size())):
   if saved_attributes[hero] is Array:
    for field in range(mini(4, saved_attributes[hero].size())):
     GameManager.hardening_attributes[hero][field] = clampi(int(saved_attributes[hero][field]), 0, GameManager.HARDENING_NAMES.size() - 1)
 AdManager.ads_watched_today = clampi(int(data.get("ads_watched", 0)), 0, 3)
 AdManager.last_watch_date = str(data.get("ad_date", ""))
 AdManager.check_daily_reset()
 GameManager.gold_changed.emit(GameManager.current_gold)
 GameManager.tickets_changed.emit(GameManager.reincarnation_tickets)
 GameManager.reincarnation_performed.emit(GameManager.current_reincarnation_level)
func get_saved_battle_progress() -> Vector2i:
 var data: Dictionary = SAVE_FILE_STORE.load_latest(SAVE_PATH)
 if not data.is_empty():
  return Vector2i(maxi(1, int(data.get("stage", 1))), clampi(int(data.get("wave", 1)), 1, 10))
 return Vector2i(1, 1)
func _notification(what: int) -> void:
 if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
  save_game()
  if what == NOTIFICATION_APPLICATION_PAUSED and timer != null:
   timer.stop()
 elif what == NOTIFICATION_APPLICATION_RESUMED:
  _claim_offline_on_resume()
  if timer != null:
   timer.start()

func _claim_offline_rewards(data: Dictionary) -> Dictionary:
 var now_unix: int = int(Time.get_unix_time_from_system())
 var claim: Dictionary = OFFLINE_REWARDS.make_claim(data, now_unix)
 var earned: Dictionary = claim.get("reward", {})
 var gold: int = int(earned.get("gold", 0))
 if gold <= 0:
  return data
 var updated: Dictionary = claim.get("save", {})
 var error: Error = SAVE_FILE_STORE.save_atomic(SAVE_PATH, updated)
 if error != OK:
  push_warning("Offline reward could not be saved safely: " + str(error))
  return data
 last_offline_gold = gold
 last_offline_seconds = int(earned.get("seconds", 0))
 offline_rewards_received.emit(last_offline_gold, last_offline_seconds)
 return updated

func _claim_offline_on_resume() -> void:
 var saved: Dictionary = SAVE_FILE_STORE.load_latest(SAVE_PATH)
 if saved.is_empty():
  return
 var applied: Dictionary = _claim_offline_rewards(saved)
 var earned: int = int(applied.get("gold", 0)) - int(saved.get("gold", 0))
 if earned > 0:
  # Wiederaufnahme ohne komplettes Neuladen von Skills, Formation oder Kampfstufe.
  GameManager.current_gold = maxi(GameManager.current_gold, int(applied.get("gold", 0)))
  GameManager.gold_changed.emit(GameManager.current_gold)

func get_saved_skill_choices() -> Array[int]:
 var choices: Array[int] = [0, 0, 0, 0]
 var data: Dictionary = SAVE_FILE_STORE.load_latest(SAVE_PATH)
 if not data.is_empty():
  var saved: Variant = data.get("skill_choices", [])
  if saved is Array:
   for i in range(mini(4, saved.size())):
    choices[i] = clampi(int(saved[i]), 0, 1)
 return choices
func get_saved_talents() -> Array:
 var result: Array = [[0,0,0], [0,0,0], [0,0,0], [0,0,0]]
 var data: Dictionary = SAVE_FILE_STORE.load_latest(SAVE_PATH)
 var saved: Variant = data.get("talents", [])
 if not saved is Array or saved.size() != 4:
  return result
 for slot in range(4):
  if saved[slot] is Array and saved[slot].size() == 3:
   for tree in range(3):
    result[slot][tree] = clampi(int(saved[slot][tree]), 0, TitanTalentSystem.MAX_RANK)
 return result
func get_saved_talent_branches() -> Array:
 var result: Array = [[-1,-1,-1],[-1,-1,-1],[-1,-1,-1],[-1,-1,-1]]
 var data: Dictionary = SAVE_FILE_STORE.load_latest(SAVE_PATH)
 var saved: Variant = data.get("talent_branches", [])
 if not saved is Array or saved.size() != 4:
  return result
 for slot in range(4):
  if saved[slot] is Array and saved[slot].size() == 3:
   for tree in range(3):
    result[slot][tree] = clampi(int(saved[slot][tree]), -1, 1)
 return result
func get_saved_skill_loadouts() -> Array:
 var result: Array = [[0,1,2,7],[0,1,2,7],[0,1,2,7],[0,1,2,7]]
 var data: Dictionary = SAVE_FILE_STORE.load_latest(SAVE_PATH)
 var saved: Variant = data.get("skill_loadouts", [])
 if saved is Array and saved.size() == 4:
  for hero in range(4):
   if saved[hero] is Array and saved[hero].size() == 4:
    for skill_slot in range(4):
     result[hero][skill_slot] = clampi(int(saved[hero][skill_slot]), 0, 10)
 return result
func get_saved_astral() -> Dictionary:
 var data: Dictionary = SAVE_FILE_STORE.load_latest(SAVE_PATH)
 if not data.is_empty():
  return {"floor": maxi(1, int(data.get("astral_floor", 1))), "marks": maxi(0, int(data.get("astral_marks", 0)))}
 return {"floor": 1, "marks": 0}
