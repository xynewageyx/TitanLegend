extends Node
class_name ChatModerationRpcServer

# Add this node at the same path on client and dedicated server.
# Server must inject authority after authenticated login; never expose peer binding as RPC.
# ENetMultiplayerPeer server ID is 1. Requests are only accepted by the server.
var authority: ChatModerationPeerAuthority

func _ready() -> void:
	if multiplayer.is_server():
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)

# Trusted server-side login callback only. The login service must validate
# the player's session token before calling this method; never expose as RPC.
func on_verified_login(peer_id: int, verified_account_id: String) -> bool:
	if not multiplayer.is_server() or authority == null:
		return false
	if peer_id <= 1 or not multiplayer.get_peers().has(peer_id):
		return false
	return authority.bind_authenticated_peer(peer_id, verified_account_id)

# Called by the trusted session manager on logout or token revocation.
# Removes access immediately without waiting for the network disconnect.
func on_verified_logout(peer_id: int) -> void:
	if not multiplayer.is_server() or authority == null:
		return
	authority.disconnect_peer(peer_id)
	if multiplayer.get_peers().has(peer_id):
		receive_admin_access.rpc_id(peer_id, false)

func configure_server_authority(server_authority: ChatModerationPeerAuthority) -> void:
	if not multiplayer.is_server():
		push_error("Only the multiplayer server can configure moderation authority")
		return
	authority = server_authority

func _on_peer_disconnected(peer_id: int) -> void:
	if authority != null:
		authority.disconnect_peer(peer_id)

# Server returns only a boolean; never trust client-side visibility as permission.
signal admin_access_received(allowed: bool)

@rpc("any_peer", "call_remote", "reliable")
func request_admin_access() -> void:
	if not multiplayer.is_server():
		return
	var sender := multiplayer.get_remote_sender_id()
	if sender <= 0:
		return
	var allowed := false
	if authority != null and authority.gateway != null:
		allowed = authority.gateway._is_owner(authority._account_for_peer(sender))
	receive_admin_access.rpc_id(sender, allowed)

@rpc("authority", "call_remote", "reliable")
func receive_admin_access(allowed: bool) -> void:
	if not multiplayer.is_server():
		admin_access_received.emit(allowed)

@rpc("any_peer", "call_remote", "reliable")
func request_pending_cases() -> void:
	if not multiplayer.is_server():
		return
	var sender := multiplayer.get_remote_sender_id()
	if sender <= 0:
		return
	var data: Array = []
	if authority != null:
		data = authority.pending_cases_for_peer(sender)
	receive_pending_cases.rpc_id(sender, data)

@rpc("any_peer", "call_remote", "reliable")
func request_case_evidence(case_id: String) -> void:
	if not multiplayer.is_server():
		return
	var sender := multiplayer.get_remote_sender_id()
	if sender <= 0 or case_id.length() > 64:
		return
	var evidence := ""
	if authority != null:
		evidence = authority.evidence_for_peer(sender, case_id)
	receive_case_evidence.rpc_id(sender, case_id, evidence)

@rpc("any_peer", "call_remote", "reliable")
func request_case_decision(case_id: String, action: String, hours: int, reason: String) -> void:
	if not multiplayer.is_server():
		return
	var sender := multiplayer.get_remote_sender_id()
	if sender <= 0 or case_id.length() > 64 or reason.length() > 512 or action not in ["approve", "reject"]:
		return
	var result := {"ok": false, "error": "not_configured"}
	if authority != null:
		result = authority.decide_for_peer(sender, case_id, action, hours, reason, int(Time.get_unix_time_from_system()))
	receive_case_decision.rpc_id(sender, case_id, result)

# Client-only replies: never accept an RPC from another player.
signal pending_cases_received(cases: Array)
signal case_evidence_received(case_id: String, evidence_json: String)
signal case_decision_received(case_id: String, result: Dictionary)

@rpc("authority", "call_remote", "reliable")
func receive_pending_cases(cases: Array) -> void:
	if not multiplayer.is_server():
		pending_cases_received.emit(cases)

@rpc("authority", "call_remote", "reliable")
func receive_case_evidence(case_id: String, evidence_json: String) -> void:
	if not multiplayer.is_server():
		case_evidence_received.emit(case_id, evidence_json)

@rpc("authority", "call_remote", "reliable")
func receive_case_decision(case_id: String, result: Dictionary) -> void:
	if not multiplayer.is_server():
		case_decision_received.emit(case_id, result)
