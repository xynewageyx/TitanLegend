extends SceneTree

var failures := 0

func _initialize() -> void:
	_run_tests()
	if failures > 0:
		push_error("%d chat moderation test(s) failed" % failures)
		quit(1)
	else:
		print("Chat moderation tests passed")
		quit(0)

func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func _run_tests() -> void:
	var service := ChatModerationServer.new()
	var now := 1800000000
	for index in range(1, 4):
		var result := service.register_violation("account-a", [{"text": "example"}], now)
		_assert_true(result.get("status") == "warning", "Warning %d should not create a ban" % index)
		_assert_true(result.get("warning_number") == index, "Wrong warning count")
		_assert_true(not service.is_account_banned("account-a", now), "Warning must not ban")
	var pending := service.register_violation("account-a", [{"text": "example"}], now)
	_assert_true(pending.get("status") == "pending_owner_approval", "Fourth violation must create pending case")
	var case_id := str(pending.get("case_id", ""))
	_assert_true(not service.is_account_banned("account-a", now), "Pending case must not ban")
	var denied := service.review_case(case_id, "approve", 5, "reviewed", false, now)
	_assert_true(not denied.get("ok", false), "Unapproved admin request must fail")
	var approved := service.review_case(case_id, "approve", 5, "reviewed", true, now)
	_assert_true(approved.get("ok", false), "Owner approval should succeed")
	_assert_true(service.is_account_banned("account-a", now), "Approved account ban should be active")
	_assert_true(int(service.accounts["account-a"]["ban_until"]) == now + 5 * 3600, "Custom duration must be applied")
	var duplicate := service.review_case(case_id, "approve", 5, "repeat", true, now)
	_assert_true(not duplicate.get("ok", false), "Case must not be approved twice")
	var evidence := service.owner_evidence(case_id, true)
	_assert_true(evidence.get("messages", []).size() == 1, "Evidence should be available to owner")
	_assert_true(service.owner_evidence(case_id, false).is_empty(), "Evidence must not leak to unauthenticated user")
