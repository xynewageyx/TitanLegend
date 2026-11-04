extends RefCounted
class_name TitanAdventureUITheme

# Original parchment/wood/amber fantasy UI for the portrait combat screen.
# All components are generated in Godot: no paid fonts, textures or plugins.
const INK: Color = Color("#493321")
const MUTED: Color = Color("#82664c")
const PAPER: Color = Color("#fff4d8")
const PAPER_ALT: Color = Color("#f4deae")
const WOOD: Color = Color("#a46a3f")
const WOOD_DARK: Color = Color("#55351f")
const GOLD: Color = Color("#f3c45f")
const GOLD_LIGHT: Color = Color("#ffe7a7")
const TEAL: Color = Color("#4fae9e")
const GREEN: Color = Color("#72be69")
const SKY: Color = Color("#81d5ed")
const CORAL: Color = Color("#f69b71")

static func plaque(fill: Color = PAPER, border: Color = WOOD, radius: int = 17, border_size: int = 3) -> StyleBoxFlat:
 var box := StyleBoxFlat.new()
 box.bg_color = fill
 box.border_color = border
 box.set_border_width_all(border_size)
 box.set_corner_radius_all(radius)
 box.content_margin_left = 10
 box.content_margin_right = 10
 box.content_margin_top = 8
 box.content_margin_bottom = 8
 box.shadow_color = Color(0.12, 0.07, 0.03, 0.30)
 box.shadow_size = 7
 box.shadow_offset = Vector2(0, 4)
 return box

static func button(button_node: Button, chosen: bool = false, compact: bool = false) -> void:
 var normal_fill: Color = GOLD_LIGHT if chosen else Color("#fff5db")
 var hover_fill: Color = Color("#ffedbf")
 button_node.add_theme_stylebox_override("normal", plaque(normal_fill, GOLD if chosen else WOOD, 20, 3))
 button_node.add_theme_stylebox_override("hover", plaque(hover_fill, GOLD, 20, 3))
 button_node.add_theme_stylebox_override("pressed", plaque(GOLD, WOOD_DARK, 20, 3))
 button_node.add_theme_stylebox_override("disabled", plaque(Color("#e8dec9"), Color("#9e9076"), 15, 2))
 button_node.add_theme_stylebox_override("focus", plaque(Color.TRANSPARENT, GOLD, 15, 2))
 button_node.add_theme_color_override("font_color", INK)
 button_node.add_theme_color_override("font_hover_color", INK)
 button_node.add_theme_color_override("font_pressed_color", WOOD_DARK)
 button_node.add_theme_color_override("font_focus_color", INK)
 button_node.add_theme_color_override("font_disabled_color", Color("#493b2c"))
 button_node.add_theme_font_size_override("font_size", 18 if compact else 20)
 button_node.custom_minimum_size.y = 56 if compact else 64
 button_node.clip_text = true
 button_node.pivot_offset = button_node.custom_minimum_size * 0.5
 if not button_node.has_meta("titan_press_animation"):
  button_node.set_meta("titan_press_animation", true)
  button_node.button_down.connect(_animate_button.bind(button_node, Vector2(0.95, 0.95)))
  button_node.button_up.connect(_animate_button.bind(button_node, Vector2.ONE))

static func title(label: Label, px: int = 24) -> void:
 label.add_theme_color_override("font_color", INK)
 label.add_theme_font_size_override("font_size", px)
 label.add_theme_color_override("font_shadow_color", Color("#fff7df"))
 label.add_theme_constant_override("shadow_offset_x", 1)
 label.add_theme_constant_override("shadow_offset_y", 1)

static func small_bar(bar: ProgressBar, fill: Color = GREEN) -> void:
 bar.add_theme_stylebox_override("background", plaque(Color("#806a4d"), Color("#ead5a6"), 6, 1))
 bar.add_theme_stylebox_override("fill", plaque(fill, Color("#ffffff74"), 6, 0))
 bar.show_percentage = false

static func style_menu_tree(node: Node) -> void:
 # Apply a shared illustrated-paper palette to existing fully functional
 # team, skills, talents and cosmetic-shop menus.
 if node is ColorRect:
  (node as ColorRect).color = Color("#f3e4bf")
 elif node is PanelContainer:
  if not (node as PanelContainer).has_theme_stylebox_override("panel"):
   (node as PanelContainer).add_theme_stylebox_override("panel", plaque(PAPER, WOOD, 17, 3))
 elif node is OptionButton:
  button(node as Button, false, true)
 elif node is Button:
  button(node as Button, false, true)
 elif node is Label:
  (node as Label).add_theme_color_override("font_color", INK)
 elif node is ProgressBar:
  small_bar(node as ProgressBar, TEAL)
 elif node is TextEdit:
  var multi: TextEdit = node as TextEdit
  multi.add_theme_stylebox_override("normal", plaque(Color("#fffae9"), WOOD, 10, 2))
  multi.add_theme_stylebox_override("focus", plaque(Color("#fff6d8"), GOLD, 10, 2))
  multi.add_theme_color_override("font_color", INK)
  multi.add_theme_color_override("font_placeholder_color", MUTED)
 elif node is LineEdit:
  var edit: LineEdit = node as LineEdit
  edit.add_theme_stylebox_override("normal", plaque(Color("#fffae9"), WOOD, 10, 2))
  edit.add_theme_stylebox_override("focus", plaque(Color("#fff6d8"), GOLD, 10, 2))
  edit.add_theme_color_override("font_color", INK)
  edit.add_theme_color_override("font_placeholder_color", MUTED)
 for child in node.get_children():
  style_menu_tree(child)

static func _animate_button(button_node: Button, target: Vector2) -> void:
 if not is_instance_valid(button_node):
  return
 var tween := button_node.create_tween()
 tween.tween_property(button_node, "scale", target, 0.11).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

# Shared optional helpers for new portrait panels. Existing gameplay is unchanged.
static func section_heading(label: Label) -> void:
 title(label, 22)
 label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

static func touch_action(action: Button, primary: bool = false) -> void:
 button(action, primary, false)
 action.custom_minimum_size.y = maxf(action.custom_minimum_size.y, 64.0)
 action.focus_mode = Control.FOCUS_ALL

static func status_chip(panel: PanelContainer, positive: bool = false) -> void:
 panel.add_theme_stylebox_override("panel", plaque(Color("#e6f3d9") if positive else PAPER_ALT, GREEN if positive else WOOD, 12, 2))
