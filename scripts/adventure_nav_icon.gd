extends Control
class_name TitanAdventureNavIcon

# Five original miniature hand-drawn vector icons. They render at any
# Android resolution without external assets or texture downloads.
var kind: String = "combat"
const OUTLINE := Color("#694127")
const CREAM := Color("#fff2cf")
const AMBER := Color("#f5b64f")
const BLUE := Color("#65bddd")
const GREEN := Color("#68ba83")
const RED := Color("#e37c59")

func _line(a: Vector2, b: Vector2, tint: Color, thickness: float = 4.0) -> void:
 draw_line(a, b, OUTLINE, thickness + 3.0, true)
 draw_line(a, b, tint, thickness, true)

func _gem(center: Vector2, scale_value: float, tint: Color) -> void:
 var pts := PackedVector2Array([
  center + Vector2(-12, -7) * scale_value,
  center + Vector2(0, -15) * scale_value,
  center + Vector2(12, -7) * scale_value,
  center + Vector2(9, 8) * scale_value,
  center + Vector2(0, 17) * scale_value,
  center + Vector2(-9, 8) * scale_value
 ])
 draw_colored_polygon(pts, tint)
 draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[4], pts[5], pts[0]]), OUTLINE, 2.2, true)
 draw_line(pts[1], center, CREAM, 2.0, true)
 draw_line(center, pts[4], OUTLINE, 1.5, true)

func _draw() -> void:
 var c: Vector2 = size / 2.0
 draw_circle(c + Vector2(0, 1), 22, Color("#f7d686"))
 draw_arc(c, 22, 0, TAU, 32, OUTLINE, 2.2, true)
 match kind:
  "combat":
   # Crossed adventurer blades with wooden grips and polished steel.
   _line(c + Vector2(-15, -17), c + Vector2(16, 13), Color("#e3eef2"), 5.0)
   _line(c + Vector2(15, -17), c + Vector2(-16, 13), Color("#ddeaf0"), 5.0)
   _line(c + Vector2(-19, 11), c + Vector2(-10, 20), RED, 5.5)
   _line(c + Vector2(19, 11), c + Vector2(10, 20), RED, 5.5)
   _line(c + Vector2(-19, 7), c + Vector2(-9, 7), AMBER, 3.0)
   _line(c + Vector2(19, 7), c + Vector2(9, 7), AMBER, 3.0)
  "jewels":
   # Saturated jewel in an open treasure chest.
   draw_rect(Rect2(c + Vector2(-18, 0), Vector2(36, 17)), OUTLINE)
   draw_rect(Rect2(c + Vector2(-15, 2), Vector2(30, 12)), Color("#a7653f"))
   draw_rect(Rect2(c + Vector2(-17, 12), Vector2(34, 4)), AMBER)
   _gem(c + Vector2(0, -7), 0.90, BLUE)
  "team":
   # Three teammates with individually colored silhouettes.
   draw_circle(c + Vector2(-12, -8), 8.5, OUTLINE)
   draw_circle(c + Vector2(12, -8), 8.5, OUTLINE)
   draw_circle(c + Vector2(-12, -9), 6.0, RED)
   draw_circle(c + Vector2(12, -9), 6.0, GREEN)
   draw_circle(c + Vector2(0, -14), 9.0, OUTLINE)
   draw_circle(c + Vector2(0, -15), 7.0, Color("#efc39b"))
   draw_arc(c + Vector2(-12, 14), 11, PI, TAU, 12, OUTLINE, 6.0, true)
   draw_arc(c + Vector2(12, 14), 11, PI, TAU, 12, OUTLINE, 6.0, true)
   draw_arc(c + Vector2(0, 15), 12, PI, TAU, 12, BLUE, 8.0, true)
  "skills":
   # A glowing magical staff with four-point spell sparks.
   _line(c + Vector2(-12, 18), c + Vector2(8, -13), Color("#9c6a46"), 6.0)
   _gem(c + Vector2(9, -16), 0.67, BLUE)
   _line(c + Vector2(-15, -16), c + Vector2(-15, -7), AMBER, 2.0)
   _line(c + Vector2(-19, -12), c + Vector2(-11, -12), AMBER, 2.0)
   _line(c + Vector2(19, 4), c + Vector2(19, 13), CREAM, 2.0)
   _line(c + Vector2(15, 8), c + Vector2(23, 8), CREAM, 2.0)
  "more":
   # Tiny stylized scroll with gold rivets.
   draw_rect(Rect2(c + Vector2(-17, -11), Vector2(34, 24)), OUTLINE)
   draw_rect(Rect2(c + Vector2(-14, -9), Vector2(28, 20)), Color("#f9ecd0"))
   draw_circle(c + Vector2(-9, 1), 3.4, AMBER)
   draw_circle(c + Vector2(0, 1), 3.4, AMBER)
   draw_circle(c + Vector2(9, 1), 3.4, AMBER)
  _:
   _gem(c, 0.6, GREEN)
