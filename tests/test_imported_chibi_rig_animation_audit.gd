extends SceneTree
## Read-only inspection of the actual original Blender-generated chibi GLBs.
## Used to decide whether live equipment can eventually follow imported bones
## rather than the optional 18-bone preview overlay.
const BRIDGE = preload("res://scripts/rig/titan_skeleton_bridge.gd")
const CLASSES := [
 "warrior", "paladin", "druid", "shaman", "hunter", "rogue",
 "mage", "warlock", "summoner", "priest", "brawler", "death_knight"
]
const REQUIRED_BONES := ["Root", "Hips", "Spine", "Head", "Arm_L", "Arm_R", "Leg_L", "Leg_R"]

func _initialize() -> void:
 call_deferred("_run")

func _fail(why: String) -> void:
 push_error(why)
 quit(1)

func _find_animation_player(node: Node) -> AnimationPlayer:
 if node is AnimationPlayer:
  return node as AnimationPlayer
 for child in node.get_children():
  var found := _find_animation_player(child)
  if found != null:
   return found
 return null

func _run() -> void:
 var total_bones := 0
 var animated := 0
 for class_token in CLASSES:
  var hero_class: String = String(class_token)
  var path: String = "res://assets/heroes/chibi/" + hero_class + ".glb"
  if not ResourceLoader.exists(path):
   _fail("Missing chibi GLB: " + hero_class)
   return
  var packed: PackedScene = load(path) as PackedScene
  if packed == null:
   _fail("Unable to import chibi GLB: " + hero_class)
   return
  var model: Node = packed.instantiate()
  if model == null:
   _fail("Cannot instantiate chibi GLB: " + hero_class)
   return
  root.add_child(model)
  var skeleton: Skeleton3D = BRIDGE.find_skeleton(model)
  if skeleton == null:
   _fail("No imported Skeleton3D on " + hero_class)
   return
  var missing := PackedStringArray()
  for bone in REQUIRED_BONES:
   if skeleton.find_bone(bone) < 0:
    missing.append(bone)
  if not missing.is_empty():
   _fail("Missing imported rig bones for %s: %s" % [hero_class, str(missing)])
   return
  var player := _find_animation_player(model)
  var clips := PackedStringArray()
  if player != null:
   for name in player.get_animation_list():
    clips.append(String(name))
  var expected_motions := ["Idle", "Walk", "Attack", "Hit", "Dodge"]
  var motion_matches := 0
  for motion in expected_motions:
   for clip in clips:
    if clip.ends_with(motion):
     motion_matches += 1
     break
  if motion_matches == expected_motions.size():
   animated += 1
  total_bones += skeleton.get_bone_count()
  print("CHIBI_IMPORTED_RIG class=%s bones=%d clips=%s matched=%d" %
    [hero_class, skeleton.get_bone_count(), str(clips), motion_matches])
  root.remove_child(model)
  model.free()
 print("CHIBI_IMPORTED_RIG_AUDIT_OK classes=%d bones=%d full_clip_sets=%d" %
  [CLASSES.size(), total_bones, animated])
 quit(0)
