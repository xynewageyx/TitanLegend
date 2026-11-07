extends CanvasLayer
class_name TitanMultiplayerConnectPanel

# Optional transport diagnostics, not an account login.
@export var client_path: NodePath = NodePath("../MultiplayerClient")
var client: TitanMultiplayerClient
var host_input: LineEdit
var port_input: SpinBox
var status_label: Label
var connect_button: Button
var disconnect_button: Button

func _ready() -> void:
	client = get_node_or_null(client_path) as TitanMultiplayerClient
	var root := PanelContainer.new()
	root.set_anchors_preset(Control.PRESET_TOP_LEFT)
	root.position = Vector2(12, 300)
	root.custom_minimum_size = Vector2(300, 0)
	add_child(root)
	var layout := VBoxContainer.new()
	root.add_child(layout)
	var title := Label.new()
	title.text = "Multiplayer-Test (ohne Anmeldung)"
	layout.add_child(title)
	host_input = LineEdit.new()
	host_input.placeholder_text = "Server-IP oder Domain"
	host_input.text = "127.0.0.1"
	layout.add_child(host_input)
	port_input = SpinBox.new()
	port_input.min_value = 1024
	port_input.max_value = 65535
	port_input.value = 24567
	layout.add_child(port_input)
	connect_button = Button.new()
	connect_button.text = "Verbinden"
	connect_button.pressed.connect(_connect_pressed)
	layout.add_child(connect_button)
	disconnect_button = Button.new()
	disconnect_button.text = "Trennen"
	disconnect_button.pressed.connect(_disconnect_pressed)
	layout.add_child(disconnect_button)
	status_label = Label.new()
	status_label.text = "Offline"
	layout.add_child(status_label)
	if client != null:
		client.connection_status_changed.connect(_update_status)
	else:
		_update_status("network_client_missing")

func _connect_pressed() -> void:
	if client == null:
		return
	var host := host_input.text.strip_edges()
	if host.is_empty() or host.contains("/") or host.contains(" "):
		_update_status("invalid_server_address")
		return
	client.server_host = host
	client.server_port = int(port_input.value)
	var error := client.connect_to_test_server()
	if error != OK:
		_update_status("error_%d" % error)

func _disconnect_pressed() -> void:
	if client != null:
		client.disconnect_from_test_server()

func _update_status(value: String) -> void:
	status_label.text = "Netzwerk: " + value
