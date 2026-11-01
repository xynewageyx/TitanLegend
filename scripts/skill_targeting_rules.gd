extends RefCounted
class_name TitanSkillTargetingRules

# Pure targeting rules: skill properties determine their effect, never the AI.
const EFFECTS := ["single_damage", "area_damage", "single_heal", "group_heal", "shield", "buff", "control", "interrupt"]

static func valid_effect(skill: Dictionary) -> bool:
 var effect: String = str(skill.get("effect", ""))
 return EFFECTS.has(effect) and not skill.has("effects")

static func is_area(skill: Dictionary) -> bool:
 return str(skill.get("effect", "")) == "area_damage"

static func single_heal_target(hp: Array, max_hp: Array, allow_self: bool = true, caster_slot: int = -1) -> int:
 var best: int = -1
 for i in range(mini(hp.size(), max_hp.size())):
  if not allow_self and i == caster_slot:
   continue
  var current: int = int(hp[i])
  var maximum: int = int(max_hp[i])
  if maximum <= 0 or current <= 0 or current >= maximum:
   continue
  if best == -1:
   best = i
   continue
  var best_hp: int = int(hp[best])
  var best_max: int = int(max_hp[best])
  # Cross multiplication avoids rounding errors in percentage comparisons.
  var lhs: int = current * best_max
  var rhs: int = best_hp * maximum
  if lhs < rhs or (lhs == rhs and current < best_hp):
   best = i
 return best

static func can_interrupt(skill: Dictionary, enemy_casting: bool, cast_interruptible: bool) -> bool:
 return valid_effect(skill) and str(skill.get("effect", "")) == "interrupt" and enemy_casting and cast_interruptible
