extends Node3D
# Temporary compatibility implementation for Update 168.
# Replaces missing team_formation.gd; still requires a full original import.
signal walking_finished
signal team_changed

const CLASS_NAMES := ["Krieger", "Paladin", "Druide", "Schamane", "Jaeger", "Schurke", "Magier", "Hexer", "Beschwoerer", "Priester", "Raufbold"]
const CLASS_COLORS := [Color("#aab6c5"), Color("#f5d16c"), Color("#4bb77d"), Color("#4ca8e8"), Color("#4f9b50"), Color("#5d567e"), Color("#5086ef"), Color("#a45cd0"), Color("#ba78db"), Color("#e9e2ae"), Color("#ba6e51")]
const ROLE_NAMES := ["Tank", "DD", "Heiler"]
const ALLOWED_ROLES := [[0,1], [0,1,2], [0,1,2], [0,1,2], [1], [1], [1], [1], [1], [1,2], [1]]
# Deterministic rows: tanks and melee damage dealers in front; the rest behind.
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
 var spacing: float = 1.25
 var x: float = (float(index_in_row) - float(row.size() - 1) / 2.0) * spacing
 return Vector3(x, 0.0, -1.7 if in_front else 1.0)

var class_ids: Array[int] = [0, 6, 4, 9]
var role_ids: Array[int] = [0, 1, 1, 2]
var pet_element_ids: Array[int] = [0, 1, 2, 3]
var talent_ranks: Array = [[0,0,0], [0,0,0], [0,0,0], [0,0,0]]
var talent_branches: Array = [[-1,-1,-1], [-1,-1,-1], [-1,-1,-1], [-1,-1,-1]]
var heroes: Array[Node3D] = []
var is_walking: bool = false
var animation_clock: float = 0.0
var fallen_heroes: Dictionary = {}
var defeat_tweens: Dictionary = {}
var attack_tweens: Dictionary = {}
var walk_tween: Tween
var protection_wall: Node3D
var wall_active: bool = false

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

func _process(delta: float) -> void:
 animation_clock += delta
 if protection_wall != null:
  protection_wall.visible = wall_active and not is_walking
 for i in range(heroes.size()):
  var hero: Node3D = heroes[i]
  if not is_instance_valid(hero) or fallen_heroes.has(i):
   continue
  if is_walking:
   hero.position.y = 0.07 * sin(animation_clock * 10.0 + float(i))
  else:
   hero.position.y = 0.018 * sin(animation_clock * 2.0 + float(i))
  var pet: Node3D = hero.get_node_or_null("PassivePet") as Node3D
  if pet != null:
   pet.position.y = 0.12 + 0.1 * sin(animation_clock * 3.0 + float(i))

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

func create_team() -> void:
 for hero in heroes:
  if is_instance_valid(hero):
   # Detach immediately so replacement heroes can keep stable Hero1..Hero4 names.
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
  _build_hero(hero, role_ids[i], CLASS_COLORS[class_ids[i]])
  _decorate_class(hero, class_ids[i])
  _create_hero_health_bar(hero)
  var pet := Node3D.new()
  pet.name = "PassivePet"
  pet.position = Vector3(0.76, 0.1, 0.12)
  hero.add_child(pet)
  _build_pet(pet, role_ids[i], CLASS_COLORS[class_ids[i]])
 team_changed.emit()
 call_deferred("_refresh_health_after_rebuild")

func _refresh_health_after_rebuild() -> void:
 var battle: Node = get_tree().get_first_node_in_group("battle_manager")
 if battle != null and battle.has_method("_sync_team_health"):
  battle.call("_sync_team_health")

func _build_hero(hero: Node3D, role: int, tint: Color) -> void:
 VisualFactory.sphere(hero, 0.37, Vector3(0, 1.85, 0), Color("#d5a17b"))
 VisualFactory.box(hero, Vector3(0.85, 1.1, 0.55), Vector3(0, 1.05, 0), tint)
 for side in [-1.0, 1.0]:
  VisualFactory.cylinder(hero, 0.65, 0.16, Vector3(side * 0.24, 0.35, 0), tint.darkened(0.3))
  VisualFactory.cylinder(hero, 0.55, 0.15, Vector3(side * 0.51, 1.3, 0), tint)
 var motion := Node3D.new()
 motion.name = "HeroCombatMotion"
 motion.set_script(load("res://scripts/hero_combat_motion.gd"))
 hero.add_child(motion)
 motion.call("configure", class_ids[heroes.find(hero)])

func _build_pet(pet: Node3D, role: int, color: Color) -> void:
 VisualFactory.sphere(pet, 0.26, Vector3(0, 0.42, 0), color.lightened(0.25))
 VisualFactory.sphere(pet, 0.19, Vector3(0, 0.75, -0.08), color)
 # Pets are passive: no damage, cooldown, attack or skill component.

func _decorate_class(hero: Node3D, class_id: int) -> void:
 preload("res://scripts/hero_class_silhouettes_64.gd").decorate(hero, class_id)

func start_walking() -> void:
 if is_walking:
  return
 is_walking = true
 if walk_tween != null and walk_tween.is_running():
  walk_tween.kill()
 walk_tween = create_tween()
 walk_tween.tween_interval(1.25)
 walk_tween.tween_callback(_finish_walking)

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

func play_attack() -> void:
 for i in range(heroes.size()):
  play_attack_for_hero(i)

func play_attack_for_hero(i: int) -> void:
 if i < 0 or i >= heroes.size() or fallen_heroes.has(i):
  return
 var motion: Node = heroes[i].get_node_or_null("HeroCombatMotion")
 if motion != null and motion.has_method("play_attack"):
  motion.play_attack()

func play_hit_targets(targets: Array[int], critical: bool = false) -> void:
 for i in targets:
  if i < 0 or i >= heroes.size() or fallen_heroes.has(i):
   continue
  var motion: Node = heroes[i].get_node_or_null("HeroCombatMotion")
  if motion != null:
   motion.play_hit(critical)

func play_dodge_targets(targets: Array[int]) -> void:
 for i in targets:
  if i < 0 or i >= heroes.size() or fallen_heroes.has(i):
   continue
  var motion: Node = heroes[i].get_node_or_null("HeroCombatMotion")
  if motion != null:
   motion.play_dodge()

func play_elemental_hit(element: int) -> void:
 for i in range(heroes.size()):
  play_elemental_hit_targets(element, [i])

func play_elemental_hit_targets(element: int, targets: Array[int]) -> void:
 for i in targets:
  if i < 0 or i >= heroes.size():
   continue
  var motion: Node = heroes[i].get_node_or_null("HeroCombatMotion")
  if motion != null:
   motion.play_elemental_hit(element)

func play_team_hit() -> void:
 for i in range(heroes.size()):
  play_hit_targets([i])

func play_hero_defeat(i: int) -> void:
 if i < 0 or i >= heroes.size() or fallen_heroes.has(i):
  return
 fallen_heroes[i] = true
 var hero: Node3D = heroes[i]
 var tween := create_tween().set_parallel(true)
 defeat_tweens[i] = tween
 tween.tween_property(hero, "rotation:z", 1.2 if i % 2 else -1.2, 0.4)
 tween.tween_property(hero, "position:y", -0.5, 0.4)

func play_team_defeat() -> void:
 for i in range(heroes.size()):
  play_hero_defeat(i)

func reset_individual_defeat_poses() -> void:
 reset_team_defeat_pose()

func reset_team_defeat_pose() -> void:
 for tween in defeat_tweens.values():
  if tween is Tween and tween.is_running():
   tween.kill()
 defeat_tweens.clear()
 fallen_heroes.clear()
 for i in range(heroes.size()):
  if is_instance_valid(heroes[i]):
   heroes[i].position = _formation_position(i)
   heroes[i].rotation = Vector3.ZERO

func set_team_protection_wall(enabled: bool) -> void:
 wall_active = enabled
 if protection_wall == null:
  protection_wall = Node3D.new()
  protection_wall.name = "TankTeamProtectionWall"
  add_child(protection_wall)
  protection_wall.position = Vector3(0, 1.3, -2.1)
  var mesh := BoxMesh.new()
  mesh.size = Vector3(4.8, 2.4, 0.1)
  var wall := MeshInstance3D.new()
  wall.mesh = mesh
  var material := StandardMaterial3D.new()
  material.albedo_color = Color(0.15, 0.58, 1.0, 0.25)
  material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
  material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
  wall.material_override = material
  protection_wall.add_child(wall)
 protection_wall.visible = wall_active

func play_team_protection_impact(_element_id: int = -1) -> void:
 if wall_active and protection_wall != null:
  var tween := create_tween()
  tween.tween_property(protection_wall, "scale", Vector3(1.1, 1.12, 1.0), 0.12)
  tween.tween_property(protection_wall, "scale", Vector3.ONE, 0.2)

func _health_bar_piece(parent: Node3D, piece_name: String, tint: Color, depth: float) -> MeshInstance3D:
 var piece := MeshInstance3D.new()
 piece.name = piece_name
 var mesh := QuadMesh.new()
 mesh.size = Vector2(1.04, 0.14)
 piece.mesh = mesh
 var material := StandardMaterial3D.new()
 material.albedo_color = tint
 material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
 material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
 material.no_depth_test = true
 piece.material_override = material
 piece.position.z = depth
 parent.add_child(piece)
 return piece

func _create_hero_health_bar(hero: Node3D) -> void:
 var bar := Node3D.new()
 bar.name = "HeroHealthBar"
 bar.position = Vector3(0.0, 2.68, 0.0)
 hero.add_child(bar)
 var frame: MeshInstance3D = _health_bar_piece(bar, "Frame", Color(0.02, 0.04, 0.08, 0.98), -0.012)
 (frame.mesh as QuadMesh).size = Vector2(1.10, 0.20)
 _health_bar_piece(bar, "Background", Color(0.18, 0.20, 0.24, 0.98), 0.0)
 _health_bar_piece(bar, "Fill", Color(0.25, 0.88, 0.43), 0.018)
 var value_label := Label3D.new()
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

func _enforce_single_tank() -> void:
 # Keep the FIRST active tank. Never replace another player's tank choice.
 var keeper: int = -1
 for i in range(4):
  if role_ids[i] != 0:
   continue
  if keeper == -1:
   keeper = i
  else:
   role_ids[i] = 1 if 1 in ALLOWED_ROLES[class_ids[i]] else 2

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
 var data: Variant = JSON.parse_string(file.get_as_text())
 if data is Array and data.size() == 4:
  for i in range(4):
   class_ids[i] = clampi(int(data[i]), 0, CLASS_NAMES.size() - 1)

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
 var data: Variant = JSON.parse_string(file.get_as_text())
 if data is Array and data.size() == 4:
  for i in range(4):
   var candidate: int = int(data[i])
   role_ids[i] = candidate if candidate in ALLOWED_ROLES[class_ids[i]] else ALLOWED_ROLES[class_ids[i]][0]
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
 var result: int = 0
 for ranks in talent_ranks:
  result += int(ranks[tree])
 return result

func select_talent_branch(slot: int, tree: int, branch: int) -> bool:
 if slot < 0 or slot >= 4 or tree < 0 or tree >= 3 or branch < 0 or branch > 1:
  return false
 if int(talent_ranks[slot][tree]) < TitanTalentSystem.BRANCH_UNLOCK_RANK:
  return false
 talent_branches[slot][tree] = branch
 SaveManager.save_game()
 team_changed.emit()
 return true

func talent_reset_cost() -> int:
 return 500 + maxi(0, GameManager.character_level - 1) * 25

func reset_hero_talents(slot: int) -> bool:
 if slot < 0 or slot >= talent_ranks.size():
  return false
 var used: int = 0
 for rank in talent_ranks[slot]:
  used += int(rank)
 if used == 0 or GameManager.current_gold < talent_reset_cost():
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
  var old: Node = hero.get_node_or_null("CosmeticSkin")
  if old != null:
   old.queue_free()
  var skin_id: String = str(ShopManager.equipped_skins[i])
  if skin_id == "":
   continue
  var cosmetics := Node3D.new()
  cosmetics.name = "CosmeticSkin"
  hero.add_child(cosmetics)
  if skin_id == "shadow_ninja":
   VisualFactory.box(cosmetics, Vector3(0.8, 0.26, 0.66), Vector3(0, 2.20, 0), Color("#29243d"))
  elif skin_id == "light_paladin":
   VisualFactory.sphere(cosmetics, 0.2, Vector3(0, 2.38, 0), Color("#fff5bd"))

func sync_elemental_status_aura(element: int, targets: Array[int]) -> void:
 for i in range(heroes.size()):
  if is_instance_valid(heroes[i]):
   TitanElementStatusFX.set_persistent(heroes[i], element if i in targets else -1)

func clear_elemental_status_auras() -> void:
 sync_elemental_status_aura(-1, [])

func _on_reincarnation(_level: int) -> void:
 reset_team_defeat_pose()
