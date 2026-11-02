extends Control
class_name ChatModerationAdminPanel

# Review UI only. All actions must be authenticated and authorized server-side.
signal decision_requested(case_id: String, action: String, hours: int, reason: String)
signal evidence_requested(case_id: String)

var current_case: Dictionary = {}
var case_label: Label
var evidence_button: Button
var hours_input: SpinBox
var reason_input: LineEdit
var status_label: Label

func _ready() -> void:
	var layout := VBoxContainer.new()
	layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(layout)
	case_label = Label.new()
	layout.add_child(case_label)
	evidence_button = Button.new()
	evidence_button.text = "Chatprotokoll anfordern"
	evidence_button.pressed.connect(_request_evidence)
	layout.add_child(evidence_button)
	var duration_label := Label.new()
	duration_label.text = "Sperrdauer in Stunden (anpassbar)"
	layout.add_child(duration_label)
	hours_input = SpinBox.new()
	hours_input.min_value = 1
	hours_input.max_value = 8760
	hours_input.step = 1
	layout.add_child(hours_input)
	reason_input = LineEdit.new()
	reason_input.placeholder_text = "Begruendung (Pflichtfeld)"
	layout.add_child(reason_input)
	var approve := Button.new()
	approve.text = "Sperre zur Freigabe senden"
	approve.pressed.connect(func(): _request_decision("approve"))
	layout.add_child(approve)
	var reject := Button.new()
	reject.text = "Sperrantrag ablehnen"
	reject.pressed.connect(func(): _request_decision("reject"))
	layout.add_child(reject)
	status_label = Label.new()
	layout.add_child(status_label)
	show_case({})

func show_case(case_data: Dictionary) -> void:
	current_case = case_data.duplicate(true)
	var pending := str(current_case.get("status", "")) == "pending_owner_approval"
	case_label.text = "Fall: %s | Account: %s | Status: %s" % [str(current_case.get("case_id", "-")), str(current_case.get("account_id", "-")), str(current_case.get("status", "-"))]
	hours_input.value = clampi(int(current_case.get("proposed_hours", 2)), 1, 8760)
	evidence_button.disabled = not pending
	status_label.text = "Nur eine Vorschau. Serverfreigabe erforderlich." if pending else "Kein offener Fall."

func _request_evidence() -> void:
	if str(current_case.get("status", "")) == "pending_owner_approval":
		evidence_requested.emit(str(current_case.get("case_id", "")))

func _request_decision(action: String) -> void:
	if str(current_case.get("status", "")) != "pending_owner_approval":
		return
	var reason := reason_input.text.strip_edges()
	if reason.is_empty():
		status_label.text = "Bitte Begruendung eingeben."
		return
	var hours := int(hours_input.value)
	if action == "approve" and not ChatModerationPolicy.validate_owner_choice(hours, reason):
		status_label.text = "Ungueltige Sperrdauer."
		return
	decision_requested.emit(str(current_case.get("case_id", "")), action, hours, reason)
	status_label.text = "Anfrage gesendet. Warte auf Serverbestaetigung."
