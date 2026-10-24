extends RefCounted
## Gemeinsames XP-/Level-Balancing fuer normale Mobwellen (online/offline).
## Boss-Levelaufstiege aus der bisherigen Spiellogik bleiben zusaetzlich erhalten.
const XP_PER_STAGE_PER_WAVE: int = 10
const MAX_STAGE: int = 1200
const BASE_LEVEL_XP: int = 5000
const XP_GROWTH_PER_LEVEL: int = 1000

static func mob_wave_xp(stage: int) -> int:
 return clampi(stage, 1, MAX_STAGE) * XP_PER_STAGE_PER_WAVE

static func xp_for_next_level(level: int) -> int:
 return BASE_LEVEL_XP + maxi(1, level) * XP_GROWTH_PER_LEVEL

static func apply_xp(level: int, progress_xp: int, earned_xp: int) -> Dictionary:
 var new_level: int = maxi(1, level)
 var progress: int = maxi(0, progress_xp) + maxi(0, earned_xp)
 var levels_gained: int = 0
 while progress >= xp_for_next_level(new_level):
  progress -= xp_for_next_level(new_level)
  new_level += 1
  levels_gained += 1
 return {
  "level": new_level,
  "xp": progress,
  "levels_gained": levels_gained
 }
