extends RefCounted
class_name ChatModerationBanManagement

# Server-only operations. Owner authorization must be established by trusted
# authentication middleware; never accept a client-provided boolean directly.
static func change_ban(coordinator: ChatModerationCoordinator, account_id: String, action: String, duration_hours: int, reason: String, owner_authorized: bool, now_unix: int) -> Dictionary:
	if not owner_authorized or not coordinator.loaded or account_id.is_empty() or reason.strip_edges().is_empty() or now_unix <= 0:
		return {"ok": false, "error": "unauthorized_or_invalid"}
	if not coordinator.service.accounts.has(account_id):
		return {"ok": false, "error": "unknown_account"}
	if action not in ["revoke", "replace_remaining"]:
		return {"ok": false, "error": "invalid_action"}
	if action == "replace_remaining" and (duration_hours < 1 or duration_hours > 8760):
		return {"ok": false, "error": "invalid_duration"}
	var candidate := coordinator._clone_service()
	var state: Dictionary = candidate.accounts[account_id]
	var old_until := int(state.get("ban_until", 0))
	if old_until <= now_unix:
		return {"ok": false, "error": "no_active_ban"}
	var new_until := now_unix + duration_hours * 3600 if action == "replace_remaining" else now_unix
	state["ban_until"] = new_until
	candidate.accounts[account_id] = state
	candidate.audit_log.append({
		"action": "ban_" + action,
		"account_id": account_id,
		"previous_until": old_until,
		"new_until": new_until,
		"reason": reason,
		"at": now_unix
	})
	if not ChatModerationStorage.save_state(candidate):
		return {"ok": false, "error": "storage_failed"}
	coordinator.service = candidate
	return {"ok": true, "ban_until": new_until, "action": action}
