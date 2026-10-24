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
 battle._leave_afk_farming()
 if battle.afk_farming:
  _fail("AFK did not stop on user return")
  return
 battle.spawn_wave()
 if not battle.is_boss:
  _fail("Boss checkpoint did not resume after user returned")
  return
 scene.queue_free()
 print("Titan Legends AFK integration passed: 5min activation, boss protected, one payout/min, Gold+XP, return to boss")
 quit(0)

func _fail(message: String) -> void:
 push_error(message)
 quit(1)
