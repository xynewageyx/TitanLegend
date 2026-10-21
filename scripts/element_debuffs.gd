extends RefCounted
class_name TitanElementDebuffs

# Deterministic elemental debuffs. Bosses resist hard control; the CC interrupt
# mechanic remains the sole reliable way to stop a boss cast.
static func status_name(element_id: int) -> String:
 match element_id:
  0: return "Brennen"
  1: return "Durchnaesst"
  2: return "Ruestungsbruch"
  3: return "Gift"
  4: return "Geblendet"
  5: return "Geschwaecht"
  6: return "Verlangsamt"
  7: return "Frost"
  8: return "Schock"
  9: return "Chaosmal"
 return "Elementarmal"

static func duration_ticks(element_id: int, boss: bool) -> int:
 var duration: int = 5 if element_id == 0 or element_id == 3 else 3
 return maxi(1, duration - (2 if boss else 0))

static func periodic_damage(element_id: int, base_damage: int, boss: bool) -> int:
 if element_id != 0 and element_id != 3:
  return 0
 return maxi(1, int(round(float(base_damage) * (0.035 if boss else 0.08))))

static func damage_multiplier(element_id: int, boss: bool) -> float:
 match element_id:
  2: return 1.04 if boss else 1.10
  4: return 1.02 if boss else 1.06
  9: return 1.03 if boss else 1.08
 return 1.0

static func slows_attack(element_id: int, boss: bool) -> bool:
 return not boss and (element_id == 6 or element_id == 7 or element_id == 8)
