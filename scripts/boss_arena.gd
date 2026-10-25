extends RefCounted
# Lightweight elemental boss arena, generated from primitive meshes.
const PALETTE = [Color("#ff652d"), Color("#4bcbe3"), Color("#bba06b"), Color("#55c86d"), Color("#fff0a3"), Color("#8655b8"), Color("#b6ecf0"), Color("#b9eaff"), Color("#7795ff"), Color("#e452ac")]

static func decorate(parent: Node3D, biome: int, fusion: bool) -> void:
 var index: int = clampi(biome, 0, 9)
 var tint: Color = PALETTE[index]
 var arena := Node3D.new()
 arena.name = "ElementalBossArena"
 parent.add_child(arena)
 # Open ring: keeps the middle clear and avoids hiding the boss.
 var count: int = 12 if fusion else 8
 var radius: float = 4.9 if fusion else 4.3
 for i in range(count):
  var angle: float = TAU * float(i) / float(count)
  var pos := Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
  var height: float = 1.8 if fusion else 1.15
  var obelisk := VisualFactory.box(arena, Vector3(0.45, height, 0.45), pos + Vector3(0, height * 0.5, 0), tint.darkened(0.35))
  obelisk.rotation.y = angle
  if i % 2 == 0:
   var crystal := VisualFactory.sphere(arena, 0.24 if fusion else 0.17, pos + Vector3(0, height + 0.18, 0), tint.lightened(0.35))
   crystal.name = "ArenaCrystal"
 # Floor markers are thin, unlit geometry, with no collision or particles.
 for i in range(8):
  var angle: float = TAU * float(i) / 8.0
  var marker_pos := Vector3(cos(angle) * 3.15, 0.035, sin(angle) * 3.15)
  var marker := VisualFactory.box(arena, Vector3(0.75, 0.035, 0.18), marker_pos, tint)
  marker.rotation.y = -angle
