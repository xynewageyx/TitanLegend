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
 if index == 11:
  set_meta("death_knight_tinted_surfaces", _tone_death_knight_whites(model))
 # The hero was originally constructed from standalone primitive meshes.
 # Those parts now intersect the imported chibi skin and the modular armor.
 # Hide ONLY direct legacy MeshInstance3D children and the legacy cape/face,
 # not equipment, the animation controller, the pet or battle FX.
 var hero: Node = get_parent()
 if hero != null:
  var hidden_legacy_meshes := 0
  for old in hero.get_children():
   if old is MeshInstance3D:
    (old as MeshInstance3D).visible = false
    hidden_legacy_meshes += 1
  for node_name in ["HeroCape", "StorybookFace"]:
   var obsolete: Node3D = hero.get_node_or_null(node_name) as Node3D
   if obsolete != null:
    obsolete.visible = false
  set_meta("hidden_legacy_body_meshes", hidden_legacy_meshes)
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

## The imported Death Knight uses several pure-white GLB materials.
## Remap only overly bright surfaces on the original model, not player armor,
## spell particles, UI or other classes. Every material is duplicated locally.
func _tone_death_knight_whites(source: Node) -> int:
 var edits := 0
 if source is MeshInstance3D:
  var item := source as MeshInstance3D
  if item.mesh != null:
   for surface in range(item.mesh.get_surface_count()):
    var base_material: BaseMaterial3D = item.get_surface_override_material(surface) as BaseMaterial3D
    if base_material == null:
     base_material = item.mesh.surface_get_material(surface) as BaseMaterial3D
    if base_material == null:
     base_material = item.material_override as BaseMaterial3D
    if base_material == null:
     continue
    var source_color: Color = base_material.albedo_color
    if minf(source_color.r, minf(source_color.g, source_color.b)) < 0.78:
     continue
    var identifier: String = (String(item.name) + " " + String(base_material.resource_name)).to_lower()
    var target: Color = Color("#96879b")
    if identifier.contains("hair") or identifier.contains("horn") or identifier.contains("helmet") or identifier.contains("crown"):
     target = Color("#4a4056")
    elif identifier.contains("eye") or identifier.contains("glint"):
     target = Color("#cbc5ce")
    elif identifier.contains("bone") or identifier.contains("tooth"):
     target = Color("#a99d9f")
    elif identifier.contains("head") or identifier.contains("face") or identifier.contains("skin"):
     target = Color("#a48e9d")
    else:
     target = Color("#817c90")
    var tinted: BaseMaterial3D = base_material.duplicate(true) as BaseMaterial3D
    if tinted == null:
     continue
    tinted.albedo_color = target
    tinted.roughness = 0.68
    if tinted.emission_enabled:
     tinted.emission_energy_multiplier = minf(0.2, tinted.emission_energy_multiplier)
    item.set_surface_override_material(surface, tinted)
    edits += 1
 for child in source.get_children():
  edits += _tone_death_knight_whites(child)
 return edits

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
