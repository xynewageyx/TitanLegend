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
 "class_attack_0": "res://assets/audio/classes/warrior_attack.wav",
 "class_attack_1": "res://assets/audio/classes/paladin_attack.wav",
 "class_attack_2": "res://assets/audio/classes/druid_attack.wav",
 "class_attack_3": "res://assets/audio/classes/shaman_attack.wav",
 "class_attack_4": "res://assets/audio/classes/hunter_attack.wav",
 "class_attack_5": "res://assets/audio/classes/rogue_attack.wav",
 "class_attack_6": "res://assets/audio/classes/mage_attack.wav",
 "class_attack_7": "res://assets/audio/classes/warlock_attack.wav",
 "class_attack_8": "res://assets/audio/classes/summoner_attack.wav",
 "class_attack_9": "res://assets/audio/classes/priest_attack.wav",
 "class_attack_10": "res://assets/audio/classes/brawler_attack.wav",
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
