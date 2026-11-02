extends SceneTree

var failures := 0

func _initialize() -> void:
	_run()
	quit(1 if failures > 0 else 0)

func check(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)

func _run() -> void:
	var coordinator := ChatModerationCoordinator.new()
	# In-memory fixture: avoid modifying production moderation persistence.
	coordinator.loaded = true
	var gateway := ChatModerationAdminGateway.new(coordinator, "owner-account")
	var authority := ChatModerationPeerAuthority.new(gateway)
	check(authority.pending_cases_for_peer(42).is_empty(), "Unknown peer must see no cases")
	check(authority.evidence_for_peer(42, "MOD-000001").is_empty(), "Unknown peer must see no evidence")
	check(not authority.decide_for_peer(42, "MOD-000001", "approve", 2, "test", 1800000000).get("ok", false), "Unknown peer must not approve")
	check(not authority.bind_authenticated_peer(0, "owner-account"), "Peer zero must be rejected")
	check(not authority.bind_authenticated_peer(42, ""), "Empty account must be rejected")
	check(authority.bind_authenticated_peer(42, "normal-account"), "Verified normal account should bind")
	check(not authority.decide_for_peer(42, "MOD-000001", "approve", 2, "test", 1800000000).get("ok", false), "Normal player must not approve")
	check(authority.evidence_for_peer(42, "MOD-000001").is_empty(), "Normal player must not read evidence")
	check(authority.bind_authenticated_peer(43, "owner-account"), "Verified owner should bind")
	check(gateway._is_owner("owner-account"), "Owner should pass owner identity check")
	check(not gateway._is_owner("normal-account"), "Normal account must fail owner check")
	authority.disconnect_peer(43)
	check(not authority.decide_for_peer(43, "MOD-000001", "approve", 2, "test", 1800000000).get("ok", false), "Disconnected owner must lose authorization")
	check(authority.pending_cases_for_peer(43).is_empty(), "Disconnected owner must see no cases")
	if failures == 0:
		print("Peer authority security tests passed")
