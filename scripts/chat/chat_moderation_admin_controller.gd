extends Control
class_name ChatModerationAdminController

# UI controller only. Set gateway only in trusted server/test context.
# In production the Android client MUST use authenticated RPC/HTTPS endpoints,
# never instantiate a privileged gateway locally.
signal server_decision_requested(case_id: String, action: String, hours: int, reason: String)
signal server_evidence_requested(case_id: String)

var panel: ChatModerationAdminPanel

func _ready() -> void:
	panel = ChatModerationAdminPanel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(panel)
	panel.decision_requested.connect(_on_decision)
	panel.evidence_requested.connect(_on_evidence)

func show_pending_case(case_data: Dictionary) -> void:
	if panel == null:
		return
	panel.show_case(case_data)

func _on_decision(case_id: String, action: String, hours: int, reason: String) -> void:
	if case_id.is_empty():
		return
	server_decision_requested.emit(case_id, action, hours, reason)

func _on_evidence(case_id: String) -> void:
	if case_id.is_empty():
		return
	server_evidence_requested.emit(case_id)

func show_server_result(result: Dictionary) -> void:
	if panel == null:
		return
	panel.status_label.text = "Server hat die Aktion bestaetigt." if result.get("ok", false) else "Serveraktion fehlgeschlagen: %s" % str(result.get("error", "unbekannt"))
