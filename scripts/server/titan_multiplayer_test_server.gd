extends Node3D
class_name TitanMultiplayerTestServer

# Headless ENet test server. No anonymous client is trusted as an owner.
# Authentication is deliberately NOT implemented here.
@export_range(1024, 65535) var port := 24567
@export_range(1, 1000) var max_clients := 32
@export var owner_account_id := ""

@onready var moderation_rpc: ChatModerationRpcServer = $ModerationAdminLauncher/ChatModerationAdmin/ModerationRpc

var coordinator: ChatModerationCoordinator
var gateway: ChatModerationAdminGateway
var authority: ChatModerationPeerAuthority

func _ready() -> void:
	if not OS.has_feature("dedicated_server") and not DisplayServer.get_name() == "headless":
		push_warning("This scene is intended for a headless dedicated server.")
	coordinator = ChatModerationCoordinator.new()
	if not coordinator.initialize():
		push_error("Moderation storage failed; refusing server startup.")
		get_tree().quit(1)
		return
	gateway = ChatModerationAdminGateway.new(coordinator, owner_account_id)
	authority = ChatModerationPeerAuthority.new(gateway)
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(port, max_clients)
	if error != OK:
		push_error("ENet server startup failed: %s" % error_string(error))
		get_tree().quit(1)
		return
	multiplayer.multiplayer_peer = peer
	moderation_rpc.configure_server_authority(authority)
	multiplayer.peer_connected.connect(_on_peer_connected)
	print("Titan Legends headless test server listening on UDP %d (authentication disabled)" % port)

func _on_peer_connected(peer_id: int) -> void:
	# No verified session yet: do not bind a user-supplied account ID.
	# This is only a transport smoke-test server.
	print("Unauthenticated test peer connected: %d" % peer_id)
