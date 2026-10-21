extends CanvasLayer
## Kurze, nicht blockierende Boss-Inszenierung. Keine externen Assets nötig.
signal finished
var panel: ColorRect
var headline: Label
var subtitle: Label

func _ready() -> void:
 layer = 20
 panel = ColorRect.new()
 panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 panel.color = Color(0.025, 0.015, 0.07, 0.0)
 panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(panel)
 var center := CenterContainer.new()
 center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 center.mouse_filter = Control.MOUSE_FILTER_IGNORE
 panel.add_child(center)
 var stack := VBoxContainer.new()
 stack.alignment = BoxContainer.ALIGNMENT_CENTER
 stack.add_theme_constant_override("separation", 18)
 center.add_child(stack)
 headline = Label.new()
 headline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 headline.add_theme_font_size_override("font_size", 50)
 headline.add_theme_color_override("font_color", Color(1.0, 0.81, 0.3))
 stack.add_child(headline)
 subtitle = Label.new()
 subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 subtitle.add_theme_font_size_override("font_size", 26)
 subtitle.add_theme_color_override("font_color", Color.WHITE)
 stack.add_child(subtitle)

func show_intro(boss: Node3D, element_name: String, fusion: bool) -> void:
 headline.text = "FUSIONSTITAN" if fusion else "GEBIETSBOSS"
 subtitle.text = element_name + "  •  " + ("ULTIMATIVE FORM" if fusion else "TITAN ERWACHT")
 panel.visible = true
 panel.modulate.a = 0.0
 var initial_scale := boss.scale
 var enlarged_scale := initial_scale * (1.20 if fusion else 1.08)
 var intro := create_tween()
 intro.set_parallel(true)
 intro.tween_property(panel, "modulate:a", 1.0, 0.3)
 intro.tween_property(boss, "scale", enlarged_scale, 0.55).set_trans(Tween.TRANS_BACK)
 await intro.finished
 if not is_instance_valid(boss):
  panel.visible = false
  finished.emit()
  return
 var outro := create_tween()
 outro.set_parallel(true)
 outro.tween_property(boss, "scale", initial_scale, 0.5)
 outro.tween_property(panel, "modulate:a", 0.0, 0.6).set_delay(0.55)
 await outro.finished
 panel.visible = false
 finished.emit()
