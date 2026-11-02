extends RefCounted
## Per-character save storage. Not yet wired to the live SaveManager.
## All slots have separate files and backups; legacy save_data.json is untouched.
const PROFILES = preload("res://scripts/character_profiles.gd")
const STORE = preload("res://scripts/save_file_store.gd")

static func initial_save(profile: Dictionary) -> Dictionary:
 return {
  "version": 2, "stage": 1, "wave": 1, "astral_floor": 1, "astral_marks": 0,
  "gold": 0, "tickets": 0, "gems": 0,
  "character_level": 1, "character_xp": 0, "reincarnation": 0,
  "character_name": str(profile.get("name", "")),
  "class_id": int(profile.get("class_id", -1)),
  "role_id": int(profile.get("role_id", -1)),
  "jewel_level": 1,
  "weapon_levels": [0,0,0,0], "weapon_rarities": [0,0,0,0],
  "equipment_inventory": [], "equipped_loot": [],
  "hardening_levels": [[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]],
  "hardening_attributes": [[0,1,2,3],[0,1,2,3],[0,1,2,3],[0,1,2,3]],
  "skill_choices": [0,0,0,0],
  "skill_loadouts": [[0,1,2,7],[0,1,2,7],[0,1,2,7],[0,1,2,7]],
  "talents": [[0,0,0],[0,0,0],[0,0,0],[0,0,0]],
  "talent_branches": [[-1,-1,-1],[-1,-1,-1],[-1,-1,-1],[-1,-1,-1]],
  "last_active_unix": int(Time.get_unix_time_from_system())
 }

static func load_slot(registry: Dictionary, slot: int) -> Dictionary:
 var path: String = PROFILES.character_save_path(registry, slot)
 if path.is_empty():
  return {}
 var data: Dictionary = STORE.load_latest(path)
 if data.is_empty():
  return {}
 var profile: Dictionary = registry["characters"][slot]
 if int(data.get("class_id", -1)) != int(profile.get("class_id", -2)) or int(data.get("role_id", -1)) != int(profile.get("role_id", -2)):
  push_warning("Character save identity does not match the selected profile.")
  return {}
 return data

static func create_slot_save(registry: Dictionary, slot: int) -> Error:
 var path: String = PROFILES.character_save_path(registry, slot)
 if path.is_empty():
  return ERR_INVALID_PARAMETER
 if FileAccess.file_exists(path) or FileAccess.file_exists(path + ".bak"):
  return ERR_ALREADY_EXISTS
 var profile: Dictionary = registry["characters"][slot]
 if bool(profile.get("legacy_import_pending", false)):
  return ERR_UNAVAILABLE
 return STORE.save_atomic(path, initial_save(profile))

static func save_slot(registry: Dictionary, slot: int, data: Dictionary) -> Error:
 var path: String = PROFILES.character_save_path(registry, slot)
 if path.is_empty():
  return ERR_INVALID_PARAMETER
 var profile: Dictionary = registry["characters"][slot]
 if int(data.get("class_id", -1)) != int(profile.get("class_id", -2)):
  return ERR_INVALID_DATA
 if int(data.get("role_id", -1)) != int(profile.get("role_id", -2)):
  return ERR_INVALID_DATA
 if int(data.get("character_level", 0)) < 1:
  return ERR_INVALID_DATA
 return STORE.save_atomic(path, data)

## Recover an interrupted character creation without deleting or overwriting
## an existing save. Only the exact original identity may reclaim the slot.
static func recover_pending_creation(registry: Dictionary, slot: int) -> bool:
 var path: String = PROFILES.character_save_path(registry, slot)
 if path.is_empty():
  return false
 var profile: Dictionary = registry["characters"][slot]
 var saved: Dictionary = STORE.load_latest(path)
 if saved.is_empty():
  return false
 if str(saved.get("character_name", "")) != str(profile.get("name", "")):
  return false
 if int(saved.get("class_id", -1)) != int(profile.get("class_id", -2)):
  return false
 if int(saved.get("role_id", -1)) != int(profile.get("role_id", -2)):
  return false
 return true
