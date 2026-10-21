extends Node
var music: AudioStreamPlayer
var effects: Array[AudioStreamPlayer] = []
func _ready() -> void:
 music = AudioStreamPlayer.new()
 add_child(music)
 for i in range(6):
  var player: AudioStreamPlayer = AudioStreamPlayer.new()
  add_child(player)
  effects.append(player)
func play_sfx(stream: AudioStream) -> void:
 if stream == null:
  return
 for player in effects:
  if not player.playing:
   player.stream = stream
   player.play()
   return
func play_bgm(stream: AudioStream) -> void:
 if stream == null:
  return
 music.stream = stream
 music.play()
