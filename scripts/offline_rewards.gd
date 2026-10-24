extends RefCounted
## Konservative Offline-Ertraege: keine Stage-, Boss-, Loot- oder Level-Fortschritte.
## Ausschliesslich Gold aus normalen Gegnerwellen, mit 8-Stunden-Obergrenze.
const MAX_OFFLINE_SECONDS: int = 8 * 60 * 60
const MIN_AWAY_SECONDS: int = 5 * 60
const SECONDS_PER_MOB_WAVE: int = 60
const GOLD_PER_STAGE_PER_WAVE: int = 50
const MAX_STAGE: int = 1200

static func calculate(stage: int, last_active_unix: int, now_unix: int) -> Dictionary:
 var result := {"seconds": 0, "waves": 0, "gold": 0}
 if last_active_unix <= 0 or now_unix <= last_active_unix:
  return result
 var seconds: int = mini(now_unix - last_active_unix, MAX_OFFLINE_SECONDS)
 if seconds < MIN_AWAY_SECONDS:
  return result
 var waves: int = seconds / SECONDS_PER_MOB_WAVE
 var safe_stage: int = clampi(stage, 1, MAX_STAGE)
 result["seconds"] = seconds
 result["waves"] = waves
 result["gold"] = safe_stage * GOLD_PER_STAGE_PER_WAVE * waves
 return result

static func make_claim(save_data: Dictionary, now_unix: int) -> Dictionary:
 # Der Zeitstempel ist bei Altspielstaenden nicht vorhanden; keine rueckwirkenden Praemien.
 var stage: int = maxi(1, int(save_data.get("stage", 1)))
 var previous: int = int(save_data.get("last_active_unix", 0))
 var earned: Dictionary = calculate(stage, previous, now_unix)
 var updated: Dictionary = save_data.duplicate(true)
 # Niemals Boss-, Stage-, Wellen- oder Loot-Werte veraendern.
 updated["last_active_unix"] = maxi(previous, now_unix)
 if int(earned["gold"]) > 0:
  var previous_gold: int = maxi(0, int(updated.get("gold", 0)))
  updated["gold"] = previous_gold + int(earned["gold"])
 return {"save": updated, "reward": earned}
