extends Control
# Update 22: echte gezeichnete Talentverbindungen, Meilensteine und Zweige.
# Rein visuell: Investitionen und Speicherung verbleiben im TalentMenu.
var rank: int = 0
var selected_branch: int = -1
const MILESTONES: Array[int] = [10, 25, 50, 100]

func _ready() -> void:
 custom_minimum_size = Vector2(240, 195)
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 resized.connect(queue_redraw)

func set_progress(new_rank: int, branch: int) -> void:
 rank = maxi(0, new_rank)
 selected_branch = branch
 queue_redraw()

func _draw() -> void:
 var w: float = size.x
 var cx: float = w * 0.5
 var top: float = 22.0
 var step: float = 32.0
 var locked := Color(0.33, 0.39, 0.48, 1.0)
 var earned := Color(0.31, 0.86, 0.63, 1.0)
 var highlight := Color(1.0, 0.77, 0.27, 1.0)
 for i in range(3):
  var start := Vector2(cx, top + float(i) * step)
  var finish := Vector2(cx, top + float(i + 1) * step)
  draw_line(start, finish, earned if rank >= MILESTONES[i + 1] else locked, 5.0, true)
 for i in range(4):
  var pos := Vector2(cx, top + float(i) * step)
  var unlocked: bool = rank >= MILESTONES[i]
  draw_circle(pos, 12.0, earned if unlocked else locked)
  draw_arc(pos, 12.0, 0.0, TAU, 28, highlight if unlocked else Color(0.14, 0.18, 0.25), 2.0, true)
  draw_string(ThemeDB.fallback_font, pos + Vector2(19, 5), str(MILESTONES[i]), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
 # Pfadwahl ab Rang 25; die beiden Pfad-Schaltflaechen darunter bleiben interaktiv.
 var fork := Vector2(cx, 150.0)
 var left := Vector2(w * 0.28, 181.0)
 var right := Vector2(w * 0.72, 181.0)
 for branch in range(2):
  var dest: Vector2 = left if branch == 0 else right
  var active: bool = rank >= 25 and selected_branch == branch
  draw_line(fork, dest, highlight if active else locked, 4.0, true)
  draw_circle(dest, 9.0, highlight if active else locked)
