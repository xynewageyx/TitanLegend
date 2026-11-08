extends SceneTree
## Godot 4.7.2 DISPLAY-based render QA of Titan Legends' actual live hero scene.
## This tool makes PNGs only from the 12 original GLBs and procedural inventory
## weapons/armor. It never changes saves, game stats, or repository assets.
const CLASSES := [
 "warrior", "paladin", "druid", "shaman", "hunter", "rogue",
 "mage", "warlock", "summoner", "priest", "brawler", "death_knight"
]
const ADAPTER = preload("res://scripts/equipment/formation_equipment_adapter.gd")
const OUTPUT := "res://build/animated_equipment_qa"
var world: Node3D
var team: Node3D
var camera: Camera3D
var results: Array[Dictionary] = []

func _initialize() -> void:
 call_deferred("_run")

func _fail(message: String) -> void:
 push_error(message)
 quit(1)

func _make_scene() -> bool:
 world = Node3D.new()
 world.name = "VisualQAWorld"
 root.add_child(world)
 var environment := WorldEnvironment.new()
 var settings := Environment.new()
 settings.background_mode = Environment.BG_COLOR
 settings.background_color = Color("#202936")
 settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
 settings.ambient_light_color = Color("#ffffff")
 settings.ambient_light_energy = 1.25
 environment.environment = settings
 world.add_child(environment)
 var sun := DirectionalLight3D.new()
 sun.light_energy = 1.3
 sun.rotation_degrees = Vector3(-42, 30, 0)
 world.add_child(sun)
 var fill := OmniLight3D.new()
 fill.position = Vector3(3.0, 4.5, 3.5)
 fill.light_energy = 1.4
 fill.omni_range = 12.0
 world.add_child(fill)
 var floor := MeshInstance3D.new()
 var floor_mesh := PlaneMesh.new()
 floor_mesh.size = Vector2(12, 12)
 floor.mesh = floor_mesh
 floor.position.y = -0.05
 var floor_mat := StandardMaterial3D.new()
 floor_mat.albedo_color = Color("#303c4a")
 floor.material_override = floor_mat
 world.add_child(floor)
 camera = Camera3D.new()
 camera.name = "EquipmentQACamera"
 camera.projection = Camera3D.PROJECTION_ORTHOGONAL
 camera.size = 3.65
 # Blender's GLTF forward axis maps its facial -Y geometry to Godot +Z.
 # Front portraits must look toward +Z to show the eyes, not the back of hair.
 camera.position = Vector3(0.0, 2.45, 7.6)
 world.add_child(camera)
 camera.look_at(Vector3(0, 1.22, 0), Vector3.UP)
 camera.current = true
 var script: Script = load("res://scripts/team_formation.gd")
 if script == null:
  return false
 team = script.new() as Node3D
 team.name = "EquipmentQATeam"
 world.add_child(team)
 team.set_process(false)
 # A normal team creates CanvasLayer helper menus; leave them out of the
 # screenshots. Gameplay entities stay intact.
 for item in team.get_children():
  if item is CanvasLayer:
   item.visible = false
 return true

func _capture(label: String, hero: Node3D, pose: String, class_index: int) -> bool:
 # Render two actual GPU frames before saving to avoid stale viewport images.
 await RenderingServer.frame_post_draw
 await RenderingServer.frame_post_draw
 var frame: Image = root.get_texture().get_image()
 if frame == null or frame.is_empty():
  _fail("Screen readback failed for " + label)
  return false
 var path: String = OUTPUT + "/" + label + ".png"
 if frame.save_png(path) != OK:
  _fail("PNG write failed for " + label)
  return false
 var chibi: Node3D = hero.get_node_or_null("ChibiGLBVisual")
 var skel: Skeleton3D = chibi.get("imported_skeleton") as Skeleton3D if chibi != null else null
 var controller: Node3D = hero.get_node_or_null("EquipmentController")
 if skel == null or controller == null:
  _fail("Missing real imported hero/weapon rig for " + label)
  return false
 var weapon_anchor: Node3D = controller.call("_socket", "RightHandSocket") as Node3D
 if weapon_anchor == null or weapon_anchor.get_child_count() != 1:
  _fail("Missing right-hand weapon in screenshot " + label)
  return false
 var visible_meshes := 0
 for node in _descendants(hero):
  if node is MeshInstance3D and (node as MeshInstance3D).is_visible_in_tree():
   visible_meshes += 1
 var weapon_glb_distance := hero.global_position.distance_to(weapon_anchor.global_position)
 # This is a geometry/framing sanity limit, not a claim of aesthetic quality.
 if weapon_glb_distance > 3.5:
  _fail("Weapon anchor far away from imported hero: %s, %f" % [label, weapon_glb_distance])
  return false
 results.append({
  "image": label + ".png",
  "class": CLASSES[class_index],
  "pose": pose,
  "imported_bones": skel.get_bone_count(),
  "weapon_bone": skel.get_node("RightHandSocket").bone_name,
  "visible_meshes": visible_meshes,
  "weapon_anchor_distance_to_hero_m": snappedf(weapon_glb_distance, 0.001),
  "width": frame.get_width(),
  "height": frame.get_height()
 })
 print("TITAN_VISUAL_QA_FRAME class=%s pose=%s meshes=%d image=%s" %
  [CLASSES[class_index], pose, visible_meshes, path])
 return true

func _descendants(parent: Node) -> Array[Node]:
 var items: Array[Node] = []
 for child in parent.get_children():
  items.append(child)
  items.append_array(_descendants(child))
 return items

func _run() -> void:
 if DisplayServer.get_name() == "headless":
  _fail("Visual QA requires a display renderer, not Godot headless mode")
  return
 if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT)) != OK:
  _fail("Cannot create visual QA directory")
  return
 if not _make_scene():
  _fail("Cannot initialize the actual four-hero team")
  return
 await process_frame
 var pictures := 0
 for i in range(CLASSES.size()):
  # Rebuild the actual team with the selected class in the first position.
  team.class_ids[0] = i
  team.create_team()
  await process_frame
  var hero: Node3D = team.heroes[0]
  hero.position = Vector3.ZERO
  hero.rotation = Vector3.ZERO
  for other in range(1, team.heroes.size()):
   team.heroes[other].visible = false
  var ctrl: Node3D = hero.get_node_or_null("EquipmentController")
  if ctrl == null:
   _fail("Missing equipment controller for " + CLASSES[i])
   return
  if not bool(ctrl.call("equip_weapon", ADAPTER.weapon_type_for_class(i), 5)):
   _fail("Could not equip weapon " + CLASSES[i])
   return
  var pieces := 0
  for socket_name in ADAPTER.SOCKETS:
   if socket_name in ["RightHandSocket", "LeftHandSocket"]:
    continue
   if not bool(ctrl.call("equip_armor_slot", socket_name, i, 5)):
    _fail("Cannot equip " + socket_name + " for " + CLASSES[i])
    return
   pieces += 1
  if pieces != 13:
   _fail("Only %d/13 armor pieces equipped for %s" % [pieces, CLASSES[i]])
   return
  await process_frame
  var chibi: Node3D = hero.get_node_or_null("ChibiGLBVisual")
  var animator: AnimationPlayer = chibi.get("animation_player") as AnimationPlayer if chibi != null else null
  if animator == null:
   _fail("Missing original GLB animation for " + CLASSES[i])
   return
  # Front and attack frames for every class; side view for the hero and death
  # knight. Screenshots use real GLB body and actual rarity-5 equipment.
  chibi.call("play_clip", "Idle")
  if not await _capture(CLASSES[i] + "_front_idle", hero, "front_idle", i):
   return
  pictures += 1
  hero.get_node("HeroCombatMotion").call("play_attack")
  chibi.call("play_clip", "Attack")
  var clip: Animation = animator.get_animation(animator.current_animation)
  var midpoint: float = maxf(0.0, clip.length - 0.45)
  animator.seek(midpoint, true)
  if not await _capture(CLASSES[i] + "_front_attack", hero, "front_attack", i):
   return
  pictures += 1
  if i == 0 or i == 11:
   hero.rotation.y = PI * 0.5
   if not await _capture(CLASSES[i] + "_side_attack", hero, "side_attack", i):
    return
   pictures += 1
   hero.rotation.y = 0.0
 var file := FileAccess.open(OUTPUT + "/manifest.json", FileAccess.WRITE)
 if file == null:
  _fail("Cannot write QA manifest")
  return
 file.store_string(JSON.stringify({
   "generator": "Godot 4.7.2 live imported GLB equipment QA",
   "image_count": pictures, "class_count": CLASSES.size(),
   "real_android_device_tested": false, "renders": results
  }, "  "))
 file.close()
 print("TITAN_EQUIPMENT_VISUAL_QA_OK images=%d classes=%d" % [pictures, CLASSES.size()])
 quit(0)
