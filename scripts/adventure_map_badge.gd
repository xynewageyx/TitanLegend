extends Control
class_name TitanAdventureMapBadge

# A tiny procedural travel-map ornament. Stage data is shown as text beside
# it; this is decorative and does not pretend to show a network map.
var wave: int = 1
var biome: int = 0

func set_progress(next_wave: int, biome_id: int) -> void:
 wave = clampi(next_wave, 1, 10)
 biome = biome_id
 queue_redraw()

func _draw() -> void:
 var c: Vector2 = size / 2.0
 var radius: float = minf(size.x, size.y) * 0.45
 draw_circle(c + Vector2(0, 3), radius + 4.0, Color("#65452e"))
 draw_circle(c, radius, Color("#71cbd2"))
 draw_arc(c, radius, 0, TAU, 36, Color("#fff2c9"), 4.0, true)
 var ground_tint: Color = Color("#75b86e")
 if biome % 5 == 0:
  ground_tint = Color("#8ec56d")
 elif biome % 5 == 1:
  ground_tint = Color("#76a9c4")
 elif biome % 5 == 2:
  ground_tint = Color("#cfb77c")
 elif biome % 5 == 3:
  ground_tint = Color("#a0ca84")
 else:
  ground_tint = Color("#b69ac7")
 var island := PackedVector2Array([
  c + Vector2(-radius * 0.88, -radius * 0.10),
  c + Vector2(-radius * 0.62, -radius * 0.78),
  c + Vector2(radius * 0.12, -radius * 0.85),
  c + Vector2(radius * 0.55, -radius * 0.42),
  c + Vector2(radius * 0.87, radius * 0.15),
  c + Vector2(radius * 0.43, radius * 0.76),
  c + Vector2(-radius * 0.36, radius * 0.83),
  c + Vector2(-radius * 0.76, radius * 0.47)
 ])
 draw_colored_polygon(island, ground_tint)
 var path_points := PackedVector2Array([
  c + Vector2(-radius * 0.65, radius * 0.49),
  c + Vector2(-radius * 0.3, radius * 0.18),
  c + Vector2(-radius * 0.22, -radius * 0.25),
  c + Vector2(radius * 0.18, -radius * 0.35),
  c + Vector2(radius * 0.52, -radius * 0.56)
 ])
 draw_polyline(path_points, Color("#e6cf91"), 6.0, true)
 draw_polyline(path_points, Color("#fff4c7"), 3.0, true)
 var t: float = float(wave - 1) / 9.0
 var segment: float = t * float(path_points.size() - 1)
 var a: int = mini(int(segment), path_points.size() - 2)
 var position: Vector2 = path_points[a].lerp(path_points[a + 1], segment - float(a))
 draw_circle(position, 7, Color("#7f3e24"))
 draw_circle(position + Vector2(0, -1), 4, Color("#ffe48b"))
 # Two small trees, drawn as original flat shapes rather than textures.
 for offset in [Vector2(-17, -16), Vector2(19, 21)]:
  var p: Vector2 = c + offset
  draw_line(p, p + Vector2(0, 9), Color("#765031"), 3.0)
  draw_circle(p, 7, Color("#38845e"))
  draw_circle(p + Vector2(-3, -2), 4, Color("#72b95f"))
