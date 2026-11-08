extends Control
## Touch-friendly graphics submenu. Changes affect visuals, never combat mechanics.
var battle_manager: Node3D
var quality_selector: OptionButton

func initialize(battle: Node3D) -> void:
 battle_manager = battle

func _ready() -> void:
 visible = false
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 mouse_filter = Control.MOUSE_FILTER_STOP
 var shade := ColorRect.new()
 shade.color = Color(0.025, 0.035, 0.065, 0.97)
 shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(shade)
 var margin := MarginContainer.new()
 margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 margin.add_theme_constant_override("margin_left", 26)
 margin.add_theme_constant_override("margin_right", 26)
 margin.add_theme_constant_override("margin_top", 115)
 margin.add_theme_constant_override("margin_bottom", 145)
 add_child(margin)
 var stack := VBoxContainer.new()
 stack.add_theme_constant_override("separation", 20)
 margin.add_child(stack)
 var title := Label.new()
 title.text = "GRAFIK – SKILLEFFEKTE"
 title.add_theme_font_size_override("font_size", 26)
 stack.add_child(title)
 var hint := Label.new()
 hint.text = "Maximal gleichzeitig sichtbare Effekte. Kampfstärke bleibt unverändert."
 hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 stack.add_child(hint)
 quality_selector = OptionButton.new()
 quality_selector.custom_minimum_size.y = 64
 for name in ["Niedrig (3)", "Mittel (6)", "Hoch (9)", "Ultra (12)"]:
  quality_selector.add_item(name)
 stack.add_child(quality_selector)
 quality_selector.item_selected.connect(_on_quality_selected)
 var close := Button.new()
 close.text = "Zurück zum Spiel"
 close.custom_minimum_size.y = 68
 close.pressed.connect(func() -> void: hide())
 stack.add_child(close)

func open_menu() -> void:
 if battle_manager != null:
  quality_selector.select(clampi(int(battle_manager.get("skill_vfx_quality")), 0, 3))
 show()

func _on_quality_selected(index: int) -> void:
 if battle_manager != null and battle_manager.has_method("set_skill_vfx_quality"):
  battle_manager.call("set_skill_vfx_quality", index)
