extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func _run() -> void:
	var admin_packed: PackedScene = load("res://scenes/chat_moderation_admin.tscn")
	_check(admin_packed != null, "Admin scene must load")
	if admin_packed != null:
		var admin: ChatModerationAdminController = admin_packed.instantiate() as ChatModerationAdminController
		_check(admin != null, "Admin scene must instantiate as controller")
		if admin == null:
			quit(1)
			return
		root.add_child(admin)
		await process_frame
		_check(admin is ChatModerationAdminController, "Admin scene must use controller")
		_check(admin.get_node_or_null("ModerationRpc") is ChatModerationRpcServer, "Admin scene must include RPC transport")
		_check(admin.rpc_transport != null, "Admin controller must connect to transport")
		admin.queue_free()
		await process_frame
	var launcher := ChatModerationAdminLauncher.new()
	root.add_child(launcher)
	await process_frame
	_check(not launcher.open_button.visible, "Admin entry must start hidden")
	_check(not launcher.admin_view.visible, "Admin panel must start hidden")
	# A positive server grant may show the entry, but revocation must erase
	# any private evidence cached by the UI.
	launcher.set_server_granted_visibility(true)
	_check(launcher.open_button.visible, "Server grant must reveal admin entry")
	var controller := launcher.admin_view as ChatModerationAdminController
	_check(controller != null, "Launcher must instantiate admin controller")
	if controller != null:
		controller.show_pending_case({"case_id": "MOD-TEST", "account_id": "test", "status": "pending_owner_approval", "proposed_hours": 2})
		controller.evidence_output.text = "PRIVATE TEST EVIDENCE"
	launcher.set_server_granted_visibility(false)
	_check(not launcher.open_button.visible, "Unauthorized entry must remain hidden")
	_check(not launcher.admin_view.visible, "Revocation must hide admin view")
	if controller != null:
		_check(controller.pending_cases.is_empty(), "Revocation must clear cached cases")
		_check(controller.evidence_output.text.is_empty(), "Revocation must clear private evidence")
	launcher.queue_free()
	await process_frame
	if failures == 0:
		print("Chat admin scene smoke test passed")
	quit(1 if failures > 0 else 0)
