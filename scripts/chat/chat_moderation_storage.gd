extends RefCounted
class_name ChatModerationStorage

# Dedicated-server local storage. Protect user:// directory at the host level.
# For multi-server deployments replace this with transactional database storage.
const SAVE_PATH := "user://moderation_state.json"
const TEMP_PATH := "user://moderation_state.tmp"
const MAX_FILE_BYTES := 10 * 1024 * 1024

static func save_state(service: ChatModerationServer) -> bool:
	var payload := {
		"schema_version": 1,
		"accounts": service.accounts,
		"cases": service.cases,
		"audit_log": service.audit_log,
		"next_case_id": service.next_case_id
	}
	var serialized := JSON.stringify(payload)
	if serialized.to_utf8_buffer().size() > MAX_FILE_BYTES:
		push_error("Moderation state exceeds storage limit")
		return false
	var file := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(serialized)
	file.flush()
	file.close()
	var absolute_temp := ProjectSettings.globalize_path(TEMP_PATH)
	var absolute_save := ProjectSettings.globalize_path(SAVE_PATH)
	var err := DirAccess.rename_absolute(absolute_temp, absolute_save)
	if err != OK:
		push_error("Moderation state rename failed: %s" % err)
		return false
	return true

static func load_state(service: ChatModerationServer) -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null or file.get_length() > MAX_FILE_BYTES:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary) or parsed.get("schema_version") != 1:
		return false
	if not (parsed.get("accounts") is Dictionary and parsed.get("cases") is Dictionary and parsed.get("audit_log") is Array):
		return false
	service.accounts = parsed["accounts"].duplicate(true)
	service.cases = parsed["cases"].duplicate(true)
	service.audit_log.clear()
	for entry in parsed["audit_log"]:
		if entry is Dictionary:
			service.audit_log.append(entry.duplicate(true))
	service.next_case_id = maxi(1, int(parsed.get("next_case_id", 1)))
	return true
