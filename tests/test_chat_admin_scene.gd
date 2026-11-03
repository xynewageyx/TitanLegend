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
	launcher.set_server_granted_visibility(false)
	_check(not launcher.open_button.visible, "Unauthorized entry must remain hidden")
	launcher.queue_free()
	await process_frame
	if failures == 0:
		print("Chat admin scene smoke test passed")
	quit(1 if failures > 0 else 0)
