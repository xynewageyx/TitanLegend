extends CanvasLayer
class_name TitanMultiplayerConnectPanel

# Optional transport diagnostics, accessible from Mehr > Netzwerk-Test.
# Hidden while fighting so it cannot cover the team HUD on Android.
@export var client_path: NodePath = NodePath("../MultiplayerClient")
var client: TitanMultiplayerClient
var popup: CenterContainer
var host_input: LineEdit
var port_input: SpinBox
var status_label: Label
var connect_button: Button
var disconnect_button: Button

func _ready() -> void:
    layer = 18
    client = get_node_or_null(client_path) as TitanMultiplayerClient
    popup = CenterContainer.new()
    popup.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(popup)
    var root := PanelContainer.new()
    root.name = "NetworkTestCard"
    root.custom_minimum_size = Vector2(320, 0)
    root.mouse_filter = Control.MOUSE_FILTER_STOP
    popup.add_child(root)
    var layout := VBoxContainer.new()
    layout.add_theme_constant_override("separation", 8)
    root.add_child(layout)
    var title := Label.new()
    title.text = "Multiplayer-Test (ohne Anmeldung)"
    title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    layout.add_child(title)
    host_input = LineEdit.new()
    host_input.placeholder_text = "Server-IP oder Domain"
    host_input.text = ""
    layout.add_child(host_input)
    var hint := Label.new()
    hint.text = "127.0.0.1 = dieses Handy, nicht dein externer Server."
    hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    layout.add_child(hint)
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
    status_label.text = "Netzwerk: Offline"
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    layout.add_child(status_label)
    var close_button := Button.new()
    close_button.text = "Schließen"
    close_button.pressed.connect(close_panel)
    layout.add_child(close_button)
    popup.hide()
    if client != null:
        client.connection_status_changed.connect(_update_status)
    else:
        _update_status("network_client_missing")

func open_panel() -> void:
    popup.show()

func close_panel() -> void:
    popup.hide()

func _connect_pressed() -> void:
    if client == null:
        _update_status("network_client_missing")
        return
    var host := host_input.text.strip_edges()
    if host.is_empty() or host.contains("/") or host.contains(" "):
        _update_status("invalid_server_address")
        return
    client.server_host = host
    client.server_port = int(port_input.value)
    var error := client.connect_to_test_server()
    if error == ERR_ALREADY_IN_USE:
        _update_status("already_in_use")
    elif error != OK:
        _update_status("error_%d" % error)

func _disconnect_pressed() -> void:
    if client != null:
        client.disconnect_from_test_server()

func _update_status(value: String) -> void:
    var messages := {
        "offline": "Offline",
        "connecting": "Verbindung wird aufgebaut …",
        "connected_unauthenticated": "Verbunden (ohne Anmeldung)",
        "disconnected": "Getrennt",
        "connection_failed": "Server nicht erreichbar. Adresse/Port prüfen.",
        "connection_setup_failed": "Verbindung konnte nicht gestartet werden.",
        "network_client_missing": "Netzwerkclient fehlt.",
        "invalid_server_address": "Bitte gültige Server-IP oder Domain eingeben.",
        "already_in_use": "Verbindung bereits aktiv. Erst trennen."
    }
    status_label.text = "Netzwerk: " + str(messages.get(value, value))
