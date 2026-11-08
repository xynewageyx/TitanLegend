extends Node
class_name TitanMultiplayerClient

# Transport-only client for Android test builds. No credentials or owner
# privileges are sent here; authentication requires a separate secure flow.
signal connection_status_changed(status: String)

@export var server_host := "127.0.0.1"
@export_range(1024, 65535) var server_port := 24567

func connect_to_test_server() -> Error:
	# Godot starts with an OfflineMultiplayerPeer, which is not an active network session.
	var current_peer: MultiplayerPeer = multiplayer.multiplayer_peer
	if current_peer != null and not (current_peer is OfflineMultiplayerPeer):
		return ERR_ALREADY_IN_USE
	var peer := ENetMultiplayerPeer.new()
	var result := peer.create_client(server_host, server_port)
	if result != OK:
		connection_status_changed.emit("connection_setup_failed")
		return result
	multiplayer.multiplayer_peer = peer
	if not multiplayer.connected_to_server.is_connected(_on_connected):
		multiplayer.connected_to_server.connect(_on_connected)
	if not multiplayer.connection_failed.is_connected(_on_connection_failed):
		multiplayer.connection_failed.connect(_on_connection_failed)
	if not multiplayer.server_disconnected.is_connected(_on_disconnected):
		multiplayer.server_disconnected.connect(_on_disconnected)
	connection_status_changed.emit("connecting")
	return OK

func disconnect_from_test_server() -> void:
	_release_peer()
	connection_status_changed.emit("disconnected")

func _on_connected() -> void:
	connection_status_changed.emit("connected_unauthenticated")

func _on_connection_failed() -> void:
	_release_peer()
	connection_status_changed.emit("connection_failed")

func _on_disconnected() -> void:
	_release_peer()
	connection_status_changed.emit("disconnected")

func _release_peer() -> void:
	var current_peer: MultiplayerPeer = multiplayer.multiplayer_peer
	if current_peer != null and not (current_peer is OfflineMultiplayerPeer):
		current_peer.close()
	# Restore Godot's offline authority when the test connection ends.
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
