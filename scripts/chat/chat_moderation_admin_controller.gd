extends Control
class_name ChatModerationAdminController

# Client UI only. The server owns identity, authorization, cases and evidence.
signal server_decision_requested(case_id: String, action: String, hours: int, reason: String)
signal server_evidence_requested(case_id: String)

@export var moderation_rpc_path: NodePath
var panel: ChatModerationAdminPanel
var rpc_transport: ChatModerationRpcServer
var pending_cases: Array = []
var selected_index := 0
var refresh_button: Button
var previous_button: Button
var next_button: Button
var evidence_output: TextEdit

func _ready() -> void:
	var layout := VBoxContainer.new()
	layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(layout)
	var navigation := HBoxContainer.new()
	layout.add_child(navigation)
	refresh_button = Button.new()
	refresh_button.text = "Sperrantraege aktualisieren"
	refresh_button.pressed.connect(refresh_cases)
	navigation.add_child(refresh_button)
	previous_button = Button.new()
	previous_button.text = "Zurueck"
	previous_button.pressed.connect(func(): _select_case(selected_index - 1))
	navigation.add_child(previous_button)
	next_button = Button.new()
	next_button.text = "Weiter"
	next_button.pressed.connect(func(): _select_case(selected_index + 1))
	navigation.add_child(next_button)
	panel = ChatModerationAdminPanel.new()
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(panel)
	panel.decision_requested.connect(_on_decision)
	panel.evidence_requested.connect(_on_evidence)
	evidence_output = TextEdit.new()
	evidence_output.editable = false
	evidence_output.custom_minimum_size.y = 180
	evidence_output.placeholder_text = "Chatbeweise werden nur nach Serverfreigabe angezeigt."
	layout.add_child(evidence_output)
	_connect_transport()
	_select_case(0)

func _connect_transport() -> void:
	# The embedded RPC node is the default transport for this scene.
	# Resolve it even when an exported NodePath was not restored on instantiation.
	var transport_path: NodePath = moderation_rpc_path if not moderation_rpc_path.is_empty() else NodePath("ModerationRpc")
	rpc_transport = get_node_or_null(transport_path) as ChatModerationRpcServer
	if rpc_transport == null:
		push_warning("Moderation RPC transport not found")
		return
	rpc_transport.pending_cases_received.connect(_on_pending_cases)
	rpc_transport.case_evidence_received.connect(_on_case_evidence)
	rpc_transport.case_decision_received.connect(_on_case_decision)

func refresh_cases() -> void:
	if rpc_transport == null or not multiplayer.has_multiplayer_peer():
		panel.status_label.text = "Keine Serververbindung."
		return
	rpc_transport.request_pending_cases.rpc_id(1)
	panel.status_label.text = "Sperrantraege werden angefordert."

func _on_pending_cases(cases: Array) -> void:
	pending_cases = cases.duplicate(true)
	_select_case(0)

func _select_case(index: int) -> void:
	selected_index = clampi(index, 0, maxi(pending_cases.size() - 1, 0))
	previous_button.disabled = selected_index <= 0
	next_button.disabled = selected_index >= pending_cases.size() - 1
	evidence_output.text = ""
	if pending_cases.is_empty():
		panel.show_case({})
	else:
		panel.show_case(pending_cases[selected_index])

func show_pending_case(case_data: Dictionary) -> void:
	pending_cases = [case_data.duplicate(true)]
	_select_case(0)

func _on_decision(case_id: String, action: String, hours: int, reason: String) -> void:
	if case_id.is_empty():
		return
	if rpc_transport == null or not multiplayer.has_multiplayer_peer():
		panel.status_label.text = "Keine Serververbindung."
		return
	server_decision_requested.emit(case_id, action, hours, reason)
	rpc_transport.request_case_decision.rpc_id(1, case_id, action, hours, reason)

func _on_evidence(case_id: String) -> void:
	if case_id.is_empty():
		return
	if rpc_transport == null or not multiplayer.has_multiplayer_peer():
		panel.status_label.text = "Keine Serververbindung."
		return
	server_evidence_requested.emit(case_id)
	rpc_transport.request_case_evidence.rpc_id(1, case_id)

func _on_case_evidence(case_id: String, evidence_json: String) -> void:
	if pending_cases.is_empty() or str(pending_cases[selected_index].get("case_id", "")) != case_id:
		return
	evidence_output.text = evidence_json if not evidence_json.is_empty() else "Keine Beweise verfuegbar oder Zugriff verweigert."

func _on_case_decision(case_id: String, result: Dictionary) -> void:
	if pending_cases.is_empty() or str(pending_cases[selected_index].get("case_id", "")) != case_id:
		return
	show_server_result(result)
	if result.get("ok", false):
		refresh_cases()

func show_server_result(result: Dictionary) -> void:
	if panel == null:
		return
	panel.status_label.text = "Server hat die Aktion bestaetigt." if result.get("ok", false) else "Serveraktion fehlgeschlagen: %s" % str(result.get("error", "unbekannt"))
