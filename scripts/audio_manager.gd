extends Node
## Engine-independent audio facade. Keep gameplay calling play_sfx/play_bgm;
## a licensed CRIWARE backend can be connected here later without touching combat.
signal audio_backend_changed(backend_name: String)

const SFX_POOL_SIZE: int = 8
var music: AudioStreamPlayer
var effects: Array[AudioStreamPlayer] = []
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var music_muted: bool = false
var sfx_muted: bool = false
var _next_sfx_index: int = 0

func _ready() -> void:
 music = AudioStreamPlayer.new()
 music.name = "Music"
 add_child(music)
 for i in range(SFX_POOL_SIZE):
  var player := AudioStreamPlayer.new()
  player.name = "SFX_%d" % i
  add_child(player)
  effects.append(player)
 _apply_volumes()
 audio_backend_changed.emit("godot")

func _apply_volumes() -> void:
 if music != null:
  music.volume_linear = 0.0 if music_muted else music_volume
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

func stop_bgm() -> void:
 music.stop()

func stop_sfx() -> void:
 for player in effects:
  player.stop()
