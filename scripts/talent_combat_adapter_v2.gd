extends RefCounted
## Optional adapter: converts V2 talent ranks to bounded combat bonuses.
## The legacy three-rank talent system remains authoritative until migration.
const TREES = preload("res://scripts/talent_tree_v2.gd")
const CLASS_ATTACK_WEIGHTS := [1.0, 0.85, 0.75, 0.8, 1.15, 1.2, 1.2, 1.1, 0.95, 0.65, 1.1]
const CLASS_DEFENSE_WEIGHTS := [1.15, 1.2, 1.05, 1.0, 0.8, 0.75, 0.75, 0.85, 0.9, 1.0, 1.0]
const CLASS_HEAL_WEIGHTS := [0.5, 1.0, 1.2, 1.1, 0.5, 0.4, 0.6, 0.75, 0.8, 1.3, 0.5]

static func bonuses(class_id: int, level: int, build: Array) -> Dictionary:
 var safe: Array = TREES.validate_build(level, build)
 var ranks: Array[int] = [0, 0, 0]
 for branch in range(3):
  for value in safe[branch]:
   ranks[branch] += int(value)
 var index: int = clampi(class_id, 0, 10)
 return {
  "attack": minf(0.75, float(ranks[0]) * 0.006 * CLASS_ATTACK_WEIGHTS[index]),
  "defense": minf(0.35, float(ranks[1]) * 0.003 * CLASS_DEFENSE_WEIGHTS[index]),
  "healing": minf(0.75, float(ranks[2]) * 0.006 * CLASS_HEAL_WEIGHTS[index])
 }

static func apply_attack(base_damage: int, bonus: Dictionary) -> int:
 return maxi(0, roundi(float(maxi(0, base_damage)) * (1.0 + float(bonus.get("attack", 0.0)))))

static func apply_incoming_damage(raw_damage: int, bonus: Dictionary) -> int:
 return maxi(0, roundi(float(maxi(0, raw_damage)) * (1.0 - float(bonus.get("defense", 0.0)))))

static func apply_healing(base_heal: int, bonus: Dictionary) -> int:
 return maxi(0, roundi(float(maxi(0, base_heal)) * (1.0 + float(bonus.get("healing", 0.0)))))
