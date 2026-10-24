extends SceneTree
const AFK = preload("res://scripts/afk_farming_policy.gd")
const EXPERIENCE = preload("res://scripts/experience_system.gd")

func _initialize() -> void:
 call_deferred("_run_tests")

func _run_tests() -> void:
 var now: int = 500000
 var recent_input: int = now - 299999
 if AFK.should_activate(recent_input, now, false, false):
  _fail("AFK entered before five minutes")
  return
 if not AFK.should_activate(now - 300000, now, false, false):
  _fail("AFK did not enter at five-minute boundary")
  return
 if AFK.should_activate(now - 310000, now, true, false):
  _fail("AFK must not farm Astral bosses")
  return
 if AFK.should_activate(now - 310000, now, false, true):
  _fail("AFK must not run while Android is paused")
  return
 if AFK.should_activate(now + 1, now, false, false):
  _fail("Monotonic clock inversion yielded AFK state")
  return
 if AFK.is_boss_encounter(true, false, 10) or AFK.is_boss_encounter(true, true, 10):
  _fail("AFK encounter was incorrectly classified as boss")
  return
 if not AFK.is_boss_encounter(false, false, 10):
  _fail("Returning player must retain their boss encounter")
  return
 if not AFK.is_boss_encounter(false, true, 2):
  _fail("Astral boss logic must remain unchanged")
  return
 if AFK.can_advance_stage(true) or not AFK.can_advance_stage(false):
  _fail("AFK stage progression guard incorrect")
  return
 if AFK.reward_ready(true, true, false, now - 1, now) or not AFK.reward_ready(true, true, false, now, now):
  _fail("AFK one-minute payout limit not enforced")
  return
 if AFK.reward_ready(true, true, true, now + 999, now) or AFK.reward_ready(false, true, false, now + 999, now):
  _fail("AFK reward issued outside of active play")
  return
 if AFK.reward_ready(true, false, false, now + 999, now):
  _fail("AFK reward issued without a defeated mob wave")
  return

 # Integration: root scene, boss checkpoint, AFK mobs, capped payout, return.
 var packed: PackedScene = load("res://scenes/main.tscn")
 if packed == null:
  _fail("Titan Legends scene could not load for AFK integration")
  return
 var scene: Node3D = packed.instantiate()
 root.add_child(scene)
 var battle: Node = scene.get_node("BattleManager")
 if battle == null:
  _fail("BattleManager missing")
  return
 battle.current_level = 10
 battle.current_wave = 10
 battle.world_progress = Vector2i(10, 10)
 battle.astral_active = false
 battle._last_player_input_ms = Time.get_ticks_msec() - AFK.IDLE_TO_AFK_MS
 battle._enter_afk_farming(Time.get_ticks_msec())
 if not battle.afk_farming:
  _fail("Five-minute in-game AFK could not activate")
  return
 battle.spawn_wave()
 if battle.is_boss or not battle.battle_active:
  _fail("AFK wave 10 must spawn normal mobs instead of a boss")
  return
 var manager: Node = root.get_node_or_null("GameManager")
 if manager == null:
  _fail("Godot --script test could not resolve the game autoload")
  return
 var gold_before: int = int(manager.current_gold)
 var level_before: int = int(manager.character_level)
 var xp_before: int = int(manager.character_xp)
 battle.finish_wave()
 if not battle._afk_wave_pending or battle.current_level != 10 or battle.current_wave != 10:
  _fail("AFK mob victory changed the saved boss checkpoint")
  return
 if manager.current_gold != gold_before or manager.character_xp != xp_before:
  _fail("AFK payout was granted before the one-minute interval")
  return
 battle._afk_next_reward_ms = Time.get_ticks_msec() - 1
 battle._process(0.016)
 if manager.current_gold != gold_before + 500:
  _fail("AFK payout did not grant normal-wave gold")
  return
 var expected: Dictionary = EXPERIENCE.apply_xp(level_before, xp_before, 100)
 if manager.character_level != int(expected["level"]) or manager.character_xp != int(expected["xp"]):
  _fail("AFK payout did not grant normal-wave XP")
  return
 if battle.current_level != 10 or battle.current_wave != 10 or battle._afk_wave_pending:
  _fail("AFK payout advanced stage or duplicated itself")
  return
 # Same frame cannot pay again.
 battle._process(0.016)
 if manager.current_gold != gold_before + 500:
  _fail("AFK gold paid twice during the same interval")
  return
 # Ein laufender Lauf-Tween darf nach Verlassen des AFK-Modus keinen
 # spaeten Mobkampf auf dem Bosscheckpoint erzwingen.
 battle.start_next_encounter()
 var team: Node = scene.get_node("TeamFormation")
 if team == null or not team.is_walking or not battle._walking_for_encounter:
  _fail("Could not start a walking animation before leaving AFK")
  return
 battle._leave_afk_farming()
 if battle.afk_farming or team.is_walking or battle._walking_for_encounter:
  _fail("AFK exit failed to cancel a stale walking tween")
  return
 battle._on_walking_finished()
 if battle.battle_active:
  _fail("Old walking signal unexpectedly started a new encounter")
  return
 # Android pause/resume waehrend Laufanimation darf den Kampf nicht verlieren.
 battle.start_next_encounter()
 if not team.is_walking:
  _fail("Normal boss walking did not begin after AFK exit")
  return
 battle._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
 if team.is_walking or not battle._resume_walk_after_pause:
  _fail("Android pause did not cancel and remember pending walk")
  return
 battle._notification(Node.NOTIFICATION_APPLICATION_RESUMED)
 if battle._resume_walk_after_pause:
  _fail("Android resume did not schedule a new encounter")
  return
 battle._start_queued_encounter(battle._encounter_request_id)
 if not team.is_walking or not battle._walking_for_encounter:
  _fail("Boss walking was not restarted after Android resume")
  return
 battle._on_walking_finished()
 if not battle.is_boss or battle.current_level != 10 or battle.current_wave != 10:
  _fail("Boss checkpoint did not resume after user returned")
  return
 # Ein verspaeteter zweiter Walking-Callback darf den Boss nicht neu erzeugen.
 var remaining_hp: int = battle.enemy_hp
 battle._on_walking_finished()
 if battle.enemy_hp != remaining_hp:
  _fail("Duplicate walking callback reset boss health")
  return
 scene.queue_free()
 print("Titan Legends AFK integration passed: 5min, Gold+XP, no duplicate walking, Android resume, boss preserved")
 quit(0)

func _fail(message: String) -> void:
 push_error(message)
 quit(1)
