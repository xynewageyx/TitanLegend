extends RefCounted
const BALANCE = preload("res://scripts/progression_balance_v1.gd")
const TALENTS = preload("res://scripts/talent_tree_v2.gd")
static func run_checks() -> Dictionary:
 var errors: Array[String] = []
 if BALANCE.wave_xp(1, 0) != 24:
  errors.append("wave one")
 if BALANCE.talent_points_earned(250) != 747:
  errors.append("talent total")
 var build: Array = TALENTS.empty_build()
 if not TALENTS.upgrade(2, build, 0, 0):
  errors.append("upgrade")
 if TALENTS.available_points(2, build) != 2:
  errors.append("remaining points")
 return {"passed": errors.is_empty(), "errors": errors}
