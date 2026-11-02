extends RefCounted
class_name ChatModerationPolicy

# Server-side approval, authentication, evidence and audit storage are required.
const FREE_WARNINGS := 3
const BAN_HOURS := [2, 5, 24, 168]
const MAX_CUSTOM_HOURS := 24 * 365

static func proposed_duration_hours(prior_approved_bans: int) -> int:
	return BAN_HOURS[clampi(prior_approved_bans, 0, BAN_HOURS.size() - 1)]

static func decision_for_violation(confirmed_violations: int, prior_approved_bans: int, evidence_id: String, account_id: String) -> Dictionary:
	if confirmed_violations <= 0 or account_id.is_empty():
		return {}
	if confirmed_violations <= FREE_WARNINGS:
		return {"status": "system_warning", "warning_number": confirmed_violations, "warnings_total": FREE_WARNINGS, "enforce_ban": false}
	if evidence_id.is_empty():
		return {}
	return {"account_id": account_id, "evidence_id": evidence_id, "proposed_hours": proposed_duration_hours(prior_approved_bans), "status": "pending_owner_approval", "enforce_ban": false}

static func validate_owner_choice(hours: int, reason: String) -> bool:
	return hours >= 1 and hours <= MAX_CUSTOM_HOURS and not reason.strip_edges().is_empty()

static func owner_decision_preview(case_data: Dictionary, action: String, hours: int, reason: String) -> Dictionary:
	# A preview, NOT an authorization or actual account suspension.
	if case_data.get("status", "") != "pending_owner_approval":
		return {}
	if action == "reject":
		return {"action": "reject", "reason": reason, "enforce_ban": false} if not reason.strip_edges().is_empty() else {}
	if action == "approve" and validate_owner_choice(hours, reason):
		return {"action": "approve", "chosen_hours": hours, "reason": reason, "requires_server_owner_auth": true, "enforce_ban": false}
	return {}

static func may_enforce(_case_data: Dictionary) -> bool:
	return false
