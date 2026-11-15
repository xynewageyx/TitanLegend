extends RefCounted
## Titan Legends progression balance module (not wired into GameManager yet).
const XP_PER_LEVEL := 3
const AFK_XP_FACTOR := 0.72
const AFK_GOLD_FACTOR := 0.70
const AFK_MAX_SECONDS := 28800
const AFK_START_SECONDS := 300
const MOB_MULTIPLIERS := {"normal": 1.0, "strong": 1.5, "elite": 3.0, "miniboss": 6.0, "boss": 15.0}
const WAVES := [2, 5, 7]
const CLASS_TREES := {
 "warrior": ["protection", "retaliation", "war_master"],
 "paladin": ["guardian", "lightbringer", "avenger"],
 "mage": ["fire", "frost", "arcane"],
 "ranger": ["precision", "wilderness", "trapper"],
 "priest": ["healing", "blessing", "light"],
 "assassin": ["shadow", "blades", "poison"],
 "death_knight": ["blood", "frost", "unholy"]
}
const SKILL_ANIMATIONS := {
 "shield_bash": "shield_bash",
 "group_guard": "group_guard",
 "divine_judgment": "divine_judgment",
 "holy_light": "holy_light",
 "meteor_rain": "meteor_rain",
 "frost_nova": "frost_nova",
 "arrow_rain": "arrow_rain",
 "precision_shot": "precision_shot",
 "healing_wave": "healing_wave",
 "blessing": "blessing",
 "shadow_step": "shadow_step",
 "blade_storm": "blade_storm"
}
static func mob_xp(stage: int, kind: String = "normal") -> int:
 var base: float = 12.0 * pow(1.055, float(clampi(stage, 1, 1200) - 1))
 return int(floor(base * float(MOB_MULTIPLIERS.get(kind, 1.0))))
static func wave_xp(stage: int, wave_index: int) -> int:
 if wave_index < 0 or wave_index >= WAVES.size():
  return 0
 return mob_xp(stage) * WAVES[wave_index]
static func talent_points_earned(level: int) -> int:
 return maxi(0, level - 1) * XP_PER_LEVEL
static func afk_rewards(seconds_away: int, active_xp_per_hour: float, active_gold_per_hour: float) -> Dictionary:
 var seconds: int = clampi(seconds_away, 0, AFK_MAX_SECONDS)
 if seconds < AFK_START_SECONDS:
  return {"xp_per_hero": 0, "gold": 0}
 var hours: float = float(seconds) / 3600.0
 return {"xp_per_hero": int(floor(hours * maxf(0.0, active_xp_per_hour) * AFK_XP_FACTOR)), "gold": int(floor(hours * maxf(0.0, active_gold_per_hour) * AFK_GOLD_FACTOR))}
