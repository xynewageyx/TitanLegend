extends Node
## Engine-independent audio facade. Keep gameplay calling play_sfx/play_bgm;
## a licensed CRIWARE backend can be connected here later without touching combat.
signal audio_backend_changed(backend_name: String)

const SFX_POOL_SIZE: int = 8
# Keep frequently reused audio streams ready for Android combat.
const EVENT_CACHE_LIMIT: int = 24
const PINNED_AUDIO_EVENTS: Array[String] = ["boss_warning", "combat_interrupt", "skill_interrupt"]
var _event_stream_cache: Dictionary = {}
var _event_cache_order: Array[String] = []
var ambience: AudioStreamPlayer
var ambience_next: AudioStreamPlayer
var ambience_transition: Tween
var _ambience_gains: Dictionary = {}
const AMBIENCE_FADE_SECONDS: float = 0.8
var music: AudioStreamPlayer
var boss_warning_player: AudioStreamPlayer
var _boss_duck_gain: float = 1.0
var _boss_duck_tween: Tween
const BOSS_DUCK_LEVEL: float = 0.45
var effects: Array[AudioStreamPlayer] = []
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var music_muted: bool = false
var sfx_muted: bool = false
var _next_sfx_index: int = 0

func _ready() -> void:
 ambience = AudioStreamPlayer.new()
 ambience.name = "Ambience"
 add_child(ambience)
 _ambience_gains[ambience] = 1.0
 ambience.finished.connect(_on_ambience_finished.bind(ambience))
 ambience_next = AudioStreamPlayer.new()
 ambience_next.name = "AmbienceNext"
 add_child(ambience_next)
 _ambience_gains[ambience_next] = 0.0
 ambience_next.finished.connect(_on_ambience_finished.bind(ambience_next))
 boss_warning_player = AudioStreamPlayer.new()
 boss_warning_player.name = "BossWarning"
 add_child(boss_warning_player)
 boss_warning_player.finished.connect(_on_boss_warning_finished)
 music = AudioStreamPlayer.new()
 music.name = "Music"
 add_child(music)
 for i in range(SFX_POOL_SIZE):
  var player := AudioStreamPlayer.new()
  player.name = "SFX_%d" % i
  add_child(player)
  effects.append(player)
 _apply_volumes()
 # Prepare short, latency-sensitive shared cues before the first boss cast.
 _prewarm_critical_events()
 audio_backend_changed.emit("godot")

# Crossfades and boss ducking update only ambience/music, not all SFX voices.
func _apply_background_volumes() -> void:
 if ambience != null:
  ambience.volume_linear = (0.0 if sfx_muted else sfx_volume * 0.4 * _boss_duck_gain) * float(_ambience_gains.get(ambience, 1.0))
 if ambience_next != null:
  ambience_next.volume_linear = (0.0 if sfx_muted else sfx_volume * 0.4 * _boss_duck_gain) * float(_ambience_gains.get(ambience_next, 0.0))
 if music != null:
  music.volume_linear = 0.0 if music_muted else music_volume * _boss_duck_gain

func _apply_volumes() -> void:
 _apply_background_volumes()
 if boss_warning_player != null:
  boss_warning_player.volume_linear = 0.0 if sfx_muted else sfx_volume
 for player in effects:
  player.volume_linear = 0.0 if sfx_muted else sfx_volume

func set_music_volume(value: float) -> void:
 music_volume = clampf(value, 0.0, 1.0)
 _apply_volumes()

func set_sfx_volume(value: float) -> void:
 sfx_volume = clampf(value, 0.0, 1.0)
 _apply_volumes()

func set_music_muted(value: bool) -> void:
 music_muted = value
 _apply_volumes()

func set_sfx_muted(value: bool) -> void:
 sfx_muted = value
 _apply_volumes()

func _set_boss_duck_gain(value: float) -> void:
 _boss_duck_gain = clampf(value, BOSS_DUCK_LEVEL, 1.0)
 _apply_background_volumes()

func _animate_boss_duck(target: float, duration: float) -> void:
 if _boss_duck_tween != null and _boss_duck_tween.is_running():
  _boss_duck_tween.kill()
 _boss_duck_tween = create_tween()
 _boss_duck_tween.tween_method(_set_boss_duck_gain, _boss_duck_gain, target, duration)

func _on_boss_warning_finished() -> void:
 _animate_boss_duck(1.0, 0.35)

func play_sfx(stream: AudioStream) -> void:
 if stream == null or sfx_muted or sfx_volume <= 0.0:
  return
 for player in effects:
  if not player.playing:
   player.stream = stream
   player.play()
   return
 # When all voices are busy, recycle the oldest round-robin slot.
 var player: AudioStreamPlayer = effects[_next_sfx_index]
 _next_sfx_index = (_next_sfx_index + 1) % effects.size()
 player.stop()
 player.stream = stream
 player.play()

func play_bgm(stream: AudioStream) -> void:
 if stream == null:
  return
 if music.stream == stream and music.playing:
  return
 music.stop()
 music.stream = stream
 music.play()

func _set_ambience_gain(value: float, player: AudioStreamPlayer) -> void:
 _ambience_gains[player] = clampf(value, 0.0, 1.0)
 _apply_background_volumes()

func play_ambience(event_name: String) -> void:
 var stream: AudioStream = _get_event_stream(event_name)
 if stream == null or ambience == null or ambience_next == null:
  return
 if ambience_transition != null and ambience_transition.is_running():
  ambience_transition.kill()
  # Promote the louder active channel before starting a new transition.
  if float(_ambience_gains.get(ambience_next, 0.0)) > float(_ambience_gains.get(ambience, 0.0)):
   var previous: AudioStreamPlayer = ambience
   ambience = ambience_next
   ambience_next = previous
  ambience_next.stop()
  ambience_next.stream = null
  _ambience_gains[ambience_next] = 0.0
 if ambience.stream == stream and ambience.playing:
  _set_ambience_gain(1.0, ambience)
  return
 if not ambience.playing:
  ambience.stream = stream
  _set_ambience_gain(1.0, ambience)
  ambience.play()
  return
 ambience_next.stream = stream
 _set_ambience_gain(0.0, ambience_next)
 ambience_next.play()
 ambience_transition = create_tween().set_parallel(true)
 ambience_transition.tween_method(_set_ambience_gain.bind(ambience), float(_ambience_gains.get(ambience, 1.0)), 0.0, AMBIENCE_FADE_SECONDS)
 ambience_transition.tween_method(_set_ambience_gain.bind(ambience_next), 0.0, 1.0, AMBIENCE_FADE_SECONDS)
 ambience_transition.finished.connect(_finish_ambience_transition)

func _finish_ambience_transition() -> void:
 ambience.stop()
 ambience.stream = null
 var previous: AudioStreamPlayer = ambience
 ambience = ambience_next
 ambience_next = previous
 _set_ambience_gain(0.0, ambience_next)
 _set_ambience_gain(1.0, ambience)

func _on_ambience_finished(player: AudioStreamPlayer) -> void:
 if player != null and player.stream != null:
  player.play()

func stop_ambience() -> void:
 if ambience_transition != null and ambience_transition.is_running():
  ambience_transition.kill()
 for player in [ambience, ambience_next]:
  if player != null:
   player.stop()
   player.stream = null
   _ambience_gains[player] = 0.0

func stop_bgm() -> void:
 music.stop()

func stop_sfx() -> void:
 for player in effects:
  player.stop()
 if boss_warning_player != null:
  boss_warning_player.stop()
 _animate_boss_duck(1.0, 0.15)

# Session changes silence pooled hero/combat effects, but must not cancel a
# globally audible boss telegraph or reset its music/ambience ducking.
func stop_session_combat_sfx() -> void:
 for player in effects:
  player.stop()

# Named audio events keep gameplay independent from asset paths.
const AUDIO_EVENTS = preload("res://scripts/audio_event_catalog.gd")

func _prewarm_critical_events() -> void:
 for event_name in PINNED_AUDIO_EVENTS:
  _get_event_stream(event_name)

func _get_event_stream(event_name: String) -> AudioStream:
 if _event_stream_cache.has(event_name):
  _event_cache_order.erase(event_name)
  _event_cache_order.append(event_name)
  return _event_stream_cache[event_name] as AudioStream
 var stream: AudioStream = AUDIO_EVENTS.load_event(event_name)
 if stream == null:
  return null
 if _event_cache_order.size() >= EVENT_CACHE_LIMIT:
  # Never evict critical cues during heavy class/biome audio churn.
  for cached_name in _event_cache_order:
   if not PINNED_AUDIO_EVENTS.has(cached_name):
    _event_cache_order.erase(cached_name)
    _event_stream_cache.erase(cached_name)
    break
 _event_stream_cache[event_name] = stream
 _event_cache_order.append(event_name)
 return stream

func play_event(event_name: String) -> void:
 var stream: AudioStream = _get_event_stream(event_name)
 if stream == null:
  return
 if event_name.begins_with("music_"):
  play_bgm(stream)
 elif event_name == "boss_warning":
  # Critical shared boss telegraphs must not be stolen by busy hero SFX.
  if not sfx_muted and sfx_volume > 0.0 and boss_warning_player != null:
   boss_warning_player.stop()
   boss_warning_player.stream = stream
   boss_warning_player.play()
   _animate_boss_duck(BOSS_DUCK_LEVEL, 0.12)
 else:
  play_sfx(stream)

func play_combat_hit(is_critical: bool = false) -> void:
 play_event("combat_critical" if is_critical else "combat_hit")

func play_interrupt() -> void:
 play_event("combat_interrupt")

# Local client owns exactly one hero. Multiplayer must set this after login/spawn.
# -1 disables all character combat sounds until ownership is known.
var local_hero_slot: int = -1
var local_hero_class_id: int = -1

func set_local_hero_slot(slot: int) -> void:
 # Called only after trusted session ownership has been established.
 if slot < 0 or slot >= 4:
  clear_local_hero()
  return
 if local_hero_slot != slot:
  stop_session_combat_sfx()
  local_hero_class_id = -1
 local_hero_slot = slot

func clear_local_hero() -> void:
 stop_session_combat_sfx()
 local_hero_slot = -1
 local_hero_class_id = -1

# Call only after trusted slot ownership is established and the local class is known.
# Avoid loading all 22 class cues into the Android audio cache at startup.
func set_local_hero_class_id(class_id: int) -> void:
 if local_hero_slot < 0 or class_id < 0 or class_id > 11:
  local_hero_class_id = -1
  return
 if local_hero_class_id == class_id:
  return
 local_hero_class_id = class_id
 _get_event_stream("class_attack_%d" % class_id)
 _get_event_stream("class_skill_%d" % class_id)

func bind_local_hero_from_team(owner_peer_ids: Array[int], local_peer_id: int) -> bool:
 # The server/session supplies the authoritative owner IDs for four slots.
 # Never infer ownership from class, role, or formation position.
 clear_local_hero()
 if local_peer_id <= 0 or owner_peer_ids.size() != 4:
  return false
 var found_slot: int = -1
 for i in range(owner_peer_ids.size()):
  if owner_peer_ids[i] == local_peer_id:
   if found_slot != -1:
    return false
   found_slot = i
 if found_slot == -1:
  return false
 set_local_hero_slot(found_slot)
 return true

# Bind both identity and class from the same authoritative multiplayer snapshot.
# Reject incomplete snapshots rather than playing a previous character's audio.
func bind_local_hero_with_classes(owner_peer_ids: Array[int], class_ids: Array[int], local_peer_id: int) -> bool:
 clear_local_hero()
 if class_ids.size() != 4:
  return false
 if not bind_local_hero_from_team(owner_peer_ids, local_peer_id):
  return false
 var class_id: int = class_ids[local_hero_slot]
 if class_id < 0 or class_id > 11:
  clear_local_hero()
  return false
 set_local_hero_class_id(class_id)
 return true

func play_local_hero_event(slot: int, event_name: String) -> void:
 if slot != local_hero_slot or local_hero_slot < 0:
  return
 play_event(event_name)
