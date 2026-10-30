extends Node3D
## Optional cosmetic GLB layer for the warrior; never changes combat mechanics.
## Attach as a child of an existing hero node after importing the GLB.
@export var model_path: String = "res://assets/characters/titan_warrior.glb"
@export var hide_existing_visuals: bool = false
var animation_player: AnimationPlayer

func _ready() -> void:
 if not ResourceLoader.exists(model_path):
  push_warning("Warrior GLB not installed: " + model_path)
  return
 var scene := load(model_path) as PackedScene
 if scene == null:
  push_error("Warrior GLB could not be loaded")
  return
 var instance := scene.instantiate()
 add_child(instance)
 animation_player = _find_player(instance)
 if hide_existing_visuals:
  _hide_existing_meshes(get_parent())
 play_clip("idle")

func play_clip(clip: String) -> void:
 if animation_player == null:
  return
 for library_name in animation_player.get_animation_library_list():
  var library := animation_player.get_animation_library(library_name)
  if library.has_animation(clip):
   var full_name := clip if String(library_name).is_empty() else String(library_name) + "/" + clip
   animation_player.play(full_name)
   return

func play_attack() -> void:
 play_clip("attack")

func play_walk() -> void:
 play_clip("walk")

func play_idle() -> void:
 play_clip("idle")

func play_hit() -> void:
 play_clip("hit")

func play_dodge() -> void:
 play_clip("dodge")

func play_cast() -> void:
 play_clip("cast")

func _find_player(node: Node) -> AnimationPlayer:
 if node is AnimationPlayer:
  return node as AnimationPlayer
 for child in node.get_children():
  var result := _find_player(child)
  if result != null:
   return result
 return null

func _hide_existing_meshes(node: Node) -> void:
 if node == null:
  return
 for child in node.get_children():
  if child == self:
   continue
  if child is MeshInstance3D:
   child.visible = false
  else:
   _hide_existing_meshes(child)
