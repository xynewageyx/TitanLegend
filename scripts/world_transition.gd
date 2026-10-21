extends CanvasLayer
## Kurzer, nicht blockierender Gebietswechsel im Android-Hochformat.
@export var biome_manager: Node3D
var shade: ColorRect
var title_label: Label
var subtitle_label: Label
var tween: Tween
var last_biome: int = -1

func _ready() -> void:
 layer = 18
 shade = ColorRect.new()
 shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 shade.color = Color(0.02, 0.02, 0.05, 0.0)
 shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(shade)
 var center := CenterContainer.new()
 center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 center.mouse_filter = Control.MOUSE_FILTER_IGNORE
 shade.add_child(center)
 var stack := VBoxContainer.new()
 stack.add_theme_constant_override("separation", 14)
 center.add_child(stack)
 title_label = Label.new()
 title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 title_label.add_theme_font_size_override("font_size", 39)
 title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 stack.add_child(title_label)
 subtitle_label = Label.new()
 subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 subtitle_label.add_theme_font_size_override("font_size", 22)
 stack.add_child(subtitle_label)
 shade.visible = false
 if biome_manager != null:
  last_biome = int(biome_manager.get("current_biome"))
  biome_manager.biome_changed.connect(_on_biome_changed)

func _on_biome_changed(index: int) -> void:
 if index == last_biome:
  return
 last_biome = index
 if biome_manager == null:
  return
 var names: Array = biome_manager.NAMES
 var colors: Array = biome_manager.COLORS
 title_label.text = str(names[index]).to_upper()
 title_label.add_theme_color_override("font_color", colors[index].lightened(0.55))
 subtitle_label.text = "NEUES ELEMENTARGEBIET"
 if tween != null and tween.is_running():
  tween.kill()
 shade.visible = true
 shade.color.a = 0.0
 tween = create_tween()
 tween.tween_property(shade, "color:a", 0.83, 0.4)
 tween.tween_interval(1.25)
 tween.tween_property(shade, "color:a", 0.0, 0.65)
 tween.tween_callback(func() -> void: shade.visible = false)
