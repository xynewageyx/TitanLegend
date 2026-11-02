extends SceneTree

const INTERRUPTS = preload("res://scripts/class_interrupt_skills.gd")
const RULES = preload("res://scripts/skill_targeting_rules.gd")

func _initialize() -> void:
 assert(INTERRUPTS.NAMES.size() == 11)
 assert(INTERRUPTS.VFX.size() == 11)
 var names: Dictionary = {}
 for class_id in range(11):
  var skill: Dictionary = INTERRUPTS.definition_for_class(class_id)
  assert(RULES.valid_effect(skill))
  assert(str(skill.get("effect", "")) == "interrupt")
  assert(float(skill.get("power", -1.0)) == 0.0)
  assert(float(skill.get("heal", -1.0)) == 0.0)
  assert(not bool(skill.get("aoe", true)))
  assert(not names.has(skill["name"]))
  names[skill["name"]] = true
  assert(not INTERRUPTS.vfx_for_class(class_id).is_empty())
 assert(names.size() == 11)
 print("Class interrupt definitions passed")
 quit()
