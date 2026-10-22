extends RefCounted
class_name TitanElementStatusFX

# Short-lived visual-only elemental auras. No status damage or crowd control.
const TINTS: Array[Color] = [
 Color("#ff642f"), Color("#35caff"), Color("#c5a06c"),
 Color("#59e68c"), Color("#fff1a1"), Color("#9964df"),
 Color("#a4fff2"), Color("#9ce7ff"), Color("#ffe74b"), Color("#ff4ed6")
]

static func pulse(target: Node3D, element_id: int, boss: bool) -> void:
 if not is_instance_valid(target) or not target.is_inside_tree():
  return
 var old: Node = target.get_node_or_null("ElementStatusVisual")
 if old != null:
  old.queue_free()
 var root := Node3D.new()
 root.name = "ElementStatusVisual"
 target.add_child(root)
 root.position.y = 2.2 if boss else 0.55
 var tint: Color = TINTS[clampi(element_id, 0, TINTS.size() - 1)]
 var size: float = 1.65 if boss else 0.55
 var duration: float = 1.15 if boss else 0.9
 var count: int = 6 if boss else 4
 for i in range(count):
  var angle: float = TAU * float(i) / float(count)
  var shard := MeshInstance3D.new()
  var mesh := BoxMesh.new()
  mesh.size = Vector3(0.14, 0.38 if element_id == 7 else 0.18, 0.14) * (1.5 if boss else 1.0)
  shard.mesh = mesh
  var mat := StandardMaterial3D.new()
  mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
  mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
  mat.albedo_color = tint
  mat.emission_enabled = true
  mat.emission = tint
  mat.emission_energy_multiplier = 1.4
  shard.material_override = mat
  root.add_child(shard)
  shard.position = Vector3(cos(angle) * size, sin(angle * 1.5) * 0.35, sin(angle) * size)
  var move := root.create_tween().set_parallel(true)
  var rise: float = 1.3 if element_id == 0 else (0.3 if element_id == 2 else 0.75)
  move.tween_property(shard, "position:y", shard.position.y + rise, duration)
  move.tween_property(mat, "albedo_color:a", 0.0, duration)
 # A thin elemental halo makes the hit status readable from the portrait camera.
 var halo := MeshInstance3D.new()
 var ring := TorusMesh.new()
 ring.inner_radius = size * 0.82
 ring.outer_radius = size * 0.94
 ring.rings = 8
 ring.ring_segments = 18
 halo.mesh = ring
 var halo_mat := StandardMaterial3D.new()
 halo_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
 halo_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
 halo_mat.albedo_color = Color(tint.r, tint.g, tint.b, 0.65)
 halo_mat.emission_enabled = true
 halo_mat.emission = tint
 halo.material_override = halo_mat
 root.add_child(halo)
 halo.position.y = -0.35 if boss else -0.25
 var halo_tween := root.create_tween().set_parallel(true)
 halo_tween.tween_property(halo, "scale", Vector3.ONE * 1.25, duration)
 halo_tween.tween_property(halo_mat, "albedo_color:a", 0.0, duration)
 # Distinct silhouettes: frost crystals, lightning sparks and rising embers.
 if element_id == 7 or element_id == 8 or element_id == 0:
  for j in range(3):
   var spark := MeshInstance3D.new()
   var spark_mesh := BoxMesh.new()
   spark_mesh.size = Vector3(0.1, 0.32 if element_id == 7 else 0.12, 0.1) * (1.7 if boss else 1.0)
   spark.mesh = spark_mesh
   var spark_mat := StandardMaterial3D.new()
   spark_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
   spark_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
   spark_mat.albedo_color = tint.lightened(0.25)
   spark.material_override = spark_mat
   root.add_child(spark)
   var a: float = TAU * float(j) / 3.0
   spark.position = Vector3(cos(a) * size * 0.7, 0.0, sin(a) * size * 0.7)
   spark.rotation.z = a if element_id == 8 else 0.0
   var spark_tween := root.create_tween().set_parallel(true)
   spark_tween.tween_property(spark, "position:y", 1.0 if element_id == 0 else 0.45, duration)
   spark_tween.tween_property(spark_mat, "albedo_color:a", 0.0, duration)
 # The parent stays lightweight and cleans itself after the pulse.
 var cleanup := root.create_tween()
 cleanup.tween_interval(duration + 0.05)
 cleanup.tween_callback(root.queue_free)

# Update 89: persistent, lightweight aura; lifecycle is owned by the combat status.
static func set_persistent(target: Node3D, element_id: int) -> void:
 if not is_instance_valid(target) or not target.is_inside_tree():
  return
 var old: Node3D = target.get_node_or_null("PersistentElementAura") as Node3D
 if element_id < 0:
  if old != null:
   old.queue_free()
  return
 if old != null:
  if int(old.get_meta("element_id", -1)) == element_id:
   return
  old.queue_free()
 var root := Node3D.new()
 root.name = "PersistentElementAura"
 root.set_meta("element_id", element_id)
 target.add_child(root)
 root.position.y = 0.65
 var tint: Color = TINTS[clampi(element_id, 0, TINTS.size() - 1)]
 # Update 90: every element has a distinct motion silhouette, not just a tint.
 var count: int = 7 if element_id in [0, 8, 9] else 5
 for i in range(count):
  var shard := MeshInstance3D.new()
  shard.name = "AuraParticle" + str(i)
  var mesh := BoxMesh.new()
  var height: float = 0.40 if element_id == 7 else (0.09 if element_id == 8 else 0.18)
  mesh.size = Vector3(0.09, height, 0.09)
  shard.mesh = mesh
  var material := StandardMaterial3D.new()
  material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
  material.albedo_color = tint
  material.emission_enabled = true
  material.emission = tint
  material.emission_energy_multiplier = 1.25
  shard.material_override = material
  root.add_child(shard)
  var angle: float = TAU * float(i) / float(count)
  var radius: float = 0.47 if element_id != 2 else 0.55
  var base: Vector3 = Vector3(cos(angle) * radius, 0.08 + float(i % 3) * 0.11, sin(angle) * radius)
  shard.position = base
  if element_id == 0: # Embers climb and reappear at the feet.
   var flame := root.create_tween().set_loops()
   flame.tween_property(shard, "position:y", base.y + 0.95, 0.85 + float(i % 3) * 0.14).set_trans(Tween.TRANS_SINE)
   flame.tween_property(shard, "position:y", base.y, 0.01)
  elif element_id == 7: # Frost shards hover slowly without spinning.
   shard.rotation.z = angle * 0.3
   var frost := root.create_tween().set_loops()
   frost.tween_property(shard, "position:y", base.y + 0.12, 1.2).set_trans(Tween.TRANS_SINE)
   frost.tween_property(shard, "position:y", base.y - 0.06, 1.2).set_trans(Tween.TRANS_SINE)
  elif element_id == 8: # Lightning jitters rapidly and irregularly.
   shard.rotation.z = angle
   var bolt := root.create_tween().set_loops()
   bolt.tween_property(shard, "position", base + Vector3(0.12, 0.28, -0.09), 0.09)
   bolt.tween_property(shard, "position", base + Vector3(-0.08, -0.05, 0.11), 0.08)
   bolt.tween_property(shard, "position", base, 0.12)
  elif element_id == 3: # Poison/nature particles creep and swirl.
   var poison := root.create_tween().set_loops()
   poison.tween_property(shard, "position:y", base.y + 0.48, 1.6).set_trans(Tween.TRANS_SINE)
   poison.tween_property(shard, "position:y", base.y, 1.3).set_trans(Tween.TRANS_SINE)
  elif element_id == 2: # Earth pieces bob heavily, almost grounded.
   var earth := root.create_tween().set_loops()
   earth.tween_property(shard, "position:y", base.y + 0.08, 0.8)
   earth.tween_property(shard, "position:y", base.y, 0.18)
  elif element_id == 9: # Chaos fragments dart out and snap back.
   var chaos := root.create_tween().set_loops()
   chaos.tween_property(shard, "position", base * 1.35 + Vector3(0, 0.32, 0), 0.25)
   chaos.tween_property(shard, "position", base, 0.18)
  else: # Water, light, shadow and wind: smooth drifting motes.
   var drift := root.create_tween().set_loops()
   drift.tween_property(shard, "position:y", base.y + 0.3, 0.9).set_trans(Tween.TRANS_SINE)
   drift.tween_property(shard, "position:y", base.y, 0.9).set_trans(Tween.TRANS_SINE)
 # Rotation is intentionally disabled for ice and earth to preserve their weight.
 if element_id not in [2, 7]:
  var spin := root.create_tween().set_loops()
  var speed: float = 5.0 if element_id == 3 else (1.6 if element_id == 8 else 3.5)
  spin.tween_property(root, "rotation:y", TAU, speed).from(0.0)
