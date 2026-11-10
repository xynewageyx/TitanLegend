extends SceneTree
## Runtime test of ORIGINAL Titan Legends GLB animations and real equipped weapon.
## Checks grip continuity under Idle/Walk/Attack/Dodge, for all 12 classes.
## No third-party retargeting or visual Android screenshot assertion.
const ADAPTER = preload("res://scripts/equipment/formation_equipment_adapter.gd")
const IMPORTED = preload("res://scripts/equipment/chibi_imported_equipment_sockets.gd")
const WEAPON = preload("res://scripts/weapons/procedural_weapon_preview.gd")
const CLASSES := ["warrior", "paladin", "druid", "shaman", "hunter", "rogue", "mage", "warlock", "summoner", "priest", "brawler", "death_knight"]
const ACTIONS := ["Idle", "Walk", "Attack", "Dodge"]
const WINDOW := {"Idle": 1.4, "Walk": 1.1, "Attack": 0.95, "Dodge": 0.90}
const GRIP_TOLERANCE := 0.001

func _initialize() -> void:
 call_deferred("_run")

func _abort(reason: String) -> void:
 push_error(reason)
 quit(1)

func _run() -> void:
 var samples := 0
 for class_index in range(CLASSES.size()):
  var class_name: String = CLASSES[class_index]
  var hero := Node3D.new()
  hero.name = "EquipmentAnimationSmoke"
  root.add_child(hero)
  ADAPTER.install(hero)
  var view := Node3D.new()
  view.name = "ChibiGLBVisual"
  view.set_script(preload("res://scripts/chibi_glb_visual.gd"))
  hero.add_child(view)
  view.configure(class_index)
  view.set_process(false)
  var skeleton: Skeleton3D = view.get("imported_skeleton") as Skeleton3D
  var player: AnimationPlayer = view.get("animation_player") as AnimationPlayer
  if skeleton == null or player == null:
   _abort(class_name + ": missing imported skeleton or AnimationPlayer")
   return
  if not bool(view.get_meta("imported_equipment_sockets_ready", false)):
   _abort(class_name + ": imported equipment sockets not ready")
   return
  var expected_bone := "Hand_R_2" if class_name == "death_knight" else "Arm_R"
  if IMPORTED.selected_bone(skeleton, "RightHandSocket") != expected_bone:
   _abort(class_name + ": incorrect right hand bone")
   return
  var controller: Node3D = hero.get_node("EquipmentController") as Node3D
  if not bool(controller.call("equip_weapon", ADAPTER.weapon_type_for_class(class_index), 5)):
   _abort(class_name + ": cannot equip weapon")
   return
  await process_frame
  var anchor: Node3D = IMPORTED.resolve(skeleton, "RightHandSocket")
  if anchor == null or anchor.get_child_count() != 1:
   _abort(class_name + ": missing or duplicate equipped weapon")
   return
  var weapon: Node3D = anchor.get_child(0) as Node3D
  var grip: Vector3 = WEAPON.grip_local_point(int(weapon.get("weapon_type")))
  for action in ACTIONS:
   view.call("play_clip", action)
   var selected: String = str(player.current_animation)
   if not (selected == action or selected.begins_with(action + "_")):
    _abort(class_name + ": wrong clip for " + action + " (got " + selected + ")")
    return
   var animation: Animation = player.get_animation(selected)
   if animation == null or animation.get_track_count() == 0:
    _abort(class_name + ": empty imported clip " + action)
    return
   var start: float = maxf(0.0, animation.length - float(WINDOW[action]))
   var timestamps: Array[float] = [start, start + (animation.length - start) * 0.5, animation.length - 0.001]
   for timestamp in timestamps:
    player.seek(timestamp, true)
    skeleton.force_update_all_bone_transforms()
    await process_frame
    var gap: float = weapon.to_global(grip).distance_to(anchor.global_position)
    if not is_finite(gap) or gap > GRIP_TOLERANCE:
     _abort("%s: grip detached in %s at %.3f (gap=%.6f)" % [class_name, action, timestamp, gap])
     return
    samples += 1
  hero.queue_free()
  await process_frame
 print("PASS: animated weapon grip continuity classes=12 actions=4 samples=%d death_knight_hand=Hand_R_2" % samples)
 quit(0)
