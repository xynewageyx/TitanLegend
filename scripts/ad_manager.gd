extends Node
signal ads_updated(remaining: int)
const MAX_DAILY_ADS: int = 3
var ads_watched_today: int = 0
var last_watch_date: String = ""
func check_daily_reset() -> void:
 var today: String = Time.get_date_string_from_system()
 if last_watch_date != today:
  last_watch_date = today
  ads_watched_today = 0
  ads_updated.emit(MAX_DAILY_ADS)
func can_watch_ad() -> bool:
 check_daily_reset()
 return ads_watched_today < MAX_DAILY_ADS
func watch_rewarded_ad() -> void:
 # No SDK installed: do not grant rewards. Never simulate in a release build.
 push_warning("AdMob plugin not installed. No reward granted.")
func get_remaining_ads() -> int:
 check_daily_reset()
 return MAX_DAILY_ADS - ads_watched_today
