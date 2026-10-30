extends Node3D
## Standalone GLB preview. Place the GitHub artifact at res://assets/characters/titan_warrior.glb.
const MODEL_PATH := "res://assets/characters/titan_warrior.glb"
var model: Node3D
var player: AnimationPlayer
var clip_names: PackedStringArray = []
var clip_index := 0

func _ready() -> void:
 if not ResourceLoader.exists(MODEL_PATH):
  push_warning("Warrior GLB missing: " + MODEL_PATH + " (download GitHub Actions artifact)")
  return
 var packed := load(MODEL_PATH) as PackedScene
 if packed == null:
  push_error("Cannot load warrior GLB: " + MODEL_PATH)
  return
 model = packed.instantiate() as Node3D
 if model == null:
  push_error("GLB root is not Node3D")
  return
 add_child(model)
 model.position = Vector3.ZERO
 player = _find_animation_player(model)
 if player == null:
  push_warning("Warrior GLB has no AnimationPlayer")
  return
 for library_name in player.get_animation_library_list():
  if library_name == &"":
   continue
  var lib := player.get_animation_library(library_name)
  for name in lib.get_animation_list():
   clip_names.append(String(library_name) + "/" + String(name))
 if clip_names.is_empty():
  for name in player.get_animation_list():
   clip_names.append(name)
 if not clip_names.is_empty():
  _play_clip(0)
 print("Warrior GLB loaded, clips: ", clip_names)

func _find_animation_player(node: Node) -> AnimationPlayer:
 if node is AnimationPlayer:
  return node as AnimationPlayer
 for child in node.get_children():
  var result := _find_animation_player(child)
  if result != null:
   return result
 return null

func _unhandled_key_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
  _play_clip((clip_index + 1) % maxi(clip_names.size(), 1))

func _play_clip(index: int) -> void:
 if player == null or clip_names.is_empty():
  return
 clip_index = index
 player.play(clip_names[clip_index])
 print("Warrior animation: ", clip_names[clip_index])
