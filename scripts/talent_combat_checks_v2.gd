extends RefCounted
const ADAPTER = preload("res://scripts/talent_combat_adapter_v2.gd")
const TREES = preload("res://scripts/talent_tree_v2.gd")
static func run_checks() -> Dictionary:
 var failures: Array[String] = []
 for class_id in range(ADAPTER.CLASS_ATTACK_WEIGHTS.size()):
  var build: Array = TREES.empty_build()
  if not TREES.upgrade(2, build, 0, 0):
   failures.append("upgrade " + str(class_id))
  var bonus: Dictionary = ADAPTER.bonuses(class_id, 2, build)
  if float(bonus["attack"]) <= 0.0:
   failures.append("attack bonus " + str(class_id))
  if ADAPTER.apply_attack(100, bonus) < 100:
   failures.append("attack scaling " + str(class_id))
  if ADAPTER.apply_incoming_damage(100, bonus) > 100:
   failures.append("defense scaling " + str(class_id))
  if ADAPTER.apply_healing(100, bonus) < 100:
   failures.append("healing scaling " + str(class_id))
 return {"passed": failures.is_empty(), "failures": failures}
