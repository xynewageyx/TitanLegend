extends RefCounted
class_name TitanCombatBalance

# Four recurring boss archetypes in every 100-stage area, reused for repeated elements.
const BOSS_TITLES := ["Waechter", "Sturmrufer", "Runenhueter", "Urtitan"]
const BOSS_SPECIAL := ["attack", "defense", "heal", "attack"]
# Existing biome index already determines the element for the entire zone.
# 12 areas, 100 stages each. Area 1 is the baseline.
# The modest nonlinear curve makes repeated elements tougher without changing
# their element, boss identity, skill order or the 60-second boss limit.
static func area_number(stage: int) -> int:
 return clampi(int((maxi(1, stage) - 1) / 100) + 1, 1, 12)

static func enemy_hp_scale(stage: int) -> float:
 var completed: float = float(area_number(stage) - 1)
 return 1.0 + 0.045 * completed + 0.003 * completed * completed

static func enemy_damage_scale(stage: int) -> float:
 var completed: float = float(area_number(stage) - 1)
 return 1.0 + 0.022 * completed + 0.0015 * completed * completed

static func boss_variant(stage: int) -> int:
 return posmod(int(posmod(maxi(1, stage) - 1, 100) / 10), BOSS_TITLES.size())

static func boss_resistance(variant: int) -> float:
 # Element is fixed for the zone; only archetype durability changes.
 const RESISTANCES: Array[float] = [0.16, 0.14, 0.18, 0.20]
 return RESISTANCES[posmod(variant, RESISTANCES.size())]

static func has_boss_minions(stage: int, fusion: bool) -> bool:
 # Midgame begins at stage 401 (area 5 of 12). Not every encounter uses the extra enemies.
 return stage >= 401 and (fusion or posmod(int((stage - 1) / 10), 3) == 2)

static func boss_gain_type(variant: int) -> String:
 return str(BOSS_SPECIAL[posmod(variant, BOSS_SPECIAL.size())])

# Roles capable of healing: Paladin=1, Druid=2, Shaman=3, Priest=9.
# Every option has a trade-off; same total healing budget is not guaranteed.
static func healer_profile(class_id: int) -> Dictionary:
 match class_id:
  1: return {"direct":0.89, "hot":0.70, "damage":0.94, "description":"Paladin: Schutz und Einzelheilung"}
  2: return {"direct":0.76, "hot":1.30, "damage":0.95, "description":"Druide: starke Heilung ueber Zeit"}
  3: return {"direct":0.95, "hot":1.08, "damage":0.94, "description":"Schamane: flexible Gruppenheilung"}
  9: return {"direct":1.18, "hot":0.78, "damage":0.88, "description":"Priester: starke Sofortheilung"}
 return {"direct":1.0, "hot":1.0, "damage":1.0}

# Passive pet affinity: element penetration counters resistance (capped).
# No pet owns an attack, skill or cooldown.
static func passive_pet_stats(class_id: int, pet_element: int, boss_element: int) -> Dictionary:
 var match_bonus: bool = pet_element == boss_element
 var penetration: float = 0.12 if match_bonus else 0.055
 var health: float = 0.035
 var crit: float = 0.02
 if class_id in [0, 1, 2, 3]:
  health += 0.025
 if class_id in [4, 5, 6, 7, 8, 10]:
  crit += 0.015
 return {"penetration":minf(penetration, 0.15), "health":minf(health, 0.08), "crit":minf(crit, 0.05)}

static func damage_after_resistance(damage: int, resistance: float, penetration: float) -> int:
 var effective_resistance: float = clampf(resistance - penetration, 0.0, 0.60)
 return maxi(1, roundi(float(damage) * (1.0 - effective_resistance)))
