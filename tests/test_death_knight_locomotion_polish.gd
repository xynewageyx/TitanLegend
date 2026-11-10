extends SceneTree
## Regression test: original Death Knight Idle/Walk polish stays on local GLB instance.
const VISUAL = preload("res://scripts/chibi_glb_visual.gd")
const ACTIONS := ["Idle", "Walk"]
const WINDOWS := {"Idle": 1.4, "Walk": 1.1}

func _initialize() -> void:
 call_deferred("_run")

func _fail(message: String) -> void:
 push_error(message)
 quit(1)

func _find_player(node: Node) -> AnimationPlayer:
 if node is AnimationPlayer:
  return node as AnimationPlayer
 for child in node.get_children():
  var found: AnimationPlayer = _find_player(child)
  if found != null:
   return found
 return null

func _run() -> void:
 # Validate the private copied library, without constructing a second
 # source GLB fixture (which triggers an unrelated material teardown warning).
 var hero := Node3D.new()
 root.add_child(hero)
 var view := Node3D.new()
 view.name = "ChibiGLBVisual"
 view.set_script(VISUAL)
 hero.add_child(view)
 # The isolated rig need not install equipment; that is checked separately.
 view.configure(11)
 view.set_process(false)
 var report: Dictionary = view.get_meta("death_knight_locomotion_polish", {})
 if not bool(report.get("installed", false)) or int(report.get("tracks", 0)) != 6 or not bool(report.get("source_library_isolated", false)):
  _fail("Death Knight polish missing or incomplete: " + str(report))
  return
 var player: AnimationPlayer = view.get("animation_player") as AnimationPlayer
 var skeleton: Skeleton3D = view.get("imported_skeleton") as Skeleton3D
 if player == null or skeleton == null:
  _fail("Cannot obtain polished animation or skeleton")
  return
 var right: int = skeleton.find_bone("Shoulder_R")
 var left: int = skeleton.find_bone("Shoulder_L")
 if right < 0 or left < 0:
  _fail("Missing animated shoulder bone")
  return
 var changed := 0
 for action in ACTIONS:
  view.call("play_clip", action)
  var selected: String = str(player.current_animation)
  # Avoid blend-overhang from prior Idle/Walk when asserting the source keys.
  player.play(selected, 0.0)
  var clip: Animation = player.get_animation(selected)
  var start: float = maxf(0.0, clip.length - float(WINDOWS[action]))
  player.seek(start, true)
  var initial_right: Quaternion = skeleton.get_bone_pose_rotation(right)
  var initial_left: Quaternion = skeleton.get_bone_pose_rotation(left)
  player.seek(start + 0.25 * (clip.length - start), true)
  var peak_right: Quaternion = skeleton.get_bone_pose_rotation(right)
  var peak_left: Quaternion = skeleton.get_bone_pose_rotation(left)
  if initial_right.angle_to(peak_right) < 0.025 or initial_left.angle_to(peak_left) < 0.025:
   _fail(action + ": shoulder movement remains static")
   return
  changed += 1
  player.seek(clip.length - 0.001, true)
  if skeleton.get_bone_pose_rotation(right).angle_to(initial_right) > 0.03:
   _fail(action + ": shoulder pose did not return near loop baseline")
   return
 for action in ["Attack", "Dodge"]:
  if player.get_animation(action) == null:
   _fail("Death Knight original " + action + " was overwritten")
   return
 player.stop()
 hero.queue_free()
 await process_frame
 await process_frame
 print("PASS: Death Knight private Idle Walk polish actions=%d added_tracks=6 original_glb_unchanged=true" % changed)
 quit(0)
