extends SceneTree
## Headless regression: the optional debug panel stays hidden and an ENet
## client may connect while Godot is in its default OfflineMultiplayerPeer mode.

func _initialize() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error(message)
    quit(1)

func _run() -> void:
    var client := Node.new()
    client.name = "MultiplayerClient"
    client.set_script(load("res://scripts/network/titan_multiplayer_client.gd"))
    root.add_child(client)
    var panel := CanvasLayer.new()
    panel.name = "MultiplayerConnectPanel"
    panel.set_script(load("res://scripts/network/titan_multiplayer_connect_panel.gd"))
    root.add_child(panel)
    await process_frame
    var popup := panel.get("popup") as CenterContainer
    if popup == null or popup.visible:
        _fail("Network test panel must start hidden on portrait HUD")
        return
    panel.call("open_panel")
    if not popup.visible:
        _fail("Network panel did not open on demand")
        return
    panel.call("close_panel")
    if popup.visible:
        _fail("Network panel failed to close")
        return
    if not (client.multiplayer.multiplayer_peer is OfflineMultiplayerPeer):
        _fail("Expected Godot's default offline peer")
        return
    var local_server := ENetMultiplayerPeer.new()
    var local_port := 39571
    if local_server.create_server(local_port, 1) != OK:
        _fail("Could not open a local ENet test socket")
        return
    client.set("server_host", "127.0.0.1")
    client.set("server_port", local_port)
    var result: int = int(client.call("connect_to_test_server"))
    if result != OK:
        local_server.close()
        _fail("Offline peer prevented first client connect: %d" % result)
        return
    client.call("disconnect_from_test_server")
    if not (client.multiplayer.multiplayer_peer is OfflineMultiplayerPeer):
        local_server.close()
        _fail("Disconnect must restore offline peer")
        return
    local_server.close()
    panel.queue_free()
    client.queue_free()
    print("MOBILE_OVERLAY_NETWORK_SMOKE_OK")
    quit(0)
