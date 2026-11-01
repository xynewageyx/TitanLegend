extends SceneTree
const RULES = preload("res://scripts/skill_targeting_rules.gd")

func _initialize() -> void:
 assert(RULES.single_heal_target([2500, 1200, 2700, 3000], [10000, 4000, 4500, 5000]) == 0)
 assert(RULES.single_heal_target([0, 50, 100], [100, 100, 100]) == 1)
 assert(RULES.single_heal_target([100, 100], [100, 100]) == -1)
 assert(RULES.single_heal_target([25, 50], [100, 100], false, 0) == 1)
 assert(RULES.single_heal_target([25, 50], [100, 200]) == 0)
 assert(RULES.valid_effect({"effect": "single_heal"}))
 assert(not RULES.valid_effect({"effects": ["area_damage", "interrupt"]}))
 assert(not RULES.is_area({"effect": "single_damage"}))
 assert(RULES.is_area({"effect": "area_damage"}))
 assert(RULES.can_interrupt({"effect": "interrupt"}, true, true))
 assert(not RULES.can_interrupt({"effect": "interrupt"}, false, true))
 assert(not RULES.can_interrupt({"effect": "area_damage"}, true, true))
 print("Skill targeting rules passed")
 quit()
