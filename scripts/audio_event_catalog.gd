extends RefCounted
## Centralized audio-event mapping. Missing files are intentionally silent.
## Add original/licensed .ogg or .wav files under res://assets/audio/.
const EVENTS: Dictionary = {
 "ui_click": "res://assets/audio/ui/click.wav",
 "ui_reward": "res://assets/audio/ui/reward.wav",
 "combat_hit": "res://assets/audio/combat/hit.wav",
 "combat_critical": "res://assets/audio/combat/critical.wav",
 "combat_dodge": "res://assets/audio/combat/dodge.wav",
 "combat_interrupt": "res://assets/audio/combat/interrupt.wav",
 "boss_warning": "res://assets/audio/combat/boss_warning.wav",
 "skill_heal": "res://assets/audio/skills/heal.wav",
 "skill_fire": "res://assets/audio/skills/fire.wav",
 "skill_ice": "res://assets/audio/skills/ice.wav",
 "skill_shadow": "res://assets/audio/skills/shadow.wav",
 "music_forest": "res://assets/audio/music/forest.ogg",
 "music_fire": "res://assets/audio/music/fire.ogg",
 "music_ice": "res://assets/audio/music/ice.ogg",
 "music_shadow": "res://assets/audio/music/shadow.ogg",
 "music_boss": "res://assets/audio/music/boss.ogg"
}
static func load_event(event_name: String) -> AudioStream:
 var path: String = str(EVENTS.get(event_name, ""))
 if path.is_empty() or not ResourceLoader.exists(path):
  return null
 return load(path) as AudioStream
