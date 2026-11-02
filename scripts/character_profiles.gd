extends RefCounted
## Five independent character identities per local player account.
## This is the profile layer; combat and save-slot switching are integrated separately.
const MAX_CHARACTERS: int = 5
const PROFILE_PATH: String = "user://character_profiles.json"
const ROLE_NAMES := ["Tank", "DD", "Heiler"]
const CLASS_NAMES := ["Krieger", "Paladin", "Druide", "Schamane", "Jaeger", "Schurke", "Magier", "Hexer", "Beschwoerer", "Priester", "Raufbold"]
const ALLOWED_ROLES := [[0,1], [0,1,2], [0,1,2], [0,1,2], [1], [1], [1], [1], [1], [1,2], [1]]

static func new_registry() -> Dictionary:
 return {"version": 1, "active_slot": -1, "characters": [null, null, null, null, null]}

static func create_character(registry: Dictionary, slot: int, character_name: String, class_id: int, role_id: int) -> bool:
 if slot < 0 or slot >= MAX_CHARACTERS:
  return false
 var characters: Array = registry.get("characters", [])
 if characters.size() != MAX_CHARACTERS or characters[slot] != null:
  return false
 if class_id < 0 or class_id >= CLASS_NAMES.size() or role_id not in ALLOWED_ROLES[class_id]:
  return false
 var safe_name := character_name.strip_edges()
 if safe_name.is_empty() or safe_name.length() > 24:
  return false
 characters[slot] = {
  "name": safe_name, "class_id": class_id, "role_id": role_id,
  "level": 1, "xp": 0, "reincarnation": 0,
  "created_unix": int(Time.get_unix_time_from_system()),
  "save_path": "user://character_%d.json" % slot
 }
 registry["characters"] = characters
 if int(registry.get("active_slot", -1)) == -1:
  registry["active_slot"] = slot
 return true

static func select_character(registry: Dictionary, slot: int) -> bool:
 var characters: Array = registry.get("characters", [])
 if slot < 0 or slot >= MAX_CHARACTERS or characters.size() != MAX_CHARACTERS:
  return false
 if not characters[slot] is Dictionary:
  return false
 registry["active_slot"] = slot
 return true

static func save_registry(registry: Dictionary) -> Error:
 var characters: Array = registry.get("characters", [])
 if characters.size() != MAX_CHARACTERS:
  return ERR_INVALID_DATA
 var file := FileAccess.open(PROFILE_PATH + ".tmp", FileAccess.WRITE)
 if file == null:
  return FileAccess.get_open_error()
 file.store_string(JSON.stringify(registry))
 file.flush()
 file.close()
 var absolute_temp := ProjectSettings.globalize_path(PROFILE_PATH + ".tmp")
 var absolute_target := ProjectSettings.globalize_path(PROFILE_PATH)
 return DirAccess.rename_absolute(absolute_temp, absolute_target)

static func load_registry() -> Dictionary:
 if not FileAccess.file_exists(PROFILE_PATH):
  return new_registry()
 var file := FileAccess.open(PROFILE_PATH, FileAccess.READ)
 if file == null:
  return new_registry()
 var parsed: Variant = JSON.parse_string(file.get_as_text())
 if not parsed is Dictionary:
  return new_registry()
 var characters: Variant = parsed.get("characters", [])
 if not characters is Array or characters.size() != MAX_CHARACTERS:
  return new_registry()
 for character in characters:
  if character != null and not character is Dictionary:
   return new_registry()
 var active: int = int(parsed.get("active_slot", -1))
 if active < -1 or active >= MAX_CHARACTERS or (active >= 0 and not characters[active] is Dictionary):
  return new_registry()
 return parsed
