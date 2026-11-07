extends RefCounted
class_name ChatModerationAdminGateway

# Dedicated-server boundary. The network/session layer must authenticate the
# connection and resolve the immutable account ID; do not accept IDs or owner
# flags supplied by clients. Configure OWNER_ACCOUNT_ID on the server only.
var coordinator: ChatModerationCoordinator
var owner_account_id: String

func _init(moderation: ChatModerationCoordinator, configured_owner_account_id: String) -> void:
	coordinator = moderation
	owner_account_id = configured_owner_account_id

func _is_owner(authenticated_account_id: String) -> bool:
	return not owner_account_id.is_empty() and authenticated_account_id == owner_account_id and coordinator != null and coordinator.loaded

func list_pending(authenticated_account_id: String) -> Array:
	var result: Array = []
	if not _is_owner(authenticated_account_id):
		return result
	for moderation_case in coordinator.service.cases.values():
		if moderation_case is Dictionary and moderation_case.get("status") == "pending":
			result.append({
				"case_id": moderation_case.get("case_id", ""),
				"account_id": moderation_case.get("account_id", ""),
				"proposed_hours": moderation_case.get("proposed_hours", 0),
				"created_at": moderation_case.get("created_at", 0),
				"status": "pending_owner_approval"
			})
	return result

func fetch_evidence(authenticated_account_id: String, case_id: String) -> String:
	if not _is_owner(authenticated_account_id):
		return ""
	return coordinator.export_evidence_json(case_id, true)

func submit_decision(authenticated_account_id: String, case_id: String, action: String, hours: int, reason: String, now_unix: int) -> Dictionary:
	if not _is_owner(authenticated_account_id):
		return {"ok": false, "error": "unauthorized"}
	return coordinator.owner_review(case_id, action, hours, reason, true, now_unix)

func edit_active_ban(authenticated_account_id: String, account_id: String, action: String, hours: int, reason: String, now_unix: int) -> Dictionary:
	if not _is_owner(authenticated_account_id):
		return {"ok": false, "error": "unauthorized"}
	return ChatModerationBanManagement.change_ban(coordinator, account_id, action, hours, reason, true, now_unix)
