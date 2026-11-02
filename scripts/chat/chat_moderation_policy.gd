extends RefCounted
class_name ChatModerationPolicy

# Policy helper only: authoritative server must persist cases, audit logs,
# evidence snapshots, strike counts and admin approvals securely.
const BAN_HOURS := [2, 5, 24, 168]
const REPEATED_VIOLATIONS_THRESHOLD := 3

static func proposed_duration_hours(prior_approved_bans: int) -> int:
	return BAN_HOURS[clampi(prior_approved_bans, 0, BAN_HOURS.size() - 1)]

static func should_open_case(confirmed_violations: int) -> bool:
	return confirmed_violations >= REPEATED_VIOLATIONS_THRESHOLD

static func make_pending_case(account_id: String, confirmed_violations: int, prior_approved_bans: int, evidence_id: String) -> Dictionary:
	if account_id.is_empty() or evidence_id.is_empty() or not should_open_case(confirmed_violations):
		return {}
	return {
		"account_id": account_id,
		"evidence_id": evidence_id,
		"proposed_hours": proposed_duration_hours(prior_approved_bans),
		"status": "pending_owner_approval",
		"enforce_ban": false
	}

static func may_enforce(case_data: Dictionary) -> bool:
	# Never accept a client-side approval as authorization.
	# Server must verify the owner identity and signed administrative action.
	return false
