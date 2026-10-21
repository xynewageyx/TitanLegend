extends RefCounted
class_name TitanSkillSystem

# All roles can equip single-target or area damage. Role 0 = tank, 1 = DD, 2 = healer.
# AoE power is PER TARGET, not a flat bonus to the whole enemy group.
const ROLE_DAMAGE: Array[float] = [0.48, 1.0, 0.32]
const SKILLS: Array[Dictionary] = [
 {"name":"Wuchtiger Einzelhieb", "role":0, "cooldown":5, "power":1.15, "aoe":false, "heal":0.0, "guard":0.18},
 {"name":"Schutzwirbel", "role":0, "cooldown":7, "power":0.58, "aoe":true, "heal":0.0, "guard":0.25},
 {"name":"Schildwall", "role":0, "cooldown":9, "power":0.0, "aoe":false, "heal":0.0, "guard":0.45},
 {"name":"Praezisionsschlag", "role":1, "cooldown":5, "power":1.70, "aoe":false, "heal":0.0, "guard":0.0},
 {"name":"Klingensturm", "role":1, "cooldown":7, "power":0.90, "aoe":true, "heal":0.0, "guard":0.0},
 {"name":"Elementarschlag", "role":1, "cooldown":8, "power":2.15, "aoe":false, "heal":0.0, "guard":0.0},
 {"name":"Lichtimpuls", "role":2, "cooldown":5, "power":0.90, "aoe":false, "heal":0.08, "guard":0.0},
 {"name":"Reinigungswelle", "role":2, "cooldown":7, "power":0.46, "aoe":true, "heal":0.12, "guard":0.0},
 {"name":"Lebensquelle", "role":2, "cooldown":9, "power":0.0, "aoe":false, "heal":0.38, "guard":0.0}
]

static func skill_for_role(role: int, choice: int) -> Dictionary:
 if role == 0 and choice == 8:
  return {"name":"Spott", "cooldown":10, "power":0.0, "aoe":false, "heal":0.0, "guard":0.10}
 if role == 0 and choice == 9:
  return {"name":"Gruppenschaden abfangen", "cooldown":12, "power":0.0, "aoe":false, "heal":0.0, "guard":0.0}
 if choice == 3:
  return {"name":"Schneller Angriff", "cooldown":3, "power":0.65, "aoe":false, "heal":0.0, "guard":0.0}
 if choice == 4:
  return {"name":"Flaechensturm", "cooldown":10, "power":1.05, "aoe":true, "heal":0.0, "guard":0.0}
 if choice == 5:
  return {"name":"Bossbrecher", "cooldown":12, "power":2.55, "aoe":false, "heal":0.0, "guard":0.0}
 if choice == 6:
  return {"name":"Elementarwelle", "cooldown":8, "power":0.72, "aoe":true, "heal":0.0, "guard":0.0}
 var options: Array[Dictionary] = []
 for entry in SKILLS:
  if int(entry["role"]) == role:
   options.append(entry)
 if options.is_empty():
  return SKILLS[3]
 return options[clampi(choice, 0, options.size() - 1)]

static func damage_multiplier(role: int) -> float:
 return ROLE_DAMAGE[clampi(role, 0, ROLE_DAMAGE.size() - 1)]

static func damage_for_skill(skill: Dictionary, role: int, base_damage: int, target_count: int) -> int:
 var targets: int = mini(maxi(target_count, 1), 7) if bool(skill.get("aoe", false)) else 1
 return int(round(float(base_damage) * float(skill.get("power", 0.0)) * damage_multiplier(role) * float(targets)))
