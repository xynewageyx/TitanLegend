extends "res://scripts/ui_manager.gd"
## QA adapter: instantiate REAL UIManager._make_hud widgets, not a painted mock.
## Isolated test data is populated manually; no gameplay/save/network actions.
## The production UIManager._ready() normally wires all runtime dependencies.
const SOURCE := "res://scripts/ui_manager.gd"

func _ready() -> void:
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 _make_hud()
 # The normal UIManager creates all these widgets. No re-creation here.
 boss_panel.show()
 boss_countdown.show()
 chat_panel.show()
 _append("System", "Bosskampf · 00:45")
 _append("Team", "Tank schützt die Gruppe")
 gold_label.text = "GOLD"
 tickets_label.text = "TICKETS"
 xp_label.text = "LEVEL"
 action_panel.hide()

func set_boss_qa_values(display_name: String, cast_warning: bool) -> void:
 boss_panel.visible = true
 boss_name.text = "⚠ Boss-Angriff · Unterbrechen" if cast_warning else display_name
 boss_hp.value = 70.0
 boss_countdown.text = "Boss-Zeit: 00:45"
 boss_countdown.visible = true
 if cast_warning:
  _append("System", "Boss bereitet einen Angriff vor!")

func get_qa_layout() -> Dictionary:
 return {
  "source_script": SOURCE,
  "boss_panel_rect": _rect(boss_panel),
  "chat_panel_rect": _rect(chat_panel),
  "boss_health_visible": boss_hp.is_visible_in_tree(),
  "boss_timer_visible": boss_countdown.is_visible_in_tree(),
  "chat_visible": chat_panel.is_visible_in_tree(),
  "boss_name": boss_name.text,
  "boss_timer_text": boss_countdown.text,
  "health_value": boss_hp.value
 }

func _rect(control: Control) -> Array[float]:
 var box: Rect2 = control.get_global_rect()
 return [snappedf(box.position.x,0.1),snappedf(box.position.y,0.1),
  snappedf(box.size.x,0.1),snappedf(box.size.y,0.1)]
