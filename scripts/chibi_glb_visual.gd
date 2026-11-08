extends Node3D
## Imported original chibi base mesh; preserve existing gameplay and equipment nodes.
const RIG_BRIDGE = preload("res://scripts/rig/titan_skeleton_bridge.gd")
const IMPORTED_SOCKETS = preload("res://scripts/equipment/chibi_imported_equipment_sockets.gd")
const NAMES := ["warrior", "paladin", "druid", "shaman", "hunter", "rogue", "mage", "warlock", "summoner", "priest", "brawler", "death_knight"]
var imported_skeleton: Skeleton3D
var rig_audit: Dictionary = {}
var animation_player: AnimationPlayer
var active_clip: String = ""
var class_index: int = 0
# Blender's original GLB exports contain clips with an absolute keyframe
# offset. Seek into their actual motion interval to avoid seconds of stillness.
const CLIP_WINDOW := {"Idle": 1.4, "Walk": 1.1, "Attack": 0.95, "Hit": 0.65, "Dodge": 0.90}

func configure(class_id: int) -> void:
 var index: int = clampi(class_id, 0, NAMES.size() - 1)
 class_index = index
 var path: String = "res://assets/heroes/chibi/" + NAMES[index] + ".glb"
 if not ResourceLoader.exists(path):
  return
 var scene: PackedScene = load(path) as PackedScene
 if scene == null:
  return
 var model: Node3D = scene.instantiate() as Node3D
 if model == null:
  return
 model.name = "ChibiSculptedModel"
 add_child(model)
 # Hide only the old primitive body and face, never equipment, skills or companions.
 var hero: Node = get_parent()
 if hero != null:
  for node_name in ["HeroSculptedTorso", "HeroHead", "HeroHair", "StorybookFace"]:
   var old: Node3D = hero.get_node_or_null(node_name) as Node3D
   if old != null:
    old.visible = false
 # Observe imported bone structure without changing the original model or equipment.
 imported_skeleton = RIG_BRIDGE.find_skeleton(model)
 rig_audit = RIG_BRIDGE.audit(imported_skeleton)
 set_meta("rig_audit", rig_audit)
 if imported_skeleton == null:
  push_warning("Chibi model has no Skeleton3D: " + NAMES[index])
 elif not rig_audit["missing"].is_empty():
  push_warning("Chibi rig missing mapped bones for " + NAMES[index] + ": " + str(rig_audit["missing"]))
 # Prefer actual imported skeletons for visual equipment when the original
 # class mesh has the required bones; otherwise retain the helper rig.
 if imported_skeleton != null and hero is Node3D:
  var socket_ready: bool = IMPORTED_SOCKETS.install(imported_skeleton, hero as Node3D)
  set_meta("imported_equipment_sockets_ready", socket_ready)
  if socket_ready:
   # Hide only extra primitive arm/leg meshes. Preserve combat FX, old weapon
   # fallback groups, animation timers and gameplay nodes.
   for part in ["AnimatedLeftArm/SculptedAnimatedArm", "AnimatedRightArm/SculptedAnimatedArm",
                "AnimatedLeftLeg/SculptedAnimatedLeg", "AnimatedRightLeg/SculptedAnimatedLeg"]:
    var limb: Node3D = hero.get_node_or_null(NodePath("HeroCombatMotion/" + part)) as Node3D
    if limb != null:
     limb.visible = false
 animation_player = _find_animation_player(model)
 play_clip("Idle")

func _find_animation_player(node: Node) -> AnimationPlayer:
 if node is AnimationPlayer:
  return node as AnimationPlayer
 for child in node.get_children():
  var result: AnimationPlayer = _find_animation_player(child)
  if result != null:
   return result
 return null

func play_clip(clip: String) -> void:
 if animation_player == null:
  return
 # Restart non-looping imported clips when their previous playback ended.
 if clip == active_clip and animation_player.is_playing():
  return
 # Blender may export accumulated NLA actions with _001, _002 ... suffixes.
 # Prefer the clip belonging to this character, not a previous class's action.
 var owned_clip: String = clip + "_%03d" % class_index
 var chosen: String = owned_clip if class_index > 0 and animation_player.has_animation(owned_clip) else clip
 if not animation_player.has_animation(chosen):
  return
 var animation: Animation = animation_player.get_animation(chosen)
 # Only trims the inactive lead-in of source clips. Already normalized clips
 # (shorter than their expected action window) remain unchanged.
 var window: float = float(CLIP_WINDOW.get(clip, animation.length))
 var motion_start: float = maxf(0.0, animation.length - window)
 var playback_speed: float = 1.0
 if clip == "Attack":
  # Finish the cosmetic swing in the existing combat animation interval.
  # Skill cooldowns, damage and real attack timing are never changed.
  var hero: Node = get_parent()
  var motion: Node = hero.get_node_or_null("HeroCombatMotion") if hero != null else null
  if motion != null:
   var attack_duration: float = maxf(0.20, float(motion.get("attack_duration")))
   playback_speed = clampf((animation.length - motion_start) / attack_duration, 1.0, 3.0)
 animation_player.play(chosen, 0.12, playback_speed)
 if motion_start > 0.0:
  animation_player.seek(motion_start, true)
 active_clip = clip

func _process(_delta: float) -> void:
 var hero: Node = get_parent()
 if hero == null:
  return
 var motion: Node = hero.get_node_or_null("HeroCombatMotion")
 if motion != null:
  if float(motion.get("hit_remaining")) > 0.0:
   play_clip("Hit")
   return
  if float(motion.get("dodge_remaining")) > 0.0:
   play_clip("Dodge")
   return
  if float(motion.get("attack_remaining")) > 0.0:
   play_clip("Attack")
   return
 var formation: Node = hero.get_parent()
 play_clip("Walk" if formation != null and bool(formation.get("is_walking")) else "Idle")
