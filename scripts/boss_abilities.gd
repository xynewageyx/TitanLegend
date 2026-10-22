class_name BossAbilities
extends RefCounted

# Lightweight, procedural elemental attacks for Android. Damage stays in BattleManager.
static func strike(parent: Node3D, boss: Node3D, team: Node3D, element: int, fusion: bool) -> void:
 if not is_instance_valid(parent) or not is_instance_valid(boss) or not is_instance_valid(team):
  return
 var palette: Array[Color] = [Color.ORANGE_RED, Color.DODGER_BLUE, Color.SANDY_BROWN, Color.LIME_GREEN, Color.GOLD, Color.MEDIUM_PURPLE, Color.SKY_BLUE, Color.LIGHT_CYAN, Color.YELLOW, Color.MAGENTA]
 var tint: Color = palette[clampi(element, 0, palette.size() - 1)]
 var start: Vector3 = boss.global_position + Vector3(0, 3.0, 0)
 var end: Vector3 = team.global_position + Vector3(0, 1.0, 0)
 var duration: float = 0.36 if fusion else 0.48
 # Update 84: distinctive floor telegraphs for each element. Purely visual;
 # hit resolution and damage remain owned by BattleManager.
 # Floor telegraphs are now displayed during the cast wind-up.
 # Element-specific attack patterns: all effects are cosmetic, with damage handled by BattleManager.
 match element:
  0: # Fire: a rolling row of flame orbs
   for i in range(5 if fusion else 3):
    var spread: float = float(i - (2 if fusion else 1)) * 0.7
    _projectile(parent, start + Vector3(spread, 0, 0), end + Vector3(spread, 0, 0), tint, duration + 0.08 * i, 0.35, 0.12 * i, Vector3.ONE)
  1: # Water: two arcing droplets
   for i in range(3 if fusion else 2):
    _projectile(parent, start + Vector3(i * 0.35, 0, 0), end, tint, duration + 0.12, 0.34, i * 0.13, Vector3(0.8, 1.3, 0.8))
  2: # Earth: heavy slow boulder
   _projectile(parent, start, end, tint, duration * 1.4, 0.85, 0.0, Vector3(1.5, 1.0, 1.5))
  3: # Nature: seed volley
   for i in range(5 if fusion else 3):
    var spread: float = float(i - (2 if fusion else 1)) * 0.65
    _projectile(parent, start, end + Vector3(spread, 0, 0), tint, duration, 0.25, i * 0.08, Vector3(0.7, 1.3, 0.7))
  4: # Light: bright descending beam
   _projectile(parent, end + Vector3(0, 7, 0), end, tint, 0.2, 0.7, 0.2, Vector3(0.55, 2.6, 0.55))
  5: # Shadow: staggered dark bolts
   for i in range(4 if fusion else 2):
    _projectile(parent, start + Vector3((i % 2) * 0.6, 0, 0), end, tint, duration * 0.8, 0.38, i * 0.11, Vector3(0.75, 1.1, 0.75))
  6: # Wind: multiple fast gusts
   for i in range(4 if fusion else 3):
    _projectile(parent, start, end + Vector3((i - 1) * 0.5, 0, 0), tint, duration * 0.65, 0.28, i * 0.08, Vector3(1.6, 0.45, 0.8))
  7: # Ice: falling crystal spears
   for i in range(5 if fusion else 3):
    var spread: float = float(i - (2 if fusion else 1)) * 0.6
    _projectile(parent, end + Vector3(spread, 6, 0), end + Vector3(spread, 0, 0), tint, 0.34, 0.38, 0.1 * i, Vector3(0.55, 2.2, 0.55))
  8: # Lightning: a quick forked strike
   for i in range(5 if fusion else 3):
    var spread: float = float(i - (2 if fusion else 1)) * 0.55
    _projectile(parent, end + Vector3(spread, 6, 0), end + Vector3(spread * 0.4, 0, 0), tint, 0.12, 0.3, 0.08 * i, Vector3(0.45, 2.4, 0.45))
  _: # Chaos: alternating multicolored orbs
   for i in range(6 if fusion else 4):
    var chaos_tint: Color = tint.lerp(Color.CYAN if i % 2 == 0 else Color.RED, 0.55)
    _projectile(parent, start + Vector3(sin(float(i)) * 1.1, 0, 0), end, chaos_tint, duration, 0.35, 0.09 * i, Vector3.ONE)

# Flat, emissive primitive shapes: cheap to render on Android and no collision.
# Update 85: the exact same geometry drives visible warnings and hit resolution.
static func warn(parent: Node3D, team: Node3D, element: int, fusion: bool) -> void:
 if not is_instance_valid(parent) or not is_instance_valid(team):
  return
 var palette: Array[Color] = [Color.ORANGE_RED, Color.DODGER_BLUE, Color.SANDY_BROWN, Color.LIME_GREEN, Color.GOLD, Color.MEDIUM_PURPLE, Color.SKY_BLUE, Color.LIGHT_CYAN, Color.YELLOW, Color.MAGENTA]
 _floor_telegraph(parent, team.global_position + Vector3(0, 1, 0), palette[clampi(element, 0, 9)], element, fusion)

static func affected_heroes(team: Node3D, element: int, fusion: bool) -> Array[int]:
 var affected: Array[int] = []
 if not is_instance_valid(team):
  return affected
 var hero_nodes: Array = team.get("heroes")
 var shapes: Array[Vector3] = _zone_shapes(element, fusion)
 for i in range(hero_nodes.size()):
  var hero: Node3D = hero_nodes[i] as Node3D
  if not is_instance_valid(hero):
   continue
  var relative: Vector3 = hero.global_position - team.global_position
  for zone in shapes:
   # Vector3 stores center X, half width, half depth; Z center is zero.
   if absf(relative.x - zone.x) <= zone.y and absf(relative.z) <= zone.z:
    affected.append(i)
    break
 return affected

static func _zone_shapes(element: int, fusion: bool) -> Array[Vector3]:
 var count: int = 1
 var width: float = 1.25
 var depth: float = 1.25
 match element:
  0: count = 3; width = 0.65; depth = 2.7
  1: count = 3; width = 1.15; depth = 1.15
  2: width = 3.2; depth = 2.3
  3: count = 4; width = 0.75; depth = 1.6
  4: width = 1.05; depth = 1.05
  5: count = 2; width = 1.45; depth = 1.5
  6: count = 3; width = 0.35; depth = 3.5
  7: count = 3; width = 0.45; depth = 2.4
  8: count = 4; width = 0.55; depth = 0.55
  9: count = 4; width = 0.7; depth = 2.2
 var mult: float = 1.3 if fusion else 1.0
 var shapes: Array[Vector3] = []
 for i in range(count):
  var x: float = (float(i) - float(count - 1) * 0.5) * (1.15 if element == 8 else 0.95)
  shapes.append(Vector3(x, width * mult * 0.5, depth * mult * 0.5))
 return shapes

static func _floor_telegraph(parent: Node3D, center: Vector3, tint: Color, element: int, fusion: bool) -> void:
 var count: int = 1
 var width: float = 1.25
 var depth: float = 1.25
 match element:
  0: # Fire: three advancing lanes
   count = 3
   width = 0.65
   depth = 2.7
  1: # Water: concentric pools
   count = 3
   width = 1.15
   depth = 1.15
  2: # Earth: broad impact slab
   width = 3.2
   depth = 2.3
  3: # Nature: root patches
   count = 4
   width = 0.75
   depth = 1.6
  4: # Light: focused pillar marker
   width = 1.05
   depth = 1.05
  5: # Shadow: twin dark zones
   count = 2
   width = 1.45
   depth = 1.5
  6: # Wind: long sweeping lanes
   count = 3
   width = 0.35
   depth = 3.5
  7: # Ice: sharp crystal lanes
   count = 3
   width = 0.45
   depth = 2.4
  8: # Lightning: scattered strike points
   count = 4
   width = 0.55
   depth = 0.55
  9: # Chaos: unstable cross pattern
   count = 4
   width = 0.7
   depth = 2.2
 var mult: float = 1.3 if fusion else 1.0
 for i in range(count):
  var marker := MeshInstance3D.new()
  var mesh := CylinderMesh.new()
  mesh.top_radius = 0.5
  mesh.bottom_radius = 0.5
  mesh.height = 0.025
  mesh.radial_segments = 20 if element in [1, 4, 8] else 4
  marker.mesh = mesh
  var material := StandardMaterial3D.new()
  material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
  material.albedo_color = Color(tint.r, tint.g, tint.b, 0.42)
  material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
  material.emission_enabled = true
  material.emission = tint
  material.emission_energy_multiplier = 0.75
  material.no_depth_test = false
  marker.material_override = material
  parent.add_child(marker)
  var offset := Vector3.ZERO
  if count > 1:
   offset.x = (float(i) - float(count - 1) * 0.5) * (0.95 if element != 8 else 1.15)
  marker.global_position = Vector3(center.x + offset.x, 0.075, center.z + offset.z)
  marker.scale = Vector3(0.05, 1.0, 0.05)
  var target := Vector3(width * mult, 1.0, depth * mult)
  var tween := parent.create_tween()
  tween.tween_property(marker, "scale", target, 0.28).set_trans(Tween.TRANS_SINE)
  tween.tween_interval(0.22)
  tween.tween_property(marker, "scale", Vector3(0.01, 1.0, 0.01), 0.16)
  tween.tween_callback(marker.queue_free)

static func _projectile(parent: Node3D, start: Vector3, target: Vector3, tint: Color, duration: float, radius: float, delay: float, shape: Vector3) -> void:
 var projectile := _orb(parent, tint, radius)
 projectile.global_position = start
 projectile.scale = shape
 var tween := parent.create_tween()
 tween.tween_interval(0.23 + delay)
 tween.tween_property(projectile, "global_position", target, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
 tween.tween_callback(func() -> void: _impact(parent, target, tint, false))
 tween.tween_callback(projectile.queue_free)

static func _orb(parent: Node3D, tint: Color, radius: float) -> MeshInstance3D:
 var node := MeshInstance3D.new()
 var mesh := SphereMesh.new()
 mesh.radius = radius
 mesh.height = radius * 2.0
 mesh.radial_segments = 10
 mesh.rings = 5
 node.mesh = mesh
 var mat := StandardMaterial3D.new()
 mat.albedo_color = tint
 mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
 mat.emission_enabled = true
 mat.emission = tint
 mat.emission_energy_multiplier = 1.8
 mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
 node.material_override = mat
 parent.add_child(node)
 return node

static func _impact(parent: Node3D, at: Vector3, tint: Color, fusion: bool) -> void:
 if not is_instance_valid(parent) or not parent.is_inside_tree():
  return
 var burst := _orb(parent, tint, 0.7)
 burst.global_position = at
 var t := parent.create_tween()
 t.set_parallel(true)
 t.tween_property(burst, "scale", Vector3.ONE * (3.2 if fusion else 2.2), 0.25)
 t.tween_property(burst, "scale", Vector3.ONE * 0.01, 0.25).set_delay(0.25)
 t.set_parallel(false)
 t.tween_callback(burst.queue_free)
 # Four short radial sparks, no particles or textures.
 for i in range(4):
  var spark := _orb(parent, tint.lightened(0.35), 0.13)
  spark.global_position = at
  var angle: float = float(i) * TAU / 4.0
  var offset := Vector3(cos(angle), 0.25, sin(angle)) * (2.3 if fusion else 1.5)
  var s := parent.create_tween()
  s.set_parallel(true)
  s.tween_property(spark, "global_position", at + offset, 0.3)
  s.tween_property(spark, "scale", Vector3.ONE * 0.01, 0.3).set_delay(0.3)
  s.set_parallel(false)
  s.tween_callback(spark.queue_free)
