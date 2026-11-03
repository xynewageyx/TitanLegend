extends CanvasLayer
class_name ChatModerationAdminLauncher

# UI visibility is NOT authorization. The dedicated server must independently
# authenticate every request through ChatModerationPeerAuthority.
const ADMIN_SCENE := preload("res://scenes/chat_moderation_admin.tscn")
var admin_view: Control
var open_button: Button
var server_granted_visibility := false

func _ready() -> void:
	open_button = Button.new()
	open_button.text = "Moderation"
	open_button.visible = false
	open_button.position = Vector2(12, 220)
	open_button.pressed.connect(_toggle_panel)
	add_child(open_button)
	admin_view = ADMIN_SCENE.instantiate()
	admin_view.visible = false
	add_child(admin_view)
	var transport: ChatModerationRpcServer = admin_view.get_node_or_null("ModerationRpc") as ChatModerationRpcServer
	if transport != null:
		transport.admin_access_received.connect(set_server_granted_visibility)
		multiplayer.connected_to_server.connect(_request_access)
		multiplayer.server_disconnected.connect(_revoke_access)
		if multiplayer.has_multiplayer_peer() and not multiplayer.is_server():
			_request_access()

# Call only after a positive server response to an authenticated identity
# check. Never use locally saved owner flags as proof of authorization.
func set_server_granted_visibility(allowed: bool) -> void:
	server_granted_visibility = allowed
	open_button.visible = allowed
	if not allowed:
		admin_view.hide()
		# Purge previously received private case data when access is revoked.
		var controller := admin_view as ChatModerationAdminController
		if controller != null and controller.panel != null:
			controller.pending_cases.clear()
			controller._select_case(0)

func _toggle_panel() -> void:
	if not server_granted_visibility:
		return
	admin_view.visible = not admin_view.visible
	if admin_view.visible:
		admin_view.refresh_cases()

func _request_access() -> void:
	set_server_granted_visibility(false)
	if admin_view == null or not multiplayer.has_multiplayer_peer() or multiplayer.is_server():
		return
	var transport: ChatModerationRpcServer = admin_view.get_node_or_null("ModerationRpc") as ChatModerationRpcServer
	if transport != null:
		transport.request_admin_access.rpc_id(1)

func _revoke_access() -> void:
	set_server_granted_visibility(false)
