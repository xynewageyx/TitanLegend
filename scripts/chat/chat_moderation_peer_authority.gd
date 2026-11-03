extends RefCounted
class_name ChatModerationPeerAuthority

# Use on the dedicated server only. Never expose bind_peer() through RPC.
# The login service must verify credentials before calling bind_peer().
var gateway: ChatModerationAdminGateway
var peer_accounts: Dictionary = {}

func _init(admin_gateway: ChatModerationAdminGateway) -> void:
	gateway = admin_gateway

func bind_authenticated_peer(peer_id: int, verified_account_id: String) -> bool:
	if peer_id <= 1 or verified_account_id.strip_edges().is_empty():
		return false
	# A bound connection must not silently switch account identities.
	# Disconnect and reauthenticate with a new session first.
	if peer_accounts.has(peer_id):
		return str(peer_accounts[peer_id]) == verified_account_id
	peer_accounts[peer_id] = verified_account_id
	return true

func disconnect_peer(peer_id: int) -> void:
	peer_accounts.erase(peer_id)

func _account_for_peer(peer_id: int) -> String:
	return str(peer_accounts.get(peer_id, ""))

func has_owner_access(peer_id: int) -> bool:
	if gateway == null or not peer_accounts.has(peer_id):
		return false
	return gateway._is_owner(_account_for_peer(peer_id))

func pending_cases_for_peer(peer_id: int) -> Array:
	if gateway == null:
		return []
	return gateway.list_pending(_account_for_peer(peer_id))

func evidence_for_peer(peer_id: int, case_id: String) -> String:
	if gateway == null:
		return ""
	return gateway.fetch_evidence(_account_for_peer(peer_id), case_id)

func decide_for_peer(peer_id: int, case_id: String, action: String, hours: int, reason: String, now_unix: int) -> Dictionary:
	if gateway == null or not peer_accounts.has(peer_id):
		return {"ok": false, "error": "not_authenticated"}
	return gateway.submit_decision(_account_for_peer(peer_id), case_id, action, hours, reason, now_unix)

func change_ban_for_peer(peer_id: int, account_id: String, action: String, hours: int, reason: String, now_unix: int) -> Dictionary:
	if gateway == null or not peer_accounts.has(peer_id):
		return {"ok": false, "error": "not_authenticated"}
	return gateway.edit_active_ban(_account_for_peer(peer_id), account_id, action, hours, reason, now_unix)
