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

# Call only after a positive server response to an authenticated identity
# check. Never use locally saved owner flags as proof of authorization.
func set_server_granted_visibility(allowed: bool) -> void:
	server_granted_visibility = allowed
	open_button.visible = allowed
	if not allowed:
		admin_view.hide()

func _toggle_panel() -> void:
	if not server_granted_visibility:
		return
	admin_view.visible = not admin_view.visible
	if admin_view.visible:
		admin_view.refresh_cases()
