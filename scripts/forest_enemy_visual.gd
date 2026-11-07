extends Node3D
## Drop-in visual presenter for generated forest GLB models.
## Attach to a Node3D and call show_enemy(id). Does not change combat logic.
const MODEL_PATHS := {
 "forest_01": "res://assets/enemies/forest/forest_01_mooshuepfer.glb",
 "forest_02": "res://assets/enemies/forest/forest_02_pilzling.glb",
 "forest_03": "res://assets/enemies/forest/forest_03_wurzelkrabbler.glb",
 "forest_04": "res://assets/enemies/forest/forest_04_blattfuchs.glb",
 "forest_05": "res://assets/enemies/forest/forest_05_dorneneber.glb",
 "forest_06": "res://assets/enemies/forest/forest_06_rankenwerfer.glb",
 "forest_elite_01": "res://assets/enemies/forest/forest_elite_01_rindenwaechter.glb",
 "forest_elite_02": "res://assets/enemies/forest/forest_elite_02_moosbestie.glb",
 "forest_boss_01": "res://assets/enemies/forest/forest_boss_01_wurzelkoenig.glb"
}
var _visual: Node3D
var _player: AnimationPlayer
var _dead: bool = false

func show_enemy(enemy_id: String) -> bool:
 clear_visual()
 _dead = false
 var path: String = MODEL_PATHS.get(enemy_id, "")
 if path.is_empty() or not ResourceLoader.exists(path):
  push_warning("Forest GLB unavailable: %s (%s)" % [enemy_id, path])
  return false
 var scene: PackedScene = load(path) as PackedScene
 if scene == null:
  push_warning("Forest GLB could not be imported: " + path)
  return false
 _visual = scene.instantiate() as Node3D
 if _visual == null:
  return false
 add_child(_visual)
 _player = _find_animation_player(_visual)
 if _player != null:
  _player.animation_finished.connect(_on_animation_finished)
 play_clip("idle")
 return true

func _find_animation_player(node: Node) -> AnimationPlayer:
 if node is AnimationPlayer:
  return node as AnimationPlayer
 for child in node.get_children():
  var found: AnimationPlayer = _find_animation_player(child)
  if found != null:
   return found
 return null

func play_clip(clip: String) -> bool:
 if _player == null or (_dead and clip != "death"):
  return false
 for animation_name in _player.get_animation_list():
  var short_name: String = animation_name.get_slice("/", animation_name.get_slice_count("/") - 1).get_slice(".", 0)
  if short_name == clip:
   var animation: Animation = _player.get_animation(animation_name)
   if animation != null:
    # Imported GLBs may mark every clip as looping. Only idle may loop;
    # otherwise attack/hit never emit animation_finished and cannot return to idle.
    animation.loop_mode = Animation.LOOP_LINEAR if clip == "idle" else Animation.LOOP_NONE
   if clip == "death":
    if _dead:
     return true
    _dead = true
   _player.stop()
   _player.play(animation_name)
   _player.advance(0.0)
   return true
 return false

func _on_animation_finished(animation_name: StringName) -> void:
 if _dead or _player == null:
  return
 var short_name: String = String(animation_name).get_slice("/", String(animation_name).get_slice_count("/") - 1).get_slice(".", 0)
 if short_name == "attack" or short_name == "hit":
  play_clip("idle")

func clear_visual() -> void:
 if _visual != null and is_instance_valid(_visual):
  _visual.queue_free()
 _visual = null
 _player = null
 _dead = false
