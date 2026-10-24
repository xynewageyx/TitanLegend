extends RefCounted
## AFK-Farming innerhalb der geoeffneten App, getrennt vom Offline-Einkommen.
## Monotone Millisekunden aus Time.get_ticks_msec() vermeiden Geraeteuhr-Fehler.
const IDLE_TO_AFK_MS: int = 5 * 60 * 1000
const AFK_REWARD_INTERVAL_MS: int = 60 * 1000
const BOSS_WAVE: int = 10

static func should_activate(last_input_ms: int, now_ms: int, astral_active: bool, app_paused: bool) -> bool:
 if astral_active or app_paused or last_input_ms < 0 or now_ms < last_input_ms:
  return false
 return now_ms - last_input_ms >= IDLE_TO_AFK_MS

static func is_boss_encounter(afk_active: bool, astral_active: bool, current_wave: int) -> bool:
 return not afk_active and (astral_active or current_wave == BOSS_WAVE)

static func reward_ready(afk_active: bool, pending_wave: bool, app_paused: bool, now_ms: int, next_reward_ms: int) -> bool:
 return afk_active and pending_wave and not app_paused and next_reward_ms > 0 and now_ms >= next_reward_ms

static func can_advance_stage(afk_active: bool) -> bool:
 return not afk_active
