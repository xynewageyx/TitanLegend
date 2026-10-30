extends SceneTree
## CI smoke test for generated Blender GLB; exits nonzero on missing rig or clips.
const MODEL_PATH := "res://assets/characters/titan_warrior.glb"
const EXPECTED := ["idle", "walk", "attack", "cast", "hit", "dodge"]

func _initialize() -> void:
 call_deferred("_verify")

func _verify() -> void:
 if not ResourceLoader.exists(MODEL_PATH):
  _fail("Missing generated warrior GLB")
  return
 var scene := load(MODEL_PATH) as PackedScene
 if scene == null:
  _fail("GLB failed to import as PackedScene")
  return
 var root := scene.instantiate()
 get_root().add_child(root)
 var player := _find_player(root)
 if player == null:
  _fail("Imported GLB has no AnimationPlayer")
  return
 var found: Array[String] = []
 for library_name in player.get_animation_library_list():
  var library := player.get_animation_library(library_name)
  for clip_name in library.get_animation_list():
   found.append(String(clip_name).to_lower())
 for expected in EXPECTED:
  if not found.has(expected):
   _fail("Missing animation %s; imported clips: %s" % [expected, str(found)])
   return
 print("PASS: warrior GLB imported with all six clips: ", found)
 quit(0)

func _find_player(node: Node) -> AnimationPlayer:
 if node is AnimationPlayer:
  return node as AnimationPlayer
 for child in node.get_children():
  var found := _find_player(child)
  if found != null:
   return found
 return null

func _fail(message: String) -> void:
 push_error(message)
 quit(1)
