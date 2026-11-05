extends SceneTree

const INTERRUPTS = preload("res://scripts/class_interrupt_skills.gd")
const RULES = preload("res://scripts/skill_targeting_rules.gd")
const VFX = preload("res://scripts/skill_vfx_3d_v1.gd")

func _initialize() -> void:
 assert(INTERRUPTS.NAMES.size() == 12)
 assert(INTERRUPTS.VFX.size() == 12)
 var names: Dictionary = {}
 for class_id in range(12):
  var skill: Dictionary = INTERRUPTS.definition_for_class(class_id)
  assert(RULES.valid_effect(skill))
  assert(str(skill.get("effect", "")) == "interrupt")
  assert(float(skill.get("power", -1.0)) == 0.0)
  assert(float(skill.get("heal", -1.0)) == 0.0)
  assert(not bool(skill.get("aoe", true)))
  assert(not names.has(skill["name"]))
  names[skill["name"]] = true
  var effect_id: String = INTERRUPTS.vfx_for_class(class_id)
  assert(not effect_id.is_empty())
  assert(VFX.SKILL_STYLE.has(effect_id))
  assert(VFX.COLORS.has(VFX.SKILL_STYLE[effect_id]))
 assert(names.size() == 12)
 print("Class interrupt definitions passed")
 quit()
