extends RefCounted
class_name ChatModerationPolicy

# Policy proposal only. The authoritative server stores warnings, evidence,
# account-wide bans, approvals and audit history. Never trust client counts.
const FREE_WARNINGS := 3
const BAN_HOURS := [2, 5, 24, 168]

static func proposed_duration_hours(prior_approved_bans: int) -> int:
	return BAN_HOURS[clampi(prior_approved_bans, 0, BAN_HOURS.size() - 1)]

static func decision_for_violation(confirmed_violations: int, prior_approved_bans: int, evidence_id: String, account_id: String) -> Dictionary:
	if confirmed_violations <= 0 or account_id.is_empty():
		return {}
	if confirmed_violations <= FREE_WARNINGS:
		return {
			"status": "system_warning",
			"warning_number": confirmed_violations,
			"warnings_total": FREE_WARNINGS,
			"enforce_ban": false
		}
	if evidence_id.is_empty():
		return {}
	return {
		"account_id": account_id,
		"evidence_id": evidence_id,
		"proposed_hours": proposed_duration_hours(prior_approved_bans),
		"status": "pending_owner_approval",
		"enforce_ban": false
	}

static func may_enforce(_case_data: Dictionary) -> bool:
	# Only a trusted server-side owner-approval transaction may enforce a ban.
	return false
