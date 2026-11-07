extends RefCounted
class_name ChatModerationServer

# In-memory reference service. Production requires durable database, server-side
# authenticated owner identity, encrypted evidence storage, and audit persistence.
const WARNING_LIMIT := 3
const BAN_HOURS := [2, 5, 24, 168]
const MAX_EVIDENCE_MESSAGES := 50
var accounts: Dictionary = {}
var cases: Dictionary = {}
var audit_log: Array[Dictionary] = []
var next_case_id := 1

func register_violation(account_id: String, evidence_messages: Array, now_unix: int) -> Dictionary:
	if account_id.is_empty() or now_unix <= 0:
		return {}
	var state: Dictionary = accounts.get(account_id, {"warnings": 0, "approved_bans": 0, "ban_until": 0})
	state["warnings"] = int(state["warnings"]) + 1
	accounts[account_id] = state
	var count := int(state["warnings"])
	if count <= WARNING_LIMIT:
		return {"status": "warning", "warning_number": count, "remaining": WARNING_LIMIT - count}
	# Only one pending case per account; further reports can be reviewed separately.
	for existing in cases.values():
		if existing.get("account_id") == account_id and existing.get("status") == "pending":
			return {"status": "already_pending", "case_id": existing.get("case_id")}
	var case_id := "MOD-%06d" % next_case_id
	next_case_id += 1
	var safe_evidence: Array = []
	for item in evidence_messages.slice(0, MAX_EVIDENCE_MESSAGES):
		if item is Dictionary:
			safe_evidence.append(item.duplicate(true))
	var duration: int = BAN_HOURS[mini(int(state["approved_bans"]), BAN_HOURS.size() - 1)]
	cases[case_id] = {
		"case_id": case_id, "account_id": account_id,
		"status": "pending", "proposed_hours": duration,
		"evidence": safe_evidence, "created_at": now_unix
	}
	audit_log.append({"action": "case_created", "case_id": case_id, "at": now_unix})
	return {"status": "pending_owner_approval", "case_id": case_id, "proposed_hours": duration}

func review_case(case_id: String, action: String, chosen_hours: int, reason: String, authenticated_owner: bool, now_unix: int) -> Dictionary:
	# authenticated_owner must come from trusted server auth, never client payload.
	if not authenticated_owner or not cases.has(case_id) or reason.strip_edges().is_empty() or now_unix <= 0:
		return {"ok": false, "error": "unauthorized_or_invalid"}
	var moderation_case: Dictionary = cases[case_id]
	if moderation_case["status"] != "pending":
		return {"ok": false, "error": "case_not_pending"}
	if action != "reject" and action != "approve":
		return {"ok": false, "error": "invalid_action"}
	if action == "approve" and (chosen_hours < 1 or chosen_hours > 8760):
		return {"ok": false, "error": "invalid_duration"}
	var account_id: String = moderation_case["account_id"]
	if action == "approve":
		var state: Dictionary = accounts[account_id]
		state["ban_until"] = maxi(int(state.get("ban_until", 0)), now_unix) + chosen_hours * 3600
		state["approved_bans"] = int(state["approved_bans"]) + 1
		accounts[account_id] = state
		moderation_case["status"] = "approved"
		moderation_case["chosen_hours"] = chosen_hours
	else:
		moderation_case["status"] = "rejected"
	moderation_case["reviewed_at"] = now_unix
	moderation_case["reason"] = reason
	cases[case_id] = moderation_case
	audit_log.append({"action": action, "case_id": case_id, "reason": reason, "hours": chosen_hours if action == "approve" else 0, "at": now_unix})
	return {"ok": true, "status": moderation_case["status"]}

func is_account_banned(account_id: String, now_unix: int) -> bool:
	return int(accounts.get(account_id, {}).get("ban_until", 0)) > now_unix

func owner_evidence(case_id: String, authenticated_owner: bool) -> Dictionary:
	if not authenticated_owner or not cases.has(case_id):
		return {}
	var moderation_case: Dictionary = cases[case_id]
	return {"case_id": case_id, "account_id": moderation_case["account_id"], "messages": moderation_case["evidence"].duplicate(true)}
