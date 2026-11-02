extends RefCounted
class_name TitanClassInterruptSkills

# Matches TeamFormation.CLASS_NAMES class ID order.
const NAMES: Array[String] = [
 "Schildramme", "Heiliger Bann", "Wurzelgriff",
 "Donnerunterbrechung", "Betaeubungspfeil", "Kehlenschnitt",
 "Arkaner Gegenzauber", "Seelenfessel", "Dimensionsgriff",
 "Heiliges Schweigen", "Betaeubender Haken"
]
const VFX: Array[String] = [
 "shield_bash", "holy_light", "frost_nova", "frost_nova",
 "precision_shot", "precision_shot", "frost_nova",
 "frost_nova", "frost_nova", "holy_light", "shield_bash"
]

static func name_for_class(class_id: int) -> String:
 return NAMES[clampi(class_id, 0, NAMES.size() - 1)]

static func vfx_for_class(class_id: int) -> String:
 return VFX[clampi(class_id, 0, VFX.size() - 1)]

static func definition_for_class(class_id: int) -> Dictionary:
 return {"name": name_for_class(class_id), "effect": "interrupt", "power": 0.0, "aoe": false, "heal": 0.0, "guard": 0.0, "cooldown": 8}
