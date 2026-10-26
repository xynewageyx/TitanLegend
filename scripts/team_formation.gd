extends Node3D
signal walking_finished
const MELEE_CLASSES := [0, 1, 5, 10] # Warrior, Paladin, Rogue, Brawler
func _formation_position(slot: int) -> Vector3:
 var front_slots: Array[int] = []
 var back_slots: Array[int] = []
 for i in range(4):
  var melee: bool = role_ids[i] == 0 or (role_ids[i] == 1 and class_ids[i] in MELEE_CLASSES)
  if melee:
   front_slots.append(i)
  else:
   back_slots.append(i)
 var in_front: bool = front_slots.has(slot)
 var row: Array[int] = front_slots if in_front else back_slots
 var index_in_row: int = row.find(slot)
 # Keep compact all-melee teams inside the path, but give mixed teams
 # enough lateral room for large helmets, weapons and passive companions.
 var spacing: float = 1.7 if row.size() <= 3 else 1.35
 var x: float = (float(index_in_row) - float(row.size() - 1) / 2.0) * spacing
 return Vector3(x, 0.0, -1.7 if in_front else 1.0)
var heroes: Array[Node3D] = []
var class_ids: Array[int] = [0, 6, 4, 9]
var talent_branches: Array = [[-1,-1,-1], [-1,-1,-1], [-1,-1,-1], [-1,-1,-1]]
var talent_ranks: Array = [[0,0,0], [0,0,0], [0,0,0], [0,0,0]]
var role_ids: Array[int] = [0, 1, 1, 2] # 0 Tank, 1 DD, 2 Heiler
var pet_element_ids: Array[int] = [0, 1, 2, 3]
const ROLE_NAMES := ["Tank", "DD", "Heiler"]
const ALLOWED_ROLES := [[0,1], [0,1,2], [0,1,2], [0,1,2], [1], [1], [1], [1], [1], [1,2], [1]]
signal team_changed
const CLASS_NAMES := ["Krieger", "Paladin", "Druide", "Schamane", "Jaeger", "Schurke", "Magier", "Hexer", "Beschwoerer", "Priester", "Raufbold"]
const CLASS_COLORS := [Color("#aab6c5"), Color("#f5d16c"), Color("#4bb77d"), Color("#4ca8e8"), Color("#4f9b50"), Color("#5d567e"), Color("#5086ef"), Color("#a45cd0"), Color("#ba78db"), Color("#e9e2ae"), Color("#ba6e51")]
var walk_tween: Tween
var animation_clock: float = 0.0
var is_walking: bool = false
var attack_flash: float = 0.0
var attack_tweens: Dictionary = {}
# Update 75: tiny, temporary combat footwork; formation anchors remain fixed.
var combat_footwork: Dictionary = {}
# Update 94: track fallen heroes independently of the boss timeout cinematic.
var fallen_heroes: Dictionary = {}
# Update 96: cancel unfinished collapse tweens before restoring formation.
var defeat_tweens: Dictionary = {}
# Update 105: reusable visual team barrier; actual mitigation remains in battle_manager.
var protection_wall: Node3D
var wall_active: bool = false
var wall_clock: float = 0.0
var wall_impact: float = 0.0
var wall_shield_material: StandardMaterial3D
# Update 108: one reusable impact wave, not a new mesh per hit.
var wall_impact_wave: MeshInstance3D
var wall_wave_material: StandardMaterial3D
var wall_wave_time: float = 0.0
var wall_impact_element: int = -1
# Update 110: keep the wave readable and reset its pose between impacts.
var wall_wave_pulse: float = 0.0
# Update 115: delayed secondary ripple reuses its mesh between hits.
var wall_secondary_wave: MeshInstance3D
var wall_secondary_material: StandardMaterial3D
# Update 112: persistent edge shimmer and brief impact afterglow.
var wall_edge_mesh: MeshInstance3D
var wall_edge_material: StandardMaterial3D
# Update 113: reusable impact sparks across the protective barrier.
var wall_sparks: Array[MeshInstance3D] = []
var wall_spark_materials: Array[StandardMaterial3D] = []

func _process(delta: float) -> void:
 animation_clock += delta
 if protection_wall != null:
  wall_clock += delta
  wall_impact = maxf(0.0, wall_impact - delta * 3.5)
  protection_wall.visible = wall_active and not is_walking
  wall_wave_time = maxf(0.0, wall_wave_time - delta)
  if wall_impact_wave != null:
   wall_impact_wave.visible = protection_wall.visible and wall_wave_time > 0.0
  if wall_secondary_wave != null:
   wall_secondary_wave.visible = protection_wall.visible and wall_wave_time > 0.0 and wall_wave_time < 0.34
  if not protection_wall.visible:
   for spark in wall_sparks:
    spark.visible = false
  if protection_wall.visible:
   protection_wall.scale = Vector3(1.0 + 0.16 * wall_impact, 1.0 + 0.035 * sin(wall_clock * 5.0) + 0.20 * wall_impact, 1.0)
   protection_wall.rotation.y = 0.035 * sin(wall_clock * 2.5)
   if wall_shield_material != null:
    var impact_tint: Color = _protection_element_color(wall_impact_element)
    wall_shield_material.albedo_color = Color(lerpf(0.15, impact_tint.r, wall_impact), lerpf(0.58, impact_tint.g, wall_impact), lerpf(1.0, impact_tint.b, wall_impact), 0.28 + 0.34 * wall_impact)
   if wall_edge_mesh != null and wall_edge_material != null:
    wall_edge_mesh.scale = Vector3(1.0 + 0.025 * sin(wall_clock * 4.0), 1.0 + 0.02 * sin(wall_clock * 4.0), 1.0)
    wall_edge_material.albedo_color.a = 0.10 + 0.08 * (0.5 + 0.5 * sin(wall_clock * 5.0)) + 0.35 * wall_impact
   # A brief expanding flash highlights exactly where intercepted damage lands.
   if wall_impact_wave != null:
    if wall_impact_wave.visible:
     var phase: float = clampf(1.0 - wall_wave_time / 0.48, 0.0, 1.0)
     wall_impact_wave.scale = Vector3(0.35 + phase * 1.9, 0.35 + phase * 1.9, 0.06)
     var wave_tint: Color = _protection_element_color(wall_impact_element)
     wall_wave_material.albedo_color = Color(wave_tint.r, wave_tint.g, wave_tint.b, (1.0 - phase) * 0.48)
     if wall_secondary_wave != null and wall_secondary_wave.visible:
      var second_phase: float = clampf((0.34 - wall_wave_time) / 0.34, 0.0, 1.0)
      wall_secondary_wave.scale = Vector3(0.25 + second_phase * 1.65, 0.25 + second_phase * 1.65, 0.06)
      wall_secondary_material.albedo_color = Color(wave_tint.r, wave_tint.g, wave_tint.b, (1.0 - second_phase) * 0.30)
    # Update 114: radial spark motion synchronized with the actual shield impact.
    for spark_index in range(wall_sparks.size()):
     var spark: MeshInstance3D = wall_sparks[spark_index]
     var active_spark: bool = wall_wave_time > 0.0
     spark.visible = active_spark
     if active_spark:
      var phase_spark: float = clampf(1.0 - wall_wave_time / 0.48, 0.0, 1.0)
      var angle: float = TAU * float(spark_index) / float(wall_sparks.size())
      var spread: float = 0.20 + 1.85 * phase_spark
      spark.position = Vector3(cos(angle) * spread, sin(angle) * spread * 0.65, -0.17)
      spark.scale = Vector3.ONE * (1.0 - 0.65 * phase_spark)
      var spark_tint: Color = _protection_element_color(wall_impact_element)
      wall_spark_materials[spark_index].albedo_color = Color(spark_tint.r, spark_tint.g, spark_tint.b, 0.90 * (1.0 - phase_spark))
 for i in range(heroes.size()):
  var hero: Node3D = heroes[i]
  if not is_instance_valid(hero):
   continue
  if fallen_heroes.has(i):
   continue
  var speed: float = 10.0 if is_walking else 2.0
  var amplitude: float = 0.075 if is_walking else 0.018
  hero.position.y = sin(animation_clock * speed + float(i) * 0.8) * amplitude
  hero.rotation.z = sin(animation_clock * speed * 0.5 + float(i)) * (0.055 if is_walking else 0.012)
  if not is_walking and not attack_tweens.has(i):
   hero.position.x = _formation_position(i).x + sin(animation_clock * 1.35 + float(i) * 1.7) * 0.035
  var pet: Node3D = hero.get_node_or_null("PassivePet") as Node3D
  if pet != null:
   pet.position.y = 0.12 + sin(animation_clock * 3.4 + float(i)) * 0.15
   pet.rotation.y += delta * 0.65
 if attack_flash > 0.0:
  attack_flash = maxf(0.0, attack_flash - delta)

func play_hero_defeat(i: int) -> void:
 if i < 0 or i >= heroes.size() or fallen_heroes.has(i):
  return
 var hero: Node3D = heroes[i]
 if not is_instance_valid(hero):
  return
 fallen_heroes[i] = true
 if attack_tweens.has(i):
  var active: Tween = attack_tweens[i] as Tween
  if active != null and active.is_running():
   active.kill()
  attack_tweens.erase(i)
 var fall: Tween = create_tween()
 defeat_tweens[i] = fall
 fall.set_parallel(true)
 fall.tween_property(hero, "rotation:z", -1.30 if i % 2 == 0 else 1.30, 0.45)
 fall.tween_property(hero, "position:y", -0.48, 0.45)

func reset_individual_defeat_poses() -> void:
 for fall in defeat_tweens.values():
  if fall is Tween and fall.is_running():
   fall.kill()
 defeat_tweens.clear()
 fallen_heroes.clear()
 for i in range(heroes.size()):
  if is_instance_valid(heroes[i]):
   heroes[i].position = _formation_position(i)
   heroes[i].rotation = Vector3.ZERO

# Update 81: cinematic team defeat, purely visual; anchors are restored on retry.
func play_team_defeat() -> void:
 for i in range(heroes.size()):
  var hero: Node3D = heroes[i]
  if not is_instance_valid(hero):
   continue
  if attack_tweens.has(i):
   var active: Tween = attack_tweens[i] as Tween
   if active != null and active.is_running():
    active.kill()
  attack_tweens.erase(i)
  fallen_heroes[i] = true
  if defeat_tweens.has(i):
   var old_fall: Tween = defeat_tweens[i] as Tween
   if old_fall != null and old_fall.is_running():
    old_fall.kill()
  var motion: Node = hero.get_node_or_null("HeroCombatMotion")
  if motion != null and motion.has_method("play_hit"):
   motion.play_hit()
  var fall: Tween = create_tween()
  defeat_tweens[i] = fall
  fall.set_parallel(true)
  fall.tween_property(hero, "rotation:z", (-1.25 if i % 2 == 0 else 1.25), 0.65).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
  fall.tween_property(hero, "position:y", -0.55, 0.65).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
  fall.tween_property(hero, "position:z", _formation_position(i).z + 0.25, 0.65)

func reset_team_defeat_pose() -> void:
 for fall in defeat_tweens.values():
  if fall is Tween and fall.is_running():
   fall.kill()
 defeat_tweens.clear()
 fallen_heroes.clear()
 for i in range(heroes.size()):
  var hero: Node3D = heroes[i]
  if not is_instance_valid(hero):
   continue
  hero.position = _formation_position(i)
  hero.rotation = Vector3.ZERO

# Update 83: elemental boss impacts alter only the hit animation, not damage.
func play_elemental_hit(element: int) -> void:
 for hero in heroes:
  if not is_instance_valid(hero):
   continue
  var motion: Node = hero.get_node_or_null("HeroCombatMotion")
  if motion != null and motion.has_method("play_elemental_hit"):
   motion.play_elemental_hit(element)
  # Update 88: brief elemental aura on affected heroes.
  TitanElementStatusFX.pulse(hero, element, false)

# Only heroes standing in a warned zone visibly react to that elemental impact.
func play_elemental_hit_targets(element: int, targets: Array[int]) -> void:
 for i in targets:
  if i < 0 or i >= heroes.size():
   continue
  var hero: Node3D = heroes[i]
  if not is_instance_valid(hero):
   continue
  var motion: Node = hero.get_node_or_null("HeroCombatMotion")
  if motion != null and motion.has_method("play_elemental_hit"):
   motion.play_elemental_hit(element)

# Update 140: only heroes actually struck react; fallen heroes stay down.
func play_hit_targets(targets: Array[int], critical: bool = false) -> void:
 for index in targets:
  if index < 0 or index >= heroes.size() or fallen_heroes.has(index):
   continue
  var hero: Node3D = heroes[index]
  if not is_instance_valid(hero):
   continue
  var motion: Node = hero.get_node_or_null("HeroCombatMotion")
  if motion != null and motion.has_method("play_hit"):
   motion.play_hit(critical)

func play_dodge_targets(targets: Array[int]) -> void:
 for index in targets:
  if index < 0 or index >= heroes.size() or fallen_heroes.has(index):
   continue
  var hero: Node3D = heroes[index]
  if not is_instance_valid(hero):
   continue
  var motion: Node = hero.get_node_or_null("HeroCombatMotion")
  if motion != null and motion.has_method("play_dodge"):
   motion.play_dodge()

func play_team_hit() -> void:
 for hero in heroes:
  if not is_instance_valid(hero):
   continue
  var motion: Node = hero.get_node_or_null("HeroCombatMotion")
  if motion != null and motion.has_method("play_hit"):
   motion.play_hit()

# Update 76: staggered, role-aware footwork. Each hero returns to its anchor.
func play_attack() -> void:
 for i in range(heroes.size()):
  play_attack_for_hero(i)

func play_attack_for_hero(i: int) -> void:
 if fallen_heroes.has(i):
  return
 if i < 0 or i >= heroes.size():
  return
 var hero: Node3D = heroes[i]
 if not is_instance_valid(hero):
  return
 if attack_tweens.has(i):
  var old_tween: Tween = attack_tweens[i] as Tween
  if old_tween != null and old_tween.is_running():
   old_tween.kill()
 # Each hero has a short wind-up delay; attacks no longer look identical.
 var delay: float = float(i) * 0.075
 var role: int = role_ids[i] if i < role_ids.size() else 1
 var forward: float = 0.30 if role == 0 else 0.13 if role == 1 else 0.06
 var side: float = (-0.10 if i % 2 == 0 else 0.10) if role != 2 else 0.0
 var anchor: Vector3 = _formation_position(i)
 var tween: Tween = create_tween()
 attack_tweens[i] = tween
 tween.tween_interval(delay)
 tween.tween_property(hero, "position:x", anchor.x + side, 0.12).set_trans(Tween.TRANS_SINE)
 tween.parallel().tween_property(hero, "position:z", anchor.z - forward, 0.12).set_trans(Tween.TRANS_SINE)
 tween.parallel().tween_property(hero, "rotation:y", -side * 0.65, 0.12)
 tween.tween_property(hero, "position:x", anchor.x, 0.24).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
 tween.parallel().tween_property(hero, "position:z", anchor.z, 0.24).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
 tween.parallel().tween_property(hero, "rotation:y", 0.0, 0.24)
 tween.finished.connect(_on_attack_step_finished.bind(i))
 var motion: Node = hero.get_node_or_null("HeroCombatMotion")
 if motion != null and motion.has_method("play_attack"):
  # The body animation remains cosmetic and does not change attack timing.
  motion.play_attack()
 attack_flash = 0.3

func _on_attack_step_finished(hero_index: int) -> void:
 attack_tweens.erase(hero_index)


const COLORS = [Color("#c8d0df"), Color("#4f85d9"), Color("#a06dd8"), Color("#6bc37d")]
func _ready() -> void:
 add_to_group("talent_team")
 _load_classes()
 _load_roles()
 _load_pet_elements()
 talent_ranks = SaveManager.get_saved_talents()
 talent_branches = SaveManager.get_saved_talent_branches()
 create_team()
 ShopManager.skins_changed.connect(_apply_equipped_skins)
 _apply_equipped_skins()
 GameManager.reincarnation_performed.connect(_on_reincarnation)
 _on_reincarnation(GameManager.current_reincarnation_level)
# Element-colored impact feedback; defensive mechanics are unchanged.
func _protection_element_color(element_id: int) -> Color:
 const COLORS_BY_ELEMENT: Array[Color] = [Color("#ff743b"), Color("#4dc5ff"), Color("#bda16a"), Color("#63e48c"), Color("#ffe58c"), Color("#a77bff"), Color("#7dd9e7"), Color("#a5f1ff"), Color("#f7d64c"), Color("#ee77ff")]
 if element_id >= 0 and element_id < COLORS_BY_ELEMENT.size():
  return COLORS_BY_ELEMENT[element_id]
 return Color(0.55, 0.9, 1.0)

func play_team_protection_impact(element_id: int = -1) -> void:
 if wall_active and is_instance_valid(protection_wall):
  wall_impact_element = element_id
  wall_impact = 1.0
  wall_wave_time = 0.48
  if wall_impact_wave != null:
   wall_impact_wave.scale = Vector3(0.35, 0.35, 0.06)

func set_team_protection_wall(enabled: bool) -> void:
 wall_active = enabled
 if not enabled:
  wall_impact = 0.0
  wall_wave_time = 0.0
  wall_impact_element = -1
  if wall_impact_wave != null:
   wall_impact_wave.scale = Vector3(0.35, 0.35, 0.06)
  if wall_impact_wave != null:
   wall_impact_wave.visible = false
  for spark in wall_sparks:
   spark.visible = false
 if protection_wall == null:
  protection_wall = Node3D.new()
  protection_wall.name = "TankTeamProtectionWall"
  add_child(protection_wall)
  # A translucent blue shield between the enemy and the four heroes.
  var shield: MeshInstance3D = MeshInstance3D.new()
  var mesh: BoxMesh = BoxMesh.new()
  mesh.size = Vector3(4.7, 2.3, 0.10)
  shield.mesh = mesh
  var material: StandardMaterial3D = StandardMaterial3D.new()
  material.albedo_color = Color(0.15, 0.58, 1.0, 0.28)
  material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
  material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
  material.cull_mode = BaseMaterial3D.CULL_DISABLED
  shield.material_override = material
  wall_shield_material = material
  protection_wall.add_child(shield)
  # A subtle translucent rim pulses while group interception is active.
  wall_edge_mesh = MeshInstance3D.new()
  wall_edge_mesh.name = "ProtectionWallEdge"
  var edge_box: BoxMesh = BoxMesh.new()
  edge_box.size = Vector3(4.82, 2.42, 0.045)
  wall_edge_mesh.mesh = edge_box
  wall_edge_mesh.position.z = 0.075
  wall_edge_material = StandardMaterial3D.new()
  wall_edge_material.albedo_color = Color(0.32, 0.78, 1.0, 0.14)
  wall_edge_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
  wall_edge_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
  wall_edge_material.cull_mode = BaseMaterial3D.CULL_DISABLED
  wall_edge_mesh.material_override = wall_edge_material
  protection_wall.add_child(wall_edge_mesh)
  # Low-poly radial flash; hidden until the tank intercepts damage.
  wall_impact_wave = MeshInstance3D.new()
  wall_impact_wave.name = "ProtectionImpactWave"
  var wave_mesh: SphereMesh = SphereMesh.new()
  wave_mesh.radius = 0.65
  wave_mesh.height = 1.3
  wave_mesh.radial_segments = 12
  wave_mesh.rings = 6
  wall_impact_wave.mesh = wave_mesh
  wall_wave_material = StandardMaterial3D.new()
  wall_wave_material.albedo_color = Color(0.55, 0.9, 1.0, 0.0)
  wall_wave_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
  wall_wave_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
  wall_wave_material.cull_mode = BaseMaterial3D.CULL_DISABLED
  wall_impact_wave.material_override = wall_wave_material
  wall_impact_wave.position.z = -0.12
  wall_impact_wave.visible = false
  protection_wall.add_child(wall_impact_wave)
  wall_secondary_wave = MeshInstance3D.new()
  wall_secondary_wave.name = "ProtectionSecondaryRipple"
  wall_secondary_wave.mesh = wave_mesh
  wall_secondary_material = StandardMaterial3D.new()
  wall_secondary_material.albedo_color = Color(0.35, 0.75, 1.0, 0.0)
  wall_secondary_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
  wall_secondary_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
  wall_secondary_material.cull_mode = BaseMaterial3D.CULL_DISABLED
  wall_secondary_wave.material_override = wall_secondary_material
  wall_secondary_wave.position.z = -0.16
  wall_secondary_wave.visible = false
  protection_wall.add_child(wall_secondary_wave)
  # Eight lightweight sparks share the wall's lifetime and are reused.
  for spark_index in range(8):
   var spark: MeshInstance3D = MeshInstance3D.new()
   spark.name = "ShieldSpark" + str(spark_index)
   var spark_mesh: SphereMesh = SphereMesh.new()
   spark_mesh.radius = 0.075
   spark_mesh.height = 0.15
   spark_mesh.radial_segments = 6
   spark_mesh.rings = 3
   spark.mesh = spark_mesh
   var spark_material: StandardMaterial3D = StandardMaterial3D.new()
   spark_material.albedo_color = Color(0.55, 0.92, 1.0, 0.0)
   spark_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
   spark_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
   spark.material_override = spark_material
   spark.visible = false
   protection_wall.add_child(spark)
   wall_sparks.append(spark)
   wall_spark_materials.append(spark_material)
  protection_wall.position = Vector3(0.0, 1.15, -2.35)
 protection_wall.visible = enabled and not is_walking

func create_team() -> void:
 # Rebuild on class/role changes and remove old nodes immediately.
 for hero in heroes:
  if is_instance_valid(hero):
   if hero.get_parent() == self:
    remove_child(hero)
   hero.queue_free()
 heroes.clear()
 for i in range(4):
  var hero := Node3D.new()
  hero.name = "Hero" + str(i + 1)
  hero.position = _formation_position(i)
  add_child(hero)
  heroes.append(hero)
  # Update 168's complete character models, weapons, faces and combat motion.
  _decorate_class(hero, class_ids[i], role_ids[i], i)
  _create_hero_health_bar(hero)
  var pet := Node3D.new()
  pet.name = "PassivePet"
  # Place passive pets on the outer side of each row to avoid crowding.
  var anchor_x: float = _formation_position(i).x
  var pet_side: float = -1.0 if anchor_x < 0.0 else 1.0
  pet.position = Vector3(pet_side * 1.05, 0.0, 0.35)
  hero.add_child(pet)
  _build_pet(pet, i, CLASS_COLORS[class_ids[i]])
  DesignDetails.pet(pet, i)
  HeroWeapons47.decorate_pet(pet, class_ids[i])
 _apply_equipped_skins()
 _on_reincarnation(GameManager.current_reincarnation_level)
 team_changed.emit()
 call_deferred("_refresh_health_after_rebuild")
func _health_bar_piece(parent: Node3D, name_value: String, tint: Color, depth: float) -> MeshInstance3D:
 var piece: MeshInstance3D = MeshInstance3D.new()
 piece.name = name_value
 var mesh: QuadMesh = QuadMesh.new()
 mesh.size = Vector2(0.90, 0.12)
 piece.mesh = mesh
 var material: StandardMaterial3D = StandardMaterial3D.new()
 material.albedo_color = tint
 material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
 material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
 material.no_depth_test = true
 piece.material_override = material
 piece.position.z = depth
 parent.add_child(piece)
 return piece

func _create_hero_health_bar(hero: Node3D) -> void:
 var old: Node = hero.get_node_or_null("HeroHealthBar")
 if old != null:
  old.queue_free()
 var bar: Node3D = Node3D.new()
 bar.name = "HeroHealthBar"
 bar.position = Vector3(0.0, 2.68, 0.0)
 hero.add_child(bar)
 # Update 144: a larger, high-contrast health display for portrait screens.
 var frame: MeshInstance3D = _health_bar_piece(bar, "Frame", Color(0.02, 0.04, 0.08, 0.98), -0.012)
 (frame.mesh as QuadMesh).size = Vector2(1.10, 0.20)
 var background: MeshInstance3D = _health_bar_piece(bar, "Background", Color(0.18, 0.20, 0.24, 0.98), 0.0)
 (background.mesh as QuadMesh).size = Vector2(1.04, 0.14)
 var fill: MeshInstance3D = _health_bar_piece(bar, "Fill", Color(0.25, 0.88, 0.43), 0.018)
 (fill.mesh as QuadMesh).size = Vector2(1.04, 0.14)
 var value_label: Label3D = Label3D.new()
 value_label.name = "HPValue"
 value_label.position = Vector3(0.0, 0.19, 0.04)
 value_label.font_size = 34
 value_label.pixel_size = 0.004
 value_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
 value_label.no_depth_test = true
 value_label.modulate = Color(1.0, 1.0, 1.0, 0.98)
 value_label.outline_modulate = Color(0.02, 0.04, 0.09, 1.0)
 value_label.text = "HP"
 bar.add_child(value_label)

func update_hero_health_bars(hp_values: Array[int], max_values: Array[int]) -> void:
 for i in range(mini(heroes.size(), mini(hp_values.size(), max_values.size()))):
  var bar: Node3D = heroes[i].get_node_or_null("HeroHealthBar") as Node3D
  if bar == null:
   continue
  var fill: MeshInstance3D = bar.get_node_or_null("Fill") as MeshInstance3D
  if fill == null:
   continue
  var ratio: float = clampf(float(hp_values[i]) / float(maxi(1, max_values[i])), 0.0, 1.0)
  fill.scale.x = maxf(0.0001, ratio)
  fill.position.x = -0.52 * (1.0 - ratio)
  fill.visible = ratio > 0.0
  var hp_label: Label3D = bar.get_node_or_null("HPValue") as Label3D
  if hp_label != null:
   hp_label.text = "%d / %d" % [maxi(0, hp_values[i]), maxi(1, max_values[i])]
   hp_label.modulate = Color(1.0, 0.62, 0.62) if ratio <= 0.25 else Color.WHITE
  var material: StandardMaterial3D = fill.material_override as StandardMaterial3D
  if material != null:
   material.albedo_color = Color(0.94, 0.23, 0.20) if ratio <= 0.25 else (Color(0.97, 0.69, 0.22) if ratio <= 0.55 else Color(0.25, 0.88, 0.43))

func _build_hero(hero: Node3D, role: int, color: Color) -> void:
 # Update 66: rounded torso and articulated limbs replace the old rigid cubes.
 var torso: MeshInstance3D = VisualFactory.sphere(hero, 0.52, Vector3(0, 1.25, 0), color)
 torso.scale = Vector3(1.05, 1.38, 0.72)
 var waist: MeshInstance3D = VisualFactory.sphere(hero, 0.35, Vector3(0, 0.80, 0), color.darkened(0.16))
 waist.scale = Vector3(1.14, 0.65, 0.83)
 var head: MeshInstance3D = VisualFactory.sphere(hero, 0.29, Vector3(0, 1.94, 0), Color("#f0c3a0"))
 head.name = "HeroHead"
 # Update 121: readable facial features and layered silhouette in portrait view.
 # Reuse low-poly primitives; no texture or shader imports required on Android.
 var hair_color: Color = Color("#423329") if role == 0 else (Color("#61482e") if role == 1 else (Color("#313c34") if role == 2 else Color("#b5a16e")))
 var hair: MeshInstance3D = VisualFactory.sphere(hero, 0.295, Vector3(0, 2.075, 0.055), hair_color)
 hair.name = "HeroHair"
 hair.scale = Vector3(1.04, 0.48, 0.90)
 for eye_side in [-1.0, 1.0]:
  VisualFactory.sphere(hero, 0.042, Vector3(eye_side * 0.105, 1.97, -0.272), Color("#1e2633"))
  VisualFactory.sphere(hero, 0.055, Vector3(eye_side * 0.105, 2.035, -0.267), hair_color)
 var collar: MeshInstance3D = VisualFactory.sphere(hero, 0.29, Vector3(0, 1.65, 0), color.darkened(0.24))
 collar.scale = Vector3(1.34, 0.24, 1.0)
 for shoulder_side in [-1.0, 1.0]:
  var shoulder: MeshInstance3D = VisualFactory.sphere(hero, 0.20, Vector3(shoulder_side * 0.50, 1.58, 0), color.lightened(0.16))
  shoulder.scale = Vector3(1.15, 0.70, 1.15)
 for side in [-1.0, 1.0]:
  VisualFactory.sphere(hero, 0.19, Vector3(side * 0.47, 1.58, 0), color.darkened(0.1))
 if role == 0: # Krieger: Helm, Schild und Schwert
  VisualFactory.box(hero, Vector3(0.66, 0.22, 0.65), Vector3(0, 2.19, 0), Color("#9ea9b7"))
  VisualFactory.box(hero, Vector3(0.58, 0.75, 0.15), Vector3(-0.65, 1.2, -0.2), Color("#66798c"))
  VisualFactory.box(hero, Vector3(0.12, 1.5, 0.12), Vector3(0.73, 1.5, -0.05), Color("#e0e5eb"))
 elif role == 1: # Magier: Stab und Kristall
  VisualFactory.cylinder(hero, 2.25, 0.07, Vector3(0.66, 1.2, 0), Color("#69472c"))
  VisualFactory.sphere(hero, 0.23, Vector3(0.66, 2.45, 0), Color("#53d7ff"))
  VisualFactory.sphere(hero, 0.46, Vector3(0, 2.25, 0), Color("#344f99"))
 elif role == 2: # Jaeger: Bogen und Kocher
  VisualFactory.cylinder(hero, 1.7, 0.07, Vector3(0.67, 1.24, 0), Color("#a97542"))
  VisualFactory.box(hero, Vector3(0.32, 0.85, 0.34), Vector3(-0.44, 1.25, 0.25), Color("#4a633a"))
 elif role == 3: # Heiler: Lichtkristall und Umhang
  VisualFactory.box(hero, Vector3(0.85, 1.4, 0.12), Vector3(0, 1.0, 0.4), Color("#e8d6a1"))
  VisualFactory.sphere(hero, 0.28, Vector3(0.67, 1.52, -0.1), Color("#ffe888"))

func _build_pet(pet: Node3D, role: int, color: Color) -> void:
 VisualFactory.sphere(pet, 0.31, Vector3(0, 0.44, 0), color.lightened(0.28))
 VisualFactory.sphere(pet, 0.19, Vector3(0, 0.79, -0.08), color.lightened(0.4))
 VisualFactory.sphere(pet, 0.075, Vector3(-0.09, 0.83, -0.23), Color("#182632"))
 VisualFactory.sphere(pet, 0.075, Vector3(0.09, 0.83, -0.23), Color("#182632"))
 if role == 0:
  VisualFactory.box(pet, Vector3(0.15, 0.35, 0.14), Vector3(-0.21, 0.98, 0), Color("#e6c77e"))
  VisualFactory.box(pet, Vector3(0.15, 0.35, 0.14), Vector3(0.21, 0.98, 0), Color("#e6c77e"))
 elif role == 1:
  VisualFactory.sphere(pet, 0.16, Vector3(0, 1.07, 0), Color("#5deaff"))
 elif role == 2:
  VisualFactory.sphere(pet, 0.2, Vector3(0, 0.4, 0.38), Color("#5b8b4d"))
 else:
  VisualFactory.sphere(pet, 0.18, Vector3(0, 1.08, 0), Color("#fff4aa"))
func _on_reincarnation(level: int) -> void:
 for hero in heroes:
  if is_instance_valid(hero):
   hero.scale = Vector3.ONE * (1.0 + float(level) * 0.15)
 reset_team_defeat_pose()
func start_walking() -> void:
 if is_walking:
  return
 is_walking = true
 if walk_tween != null and walk_tween.is_running():
  walk_tween.kill()
 walk_tween = create_tween()
 # Actually advance through the world while respecting AFK cancellation.
 walk_tween.tween_property(self, "position:z", position.z - 2.0, 1.25)
 walk_tween.tween_callback(_finish_walking)

func _decorate_class(hero: Node3D, class_id: int, selected_role: int, slot: int) -> void:
 var color: Color = CLASS_COLORS[class_id]
 var base_role: int = 0
 match class_id:
  4, 5, 10: base_role = 2
  6, 7, 8: base_role = 1
  2, 3, 9: base_role = 3
 _build_hero(hero, base_role, color)
 if class_id in [0, 4, 6, 9]:
  var original_role: int = [0, 4, 6, 9].find(class_id)
  DesignDetails.hero(hero, original_role)
  HeroPolish.decorate(hero, original_role)
 ClassVisuals.decorate(hero, class_id)
 HeroDetail44.decorate(hero, class_id)
 preload("res://scripts/hero_class_silhouettes_64.gd").decorate(hero, class_id)
 preload("res://scripts/hero_faces_hands_70.gd").decorate(hero, class_id)
 preload("res://scripts/hero_class_identity_125.gd").decorate(hero, class_id)
 preload("res://scripts/hero_body_profiles_126.gd").decorate(hero, class_id)
 # Role-aware class silhouettes and individual face colors; visuals only.
 preload("res://scripts/hero_visual_upgrade.gd").decorate(hero, class_id, selected_role, slot)
 preload("res://scripts/hero_silhouette_v2.gd").decorate(hero, class_id, selected_role, slot)
 var motion: Node3D = Node3D.new()
 motion.name = "HeroCombatMotion"
 motion.set_script(preload("res://scripts/hero_combat_motion.gd"))
 hero.add_child(motion)
 motion.configure(class_id)

func set_class(slot: int, class_id: int) -> bool:
 if slot < 0 or slot >= 4 or class_id < 0 or class_id >= CLASS_NAMES.size():
  return false
 var allowed: Array = ALLOWED_ROLES[class_id]
 var role: int = role_ids[slot]
 if role not in allowed:
  var replacement: int = 1 if 1 in allowed else allowed[0]
  role_ids[slot] = replacement
 class_ids[slot] = class_id
 _enforce_single_tank()
 _save_classes()
 _save_roles()
 create_team() # create_team emits team_changed exactly once.
 return true

func _save_classes() -> void:
 var file := FileAccess.open("user://team_classes.json", FileAccess.WRITE)
 if file != null:
  file.store_string(JSON.stringify(class_ids))

func _load_classes() -> void:
 if not FileAccess.file_exists("user://team_classes.json"):
  return
 var file := FileAccess.open("user://team_classes.json", FileAccess.READ)
 if file == null:
  return
 var parsed: Variant = JSON.parse_string(file.get_as_text())
 if parsed is Array and parsed.size() == 4:
  for i in range(4):
   var candidate: int = int(parsed[i])
   if candidate >= 0 and candidate < CLASS_NAMES.size():
    class_ids[i] = candidate

# Update 165: Exactly one active tank role is allowed per team.
# Existing saves with multiple tanks are migrated to permitted non-tank roles.
func _enforce_single_tank() -> void:
 # Keep the first existing tank; never displace that player.
 var keeper: int = -1
 for i in range(4):
  if role_ids[i] == 0:
   if keeper == -1:
    keeper = i
   elif i != keeper:
    var replacement: int = 1
    if not replacement in ALLOWED_ROLES[class_ids[i]]:
     for candidate in ALLOWED_ROLES[class_ids[i]]:
      if candidate != 0:
       replacement = candidate
       break
    role_ids[i] = replacement

func set_role(slot: int, role: int) -> bool:
 if slot < 0 or slot >= 4 or role not in ALLOWED_ROLES[class_ids[slot]]:
  return false
 if role == 0:
  for i in range(4):
   if i != slot and role_ids[i] == 0:
    return false
 role_ids[slot] = role
 _save_roles()
 create_team() # create_team emits team_changed exactly once.
 return true

func has_formation_bonus() -> bool:
 return role_ids.count(0) == 1 and role_ids.count(1) == 2 and role_ids.count(2) == 1

func _save_roles() -> void:
 var file := FileAccess.open("user://team_roles.json", FileAccess.WRITE)
 if file != null:
  file.store_string(JSON.stringify(role_ids))

func _load_roles() -> void:
 if not FileAccess.file_exists("user://team_roles.json"):
  return
 var file := FileAccess.open("user://team_roles.json", FileAccess.READ)
 if file == null:
  return
 var parsed: Variant = JSON.parse_string(file.get_as_text())
 if parsed is Array and parsed.size() == 4:
  for i in range(4):
   var candidate := int(parsed[i])
   if candidate in ALLOWED_ROLES[class_ids[i]]:
    role_ids[i] = candidate
   else:
    role_ids[i] = ALLOWED_ROLES[class_ids[i]][0]
 _enforce_single_tank()

func spend_talent(slot: int, tree: int, available: int) -> bool:
 if slot < 0 or slot >= 4 or tree < 0 or tree >= 3:
  return false
 var used: int = 0
 for rank in talent_ranks[slot]:
  used += int(rank)
 if used >= available or int(talent_ranks[slot][tree]) >= TitanTalentSystem.MAX_RANK:
  return false
 talent_ranks[slot][tree] = int(talent_ranks[slot][tree]) + 1
 SaveManager.save_game()
 team_changed.emit()
 return true

func talent_total(tree: int) -> int:
 var total: int = 0
 for ranks in talent_ranks:
  total += int(ranks[tree])
 return total

func select_talent_branch(slot: int, tree: int, branch: int) -> bool:
 if slot < 0 or slot >= 4 or tree < 0 or tree >= 3 or branch < 0 or branch > 1:
  return false
 if int(talent_ranks[slot][tree]) < TitanTalentSystem.BRANCH_UNLOCK_RANK:
  return false
 if int(talent_branches[slot][tree]) == branch:
  return true
 talent_branches[slot][tree] = branch
 SaveManager.save_game()
 team_changed.emit()
 return true

# Update 23: Talentpunkte eines einzelnen Helden gegen Gold zuruecksetzen.
# Andere Helden und die Charakterstufe bleiben unveraendert.
func talent_reset_cost() -> int:
 return 500 + maxi(0, GameManager.character_level - 1) * 25

func reset_hero_talents(slot: int) -> bool:
 if slot < 0 or slot >= talent_ranks.size():
  return false
 var used: int = 0
 for value in talent_ranks[slot]:
  used += int(value)
 if used <= 0 or GameManager.current_gold < talent_reset_cost():
  return false
 GameManager.add_gold(-talent_reset_cost())
 talent_ranks[slot] = [0, 0, 0]
 talent_branches[slot] = [-1, -1, -1]
 SaveManager.save_game()
 team_changed.emit()
 return true

func _apply_equipped_skins() -> void:
 for i in range(mini(4, heroes.size())):
  var hero: Node3D = heroes[i]
  var skin_id: String = ShopManager.equipped_skins[i]
  var old: Node = hero.get_node_or_null("CosmeticSkin")
  if old != null:
   old.queue_free()
  if skin_id == "":
   continue
  var visual := Node3D.new()
  visual.name = "CosmeticSkin"
  hero.add_child(visual)
  if skin_id == "shadow_ninja":
   VisualFactory.box(visual, Vector3(0.8, 0.26, 0.66), Vector3(0, 2.20, 0), Color("#29243d"))
   VisualFactory.box(visual, Vector3(0.75, 0.17, 0.68), Vector3(0, 1.78, -0.12), Color("#4c285f"))
  elif skin_id == "light_paladin":
   VisualFactory.box(visual, Vector3(1.1, 0.25, 0.75), Vector3(0, 1.68, 0), Color("#f7d56e"))
   VisualFactory.sphere(visual, 0.18, Vector3(0, 2.38, 0), Color("#fff5bd"))

# Update 89: show the combat debuff only on heroes actually hit by its zones.
func sync_elemental_status_aura(element: int, targets: Array[int]) -> void:
 for i in range(heroes.size()):
  var hero: Node3D = heroes[i]
  if is_instance_valid(hero):
   TitanElementStatusFX.set_persistent(hero, element if i in targets else -1)

func clear_elemental_status_auras() -> void:
 var empty_targets: Array[int] = []
 sync_elemental_status_aura(-1, empty_targets)

func _load_pet_elements() -> void:
 if not FileAccess.file_exists("user://pet_elements.json"):
  return
 var file := FileAccess.open("user://pet_elements.json", FileAccess.READ)
 if file == null:
  return
 var data: Variant = JSON.parse_string(file.get_as_text())
 if data is Array and data.size() == 4:
  for i in range(4):
   pet_element_ids[i] = clampi(int(data[i]), 0, 9)

func set_pet_element(slot: int, element: int) -> void:
 if slot < 0 or slot >= 4:
  return
 pet_element_ids[slot] = clampi(element, 0, 9)
 var file := FileAccess.open("user://pet_elements.json", FileAccess.WRITE)
 if file != null:
  file.store_string(JSON.stringify(pet_element_ids))
 team_changed.emit()

func _refresh_health_after_rebuild() -> void:
 var battle: Node = get_tree().get_first_node_in_group("battle_manager")
 if battle != null and battle.has_method("_sync_team_health"):
  battle.call("_sync_team_health")

func stop_walking() -> void:
 # Beim Wechsel zwischen aktiven Bossen und AFK-Mobs darf kein alter Tween
 # spaeter ein zweites, unpassendes Encounter starten.
 if walk_tween != null and walk_tween.is_running():
  walk_tween.kill()
 is_walking = false

func _finish_walking() -> void:
 if not is_walking:
  return
 is_walking = false
 walking_finished.emit()
