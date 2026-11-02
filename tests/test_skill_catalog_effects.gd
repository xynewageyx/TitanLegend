extends SceneTree
const SKILLS = preload("res://scripts/skill_system.gd")
const RULES = preload("res://scripts/skill_targeting_rules.gd")

func _initialize() -> void:
 for role in range(3):
  var max_choice: int = 10 if role == 0 else (9 if role == 2 else 8)
  for choice in range(max_choice):
   if choice == 7:
    continue # Class-specific interrupt lives in its own catalog.
   var skill: Dictionary = SKILLS.skill_for_role(role, choice)
   assert(RULES.valid_effect(skill), "Invalid effect role=%d choice=%d" % [role, choice])
   var effect: String = str(skill["effect"])
   var power: float = float(skill.get("power", 0.0))
   var healing: float = float(skill.get("heal", 0.0))
   var guard: float = float(skill.get("guard", 0.0))
   assert(not (power > 0.0 and healing > 0.0), "Hybrid damage/heal: " + str(skill["name"]))
   assert(not (power > 0.0 and guard > 0.0), "Hybrid damage/guard: " + str(skill["name"]))
   if effect == "single_damage" or effect == "area_damage":
    assert(power > 0.0 and healing == 0.0)
   if effect == "single_heal" or effect == "group_heal":
    assert(power == 0.0)
   if effect == "area_damage":
    assert(bool(skill.get("aoe", false)))
   if effect == "group_heal":
    assert(healing > 0.0)
 print("Skill catalog effect checks passed")
 quit()
