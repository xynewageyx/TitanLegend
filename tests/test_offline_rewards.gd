extends SceneTree
const OFFLINE = preload("res://scripts/offline_rewards.gd")
const STORE = preload("res://scripts/save_file_store.gd")
const EXPERIENCE = preload("res://scripts/experience_system.gd")
const TEST_PATH: String = "user://ci_offline_income.json"

func _initialize() -> void:
 call_deferred("_test")

func _test() -> void:
 var base: int = 1800000000
 var no_activity: Dictionary = OFFLINE.calculate(10, base, base + 299)
 if int(no_activity["gold"]) != 0 or int(no_activity["xp"]) != 0:
  _fail("Offline farm must start only after 5 minutes")
  return
 var five_minutes: Dictionary = OFFLINE.calculate(10, base, base + 300)
 if int(five_minutes["waves"]) != 5 or int(five_minutes["gold"]) != 2500 or int(five_minutes["xp"]) != 500:
  _fail("Normal-wave reward balance incorrect")
  return
 var eight_hours: Dictionary = OFFLINE.calculate(10, base, base + 8 * 3600)
 var twelve_hours: Dictionary = OFFLINE.calculate(10, base, base + 12 * 3600)
 if eight_hours != twelve_hours:
  _fail("Offline accrual must be capped at eight hours")
  return
 if int(eight_hours["waves"]) != 480 or int(eight_hours["gold"]) != 240000 or int(eight_hours["xp"]) != 48000:
  _fail("Eight-hour offline gold incorrect")
  return
 if int(OFFLINE.calculate(10, base, base - 1)["gold"]) != 0 or int(OFFLINE.calculate(10, base, base - 1)["xp"]) != 0:
  _fail("Clock moved backwards: offline gold must be zero")
  return
 if int(OFFLINE.calculate(9000, base, base + 300)["gold"]) != 300000 or int(OFFLINE.calculate(9000, base, base + 300)["xp"]) != 60000:
  _fail("Offline stage limit of 1200 is not enforced")
  return
 if int(OFFLINE.calculate(1, 0, base + 9999)["gold"]) != 0 or int(OFFLINE.calculate(1, 0, base + 9999)["xp"]) != 0:
  _fail("Legacy saves without timestamps must not receive retroactive income")
  return
 var initial: Dictionary = {
  "version": 1, "gold": 1000, "stage": 10, "wave": 10,
  "last_active_unix": base, "equipment_inventory": [{"id": 1, "rarity": 3}],
  "character_level": 8, "character_xp": 1200, "astral_floor": 4, "skill_choices": [1, 0, 1, 0]
 }
 var payout: Dictionary = OFFLINE.make_claim(initial, base + 300)
 var updated: Dictionary = payout["save"]
 if int(updated["gold"]) != 3500:
  _fail("Claim did not credit expected gold")
  return
 if int(payout["reward"]["xp"]) != 500 or int(updated["character_xp"]) != 1700:
  _fail("Claim did not credit expected XP")
  return
 if int(updated["character_level"]) != 8:
  _fail("Five minutes must not produce an unbalanced level jump")
  return
 if int(EXPERIENCE.mob_wave_xp(10)) != 100 or int(EXPERIENCE.xp_for_next_level(8)) != 13000:
  _fail("Offline and online XP scaling diverged")
  return
 for field in ["stage", "wave", "equipment_inventory", "astral_floor", "skill_choices"]:
  if updated[field] != initial[field]:
   _fail("Offline payout changed forbidden progress: " + str(field))
   return
 for suffix in ["", ".bak", ".tmp", ".bak.tmp"]:
  var path: String = TEST_PATH + str(suffix)
  if FileAccess.file_exists(path):
   DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
 var saved: Error = STORE.save_atomic(TEST_PATH, updated)
 if saved != OK:
  _fail("Offline claim could not be stored atomically: " + str(saved))
  return
 var loaded: Dictionary = STORE.load_latest(TEST_PATH)
 var again: Dictionary = OFFLINE.make_claim(loaded, base + 300)
 if int(again["reward"]["gold"]) != 0 or int(again["reward"]["xp"]) != 0 or int(again["save"]["gold"]) != 3500 or int(again["save"]["character_xp"]) != 1700:
  _fail("Offline rewards can be claimed more than once for the same period")
  return
 # Daily log-in under threshold does not yield bonus or modify stage.
 if int(OFFLINE.make_claim(loaded, base + 330)["reward"]["gold"]) != 0 or int(OFFLINE.make_claim(loaded, base + 330)["reward"]["xp"]) != 0:
  _fail("Short return produced additional rewards")
  return
 # Acht Stunden muessen XP-Levelaufstiege erlauben, ohne Boss- oder Stage-Siege.
 var long_claim: Dictionary = OFFLINE.make_claim(initial, base + 8 * 3600)
 var long_save: Dictionary = long_claim["save"]
 var long_reward: Dictionary = long_claim["reward"]
 var gained: Dictionary = EXPERIENCE.apply_xp(8, 1200, 48000)
 if int(long_reward["xp"]) != 48000 or int(long_reward["levels_gained"]) != int(gained["levels_gained"]):
  _fail("Eight-hour reward did not grant XP levels")
  return
 if int(long_save["character_level"]) != int(gained["level"]) or int(long_save["character_xp"]) != int(gained["xp"]):
  _fail("Offline XP did not carry over across level thresholds")
  return
 if int(long_save["stage"]) != 10 or int(long_save["wave"]) != 10 or long_save["equipment_inventory"] != initial["equipment_inventory"]:
  _fail("Offline XP must not clear bosses, loot, or stage progress")
  return
 var old_save: Dictionary = {"version": 1, "stage": 10, "wave": 2, "gold": 1000, "character_level": 5}
 var legacy_result: Dictionary = OFFLINE.make_claim(old_save, base + 8 * 3600)
 if int(legacy_result["reward"]["xp"]) != 0 or int(legacy_result["save"].get("character_level", 5)) != 5:
  _fail("Legacy save without timestamp must never get retroactive XP")
  return
 var near_threshold: Dictionary = EXPERIENCE.apply_xp(8, 12900, 500)
 if int(near_threshold["level"]) != 9 or int(near_threshold["xp"]) != 400:
  _fail("XP level boundary incorrectly advances progress")
  return
 for suffix in ["", ".bak", ".tmp", ".bak.tmp"]:
  var path: String = TEST_PATH + str(suffix)
  if FileAccess.file_exists(path):
   DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
 print("Titan Legends offline-income tests passed: Gold+XP, 5min, 8h, level-ups, stage cap, no bosses, durable once-only claim")
 quit(0)

func _fail(message: String) -> void:
 push_error(message)
 quit(1)
