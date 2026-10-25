extends Node3D
signal battle_status_changed
@export var team_formation: Node3D
@export var biome_manager: Node3D
@export var enemy_spawn_node: Node3D
const FLOATING_TEXT: PackedScene = preload("res://scenes/floating_text.tscn")
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
const BOSS_TIME_LIMIT: float = 60.0
# Seconds between basic attacks: tank 1.25, damage dealer 0.75, healer 1.50.
const ROLE_ATTACK_INTERVALS: Array[float] = [1.25, 0.75, 1.50]
var hero_attack_elapsed: Array[float] = [0.0, 0.0, 0.0, 0.0]
var boss_elapsed: float = 0.0
var boss_time_remaining: float = 60.0
var enemy_animation_time: float = 0.0
var team_hp: int = 1200
var team_max_hp: int = 1200
# Update 92: Individual hero health. Shared HP remains a HUD-compatible total.
var hero_max_hp: Array[int] = [300, 300, 300, 300]
var hero_hp: Array[int] = [300, 300, 300, 300]
var last_boss_targets: Array[int] = []
var tank_taunt_until: Array[int] = [0, 0, 0, 0]
var tank_intercept_until: Array[int] = [0, 0, 0, 0]
# Update 97: explicit defeat state for both normal wipes and the 60-second finisher.
var defeat_reason: String = ""
func _sync_team_health() -> void:
 team_hp = 0
 team_max_hp = 0
 for i in range(4):
  team_hp += hero_hp[i]
  team_max_hp += hero_max_hp[i]
 if team_formation != null and team_formation.has_method("update_hero_health_bars"):
  team_formation.update_hero_health_bars(hero_hp, hero_max_hp)

func _reset_hero_health() -> void:
 for i in range(4):
  hero_hp[i] = hero_max_hp[i]
 _sync_team_health()
 tank_taunt_until.fill(0)
 tank_intercept_until.fill(0)
 if team_formation != null and team_formation.has_method("reset_individual_defeat_poses"):
  team_formation.reset_individual_defeat_poses()

# Update 143: individual combat feedback, anchored to the actual hero.
var hero_popup_counter: int = 0

func _show_hero_combat_number(slot: int, value: int, is_heal: bool) -> void:
 if value <= 0 or team_formation == null or slot < 0 or slot >= team_formation.heroes.size():
  return
 var hero: Node3D = team_formation.heroes[slot]
 if not is_instance_valid(hero):
  return
 # Update 157: Count popups belonging to this hero, not adjacent heroes.
 # Spatial proximity could suppress numbers in a tightly packed formation.
 var nearby_popups: int = 0
 for child in get_children():
  if child is Label3D and not child.is_queued_for_deletion() and child.has_meta("hero_popup_slot") and int(child.get_meta("hero_popup_slot")) == slot:
   nearby_popups += 1
 if nearby_popups >= 3:
  return
 var popup: Label3D = FLOATING_TEXT.instantiate() as Label3D
 if popup == null:
  return
 popup.set("damage_amount", value)
 popup.set("heal", is_heal)
 popup.set("critical", false)
 popup.set("lane_index", nearby_popups)
 popup.set_meta("hero_popup_slot", slot)
 hero_popup_counter += 1
 add_child(popup)
 popup.global_position = hero.global_position + Vector3(0.0, 2.15, 0.0)

func _heal_heroes(amount: int, group_heal: bool = false) -> void:
 if amount <= 0:
  return
 if group_heal:
  var per_hero: int = maxi(1, int(ceil(float(amount) / 4.0)))
  for i in range(4):
   if hero_hp[i] > 0:
    var previous_hp: int = hero_hp[i]
    hero_hp[i] = mini(hero_max_hp[i], hero_hp[i] + per_hero)
    _show_hero_combat_number(i, hero_hp[i] - previous_hp, true)
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
   var previous_hp: int = hero_hp[target]
   hero_hp[target] = mini(hero_max_hp[target], hero_hp[target] + amount)
   _show_hero_combat_number(target, hero_hp[target] - previous_hp, true)
 _sync_team_health()

# Keep the defensive aura visible only while the corresponding equipped tank skill is active.
# Update 168: resolve the single living tank in one place.
# Tank role is never reassigned automatically on death or a role change.
func _living_tank_slot() -> int:
 if team_formation == null:
  return -1
 for slot in range(mini(4, mini(hero_hp.size(), team_formation.role_ids.size()))):
  if int(team_formation.role_ids[slot]) == 0 and hero_hp[slot] > 0:
   return slot
 return -1

func _refresh_tank_defense_visuals() -> void:
 if team_formation == null:
  return
 var protection_active: bool = false
 var active_tank: int = _living_tank_slot()
 if active_tank >= 0 and tank_intercept_until[active_tank] > 0 and tank_intercept_until[active_tank] >= skill_tick:
  protection_active = true
 if team_formation.has_method("set_team_protection_wall"):
  team_formation.set_team_protection_wall(protection_active)
 for slot in range(mini(4, team_formation.heroes.size())):
  var hero_visual: Node = team_formation.heroes[slot]
  if hero_visual == null:
   continue
  var motion: Node = hero_visual.find_child("HeroCombatMotion", true, false)
  if motion == null:
   motion = hero_visual.find_child("*CombatMotion*", true, false)
  if motion == null or not motion.has_method("set_tank_defense_state"):
   continue
  var kind: int = -1
  if slot == active_tank:
   if tank_intercept_until[slot] >= skill_tick and tank_intercept_until[slot] > 0:
    kind = 9
   elif tank_taunt_until[slot] >= skill_tick and tank_taunt_until[slot] > 0:
    kind = 8
  motion.set_tank_defense_state(kind)

# Update 162: Evasion uses each hero's defensive talent investment.
# Defense mitigation remains in the existing damage pipeline; it is not applied twice.
const HERO_BASE_DODGE_CHANCE: float = 0.05
const HERO_MAX_DODGE_CHANCE: float = 0.25

func _hero_dodge_chance(index: int) -> float:
 var chance: float = HERO_BASE_DODGE_CHANCE
 if team_formation == null:
  return chance
 if index < team_formation.talent_ranks.size():
  var ranks: Array = team_formation.talent_ranks[index]
  if ranks.size() > 1:
   # +0.1 percentage points per defensive rank, capped at +20 points.
   chance += minf(0.20, maxi(0, int(ranks[1])) * 0.001)
 return clampf(chance, 0.0, HERO_MAX_DODGE_CHANCE)

func _hero_dodges(index: int) -> bool:
 if index < 0 or index >= hero_hp.size() or hero_hp[index] <= 0:
  return false
 return randf() < _hero_dodge_chance(index)

func _damage_heroes(amount: int, targets: Array[int]) -> void:
 if amount <= 0:
  return
 var living: Array[int] = []
 for index in targets:
  # Update 163: repeated target IDs must not cause multiple hits in one attack.
  if index >= 0 and index < hero_hp.size() and hero_hp[index] > 0 and not living.has(index):
   living.append(index)
 if living.is_empty():
  return
 # Boss telegraphs select exact heroes; routine strikes favor the front-line tank.
 var per_target: int = maxi(1, int(ceil(float(amount) / float(living.size()))))
 # Update 165: Only the unique active tank may intercept damage.
 var interceptor: int = _living_tank_slot()
 if interceptor >= 0 and (tank_intercept_until[interceptor] <= 0 or tank_intercept_until[interceptor] < skill_tick):
  interceptor = -1
 var redirected: int = 0
 for index in living:
  if _hero_dodges(index):
   if team_formation != null and team_formation.has_method("play_dodge_targets"):
    team_formation.play_dodge_targets([index])
   continue
  var dealt: int = per_target
  if team_formation != null and index < team_formation.role_ids.size() and int(team_formation.role_ids[index]) == 0:
   dealt = maxi(1, int(round(float(dealt) * 0.75)))
  if interceptor >= 0 and index != interceptor:
   # Never redirect the full hit: the protected hero still takes damage.
   var intercepted: int = mini(dealt - 1, int(round(float(dealt) * 0.35)))
   dealt -= intercepted
   redirected += intercepted
  var was_alive: bool = hero_hp[index] > 0
  var previous_hp: int = hero_hp[index]
  hero_hp[index] = maxi(0, hero_hp[index] - dealt)
  _show_hero_combat_number(index, previous_hp - hero_hp[index], false)
  # Update 160: animate only a living target that actually lost HP.
  if hero_hp[index] > 0 and previous_hp > hero_hp[index] and team_formation != null and team_formation.has_method("play_hit_targets"):
   team_formation.play_hit_targets([index])
  if was_alive and hero_hp[index] == 0 and team_formation != null and team_formation.has_method("play_hero_defeat"):
   team_formation.play_hero_defeat(index)
 if interceptor >= 0 and redirected > 0 and hero_hp[interceptor] > 0:
  if team_formation != null and team_formation.has_method("play_team_protection_impact"):
   team_formation.play_team_protection_impact(biome_manager.current_biome if is_boss and biome_manager != null else -1)
  var absorbed: int = maxi(1, int(round(float(redirected) * 0.75)))
  var previous_tank_hp: int = hero_hp[interceptor]
  hero_hp[interceptor] = maxi(0, hero_hp[interceptor] - absorbed)
  _show_hero_combat_number(interceptor, previous_tank_hp - hero_hp[interceptor], false)
  # Intercepted damage also triggers a hit reaction on the protecting tank.
  if hero_hp[interceptor] > 0 and previous_tank_hp > hero_hp[interceptor] and team_formation != null and team_formation.has_method("play_hit_targets"):
   team_formation.play_hit_targets([interceptor])
  if hero_hp[interceptor] == 0 and team_formation != null and team_formation.has_method("play_hero_defeat"):
   team_formation.play_hero_defeat(interceptor)
 _sync_team_health()

# Update 168: active taunt guarantees the tank is targeted. Without taunt,
# enemies prefer the living tank but occasionally attack another living hero.
# Boss telegraphed target lists are handled separately and never overridden.
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

var skill_tick: int = 0
var boss_attack_cooldown: int = 0
# Boss casts last two combat ticks. Class-specific CC can interrupt the cast.
var boss_cast_ticks: int = 0
var boss_cast_name: String = ""
var boss_interrupt_ready_at: Array[int] = [0, 0, 0, 0]
var boss_interrupt_message: String = ""
var debuff_until_tick: int = 0
var debuff_element: int = -1
var debuff_next_dot_tick: int = 0
# Update 86: statuses inflicted on the team by actual boss-zone hits.
var team_element_status: int = -1
var team_status_until_tick: int = 0
var team_status_next_dot_tick: int = 0
var team_status_affected_heroes: Array[int] = []

var boss_phase_fx: BossPhaseFX
var boss_motion: TitanBossMotion
var last_ability: String = ""
var skill_choices: Array[int] = [0, 0, 0, 0]
var skill_ready_at: Array[int] = [0, 0, 0, 0]
# One automatic decision per hero, with a separate cooldown for each skill.
var auto_skill_ready_at: Array = [[0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0]]
# Exactly four player-selected abilities for each hero.
var skill_loadouts: Array = [[0, 1, 2, 7], [0, 1, 2, 7], [0, 1, 2, 7], [0, 1, 2, 7]]
var guard_until_tick: int = 0
var guard_strength: float = 0.0
var boss_intro: CanvasLayer
var talent_ready_at: Array = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]]

func set_skill_loadout(hero: int, skill_slot: int, ability: int) -> void:
 if hero < 0 or hero >= 4 or skill_slot < 0 or skill_slot >= 4:
  return
 skill_loadouts[hero][skill_slot] = clampi(ability, 0, 10)
 SaveManager.save_game()
 battle_status_changed.emit()

func set_skill_choice(slot: int, choice: int) -> void:
 # Compatibility with old menu/saves: changes the first skill slot only.
 set_skill_loadout(slot, 0, choice)


func _process(delta: float) -> void:
 if not battle_active:
  return
 enemy_animation_time += delta
 if is_boss:
  boss_elapsed += delta
  boss_time_remaining = maxf(0.0, BOSS_TIME_LIMIT - boss_elapsed)
  if boss_elapsed >= BOSS_TIME_LIMIT:
   _boss_time_expired()
   return
 for i in range(enemy_visuals.size()):
  var mob: Node3D = enemy_visuals[i]
  if is_instance_valid(mob):
   mob.position.y = sin(enemy_animation_time * 2.2 + float(i)) * 0.085
   mob.rotation.y = sin(enemy_animation_time * 0.85 + float(i)) * 0.12
func _ready() -> void:
 add_to_group("battle_manager")
 boss_intro = preload("res://scripts/boss_intro.gd").new()
 add_child(boss_intro)
 var progress: Vector2i = SaveManager.get_saved_battle_progress()
 current_level = progress.x
 current_wave = progress.y
 world_progress = progress
 var astral_save: Dictionary = SaveManager.get_saved_astral()
 astral_floor = maxi(1, int(astral_save.get("floor", 1)))
 astral_marks = maxi(0, int(astral_save.get("marks", 0)))
 skill_choices = SaveManager.get_saved_skill_choices()
 skill_loadouts = SaveManager.get_saved_skill_loadouts()
 attack_timer = Timer.new()
 attack_timer.wait_time = 0.25
 attack_timer.timeout.connect(_attack_tick)
 add_child(attack_timer)
 if team_formation != null:
  team_formation.walking_finished.connect(_on_walking_finished)
 if biome_manager != null:
  biome_manager.call("update_biome_from_stage", current_level)
 start_next_encounter()
func enter_astral() -> void:
 if astral_active:
  return
 world_progress = Vector2i(current_level, current_wave)
 astral_active = true
 current_level = astral_floor
 current_wave = 10
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
 defeat_reason = ""
 if team_hp <= 0:
  _reset_hero_health()
 battle_active = false
 attack_timer.stop()
 team_element_status = -1
 team_status_until_tick = 0
 team_status_affected_heroes.clear()
 if team_formation != null:
  team_formation.call("clear_elemental_status_auras")
 clear_enemies()
 boss_phase_fx = null
 boss_motion = null
 if team_formation != null:
  team_formation.call("start_walking")
 else:
  _on_walking_finished()
func _on_walking_finished() -> void:
 spawn_wave()
func spawn_wave() -> void:
 is_boss = astral_active or current_wave == 10
 is_fusion_boss = is_boss and current_level % 10 == 0
 enemies_remaining = 1 if is_boss else mini(2 + current_wave, 7)
 enemy_max_hp = (220 + current_level * 65) * (8 if is_fusion_boss else (5 if is_boss else 1))
 if astral_active:
  enemy_max_hp = int(round(float(enemy_max_hp) * (1.0 + float(astral_floor) * 0.14)))
 enemy_hp = enemy_max_hp * enemies_remaining
 for i in range(enemies_remaining):
  var mob: Node3D = Node3D.new()
  mob.position = Vector3((i - (enemies_remaining - 1) / 2.0) * 1.4, 0, -float(i % 2) * 1.0)
  enemy_spawn_node.add_child(mob)
  enemy_visuals.append(mob)
  var color: Color = Color("#b84d5b") if is_boss else Color("#779f57")
  if biome_manager != null:
   color = biome_manager.COLORS[biome_manager.current_biome]
  var size: float = 2.2 if is_boss else 0.65
  VisualFactory.sphere(mob, size, Vector3(0, size, 0), color)
  if is_boss:
   VisualFactory.sphere(mob, 0.5, Vector3(-0.7, size + 0.55, -1.65), Color("#f4df76"))
   VisualFactory.sphere(mob, 0.5, Vector3(0.7, size + 0.55, -1.65), Color("#f4df76"))
   VisualFactory.box(mob, Vector3(0.7, 1.5, 0.7), Vector3(-2.0, 2.2, 0), color.darkened(0.2))
   VisualFactory.box(mob, Vector3(0.7, 1.5, 0.7), Vector3(2.0, 2.2, 0), color.darkened(0.2))
  else:
   VisualFactory.sphere(mob, 0.19, Vector3(-0.23, size + 0.15, -0.52), Color("#f9ed9b"))
   VisualFactory.sphere(mob, 0.19, Vector3(0.23, size + 0.15, -0.52), Color("#f9ed9b"))
   VisualFactory.box(mob, Vector3(0.22, 0.52, 0.25), Vector3(-0.37, 0.25, 0), color.darkened(0.3))
   VisualFactory.box(mob, Vector3(0.22, 0.52, 0.25), Vector3(0.37, 0.25, 0), color.darkened(0.3))
  if is_boss:
   VisualFactory.cylinder(mob, 0.8, 1.0, Vector3(0, 4.6, 0), Color.GOLD)
  var biome_index: int = 3
  if biome_manager != null:
   biome_index = biome_manager.current_biome
  DesignDetails.enemy(mob, biome_index, is_boss, i + current_wave)
  if not is_boss:
   MobDetails.decorate(mob, biome_index, i + current_wave)
  if is_boss:
   BossArt.build(mob, biome_index, is_fusion_boss)
   preload("res://scripts/boss_arena.gd").decorate(mob, biome_index, is_fusion_boss)
   var aura := BossAura.new()
   mob.add_child(aura)
   aura.configure(biome_index, is_fusion_boss)
   boss_phase_fx = BossPhaseFX.new()
   mob.add_child(boss_phase_fx)
   boss_phase_fx.setup(mob, biome_index, is_fusion_boss)
   boss_motion = TitanBossMotion.new()
   mob.add_child(boss_motion)
   boss_motion.configure(mob, biome_index, is_fusion_boss)
   if is_fusion_boss:
    mob.scale = Vector3.ONE * 1.35
  if biome_index == 3:
   if is_boss:
    NatureArt.titan(mob)
   else:
    NatureArt.mob(mob, i + current_wave)
 battle_active = true
 boss_elapsed = 0.0
 boss_time_remaining = BOSS_TIME_LIMIT
 hero_attack_elapsed = [0.0, 0.0, 0.0, 0.0]
 boss_attack_cooldown = 0
 boss_cast_ticks = 0
 boss_cast_name = ""
 boss_interrupt_message = ""
 debuff_until_tick = 0
 debuff_element = -1
 debuff_next_dot_tick = 0
 last_ability = ""
 battle_status_changed.emit()
 if is_boss and not enemy_visuals.is_empty():
  var biome_names: Array[String] = ["FEUER", "WASSER", "ERDE", "NATUR", "LICHT", "SCHATTEN", "WIND", "EIS", "BLITZ", "CHAOS"]
  var element_index: int = biome_manager.current_biome if biome_manager != null else 3
  var element_name: String = biome_names[clampi(element_index, 0, biome_names.size() - 1)]
  await boss_intro.show_intro(enemy_visuals[0], element_name, is_fusion_boss)
  if not is_inside_tree() or not battle_active:
   return
 attack_timer.start()
# Update 91: Boss debuffs apply only to heroes actually inside a hit zone.
func _hero_is_controlled(hero_index: int) -> bool:
 if team_element_status < 0 or skill_tick > team_status_until_tick:
  return false
 if not hero_index in team_status_affected_heroes:
  return false
 # Frost blocks alternating combat ticks; shock blocks every third tick.
 if team_element_status == 7:
  return skill_tick % 2 == 0
 if team_element_status == 8:
  return skill_tick % 3 == 0
 return false

func _attack_tick() -> void:
 if not battle_active:
  return
 # Basic attacks have role-specific real-time intervals, independent of skill slot order.
 var basic_damage: int = 0
 var base_attack: int = 65 + GameManager.jewel_level * 18 + GameManager.current_reincarnation_level * 35 + current_level * 3
 if team_formation != null:
  for hero_index in range(mini(4, team_formation.role_ids.size())):
   if hero_hp[hero_index] <= 0:
    continue
   var hero_role: int = clampi(int(team_formation.role_ids[hero_index]), 0, 2)
   if _hero_is_controlled(hero_index):
    continue
   hero_attack_elapsed[hero_index] += attack_timer.wait_time
   if hero_attack_elapsed[hero_index] < ROLE_ATTACK_INTERVALS[hero_role]:
    continue
   hero_attack_elapsed[hero_index] -= ROLE_ATTACK_INTERVALS[hero_role]
   var role_multiplier: float = 0.45 if hero_role == 0 else (1.0 if hero_role == 1 else 0.35)
   basic_damage += int(round(float(base_attack) * role_multiplier))
   if team_formation.has_method("play_attack_for_hero"):
    team_formation.call("play_attack_for_hero", hero_index)
 else:
  basic_damage = base_attack
 if enemy_visuals.size() > 0 and is_instance_valid(enemy_visuals[0]):
  var target: Node3D = enemy_visuals[0]
  if team_formation != null:
   SkillFX.cast(self, team_formation, target, skill_tick + 1)
 skill_tick += 1
 _refresh_tank_defense_visuals()
 if team_element_status >= 0 and skill_tick > team_status_until_tick:
  team_element_status = -1
  team_status_affected_heroes.clear()
  if team_formation != null:
   team_formation.call("clear_elemental_status_auras")
  battle_status_changed.emit()
 var boss_cast_interrupted: bool = false
 # Only equipped CC skills may interrupt a boss cast.
 if is_boss and boss_cast_ticks > 0 and team_formation != null:
  for slot in range(mini(4, team_formation.class_ids.size())):
   if hero_hp[slot] <= 0 or _hero_is_controlled(slot) or not 7 in skill_loadouts[slot] or skill_tick < boss_interrupt_ready_at[slot]:
    continue
   var class_id: int = int(team_formation.class_ids[slot])
   var cc_name: String = TitanCrowdControl.ability_name(class_id)
   boss_interrupt_ready_at[slot] = skill_tick + TitanCrowdControl.cooldown_ticks(class_id)
   boss_cast_ticks = 0
   boss_cast_interrupted = true
   boss_cast_name = ""
   boss_interrupt_message = cc_name + " – Boss unterbrochen!"
   last_ability = boss_interrupt_message
   if slot < team_formation.heroes.size() and not enemy_visuals.is_empty():
    TitanCrowdControl.play_interrupt(self, team_formation.heroes[slot], enemy_visuals[0], class_id)
   break
 # Use ONLY the four skills equipped by the player; decide their timing automatically.
 var skill_bonus_damage: int = 0
 var skill_healing: int = 0
 if team_formation != null:
  for slot in range(mini(4, team_formation.role_ids.size())):
   if _hero_is_controlled(slot):
    continue
   var role: int = int(team_formation.role_ids[slot])
   var selected: int = _choose_automatic_skill(slot, role)
   if selected < 0:
    continue
   var skill: Dictionary = TitanSkillSystem.skill_for_role(role, selected)
   auto_skill_ready_at[slot][selected] = skill_tick + int(skill["cooldown"])
   skill_bonus_damage += TitanSkillSystem.damage_for_skill(skill, role, 65 + GameManager.jewel_level * 18 + GameManager.current_reincarnation_level * 35 + current_level * 3, enemies_remaining)
   skill_healing += int(round(float(team_max_hp) * float(skill["heal"])))
   if role == 0 and selected in [8, 9] and slot < team_formation.heroes.size():
    var hero_visual: Node = team_formation.heroes[slot]
    if hero_visual != null:
     var combat_motion: Node = hero_visual.find_child("HeroCombatMotion", true, false)
     if combat_motion == null:
      combat_motion = hero_visual.find_child("*CombatMotion*", true, false)
     if combat_motion != null and combat_motion.has_method("play_tank_skill_fx"):
      combat_motion.play_tank_skill_fx(selected)
   if role == 0:
    if selected == 8:
     tank_taunt_until[slot] = skill_tick + 4
    elif selected == 9:
     tank_intercept_until[slot] = skill_tick + 4
   if float(skill["guard"]) > 0.0:
    guard_strength = maxf(guard_strength, float(skill["guard"]))
    guard_until_tick = skill_tick + 3
   last_ability = str(skill["name"])
 # Every fifth combat tick the heroes perform a stronger class skill.
 var special_attack: bool = skill_tick % 5 == 0
 if last_ability == "":
  last_ability = "Standardangriff"
 var base_damage: int = 65 + GameManager.jewel_level * 18 + GameManager.current_reincarnation_level * 35 + current_level * 3
 var damage: int = basic_damage
 if team_formation != null and team_formation.has_formation_bonus():
  damage = int(round(float(damage) * 1.05))
 if special_attack:
  damage = int(round(float(damage) * 1.35))
 damage += skill_bonus_damage
 # Automatische Klassen-Talente: drei eigene Cooldowns pro Held.
 var talent_damage: int = 0
 if team_formation != null:
  for slot in range(mini(4, team_formation.class_ids.size())):
   if _hero_is_controlled(slot):
    continue
   for tree in range(3):
    var rank: int = int(team_formation.talent_ranks[slot][tree])
    if rank < TitanTalentAbilities.UNLOCK_RANK or skill_tick < int(talent_ready_at[slot][tree]):
     continue
    var branch: int = int(team_formation.talent_branches[slot][tree])
    var effect: Dictionary = TitanTalentAbilities.activate(int(team_formation.class_ids[slot]), tree, rank, branch, base_damage, team_max_hp)
    talent_ready_at[slot][tree] = skill_tick + TitanTalentAbilities.cooldown_ticks(tree, branch)
    talent_damage += int(effect["damage"])
    skill_healing += int(effect["heal"])
    if float(effect["guard"]) > 0.0:
     guard_strength = maxf(guard_strength, float(effect["guard"]))
     guard_until_tick = maxi(guard_until_tick, skill_tick + 3)
    last_ability = str(effect["name"])
    # Visual feedback for the talent that was actually activated.
    if slot < team_formation.heroes.size() and enemy_visuals.size() > 0:
     var fx_hero: Node3D = team_formation.heroes[slot]
     var fx_target: Node3D = enemy_visuals[0]
     TalentVisualFX.play(self, fx_hero, fx_target, int(team_formation.class_ids[slot]), tree, branch)
 damage += talent_damage
 if team_formation != null:
  var bonuses: Dictionary = TitanTalentSystem.team_bonuses(team_formation.class_ids, team_formation.talent_ranks, team_formation.talent_branches)
  damage = int(round(float(damage) * (1.0 + float(bonuses["attack"]))))
  skill_healing = int(round(float(skill_healing) * (1.0 + float(bonuses["healing"]))))
  # Update 98: distribute equipped-skill healing without reviving fallen heroes.
  # Prefer the most injured living hero for single-target healing.
  if skill_healing > 0:
   var wounded_living: int = 0
   for i in range(4):
    if hero_hp[i] > 0 and hero_hp[i] < hero_max_hp[i]:
     wounded_living += 1
   _heal_heroes(skill_healing, wounded_living >= 2)
 if skill_tick % 3 == 0:
  var incoming: int = 35 + current_level * 3
  var living_tank: bool = false
  if team_formation != null:
   for slot in range(mini(4, team_formation.role_ids.size())):
    if int(team_formation.role_ids[slot]) == 0 and hero_hp[slot] > 0:
     living_tank = true
     break
  incoming = int(round(incoming * (0.55 if living_tank else 1.0)))
  if debuff_element >= 0 and skill_tick <= debuff_until_tick and TitanElementDebuffs.slows_attack(debuff_element, is_boss):
   incoming = int(round(float(incoming) * 0.75))
  if team_formation != null:
   var bonuses: Dictionary = TitanTalentSystem.team_bonuses(team_formation.class_ids, team_formation.talent_ranks, team_formation.talent_branches)
   incoming = int(round(float(incoming) * (1.0 - float(bonuses["defense"]))))
  if skill_tick <= guard_until_tick:
   incoming = int(round(float(incoming) * (1.0 - guard_strength)))
  # A cast has a visible preparation tick. It deals bonus damage only if
  # no hero interrupts it before the following damage tick.
  last_boss_targets.clear()
  if is_boss:
   if boss_cast_ticks > 0:
    boss_cast_ticks -= 1
    if boss_cast_ticks == 0:
     incoming = int(round(float(incoming) * (2.1 if is_fusion_boss else 1.5)))
     last_ability = boss_cast_name + " trifft!"
     boss_cast_name = ""
     if enemy_visuals.size() > 0 and is_instance_valid(enemy_visuals[0]) and team_formation != null:
      var element_id: int = biome_manager.current_biome if biome_manager != null else 3
      BossAbilities.strike(self, enemy_visuals[0], team_formation, element_id, is_fusion_boss)
      var targets: Array[int] = BossAbilities.affected_heroes(team_formation, element_id, is_fusion_boss)
      # Damage only heroes inside the telegraphed boss attack.
      last_boss_targets = targets.duplicate()
      if not targets.is_empty():
       team_element_status = element_id
       team_status_until_tick = skill_tick + TitanElementDebuffs.duration_ticks(element_id, false)
       team_status_next_dot_tick = skill_tick + 1
       team_status_affected_heroes = targets.duplicate()
       team_formation.call("sync_elemental_status_aura", element_id, team_status_affected_heroes)
      if team_formation.has_method("play_elemental_hit_targets"):
       team_formation.play_elemental_hit_targets(element_id, targets)
      if is_instance_valid(boss_motion):
       boss_motion.attack_release()
   elif not boss_cast_interrupted:
    boss_attack_cooldown += 1
    if boss_attack_cooldown >= 2:
     boss_attack_cooldown = 0
     boss_cast_ticks = 1
     boss_cast_name = "Fusionsschlag" if is_fusion_boss else "Elementarschlag"
     boss_interrupt_message = ""
     last_ability = "Boss wirkt " + boss_cast_name + "!"
     if is_instance_valid(boss_phase_fx):
      boss_phase_fx.telegraph_attack()
     if is_instance_valid(boss_motion):
      boss_motion.attack_windup()
     if team_formation != null:
      var warn_element: int = biome_manager.current_biome if biome_manager != null else 3
      BossAbilities.warn(self, team_formation, warn_element, is_fusion_boss)
  var hit_targets: Array[int] = last_boss_targets.duplicate()
  if hit_targets.is_empty() and boss_cast_name == "":
   var routine_target: int = _choose_routine_enemy_target()
   if routine_target >= 0:
    hit_targets = [routine_target]
  _damage_heroes(incoming, hit_targets)
  if incoming > 0:
   # Passive healer support is only available from a living, uncontrolled healer.
   # No healing or resurrection for a hero already at zero HP.
   var active_healers: int = 0
   if team_formation != null:
    for hero_slot in range(mini(4, team_formation.role_ids.size())):
     if int(team_formation.role_ids[hero_slot]) == 2 and hero_hp[hero_slot] > 0 and not _hero_is_controlled(hero_slot):
      active_healers += 1
   if active_healers > 0:
    var wounded_target: bool = false
    for hero_slot in range(4):
     if hero_hp[hero_slot] > 0 and hero_hp[hero_slot] < hero_max_hp[hero_slot]:
      wounded_target = true
      break
    if wounded_target:
     _heal_heroes(active_healers * (40 + current_level * 2), false)
  if team_hp <= 0:
   # Update 96: keep the fallen heroes visible until the retry begins.
   # No resurrection or healing is possible while the party is defeated.
   battle_active = false
   attack_timer.stop()
   defeat_reason = "team_wipe"
   last_ability = "Team besiegt! Neuer Versuch auf derselben Stage."
   battle_status_changed.emit()
   await get_tree().create_timer(2.0).timeout
   if is_inside_tree():
    start_next_encounter()
   return
 var critical: bool = randf() < 0.2
 if critical:
  damage *= 2
 # Elemental status is applied on every fourth attack, with shorter boss duration.
 var current_element: int = biome_manager.current_biome if biome_manager != null else 3
 if skill_tick % 4 == 0:
  debuff_element = current_element
  debuff_until_tick = skill_tick + TitanElementDebuffs.duration_ticks(current_element, is_boss)
  debuff_next_dot_tick = skill_tick + 1
  boss_interrupt_message = TitanElementDebuffs.status_name(current_element) + " aktiv"
 if debuff_element >= 0 and skill_tick <= debuff_until_tick:
  damage = int(round(float(damage) * TitanElementDebuffs.damage_multiplier(debuff_element, is_boss)))
  if skill_tick >= debuff_next_dot_tick:
   damage += TitanElementDebuffs.periodic_damage(debuff_element, base_damage, is_boss)
   debuff_next_dot_tick = skill_tick + 1
 elif skill_tick > debuff_until_tick:
  debuff_element = -1
 enemy_hp = maxi(0, enemy_hp - damage)
 if is_boss and is_instance_valid(boss_phase_fx) and enemy_max_hp > 0:
  boss_phase_fx.set_health_ratio(float(enemy_hp) / float(enemy_max_hp))
  if is_instance_valid(boss_motion):
   boss_motion.set_enraged(float(enemy_hp) / float(enemy_max_hp) <= 0.35)
 if enemy_visuals.size() > 0 and is_instance_valid(enemy_visuals[0]):
  var hit_target: Node3D = enemy_visuals[0]
  var element_id: int = biome_manager.current_biome if biome_manager != null else 3
  TitanElementImpactFX.show_hit(hit_target, element_id, critical, is_boss)
  if is_boss and is_instance_valid(boss_motion):
   boss_motion.react_to_hit(critical)
  if skill_tick % 4 == 0 or critical:
   TitanElementStatusFX.pulse(hit_target, element_id, is_boss)
  TitanElementImpactFX.show_damage_label(self, hit_target, FLOATING_TEXT, damage, critical, is_boss)
  # Short squash-and-recover hit reaction, independent of attack animation.
  var normal_scale: Vector3 = Vector3.ONE * (1.35 if is_fusion_boss else 1.0)
  var hit_tween: Tween = create_tween()
  # Update 156: critical hits have a stronger visual recoil, without altering damage.
  var impact_scale: Vector3 = Vector3(1.17, 0.83, 1.17) if critical else Vector3(1.08, 0.91, 1.08)
  hit_tween.tween_property(hit_target, "scale", normal_scale * impact_scale, 0.09 if critical else 0.075)
  hit_tween.tween_property(hit_target, "scale", normal_scale, 0.22 if critical else 0.16)
 if enemy_hp <= 0:
  finish_wave()
 battle_status_changed.emit()
func _boss_time_expired() -> void:
  # Enrage finisher: after 60 seconds the boss defeats the entire party in one hit.
  # This is a loss, so do not grant loot or advance the stage.
  if not battle_active or not is_boss:
   return
  battle_active = false
  attack_timer.stop()
  team_element_status = -1
  team_status_affected_heroes.clear()
  if team_formation != null:
   team_formation.call("clear_elemental_status_auras")
  boss_time_remaining = 0.0
  last_ability = "60 Sekunden! Boss setzt Vernichtungsschlag ein!"
  if is_instance_valid(boss_phase_fx):
   boss_phase_fx.telegraph_attack()
  if is_instance_valid(boss_motion):
   boss_motion.attack_release()
  if enemy_visuals.size() > 0 and is_instance_valid(enemy_visuals[0]) and team_formation != null:
   var element_id: int = biome_manager.current_biome if biome_manager != null else 3
   BossAbilities.strike(self, enemy_visuals[0], team_formation, element_id, is_fusion_boss)
  if is_instance_valid(boss_phase_fx):
   boss_phase_fx.play_finisher_explosion()
  if team_formation != null and team_formation.has_method("play_team_defeat"):
   team_formation.call("play_team_defeat")
  for hero in range(4):
   hero_hp[hero] = 0
  _sync_team_health()
  defeat_reason = "boss_finisher"
  last_ability = "Vernichtungsschlag! Das gesamte Team wurde besiegt."
  battle_status_changed.emit()
  # Keep the defeated state visible briefly before retrying this same stage.
  await get_tree().create_timer(2.0).timeout
  if is_inside_tree():
   if team_formation != null and team_formation.has_method("reset_team_defeat_pose"):
    team_formation.call("reset_team_defeat_pose")
   start_next_encounter()

func finish_wave() -> void:
 battle_active = false
 attack_timer.stop()
 var gold_reward: int = current_level * (500 if is_fusion_boss else (250 if is_boss else 50))
 if team_formation != null and team_formation.has_formation_bonus():
  gold_reward = int(round(gold_reward * 1.05))
 GameManager.add_gold(gold_reward)
 if astral_active:
  astral_marks += 5 + mini(astral_floor, 50)
  astral_floor += 1
  current_level = astral_floor
  current_wave = 10
  SaveManager.save_game()
  start_next_encounter()
  return
 if is_boss:
  GameManager.character_level += 1
  current_level += 1
  current_wave = 1
  if biome_manager != null:
   biome_manager.call("update_biome_from_stage", current_level)
 else:
  current_wave += 1
 SaveManager.save_game()
 start_next_encounter()
func clear_enemies() -> void:
 for mob in enemy_visuals:
  if is_instance_valid(mob):
   mob.queue_free()
 enemy_visuals.clear()

# Player loadout is authoritative. CC (7) is handled during a boss cast above.
# The player's slot order is authoritative in every battle using this manager.
# Slot 1 is checked first; a skill on cooldown or with unmet conditions is skipped.
func _choose_automatic_skill(slot: int, role: int) -> int:
 # The loadout order remains authoritative; support skills wait for actual injuries.
 var hp_ratio: float = 1.0
 var wounded_count: int = 0
 for i in range(4):
  if hero_hp[i] > 0:
   hp_ratio = minf(hp_ratio, float(hero_hp[i]) / float(maxi(1, hero_max_hp[i])))
   if hero_hp[i] < hero_max_hp[i]:
    wounded_count += 1
 for ability in skill_loadouts[slot]:
  var index: int = int(ability)
  # CC is triggered only by an active boss cast in _attack_tick.
  if index == 7:
   continue
  if index < 0 or index >= auto_skill_ready_at[slot].size():
   continue
  if skill_tick < int(auto_skill_ready_at[slot][index]):
   continue
  # Healer support is only used when health is actually missing.
  if role == 2:
   if index == 2 and (hp_ratio > 0.55 or wounded_count == 0):
    continue
   if index == 1 and (hp_ratio > 0.80 or wounded_count == 0):
    continue
   if index == 0 and (hp_ratio > 0.70 or wounded_count == 0):
    continue
  return index
 return -1
