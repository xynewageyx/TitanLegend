extends Node3D
# TEMPORARY compatibility implementation.
# Original Update 168 battle_manager.gd (36,410 bytes) must replace this file.
signal battle_status_changed

@export var team_formation: Node3D
@export var biome_manager: Node3D
@export var enemy_spawn_node: Node3D

const BOSS_TIME_LIMIT: float = 60.0
const ROLE_ATTACK_INTERVALS: Array[float] = [1.25, 0.75, 1.5]
const WAVE_ENEMY_COUNTS: Array[int] = [2, 5, 7]
var astral_active: bool = false
var astral_floor: int = 1
var astral_marks: int = 0
var world_progress: Vector2i = Vector2i(1, 1)
var current_level: int = 1
var current_wave: int = 1
var enemy_hp: int = 0
var enemy_max_hp: int = 0
var enemies_remaining: int = 0
var battle_active: bool = false
var is_boss: bool = false
var is_fusion_boss: bool = false
var enemy_visuals: Array[Node3D] = []
var attack_timer: Timer
var hero_attack_elapsed: Array[float] = [0.0, 0.0, 0.0, 0.0]
var boss_elapsed: float = 0.0
var boss_time_remaining: float = BOSS_TIME_LIMIT
var enemy_animation_time: float = 0.0
var team_hp: int = 1200
var team_max_hp: int = 1200
var hero_max_hp: Array[int] = [300, 300, 300, 300]
var hero_hp: Array[int] = [300, 300, 300, 300]
var last_boss_targets: Array[int] = []
var tank_taunt_until: Array[int] = [0, 0, 0, 0]
var tank_intercept_until: Array[int] = [0, 0, 0, 0]
var defeat_reason: String = ""
var hero_popup_counter: int = 0
var skill_tick: int = 0
var team_element_status: int = -1
var team_status_until_tick: int = 0
var boss_cast_ticks: int = 0
var boss_cast_name: String = ""
var boss_interrupt_message: String = ""
var last_ability: String = ""
var skill_loadouts: Array = [[0,0,0,0], [0,0,0,0], [0,0,0,0], [0,0,0,0]]
var skill_choices: Array[int] = [0, 0, 0, 0]
var _enemy_attack_elapsed: float = 0.0
var _wave_hp_pool: int = 0
var _finishing: bool = false

func _ready() -> void:
 if team_formation != null and team_formation.has_signal("walking_finished"):
  team_formation.walking_finished.connect(_on_walking_finished)
 current_level = 1 # Progress restoration remains part of the original importer
 _reset_hero_health()
 call_deferred("start_next_encounter")

func _process(delta: float) -> void:
 if not battle_active:
  return
 enemy_animation_time += delta
 if is_boss:
  boss_elapsed += delta
  boss_time_remaining = maxf(0.0, BOSS_TIME_LIMIT - boss_elapsed)
  if boss_time_remaining <= 0.0:
   _boss_time_expired()
   return
 _enemy_attack_elapsed += delta
 if _enemy_attack_elapsed >= 2.2:
  _enemy_attack_elapsed = 0.0
  _attack_tick()
 for slot in range(4):
  if hero_hp[slot] <= 0:
   continue
  hero_attack_elapsed[slot] += delta
  var role: int = 1
  if team_formation != null:
   role = clampi(int(team_formation.role_ids[slot]), 0, 2)
  if hero_attack_elapsed[slot] >= ROLE_ATTACK_INTERVALS[role]:
   hero_attack_elapsed[slot] = 0.0
   _hero_attack(slot, role)

func _sync_team_health() -> void:
 team_hp = 0
 team_max_hp = 0
 for i in range(4):
  team_hp += hero_hp[i]
  team_max_hp += hero_max_hp[i]
 if team_formation != null and team_formation.has_method("update_hero_health_bars"):
  team_formation.update_hero_health_bars(hero_hp, hero_max_hp)
 battle_status_changed.emit()

func _reset_hero_health() -> void:
 for i in range(4):
  hero_hp[i] = hero_max_hp[i]
 tank_taunt_until.fill(0)
 tank_intercept_until.fill(0)
 team_element_status = -1
 if team_formation != null and team_formation.has_method("reset_individual_defeat_poses"):
  team_formation.reset_individual_defeat_poses()
 _sync_team_health()

func _living_tank_slot() -> int:
 if team_formation == null:
  return -1
 for i in range(mini(4, team_formation.role_ids.size())):
  if int(team_formation.role_ids[i]) == 0 and hero_hp[i] > 0:
   return i
 return -1

func _choose_routine_enemy_target() -> int:
 var survivors: Array[int] = []
 var active_tank: int = _living_tank_slot()
 for index in range(mini(4, hero_hp.size())):
  if hero_hp[index] > 0:
   survivors.append(index)
 if survivors.is_empty():
  return -1
 if active_tank >= 0:
  if tank_taunt_until[active_tank] > 0 and tank_taunt_until[active_tank] >= skill_tick:
   return active_tank
  if survivors.size() == 1 or randf() < 0.65:
   return active_tank
  survivors.erase(active_tank)
 return survivors[randi_range(0, survivors.size() - 1)]
func _hero_dodge_chance(index: int) -> float:
 if index < 0 or index >= 4:
  return 0.0
 return 0.04

func _hero_dodges(index: int) -> bool:
 return randf() < _hero_dodge_chance(index)

func _show_hero_combat_number(_slot: int, _value: int, _is_heal: bool) -> void:
 # No damage popup can be shown without the original FloatingText scene.
 pass

func _damage_heroes(amount: int, targets: Array[int]) -> void:
 var hits: Array[int] = []
 var dodges: Array[int] = []
 for index in targets:
  if index < 0 or index >= 4 or hero_hp[index] <= 0:
   continue
  if _hero_dodges(index):
   dodges.append(index)
   continue
  var mitigation: float = 0.30 if index == _living_tank_slot() else 0.05
  var damage: int = maxi(1, roundi(float(amount) * (1.0 - mitigation)))
  var previous: int = hero_hp[index]
  hero_hp[index] = maxi(0, previous - damage)
  _show_hero_combat_number(index, previous - hero_hp[index], false)
  hits.append(index)
  if hero_hp[index] == 0 and team_formation != null:
   team_formation.play_hero_defeat(index)
 if team_formation != null:
  team_formation.play_hit_targets(hits)
  team_formation.play_dodge_targets(dodges)
 _sync_team_health()
 if team_hp <= 0:
  _on_team_defeat("normal")

func _heal_heroes(amount: int, group_heal: bool = false) -> void:
 if amount <= 0:
  return
 if group_heal:
  for i in range(4):
   if hero_hp[i] > 0:
    var previous: int = hero_hp[i]
    hero_hp[i] = mini(hero_max_hp[i], hero_hp[i] + maxi(1, roundi(float(amount) / 4.0)))
    _show_hero_combat_number(i, hero_hp[i] - previous, true)
 else:
  var target: int = -1
  var lowest: float = 2.0
  for i in range(4):
   if hero_hp[i] > 0:
    var ratio: float = float(hero_hp[i]) / float(maxi(1, hero_max_hp[i]))
    if ratio < lowest:
     lowest = ratio
     target = i
  if target >= 0:
   var previous: int = hero_hp[target]
   hero_hp[target] = mini(hero_max_hp[target], hero_hp[target] + amount)
   _show_hero_combat_number(target, hero_hp[target] - previous, true)
 _sync_team_health()

func _refresh_tank_defense_visuals() -> void:
 if team_formation == null:
  return
 var slot: int = _living_tank_slot()
 var active: bool = slot >= 0 and tank_intercept_until[slot] > skill_tick
 team_formation.set_team_protection_wall(active)

func _attack_tick() -> void:
 if not battle_active:
  return
 skill_tick += 1
 var target: int = _choose_routine_enemy_target()
 if target < 0:
  _on_team_defeat("normal")
  return
 var damage: int = maxi(1, 12 * current_level)
 if is_boss:
  damage = roundi(float(damage) * (1.9 if is_fusion_boss else 1.5))
 _damage_heroes(damage, [target])
 _refresh_tank_defense_visuals()
 battle_status_changed.emit()

func _hero_attack(slot: int, role: int) -> void:
 if not battle_active or enemy_hp <= 0:
  return
 if team_formation != null:
  team_formation.play_attack_for_hero(slot)
 if role == 2:
  _heal_heroes(7 + current_level * 2, skill_tick % 3 == 0)
  last_ability = "Heilung"
 else:
  var base_damage: int = 35 + current_level * 6
  if role == 0:
   base_damage = roundi(float(base_damage) * 0.6)
  var critical: bool = randf() < 0.10
  enemy_hp = maxi(0, enemy_hp - roundi(float(base_damage) * (1.6 if critical else 1.0)))
  last_ability = "Kritischer Treffer" if critical else "Standardangriff"
  if enemy_hp <= 0:
   finish_wave()
 battle_status_changed.emit()

func set_skill_loadout(hero: int, skill_slot: int, ability: int) -> void:
 if hero < 0 or hero >= 4 or skill_slot < 0 or skill_slot >= 4:
  return
 skill_loadouts[hero][skill_slot] = ability

func set_skill_choice(slot: int, choice: int) -> void:
 if slot >= 0 and slot < 4:
  skill_choices[slot] = choice

func _hero_is_controlled(_hero_index: int) -> bool:
 return false

func _choose_automatic_skill(slot: int, _role: int) -> int:
 return skill_choices[slot] if slot >= 0 and slot < 4 else 0

func enter_astral() -> void:
 if astral_active:
  return
 astral_active = true
 astral_floor = maxi(1, astral_floor)
 _reset_hero_health()
 start_next_encounter()

func leave_astral() -> void:
 if not astral_active:
  return
 astral_active = false
 _reset_hero_health()
 start_next_encounter()

func buy_astral_reward() -> bool:
 if astral_marks < 30:
  return false
 astral_marks -= 30
 GameManager.reincarnation_tickets += 10
 battle_status_changed.emit()
 return true

func start_next_encounter() -> void:
 if team_formation == null or _finishing:
  return
 clear_enemies()
 battle_active = false
 if team_formation.has_method("start_walking"):
  team_formation.start_walking()
 else:
  spawn_wave()

func _on_walking_finished() -> void:
 spawn_wave()

func spawn_wave() -> void:
 if _finishing:
  return
 clear_enemies()
 _reset_hero_health()
 boss_elapsed = 0.0
 boss_time_remaining = BOSS_TIME_LIMIT
 hero_attack_elapsed.fill(0.0)
 _enemy_attack_elapsed = 0.0
 defeat_reason = ""
 is_boss = not astral_active and current_level % 10 == 0 and current_wave == 1
 is_fusion_boss = is_boss and current_level % 100 == 0
 enemies_remaining = 1 if is_boss else WAVE_ENEMY_COUNTS[clampi(current_wave - 1, 0, 2)]
 enemy_max_hp = maxi(1, current_level * 100 * enemies_remaining * (4 if is_boss else 1))
 if is_fusion_boss:
  enemy_max_hp *= 2
 enemy_hp = enemy_max_hp
 battle_active = true
 battle_status_changed.emit()

func _boss_time_expired() -> void:
 _on_team_defeat("boss_finisher")

func _on_team_defeat(reason: String) -> void:
 battle_active = false
 defeat_reason = reason
 if team_formation != null:
  team_formation.play_team_defeat()
 battle_status_changed.emit()

func finish_wave() -> void:
 if not battle_active or _finishing:
  return
 battle_active = false
 _finishing = true
 if astral_active:
  astral_marks += 5
  astral_floor += 1
 elif is_boss:
  current_level += 1
  current_wave = 1
 else:
  current_wave += 1
  if current_wave > WAVE_ENEMY_COUNTS.size():
   current_wave = 1
   current_level += 1
 _finishing = false
 battle_status_changed.emit()
 call_deferred("start_next_encounter")

func clear_enemies() -> void:
 for enemy in enemy_visuals:
  if is_instance_valid(enemy):
   enemy.queue_free()
 enemy_visuals.clear()
