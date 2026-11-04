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

static func _read_registry(path: String) -> Dictionary:
 if not FileAccess.file_exists(path):
  return {}
 var file := FileAccess.open(path, FileAccess.READ)
 if file == null or file.get_length() > 262144:
  return {}
 var parsed: Variant = JSON.parse_string(file.get_as_text())
 file.close()
 if not parsed is Dictionary:
  return {}
 var characters: Variant = parsed.get("characters", [])
 if not characters is Array or characters.size() != MAX_CHARACTERS:
  return {}
 for character in characters:
  if character != null and not character is Dictionary:
   return {}
 var active: int = int(parsed.get("active_slot", -1))
 if active < -1 or active >= MAX_CHARACTERS or (active >= 0 and not characters[active] is Dictionary):
  return {}
 return parsed

static func save_registry(registry: Dictionary) -> Error:
 if registry.get("characters", []).size() != MAX_CHARACTERS:
  return ERR_INVALID_DATA
 var temporary: String = PROFILE_PATH + ".tmp"
 var file := FileAccess.open(temporary, FileAccess.WRITE)
 if file == null:
  return FileAccess.get_open_error()
 file.store_string(JSON.stringify(registry))
 file.flush()
 file.close()
 if _read_registry(temporary).is_empty():
  return ERR_FILE_CORRUPT
 var existing: Dictionary = _read_registry(PROFILE_PATH)
 if not existing.is_empty():
  var backup_temp: String = PROFILE_PATH + ".bak.tmp"
  var copy_error: Error = DirAccess.copy_absolute(ProjectSettings.globalize_path(PROFILE_PATH), ProjectSettings.globalize_path(backup_temp))
  if copy_error != OK:
   return copy_error
  if _read_registry(backup_temp).is_empty():
   return ERR_FILE_CORRUPT
  var rotate_error: Error = DirAccess.rename_absolute(ProjectSettings.globalize_path(backup_temp), ProjectSettings.globalize_path(PROFILE_PATH + ".bak"))
  if rotate_error != OK:
   return rotate_error
 return DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary), ProjectSettings.globalize_path(PROFILE_PATH))

static func load_registry() -> Dictionary:
 var current: Dictionary = _read_registry(PROFILE_PATH)
 if not current.is_empty():
  return current
 var backup: Dictionary = _read_registry(PROFILE_PATH + ".bak")
 if not backup.is_empty():
  push_warning("Character registry restored from backup.")
  return backup
 return new_registry()

## Explicit one-time migration: never overwrite an occupied profile.
## Legacy saves stay untouched until the new per-character save system is ready.
static func import_legacy_character(registry: Dictionary, legacy_save: Dictionary, class_id: int, role_id: int, character_name: String = "Bisheriger Held") -> bool:
 var characters: Array = registry.get("characters", [])
 if characters.size() != MAX_CHARACTERS or characters[0] != null:
  return false
 if not create_character(registry, 0, character_name, class_id, role_id):
  return false
 var profile: Dictionary = characters[0]
 profile["level"] = maxi(1, int(legacy_save.get("character_level", 1)))
 profile["xp"] = maxi(0, int(legacy_save.get("character_xp", 0)))
 profile["reincarnation"] = clampi(int(legacy_save.get("reincarnation", 0)), 0, 5)
 profile["legacy_import_pending"] = true
 characters[0] = profile
 registry["characters"] = characters
 return true

static func character_save_path(registry: Dictionary, slot: int) -> String:
 var characters: Array = registry.get("characters", [])
 if slot < 0 or slot >= MAX_CHARACTERS or characters.size() != MAX_CHARACTERS:
  return ""
 if not characters[slot] is Dictionary:
  return ""
 return "user://character_%d.json" % slot
