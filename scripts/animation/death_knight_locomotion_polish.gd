extends RefCounted
## Original, non-destructive animation polish for Titan Legends Death Knight.
## Modifies only PRIVATE duplicated Idle/Walk clip resources for this instance.
## Attack, Hit, Dodge, Skeleton3D rest poses, and equipment sockets stay untouched.
const ACTIONS := ["Idle", "Walk"]
const BONES := ["Shoulder_R", "Shoulder_L", "Chest"]
const WINDOWS := {"Idle": 1.4, "Walk": 1.1}

static func install(player: AnimationPlayer, skeleton: Skeleton3D) -> Dictionary:
 var report := {"installed": false, "animations": [], "tracks": 0, "warnings": []}
 if player == null or skeleton == null or skeleton.get_bone_count() != 24:
  report["warnings"].append("Expected original Death Knight 24-bone imported rig")
  return report
 for name in BONES:
  if skeleton.find_bone(name) < 0:
   report["warnings"].append("Missing Death Knight bone " + name)
   return report
 # The GLB AnimationPlayer's default library is shared across instantiations:
 # duplicate it before replacing clips to prevent changes to other characters.
 var original_library: AnimationLibrary = player.get_animation_library("")
 if original_library == null:
  report["warnings"].append("Missing default animation library")
  return report
 var private_library: AnimationLibrary = original_library.duplicate(true) as AnimationLibrary
 if private_library == null:
  report["warnings"].append("Cannot duplicate animation library")
  return report
 var staged: Dictionary = {}
 for action in ACTIONS:
  var chosen := action
  if not private_library.has_animation(chosen):
   # Names may be suffixed when exported in a combined NLA library.
   chosen = ""
   for name in private_library.get_animation_list():
    if str(name).begins_with(action + "_"):
     chosen = str(name)
     break
  if chosen == "":
   report["warnings"].append("Missing original imported " + action + " clip")
   return report
  var imported: Animation = private_library.get_animation(chosen)
  if imported == null:
   report["warnings"].append("Invalid imported " + action)
   return report
  var path_prefix := ""
  for index in range(imported.get_track_count()):
   var path: String = str(imported.track_get_path(index))
   if path.contains(":") and imported.track_get_type(index) == Animation.TYPE_ROTATION_3D:
    path_prefix = path.split(":")[0]
    break
  if path_prefix == "":
   report["warnings"].append("No imported skeletal rotation track for " + action)
   return report
  var replacement: Animation = imported.duplicate(true) as Animation
  var start: float = maxf(0.0, replacement.length - float(WINDOWS[action]))
  # New curves are zero at beginning/end; only original clip's active tail moves.
  for bone in BONES:
   var track_path := NodePath(path_prefix + ":" + bone)
   var old_track: int = replacement.find_track(track_path, Animation.TYPE_ROTATION_3D)
   if old_track >= 0:
    replacement.remove_track(old_track)
   var track: int = replacement.add_track(Animation.TYPE_ROTATION_3D)
   replacement.track_set_path(track, track_path)
   var axis := Vector3.FORWARD if action == "Idle" else Vector3.RIGHT
   var radians: float = 0.025 if bone == "Chest" else 0.07 if action == "Idle" else 0.28
   # Alternating shoulders give a clear walk gait, without reworking the hands.
   var side: float = -1.0 if bone == "Shoulder_L" else 1.0
   if bone == "Chest":
    radians = 0.022 if action == "Idle" else 0.035
   var sample_times: Array[float] = [0.0, start, start + (replacement.length-start)*0.25,
    start + (replacement.length-start)*0.50, start + (replacement.length-start)*0.75, replacement.length]
   for t in sample_times:
    var phase: float = (t-start)/maxf(replacement.length-start, 0.01)
    var angle: float = radians * side * sin(phase * TAU) if t > start else 0.0
    replacement.rotation_track_insert_key(track, t, Quaternion(axis, angle))
   report["tracks"] = int(report["tracks"]) + 1
  staged[chosen] = replacement
 # Commit only after all checks pass, using one instance-local library.
 player.remove_animation_library("")
 player.add_animation_library("", private_library)
 for clip_name in staged:
  private_library.add_animation(clip_name, staged[clip_name])
  report["animations"].append(clip_name)
 report["installed"] = true
 return report
