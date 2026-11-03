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
	check(authority.can_admit_account("normal-account", 1800000000), "Unbanned account should be admissible")
	check(not authority.can_admit_account("", 1800000000), "Empty account must be rejected")
	check(not authority.can_admit_account("normal-account", 0), "Invalid time must be rejected")
	coordinator.service.accounts["banned-account"] = {"warnings": 4, "approved_bans": 1, "ban_until": 1800003600}
	check(not authority.can_admit_account("banned-account", 1800000000), "Active account ban must block admission")
	check(authority.can_admit_account("banned-account", 1800003600), "Expired account ban must allow admission")
	check(not authority.has_owner_access(42), "Unknown peer must have no owner access")
	check(authority.pending_cases_for_peer(42).is_empty(), "Unknown peer must see no cases")
	check(authority.evidence_for_peer(42, "MOD-000001").is_empty(), "Unknown peer must see no evidence")
	check(not authority.decide_for_peer(42, "MOD-000001", "approve", 2, "test", 1800000000).get("ok", false), "Unknown peer must not approve")
	check(not authority.bind_authenticated_peer(0, "owner-account"), "Peer zero must be rejected")
	check(not authority.bind_authenticated_peer(42, ""), "Empty account must be rejected")
	check(authority.bind_authenticated_peer(42, "normal-account"), "Verified normal account should bind")
	check(not authority.has_owner_access(42), "Normal account must have no owner access")
	check(not authority.decide_for_peer(42, "MOD-000001", "approve", 2, "test", 1800000000).get("ok", false), "Normal player must not approve")
	check(authority.evidence_for_peer(42, "MOD-000001").is_empty(), "Normal player must not read evidence")
	check(not authority.bind_authenticated_peer(42, "owner-account"), "Bound normal account must not elevate to owner")
	check(authority._account_for_peer(42) == "normal-account", "Rejected identity change must preserve original binding")
	check(authority.bind_authenticated_peer(43, "owner-account"), "Verified owner should bind")
	check(authority.has_owner_access(43), "Verified owner should have owner access")
	check(gateway._is_owner("owner-account"), "Owner should pass owner identity check")
	check(not gateway._is_owner("normal-account"), "Normal account must fail owner check")
	authority.disconnect_peer(43)
	check(not authority.has_owner_access(43), "Logout must revoke owner access")
	check(not authority.decide_for_peer(43, "MOD-000001", "approve", 2, "test", 1800000000).get("ok", false), "Disconnected owner must lose authorization")
	check(authority.pending_cases_for_peer(43).is_empty(), "Disconnected owner must see no cases")
	if failures == 0:
		print("Peer authority security tests passed")
