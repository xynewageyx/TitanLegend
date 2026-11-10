extends SceneTree
## Godot-only motion diagnostics for 12 ORIGINAL imported GLB rigs.
## Exports aggregated per-bone motion, never animation keyframes or third-party assets.
const CLASSES := ["warrior", "paladin", "druid", "shaman", "hunter", "rogue", "mage", "warlock", "summoner", "priest", "brawler", "death_knight"]
const ACTIONS := ["Idle", "Walk", "Attack", "Dodge"]
const WINDOWS := {"Idle": 1.4, "Walk": 1.1, "Attack": 0.95, "Dodge": 0.90}
const ROLES := ["Root", "Hips", "Spine", "Head", "Arm_R", "Arm_L", "Leg_R", "Leg_L", "Hand_R_2", "Hand_L_2", "Forearm_R_2", "Forearm_L_2", "Chest"]
const OUTPUT := "res://build/twelve_class_bone_motion.json"

func _initialize() -> void:
 call_deferred("_run")

func _find(node: Node, klass: String) -> Node:
 if klass == "skeleton" and node is Skeleton3D:
  return node
 if klass == "player" and node is AnimationPlayer:
  return node
 for child in node.get_children():
  var result: Node = _find(child, klass)
  if result != null:
   return result
 return null

func _run() -> void:
 var errors: Array[String] = []
 var rows: Array[Dictionary] = []
 for hero_id in CLASSES:
  var packed: PackedScene = load("res://assets/heroes/chibi/" + hero_id + ".glb") as PackedScene
  if packed == null:
   errors.append(hero_id + ": missing GLB")
   continue
  var character: Node3D = packed.instantiate() as Node3D
  root.add_child(character)
  var skeleton: Skeleton3D = _find(character, "skeleton") as Skeleton3D
  var player: AnimationPlayer = _find(character, "player") as AnimationPlayer
  if skeleton == null or player == null:
   errors.append(hero_id + ": missing rig or AnimationPlayer")
   character.queue_free()
   continue
  for action in ACTIONS:
   var actual: String = ""
   for label in player.get_animation_list():
    var name: String = str(label)
    if name == action or name.begins_with(action + "_"):
     actual = name
     break
   if actual == "":
    errors.append(hero_id + ": missing " + action)
    continue
   var animation: Animation = player.get_animation(actual)
   var window_start: float = maxf(0.0, animation.length - float(WINDOWS[action]))
   var samples: Array[float] = [window_start,
    window_start + 0.25 * (animation.length - window_start),
    window_start + 0.50 * (animation.length - window_start),
    window_start + 0.75 * (animation.length - window_start),
    maxf(window_start, animation.length - 0.001)]
   player.play(actual)
   var baseline: Dictionary = {}
   var peak_trans: Dictionary = {}
   var peak_rot: Dictionary = {}
   for frame in range(samples.size()):
    player.seek(samples[frame], true)
    skeleton.force_update_all_bone_transforms()
    for bone_name in ROLES:
     var index: int = skeleton.find_bone(bone_name)
     if index < 0:
      continue
     var pose: Transform3D = skeleton.get_bone_global_pose(index)
     if frame == 0:
      baseline[bone_name] = pose
      peak_trans[bone_name] = 0.0
      peak_rot[bone_name] = 0.0
     else:
      var initial: Transform3D = baseline[bone_name]
      var translation: float = pose.origin.distance_to(initial.origin)
      var rotation_deg: float = rad_to_deg(pose.basis.orthonormalized().get_rotation_quaternion().angle_to(initial.basis.orthonormalized().get_rotation_quaternion()))
      peak_trans[bone_name] = maxf(float(peak_trans[bone_name]), translation)
      peak_rot[bone_name] = maxf(float(peak_rot[bone_name]), rotation_deg)
   var bones: Array[Dictionary] = []
   for bone_name in ROLES:
    if peak_trans.has(bone_name):
     bones.append({"bone": bone_name, "max_position_delta": snappedf(float(peak_trans[bone_name]), 0.00001), "max_rotation_degrees": snappedf(float(peak_rot[bone_name]), 0.001)})
   rows.append({"class": hero_id, "action": action, "clip": actual,
    "duration_seconds": snappedf(animation.length, 0.001),
    "sample_count": samples.size(), "bone_count": skeleton.get_bone_count(),
    "tracked_bones": bones})
   player.stop()
  character.queue_free()
  await process_frame
 var out := {"schema": 1, "source": "titan_original_imported_godot_glb", "classes": CLASSES.size(),
  "actions_per_class": ACTIONS.size(), "rows": rows, "errors": errors,
  "unity_retargeting_verified": false,
  "note": "Five bone global pose samples in each action's active tail window; no actual Android GPU verification."}
 DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://build"))
 var file := FileAccess.open(OUTPUT, FileAccess.WRITE)
 if file == null:
  push_error("Cannot write " + OUTPUT)
  quit(1)
  return
 file.store_string(JSON.stringify(out, "  ") + "\n")
 file.close()
 print("TITAN_BONE_MOTION_AUDIT rows=%d errors=%d" % [rows.size(), errors.size()])
 for failure in errors:
  push_error(failure)
 quit(0 if errors.is_empty() and rows.size() == 48 else 1)
