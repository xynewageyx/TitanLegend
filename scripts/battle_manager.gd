extends Node3D
const AFK_POLICY = preload("res://scripts/afk_farming_policy.gd")
# TEMPORARY compatibility implementation.
# Original Update 168 battle_manager.gd (36,410 bytes) must replace this file.
signal battle_status_changed
signal afk_mode_changed(active: bool)
signal afk_reward_received(gold: int, xp: int)

@export var team_formation: Node3D
@export var biome_manager: Node3D
@export var enemy_spawn_node: Node3D

const BOSS_TIME_LIMIT: float = 60.0
const ROLE_ATTACK_INTERVALS: Array[float] = [1.25, 0.75, 1.5]
const BOSS_WAVE: int = 10
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
var boss_variant_id: int = 0
var boss_title: String = ""
var boss_minion_hp: Array[int] = [0, 0]
var boss_minion_max_hp: int = 0
var boss_minion_visuals: Array[Node3D] = []
var boss_buff_active: bool = false
var boss_buff_kind: String = ""
var boss_resistance: float = 0.18

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
var boss_next_cast_tick: int = 0
var boss_cast_kind: String = ""
var boss_cc_required: int = 0
var boss_cc_progress: int = 0
# Successful interrupts briefly expose the boss; normal casts do not.
const INTERRUPT_VULNERABILITY_TICKS: int = 4
const INTERRUPT_BOSS_DAMAGE_BONUS: float = 0.15
var boss_vulnerable_until_tick: int = -1
var prepared_cc: Array[int] = [0, 0, 0, 0]
var prepared_healing: Array[int] = [-1, -1, -1, -1]
var boss_cast_index: int = 0
var hero_hot_ticks: Array[int] = [0, 0, 0, 0]
var hero_hot_amount: Array[int] = [0, 0, 0, 0]
var boss_interrupt_message: String = ""
var last_ability: String = ""
var skill_loadouts: Array = [[0,0,0,0], [0,0,0,0], [0,0,0,0], [0,0,0,0]]
var skill_choices: Array[int] = [0, 0, 0, 0]
var _enemy_attack_elapsed: float = 0.0
var _wave_hp_pool: int = 0
var _finishing: bool = false
var _retry_pending: bool = false
var _enemy_unit_hp: int = 1
var afk_farming: bool = false
var _afk_wave_pending: bool = false
var _afk_next_reward_ms: int = 0
var _last_player_input_ms: int = -1
var _app_paused: bool = false

func _ready() -> void:
 _last_player_input_ms = Time.get_ticks_msec()
 if team_formation != null and team_formation.has_signal("walking_finished"):
  team_formation.walking_finished.connect(_on_walking_finished)
 var saved_progress: Vector2i = SaveManager.get_saved_battle_progress()
 current_level = maxi(1, saved_progress.x)
 current_wave = clampi(saved_progress.y, 1, BOSS_WAVE)
 world_progress = saved_progress
 # Restore the area's element before spawning bosses, including save-game loads.
 if biome_manager != null:
  biome_manager.call("update_biome_from_stage", current_level)
 var astral_progress: Dictionary = SaveManager.get_saved_astral()
 astral_floor = maxi(1, int(astral_progress.get("floor", 1)))
 astral_marks = maxi(0, int(astral_progress.get("marks", 0)))
 skill_choices = SaveManager.get_saved_skill_choices()
 skill_loadouts = SaveManager.get_saved_skill_loadouts()
 add_to_group("battle_manager")
 _reset_hero_health()
 call_deferred("start_next_encounter")

func _process(delta: float) -> void:
 var now_ms: int = Time.get_ticks_msec()
 if not afk_farming and AFK_POLICY.should_activate(_last_player_input_ms, now_ms, astral_active, _app_paused):
  _enter_afk_farming(now_ms)
 if _app_paused:
  return
 if afk_farming and _afk_wave_pending:
  if AFK_POLICY.reward_ready(afk_farming, _afk_wave_pending, _app_paused, now_ms, _afk_next_reward_ms):
   _pay_afk_wave(now_ms)
  return
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
  if not battle_active:
   return
 for slot in range(4):
  if not battle_active:
   return
  if hero_hp[slot] <= 0:
   continue
  hero_attack_elapsed[slot] += delta
  var role: int = 1
  if team_formation != null:
   role = clampi(int(team_formation.role_ids[slot]), 0, 2)
  if hero_attack_elapsed[slot] >= ROLE_ATTACK_INTERVALS[role]:
   hero_attack_elapsed[slot] = 0.0
   _hero_attack(slot, role)

func _input(event: InputEvent) -> void:
 # Alle echten Touch-/Maus-/Tastatureingaben zaehlen, auch in Menues.
 var interacting: bool = false
 if event is InputEventScreenTouch:
  interacting = event.pressed
 elif event is InputEventMouseButton:
  interacting = event.pressed
 elif event is InputEventKey:
  interacting = event.pressed and not event.echo
 elif event is InputEventScreenDrag:
  interacting = true
 if interacting:
  _last_player_input_ms = Time.get_ticks_msec()
  if afk_farming:
   _leave_afk_farming()

func _notification(what: int) -> void:
 if what == NOTIFICATION_APPLICATION_PAUSED:
  _app_paused = true
 elif what == NOTIFICATION_APPLICATION_RESUMED:
  _app_paused = false
  _last_player_input_ms = Time.get_ticks_msec()
  if afk_farming:
   _leave_afk_farming()

func _enter_afk_farming(now_ms: int) -> void:
 if afk_farming or astral_active or _app_paused:
  return
 afk_farming = true
 _afk_wave_pending = false
 _afk_next_reward_ms = now_ms + AFK_POLICY.AFK_REWARD_INTERVAL_MS
 # Aktuellen Bosskampf abbrechen, nicht als offline besiegt werten.
 battle_active = false
 clear_enemies()
 _finishing = false
 afk_mode_changed.emit(true)
 battle_status_changed.emit()
 call_deferred("start_next_encounter")

func _leave_afk_farming() -> void:
 if not afk_farming:
  return
 afk_farming = false
 _afk_wave_pending = false
 _afk_next_reward_ms = 0
 battle_active = false
 clear_enemies()
 afk_mode_changed.emit(false)
 battle_status_changed.emit()
 # Der echte Boss der gespeicherten Stage darf erst nach Rueckkehr starten.
 call_deferred("start_next_encounter")

func _pay_afk_wave(now_ms: int) -> void:
 if not afk_farming or not _afk_wave_pending:
  return
 _afk_wave_pending = false
 _afk_next_reward_ms = now_ms + AFK_POLICY.AFK_REWARD_INTERVAL_MS
 var gold: int = clampi(current_level, 1, 1200) * 50
 var xp: int = GameManager.EXPERIENCE.mob_wave_xp(current_level)
 GameManager.add_gold(gold)
 GameManager.gain_character_xp(xp)
 SaveManager.save_game()
 afk_reward_received.emit(gold, xp)
 battle_status_changed.emit()
 call_deferred("start_next_encounter")

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
  var pet_health: float = float(_pet_stats(i).get("health", 0.0))
  hero_max_hp[i] = maxi(1, roundi(300.0 * (1.0 + pet_health + GameManager.hardening_bonus(i, 2) + GameManager.loot_bonus(i, 0))))
  hero_hp[i] = hero_max_hp[i]
 tank_taunt_until.fill(0)
 tank_intercept_until.fill(0)
 skill_hit_charge.fill(0)
 next_skill_slot.fill(0)
 hero_hot_ticks.fill(0)
 hero_hot_amount.fill(0)
 boss_cc_progress = 0
 prepared_cc.fill(0)
 prepared_healing.fill(-1)
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
 return minf(0.24, 0.04 + GameManager.hardening_bonus(index, 4))

func _hero_dodges(index: int) -> bool:
 return randf() < _hero_dodge_chance(index)

func _show_hero_combat_number(_slot: int, _value: int, _is_heal: bool) -> void:
 # No damage popup can be shown without the original FloatingText scene.
 pass

func _hero_progression(slot: int) -> Dictionary:
 if team_formation == null or slot < 0 or slot >= team_formation.class_ids.size():
  return {"attack":0.0, "defense":0.0, "healing":0.0}
 return TitanCombatBalance.hero_progression(int(team_formation.class_ids[slot]), team_formation.talent_ranks[slot], GameManager.jewel_level)

func _damage_heroes(amount: int, targets: Array[int], max_hp_fraction: float = 0.0) -> void:
 var hits: Array[int] = []
 var dodges: Array[int] = []
 # Resolve the tank's protection once for the entire simultaneous hit.
 # A tank defeated during this attack still protects allies struck by it.
 var tank: int = _living_tank_slot()
 var intercept_active: bool = tank >= 0 and tank_intercept_until[tank] >= skill_tick
 for index in targets:
  if index < 0 or index >= 4 or hero_hp[index] <= 0:
   continue
  if _hero_dodges(index):
   dodges.append(index)
   continue
  var mitigation: float = 0.30 if index == tank else 0.05
  # Active interception reduces damage to allies during boss area attacks.
  if intercept_active and index != tank:
   mitigation = 0.35
  # Talent defense is multiplicative and capped separately from tank mitigation.
  var talent_defense: float = float(_hero_progression(index).get("defense", 0.0))
  var incoming: int = amount
  if max_hp_fraction > 0.0:
   incoming = maxi(1, roundi(float(hero_max_hp[index]) * max_hp_fraction * TitanCombatBalance.enemy_damage_scale(current_level)))
  var damage: int = maxi(1, roundi(float(incoming) * (1.0 - mitigation) * (1.0 - talent_defense) * (1.0 - GameManager.hardening_bonus(index, 1)) * (1.0 - GameManager.loot_bonus(index, 1))))
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
 else:
  _trigger_prepared_healing()

func _has_wounded_hero() -> bool:
 for i in range(4):
  if hero_hp[i] > 0 and hero_hp[i] < hero_max_hp[i]:
   return true
 return false

func _trigger_prepared_healing() -> void:
 if not battle_active or not _has_wounded_hero():
  return
 for slot in range(4):
  if prepared_healing[slot] < 0 or hero_hp[slot] <= 0:
   continue
  var choice: int = prepared_healing[slot]
  prepared_healing[slot] = -1
  var skill: Dictionary = TitanSkillSystem.skill_for_role(2, choice)
  if choice == 8:
   _apply_heal_over_time(slot, skill)
  else:
   var class_id: int = int(team_formation.class_ids[slot]) if team_formation != null else 9
   var modifier: float = float(TitanCombatBalance.healer_profile(class_id).get("direct", 1.0))
   modifier *= 1.0 + float(_hero_progression(slot).get("healing", 0.0))
   var amount: int = maxi(1, roundi(float(team_max_hp) * float(skill.get("heal", 0.0)) * modifier))
   _heal_heroes(amount, bool(skill.get("aoe", false)))
  last_ability = "Vorbereitete Heilung"
  if not _has_wounded_hero():
   break

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

func _apply_heal_over_time(_caster: int, skill: Dictionary) -> void:
 # Renew the HoT on the most injured living ally; it never resurrects heroes.
 var target: int = -1
 var lowest: float = 1.01
 for i in range(4):
  if hero_hp[i] <= 0:
   continue
  var ratio: float = float(hero_hp[i]) / float(maxi(1, hero_max_hp[i]))
  if ratio < lowest:
   lowest = ratio
   target = i
 if target < 0:
  return
 var new_ticks: int = clampi(int(skill.get("hot_ticks", 4)), 1, 4)
 var class_id: int = int(team_formation.class_ids[_caster]) if team_formation != null else 9
 var hot_modifier: float = float(TitanCombatBalance.healer_profile(class_id).get("hot", 1.0))
 hot_modifier *= 1.0 + float(_hero_progression(_caster).get("healing", 0.0))
 var new_amount: int = maxi(1, roundi(float(hero_max_hp[target]) * float(skill.get("hot", 0.075)) * hot_modifier))
 # A weaker or shorter HoT must never erase stronger ongoing healing.
 if hero_hot_ticks[target] > 0:
  hero_hot_amount[target] = maxi(hero_hot_amount[target], new_amount)
  hero_hot_ticks[target] = maxi(hero_hot_ticks[target], new_ticks)
 else:
  hero_hot_amount[target] = new_amount
  hero_hot_ticks[target] = new_ticks
 last_ability = "Erneuerung (HoT)"

func _tick_heal_over_time() -> void:
 var changed: bool = false
 for i in range(4):
  if hero_hot_ticks[i] <= 0:
   continue
  hero_hot_ticks[i] -= 1
  if hero_hp[i] <= 0:
   continue
  var before: int = hero_hp[i]
  hero_hp[i] = mini(hero_max_hp[i], hero_hp[i] + hero_hot_amount[i])
  changed = changed or hero_hp[i] != before
  if hero_hp[i] > before:
   _show_hero_combat_number(i, hero_hp[i] - before, true)
 if changed:
  _sync_team_health()

func _apply_boss_cc_hit() -> void:
 if not battle_active or not is_boss or boss_cast_ticks <= 0 or boss_cc_required <= 0:
  return
 boss_cc_progress += 1
 last_ability = "Kontrolle %d/%d" % [boss_cc_progress, boss_cc_required]
 if boss_cc_progress >= boss_cc_required:
  boss_cast_ticks = 0
  boss_cast_kind = ""
  boss_cc_required = 0
  boss_cc_progress = 0
  boss_next_cast_tick = maxi(boss_next_cast_tick, skill_tick + 5)
  boss_vulnerable_until_tick = skill_tick + INTERRUPT_VULNERABILITY_TICKS
  boss_interrupt_message = "Boss unterbrochen"
  last_ability = "Unterbrechung"

func _begin_boss_cast() -> void:
 boss_cast_index += 1
 boss_cc_progress = 0
 boss_cast_ticks = 3
 boss_interrupt_message = ""
 # Each element has the same four recurring boss styles; spells differ.
 # Harmless casts do not require CC. Dangerous casts have limited windows.
 match boss_variant_id:
  0: # Guardian: mostly single target, some interruptible heavy blows.
   boss_cast_kind = "single"
   boss_cast_name = "Gezielter Hieb"
   boss_cc_required = 1 if boss_cast_index % 3 == 0 else 0
  1: # Stormcaller: AoE specialist, team CC matters.
   boss_cast_kind = "aoe"
   boss_cast_name = "Verheerende Welle"
   boss_cc_required = 3 if is_fusion_boss else 2
  2: # Rune keeper: self-heal alternating with mild strikes.
   if boss_cast_index % 2 == 0:
    boss_cast_kind = "single"
    boss_cast_name = "Runenschlag"
    boss_cc_required = 0
   else:
    boss_cast_kind = "self_heal"
    boss_cast_name = "Titanheilung"
    boss_cc_required = 1
  _: # Ancient titan: alternates moderate AoE and heavy single hits.
   if boss_cast_index % 2 == 0:
    boss_cast_kind = "aoe"
    boss_cast_name = "Elementarsturm"
    boss_cc_required = 2 if is_fusion_boss else 1
   else:
    boss_cast_kind = "single"
    boss_cast_name = "Zerschmettern"
    boss_cc_required = 1
 # More required CC hits give the team more real attack cycles.
 # This changes only the cast window, never the 60-second boss timer.
 boss_cast_ticks = 3 + maxi(0, boss_cc_required - 1) * 2
 boss_next_cast_tick = skill_tick + 9
 if boss_cc_required > 0:
  # Prepared hits were earned by the strict four-slot rotation earlier.
  # Each living hero can contribute at most one banked hit.
  for slot in range(4):
   if prepared_cc[slot] <= 0 or hero_hp[slot] <= 0:
    continue
   prepared_cc[slot] = 0
   _apply_boss_cc_hit()
   if boss_cast_ticks <= 0:
    break

func _resolve_boss_cast() -> void:
 if not battle_active or not is_boss:
  return
 if boss_cast_kind == "self_heal":
  enemy_hp = mini(enemy_max_hp, enemy_hp + maxi(1, roundi(float(enemy_max_hp) * 0.05)))
  last_ability = "Boss: Selbstheilung"
 elif boss_cast_kind == "single":
  var target: int = _choose_routine_enemy_target()
  if target >= 0:
   _damage_heroes(maxi(1, roundi(float(hero_max_hp[target]) * (0.18 if is_fusion_boss else 0.14) * TitanCombatBalance.enemy_damage_scale(current_level))), [target])
  last_ability = "Boss: Einzelziel"
 elif boss_cast_kind == "aoe":
  var targets: Array[int] = []
  for i in range(hero_hp.size()):
   if hero_hp[i] > 0:
    targets.append(i)
  # Each living hero takes damage proportional to their own max HP.
  _damage_heroes(0, targets, 0.13 if is_fusion_boss else 0.10)
  last_ability = "Boss: Flaechenschaden"
 boss_cast_kind = ""
 boss_cc_progress = 0
 boss_cc_required = 0

func _boss_phase_two_tick() -> void:
 if not battle_active or not is_boss or not boss_buff_active:
  return
 match boss_buff_kind:
  "heal":
   if skill_tick % 7 == 0:
    enemy_hp = mini(enemy_max_hp, enemy_hp + maxi(1, roundi(float(enemy_max_hp) * 0.02)))
    last_ability = "Boss: Regeneration"
  "attack":
   if skill_tick % 6 == 0:
    var target: int = _choose_routine_enemy_target()
    if target >= 0:
     _damage_heroes(maxi(1, roundi(float(hero_max_hp[target]) * 0.05 * TitanCombatBalance.enemy_damage_scale(current_level))), [target])
     last_ability = "Boss: Wutschlag"
  # Defense is the passive armored phase-two ability.

func _attack_tick() -> void:
 if not battle_active:
  return
 skill_tick += 1
 _tick_heal_over_time()
 # Only marked boss abilities are interruptible. Routine damage is not.
 if is_boss:
  if boss_cast_ticks > 0:
   boss_cast_ticks -= 1
   if boss_cast_ticks == 0:
    _resolve_boss_cast()
    if not battle_active:
     return
  elif skill_tick >= boss_next_cast_tick:
   _begin_boss_cast()
 var target: int = _choose_routine_enemy_target()
 if target < 0:
  _on_team_defeat("normal")
  return
 # Scale routine damage to hero durability; avoid instant kills at high stages.
 var damage: int = maxi(1, roundi(float(hero_max_hp[target]) * 0.04 * TitanCombatBalance.enemy_damage_scale(current_level)))
 if is_boss:
  damage = roundi(float(damage) * (1.9 if is_fusion_boss else 1.5))
  if boss_buff_active and boss_buff_kind == "attack":
   damage = maxi(1, roundi(float(damage) * 1.15))
  # Boss area attacks happen periodically. The tank can intercept them.
  if skill_tick % 4 == 0:
   var group_targets: Array[int] = []
   for index in range(hero_hp.size()):
    if hero_hp[index] > 0:
     group_targets.append(index)
   _damage_heroes(damage, group_targets)
  else:
   _damage_heroes(damage, [target])
 else:
  _damage_heroes(damage, [target])
 if not battle_active:
  return
 _boss_minions_attack()
 _boss_phase_two_tick()
 _refresh_tank_defense_visuals()
 battle_status_changed.emit()

# Normal hits charge equipped skills. Skill cost is capped at 5 hits.
# Each hero rotates through four equipped skill slots so no slot is starved.
const MAX_SKILL_HITS: int = 5
var skill_hit_charge: Array[int] = [0, 0, 0, 0]
var next_skill_slot: Array[int] = [0, 0, 0, 0]

func _skill_hit_cost(role: int, choice: int) -> int:
 if role == 0 and choice == 8:
  return 3 # Spott
 if role == 0 and choice == 9:
  return 5 # Gruppenschaden abfangen (strongest defensive skill)
 match choice:
  0: return 2
  1: return 3
  2: return 4
  3: return 2
  4: return 4
  5: return 5 # Bossbrecher
  6: return 3
  7: return 4 # Unterbrechung (boss only)
  8:
   if role == 2:
    return 4 # Erneuerung (HoT)
 return MAX_SKILL_HITS

func _skill_is_usable(slot: int, role: int, choice: int) -> bool:
 if role == 0 and slot != _living_tank_slot():
  return false
 if choice == 9 and role != 0:
  return false
 if choice == 8 and role not in [0, 2]:
  return false
 if role == 2 and choice == 8:
  return true
 if choice == 7:
  # The fourth slot must not deadlock on mobs or between boss casts.
  return true
 var skill: Dictionary = TitanSkillSystem.skill_for_role(role, choice)
 # Fully healed teams may prepare the healing portion of this slot.
 return true

func _try_cast_charged_skill(slot: int, role: int) -> void:
 var loadout: Array = skill_loadouts[slot]
 if loadout.is_empty():
  return
 # Strict order: slot 1 -> 2 -> 3 -> 4 -> slot 1.
 # Do not skip a slot because it is charging or its condition is unmet.
 var index: int = next_skill_slot[slot] % loadout.size()
 var choice: int = int(loadout[index])
 var required_hits: int = _skill_hit_cost(role, choice)
 if skill_hit_charge[slot] < required_hits:
  return
 if not _skill_is_usable(slot, role, choice):
  return
 skill_hit_charge[slot] = 0
 next_skill_slot[slot] = (index + 1) % loadout.size()
 _execute_equipped_skill(slot, role, choice)

func _execute_equipped_skill(slot: int, role: int, choice: int) -> void:
 if team_formation != null and slot < team_formation.heroes.size():
  var motion: Node = team_formation.heroes[slot].get_node_or_null("HeroCombatMotion")
  if motion != null and motion.has_method("play_skill_cast"):
   motion.call("play_skill_cast", role, choice)
 if role == 0 and choice == 8:
  tank_taunt_until[slot] = skill_tick + 3
  last_ability = "Spott"
  if team_formation != null:
   var motion: Node = team_formation.heroes[slot].get_node_or_null("HeroCombatMotion")
   if motion != null and motion.has_method("play_tank_skill_fx"):
    motion.call("play_tank_skill_fx", 0)
  return
 if role == 0 and choice == 9:
  tank_intercept_until[slot] = skill_tick + 4
  last_ability = "Gruppenschaden abfangen"
  _refresh_tank_defense_visuals()
  return
 if choice == 7:
  if not is_boss or boss_cast_ticks <= 0 or boss_cc_required <= 0:
   # This slot was genuinely charged and used in order; bank at most one hit.
   prepared_cc[slot] = 1
   last_ability = "Kontrolle vorbereitet"
   return
  _apply_boss_cc_hit()
  return
 var skill: Dictionary = TitanSkillSystem.skill_for_role(role, choice)
 last_ability = str(skill.get("name", "Skill"))
 if role == 2 and choice == 8:
  if _has_wounded_hero():
   _apply_heal_over_time(slot, skill)
  else:
   prepared_healing[slot] = choice
   last_ability = "Erneuerung vorbereitet"
  return
 var healing: float = float(skill.get("heal", 0.0))
 if role == 2 and healing > 0.0:
  var class_id: int = int(team_formation.class_ids[slot]) if team_formation != null else 9
  healing *= float(TitanCombatBalance.healer_profile(class_id).get("direct", 1.0))
  healing *= 1.0 + float(_hero_progression(slot).get("healing", 0.0))
  if _has_wounded_hero():
   _heal_heroes(maxi(1, roundi(float(team_max_hp) * healing)), bool(skill.get("aoe", false)))
  else:
   prepared_healing[slot] = choice
   last_ability = "Heilung vorbereitet"
 var power: float = float(skill.get("power", 0.0))
 if power > 0.0:
  var base_damage: int = 35 + current_level * 6
  var damage: int = TitanSkillSystem.damage_for_skill(skill, role, base_damage, enemies_remaining)
  if role == 2 and team_formation != null:
   damage = maxi(1, roundi(float(damage) * float(TitanCombatBalance.healer_profile(int(team_formation.class_ids[slot])).get("damage", 1.0))))
  damage = maxi(1, roundi(float(damage) * (1.0 + float(_hero_progression(slot).get("attack", 0.0)) + GameManager.weapon_attack_bonus(slot) + GameManager.hardening_bonus(slot, 0) + GameManager.loot_bonus(slot, 2))))
  _deal_damage_to_enemy(slot, maxi(1, damage), bool(skill.get("aoe", false)))

func _pet_stats(slot: int) -> Dictionary:
 if team_formation == null:
  return {"penetration":0.0, "health":0.0, "crit":0.0}
 var hero_class: int = int(team_formation.class_ids[slot])
 var pet_element: int = int(team_formation.pet_element_ids[slot])
 var boss_element: int = 0
 if biome_manager != null:
  boss_element = maxi(0, int(biome_manager.current_biome))
 return TitanCombatBalance.passive_pet_stats(hero_class, pet_element, boss_element)

func _deal_damage_to_enemy(slot: int, amount: int, is_area: bool = false) -> void:
 if not battle_active or amount <= 0:
  return
 var stats: Dictionary = _pet_stats(slot)
 var dealt: int = amount
 if not is_boss and is_area:
  # Normal mob waves use an aggregate HP pool, so distribute AoE once here.
  dealt *= mini(maxi(enemies_remaining, 1), 7)
 if is_boss:
  dealt = TitanCombatBalance.damage_after_resistance(amount, boss_resistance, float(stats.get("penetration", 0.0)) + GameManager.hardening_bonus(slot, 5))
 # Midgame minions can be targeted and removed before the main boss.
 if is_boss and not boss_minion_hp.is_empty():
  for index in range(2):
   if boss_minion_hp[index] <= 0:
    continue
   boss_minion_hp[index] = maxi(0, boss_minion_hp[index] - dealt)
   if boss_minion_hp[index] == 0:
    if index < boss_minion_visuals.size() and is_instance_valid(boss_minion_visuals[index]):
     boss_minion_visuals[index].visible = false
    _on_boss_minion_defeated()
   if not is_area:
    return
 # If an area skill hit adds, the remaining boss also takes one hit.
 var defense: float = 0.13 if boss_buff_active and boss_buff_kind == "defense" else 0.0
 var vulnerability: float = 1.0 + INTERRUPT_BOSS_DAMAGE_BONUS if is_boss and skill_tick < boss_vulnerable_until_tick else 1.0
 enemy_hp = maxi(0, enemy_hp - maxi(1, roundi(float(dealt) * (1.0 - defense) * vulnerability)))
 _update_enemy_casualties()
 if enemy_hp <= 0:
  finish_wave()

func _on_boss_minion_defeated() -> void:
 if boss_minion_hp[0] > 0 or boss_minion_hp[1] > 0 or boss_buff_active:
  return
 boss_buff_active = true
 match boss_buff_kind:
  "heal":
   enemy_hp = mini(enemy_max_hp, enemy_hp + maxi(1, roundi(float(enemy_max_hp) * 0.06)))
   last_ability = "Bossphase: Heilung"
  "defense":
   last_ability = "Bossphase: Panzerung"
  _:
   last_ability = "Bossphase: Wutanfall"
 battle_status_changed.emit()

func _boss_minions_attack() -> void:
 if not battle_active or not is_boss:
  return
 for index in range(2):
  if not battle_active:
   return
  if boss_minion_hp[index] <= 0:
   continue
  var target: int = _choose_routine_enemy_target()
  if target >= 0:
   # Each add deals ~2% of target max HP per enemy attack tick.
   _damage_heroes(maxi(1, roundi(float(hero_max_hp[target]) * 0.02 * TitanCombatBalance.enemy_damage_scale(current_level))), [target])

func _hero_attack(slot: int, role: int) -> void:
 if not battle_active or enemy_hp <= 0:
  return
 if team_formation != null:
  team_formation.play_attack_for_hero(slot)
 # Every living hero lands a normal hit to charge their next skill.
 var normal_damage: int = 35 + current_level * 6
 var multiplier: float = TitanSkillSystem.damage_multiplier(role)
 var critical: bool = randf() < minf(0.30, 0.10 + float(_pet_stats(slot).get("crit", 0.0)))
 var progression_attack: float = 1.0 + float(_hero_progression(slot).get("attack", 0.0)) + GameManager.weapon_attack_bonus(slot) + GameManager.hardening_bonus(slot, 0) + GameManager.loot_bonus(slot, 2)
 var actual_damage: int = maxi(1, roundi(float(normal_damage) * multiplier * progression_attack * (1.6 + GameManager.hardening_bonus(slot, 3) if critical else 1.0)))
 _deal_damage_to_enemy(slot, actual_damage)
 if not battle_active:
  return
 last_ability = "Kritischer Treffer" if critical else "Standardangriff"
 skill_hit_charge[slot] = mini(MAX_SKILL_HITS, skill_hit_charge[slot] + 1)
 if battle_active and enemy_hp > 0:
  _try_cast_charged_skill(slot, role)
 battle_status_changed.emit()

func set_skill_loadout(hero: int, skill_slot: int, ability: int) -> void:
 if hero < 0 or hero >= 4 or skill_slot < 0 or skill_slot >= 4:
  return
 var active_role: int = int(team_formation.role_ids[hero]) if team_formation != null else 1
 skill_loadouts[hero][skill_slot] = clampi(ability, 0, 9 if active_role == 0 else (8 if active_role == 2 else 7))
 # Changing a loadout invalidates banked effects earned by the old skills.
 # Prevents keeping an interrupt or heal after removing that skill.
 next_skill_slot[hero] = 0
 skill_hit_charge[hero] = 0
 prepared_cc[hero] = 0
 prepared_healing[hero] = -1
 SaveManager.save_game()
 battle_status_changed.emit()

func set_skill_choice(slot: int, choice: int) -> void:
 if slot < 0 or slot >= 4:
  return
 skill_choices[slot] = clampi(choice, 0, 1)
 set_skill_loadout(slot, 0, choice)

func _hero_is_controlled(_hero_index: int) -> bool:
 return false

func _choose_automatic_skill(slot: int, _role: int) -> int:
 return skill_choices[slot] if slot >= 0 and slot < 4 else 0

func enter_astral() -> void:
 if astral_active:
  return
 world_progress = Vector2i(current_level, current_wave)
 astral_active = true
 current_level = maxi(1, astral_floor)
 current_wave = BOSS_WAVE
 start_next_encounter()
 battle_status_changed.emit()

func leave_astral() -> void:
 if not astral_active:
  return
 astral_active = false
 current_level = world_progress.x
 current_wave = world_progress.y
 if biome_manager != null:
  biome_manager.call("update_biome_from_stage", current_level)
 start_next_encounter()
 SaveManager.save_game()
 battle_status_changed.emit()

func buy_astral_reward() -> bool:
 if astral_marks < 30:
  return false
 astral_marks -= 30
 GameManager.add_tickets(10)
 SaveManager.save_game()
 battle_status_changed.emit()
 return true

func start_next_encounter() -> void:
 if _finishing or _afk_wave_pending:
  return
 if team_hp <= 0:
  _reset_hero_health()
 clear_enemies()
 battle_active = false
 if team_formation.has_method("start_walking"):
  team_formation.start_walking()
 else:
  spawn_wave()

func _on_walking_finished() -> void:
 if not _afk_wave_pending:
  spawn_wave()

func spawn_wave() -> void:
 if _finishing or _afk_wave_pending:
  return
 clear_enemies()
 # Preserve surviving heroes' HP across normal waves.
 # Full recovery only occurs when an explicit run/reset begins.
 boss_elapsed = 0.0
 boss_time_remaining = BOSS_TIME_LIMIT
 boss_cast_ticks = 0
 boss_cast_name = ""
 boss_cast_kind = ""
 boss_cc_required = 0
 boss_cc_progress = 0
 boss_vulnerable_until_tick = -1
 boss_cast_index = 0
 boss_interrupt_message = ""
 boss_next_cast_tick = skill_tick + 4
 hero_attack_elapsed.fill(0.0)
 _enemy_attack_elapsed = 0.0
 defeat_reason = ""
 is_boss = AFK_POLICY.is_boss_encounter(afk_farming, astral_active, current_wave)
 is_fusion_boss = is_boss and current_level % 10 == 0
 boss_variant_id = TitanCombatBalance.boss_variant(current_level)
 boss_title = TitanCombatBalance.BOSS_TITLES[boss_variant_id]
 # Four archetypes share their zone element but have distinct resistances.
 boss_resistance = TitanCombatBalance.boss_resistance(boss_variant_id)
 boss_buff_active = false
 boss_buff_kind = TitanCombatBalance.boss_gain_type(boss_variant_id)
 boss_minion_hp = [0, 0]
 enemies_remaining = 1 if is_boss else mini(2 + current_wave, 7)
 enemy_max_hp = (220 + current_level * 65) * (8 if is_fusion_boss else (5 if is_boss else 1))
 if is_boss:
  # Small archetype differences, not multiplying HP every time elements repeat.
  var variant_hp_scale: Array[float] = [1.08, 0.96, 0.94, 1.05]
  enemy_max_hp = maxi(1, roundi(float(enemy_max_hp) * variant_hp_scale[boss_variant_id]))
 # Area progression raises enemy durability from stage 101 onward.
 enemy_max_hp = maxi(1, roundi(float(enemy_max_hp) * TitanCombatBalance.enemy_hp_scale(current_level)))
 if astral_active:
  enemy_max_hp = roundi(float(enemy_max_hp) * (1.0 + float(astral_floor) * 0.14))
 _enemy_unit_hp = maxi(1, enemy_max_hp)
 enemy_hp = _enemy_unit_hp * enemies_remaining
 if is_boss and TitanCombatBalance.has_boss_minions(current_level, is_fusion_boss):
  # Each of the two adds owns 12 percent of boss health.
  boss_minion_max_hp = maxi(1, roundi(float(enemy_max_hp) * 0.12))
  boss_minion_hp = [boss_minion_max_hp, boss_minion_max_hp]
 else:
  boss_minion_max_hp = 0
 _spawn_enemy_visuals()
 _spawn_boss_minion_visuals()
 battle_active = true
 battle_status_changed.emit()

func _boss_time_expired() -> void:
 _on_team_defeat("boss_finisher")

func _on_team_defeat(reason: String) -> void:
 if _retry_pending:
  return
 battle_active = false
 defeat_reason = reason
 _retry_pending = true
 if team_formation != null:
  team_formation.play_team_defeat()
 battle_status_changed.emit()
 # Restart the same wave, not a later one; no automatic role reassignment.
 get_tree().create_timer(2.0).timeout.connect(_retry_defeated_encounter)

func _retry_defeated_encounter() -> void:
 _retry_pending = false
 if not is_inside_tree() or battle_active:
  return
 _reset_hero_health()
 start_next_encounter()

func finish_wave() -> void:
 if not battle_active or _finishing:
  return
 battle_active = false
 _finishing = true
 if afk_farming:
  # Eine abgeschlossene AFK-Welle gibt maximal alle 60 Sekunden Belohnung.
  # Niemals Bossloot vergeben oder die gespeicherte Stage/Welle erhoehen.
  _finishing = false
  _afk_wave_pending = true
  clear_enemies()
  battle_status_changed.emit()
  return
 var gold_reward: int = current_level * (500 if is_fusion_boss else (250 if is_boss else 50))
 if team_formation != null and team_formation.has_formation_bonus():
  gold_reward = roundi(float(gold_reward) * 1.05)
 GameManager.add_gold(gold_reward)
 # Gleiche normale Mob-XP-Rate wie beim Offline-Farming.
 # Bosskaempfe geben weiterhin ihr bisheriges direktes Charakterlevel.
 if not astral_active:
  var wave_xp: int = GameManager.EXPERIENCE.mob_wave_xp(current_level)
  if is_boss:
   wave_xp *= 5
  GameManager.gain_character_xp(wave_xp)
 if is_boss and not astral_active:
  var found_loot: Dictionary = GameManager.grant_boss_loot(current_level, is_fusion_boss)
  if not found_loot.is_empty():
   last_ability = "Loot: " + GameManager.loot_item_name(found_loot)
 if astral_active:
  astral_marks += 5 + mini(astral_floor, 50)
  astral_floor += 1
  current_level = astral_floor
  current_wave = BOSS_WAVE
 elif is_boss:
  GameManager.gain_boss_level()
  current_level += 1
  current_wave = 1
  if biome_manager != null:
   biome_manager.call("update_biome_from_stage", current_level)
 else:
  current_wave += 1
  # Wave ten is always the boss; do not advance stage early.
 _finishing = false
 SaveManager.save_game()
 battle_status_changed.emit()
 call_deferred("start_next_encounter")

func _update_enemy_casualties() -> void:
 if is_boss or _enemy_unit_hp <= 0:
  return
 var survivors: int = ceili(float(enemy_hp) / float(_enemy_unit_hp))
 survivors = clampi(survivors, 0, enemy_visuals.size())
 for index in range(survivors, enemy_visuals.size()):
  var mob: Node3D = enemy_visuals[index]
  if is_instance_valid(mob):
   mob.visible = false
 enemies_remaining = survivors

func _spawn_enemy_visuals() -> void:
 if enemy_spawn_node == null:
  return
 for i in range(enemies_remaining):
  var mob := Node3D.new()
  mob.name = "Boss" if is_boss else "WaveMob" + str(i + 1)
  mob.position = Vector3((float(i) - float(enemies_remaining - 1) / 2.0) * 1.4, 0.0, -float(i % 2))
  enemy_spawn_node.add_child(mob)
  enemy_visuals.append(mob)
  var tint := Color("#b84d5b") if is_boss else Color("#779f57")
  if biome_manager != null:
   tint = biome_manager.COLORS[biome_manager.current_biome]
  var size := 2.2 if is_boss else 0.65
  if is_boss:
   # Recognizable silhouettes; the tint remains the shared zone element.
   size *= [1.05, 0.85, 0.95, 1.17][boss_variant_id]
  VisualFactory.sphere(mob, size, Vector3(0, size, 0), tint)
  VisualFactory.sphere(mob, 0.19 if not is_boss else 0.35, Vector3(-0.23, size + 0.14, -0.52), Color("#f9ed9b"))
  VisualFactory.sphere(mob, 0.19 if not is_boss else 0.35, Vector3(0.23, size + 0.14, -0.52), Color("#f9ed9b"))
  if is_boss:
   match boss_variant_id:
    0:
     VisualFactory.box(mob, Vector3(2.2, 0.42, 0.7), Vector3(0, size * 1.25, -0.25), tint.lightened(0.3))
    1:
     VisualFactory.sphere(mob, 0.75, Vector3(0, size * 2.0 + 0.35, 0), tint.lightened(0.48))
    2:
     VisualFactory.cylinder(mob, 1.25, 0.52, Vector3(0, size * 1.8, 0), tint.darkened(0.32))
    3:
     VisualFactory.box(mob, Vector3(2.6, 0.55, 1.1), Vector3(0, size * 1.65, 0), tint.darkened(0.2))

func _spawn_boss_minion_visuals() -> void:
 if not is_boss or boss_minion_max_hp <= 0 or enemy_spawn_node == null:
  return
 var tint: Color = Color("#7dbac1")
 if biome_manager != null and biome_manager.current_biome >= 0:
  tint = biome_manager.COLORS[biome_manager.current_biome]
 for i in range(2):
  var companion := Node3D.new()
  companion.name = "BossMinion%d" % [i + 1]
  companion.position = Vector3(-2.4 if i == 0 else 2.4, 0.0, -0.8)
  enemy_spawn_node.add_child(companion)
  boss_minion_visuals.append(companion)
  VisualFactory.sphere(companion, 0.72, Vector3(0, 0.8, 0), tint.lightened(0.18))
  VisualFactory.sphere(companion, 0.23, Vector3(0, 1.44, -0.25), tint.darkened(0.3))

func clear_enemies() -> void:
 for companion in boss_minion_visuals:
  if is_instance_valid(companion):
   companion.queue_free()
 boss_minion_visuals.clear()
 for enemy in enemy_visuals:
  if is_instance_valid(enemy):
   enemy.queue_free()
 enemy_visuals.clear()
