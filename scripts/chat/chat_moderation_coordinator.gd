extends RefCounted
class_name ChatModerationCoordinator

# Instantiate ONLY on a dedicated authoritative server.
# Caller must authenticate account IDs and moderator privileges server-side.
var service := ChatModerationServer.new()
var loaded := false

func initialize() -> bool:
	loaded = ChatModerationStorage.load_state(service)
	# Missing save is valid for a fresh installation; malformed saves must not
	# silently overwrite existing evidence.
	if not loaded and FileAccess.file_exists(ChatModerationStorage.SAVE_PATH):
		push_error("Moderation storage invalid; refusing to start")
		return false
	loaded = true
	return true

func report_confirmed_violation(account_id: String, evidence: Array, now_unix: int) -> Dictionary:
	if not loaded:
		return {"ok": false, "error": "not_initialized"}
	# Work on a copy; never claim persistence if the write fails.
	var candidate := _clone_service()
	var result := candidate.register_violation(account_id, evidence, now_unix)
	if result.is_empty() or not ChatModerationStorage.save_state(candidate):
		return {"ok": false, "error": "storage_failed_or_invalid"}
	service = candidate
	return result

func owner_review(case_id: String, action: String, hours: int, reason: String, authenticated_owner: bool, now_unix: int) -> Dictionary:
	if not loaded or not authenticated_owner:
		return {"ok": false, "error": "unauthorized"}
	var candidate := _clone_service()
	var result := candidate.review_case(case_id, action, hours, reason, authenticated_owner, now_unix)
	if not result.get("ok", false):
		return result
	if not ChatModerationStorage.save_state(candidate):
		return {"ok": false, "error": "storage_failed"}
	service = candidate
	return result

func export_evidence_json(case_id: String, authenticated_owner: bool) -> String:
	if not loaded or not authenticated_owner:
		return ""
	var evidence := service.owner_evidence(case_id, authenticated_owner)
	if evidence.is_empty():
		return ""
	return JSON.stringify(evidence, "  ")

func is_banned(account_id: String, now_unix: int) -> bool:
	return loaded and service.is_account_banned(account_id, now_unix)

func _clone_service() -> ChatModerationServer:
	var copy := ChatModerationServer.new()
	copy.accounts = service.accounts.duplicate(true)
	copy.cases = service.cases.duplicate(true)
	copy.audit_log = service.audit_log.duplicate(true)
	copy.next_case_id = service.next_case_id
	return copy
