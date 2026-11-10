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
 settings.ambient_light_energy = 0.70
 environment.environment = settings
 world.add_child(environment)
 var sun := DirectionalLight3D.new()
 sun.light_energy = 1.0
 sun.rotation_degrees = Vector3(-42, 30, 0)
 world.add_child(sun)
 var fill := OmniLight3D.new()
 fill.position = Vector3(3.0, 4.5, 3.5)
 fill.light_energy = 0.35
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

func _vec3_metrics(value: Vector3) -> Array:
 return [snappedf(value.x, 0.001), snappedf(value.y, 0.001), snappedf(value.z, 0.001)]

func _visible_mesh_bounds(node: Node3D) -> Dictionary:
 var found := false
 var combined := AABB()
 for descendant in _descendants(node):
  var piece: MeshInstance3D = descendant as MeshInstance3D
  if piece == null or piece.mesh == null or not piece.is_visible_in_tree():
   continue
  var bounds: AABB = piece.global_transform * piece.get_aabb()
  if not found:
   combined = bounds
   found = true
  else:
   combined = combined.merge(bounds)
 if not found:
  return {}
 return {"center_m": _vec3_metrics(combined.get_center()),
         "size_m": _vec3_metrics(combined.size)}

func _build_contact_sheet(pose: String) -> bool:
 # A phone-friendly 4x3 overview avoids opening twelve separate screenshots.
 var tile := Vector2i(225, 400)
 var columns := 4
 var sheet: Image = Image.create(tile.x * columns, tile.y * 3, false, Image.FORMAT_RGBA8)
 sheet.fill(Color("#151d2d"))
 for i in range(CLASSES.size()):
  var source: String = OUTPUT + "/" + CLASSES[i] + "_" + pose + ".png"
  var frame: Image = Image.load_from_file(source)
  if frame == null or frame.is_empty():
   _fail("Missing class pose for contact sheet: " + source)
   return false
  frame.convert(Image.FORMAT_RGBA8)
  frame.resize(tile.x, tile.y, Image.INTERPOLATE_LANCZOS)
  var destination := Vector2i((i % columns) * tile.x, int(i / columns) * tile.y)
  sheet.blit_rect(frame, Rect2i(Vector2i.ZERO, tile), destination)
 var filename: String = OUTPUT + "/overview_" + pose + ".png"
 if sheet.save_png(filename) != OK:
  _fail("Cannot write phone-friendly equipment overview: " + filename)
  return false
 return true

func _fit_camera_to_visible_hero(hero: Node3D, formation: bool = false) -> bool:
 # The oversized Mythic greatsword and lateral spell focuses can extend well
 # outside a fixed portrait crop. Fit all visible 3D meshes in camera space
 # while retaining a consistent viewing direction for front/side comparisons.
 var view_inverse: Transform3D = camera.global_transform.affine_inverse()
 var low := Vector2(INF, INF)
 var high := Vector2(-INF, -INF)
 var found := false
 for node in _descendants(hero):
  var piece: MeshInstance3D = node as MeshInstance3D
  if piece == null or piece.mesh == null or not piece.is_visible_in_tree():
   continue
  var box: AABB = piece.get_aabb()
  for index in range(8):
   var world_point: Vector3 = piece.global_transform * box.get_endpoint(index)
   var camera_point: Vector3 = view_inverse * world_point
   low.x = minf(low.x, camera_point.x)
   low.y = minf(low.y, camera_point.y)
   high.x = maxf(high.x, camera_point.x)
   high.y = maxf(high.y, camera_point.y)
   found = true
 if not found:
  _fail("Cannot frame an empty character")
  return false
 var center := (low + high) * 0.5
 camera.global_position += camera.global_transform.basis.x * center.x
 camera.global_position += camera.global_transform.basis.y * center.y
 var viewport_size: Vector2 = root.get_visible_rect().size
 var aspect: float = maxf(0.1, viewport_size.x / maxf(1.0, viewport_size.y))
 # Leave 0.45m safety margin for fast-moving cloth and weapon tips.
 var needed: float = maxf(high.y - low.y + 0.45, (high.x - low.x + 0.45) / aspect)
 camera.size = maxf(3.95, needed)
 if is_nan(camera.size) or camera.size > (24.0 if formation else 12.0):
  _fail("Equipment is too far from hero for a readable QA frame")
  return false
 return true

func _capture(label: String, hero: Node3D, pose: String, class_index: int) -> bool:
 # Let the attack flash and imported bone pose reach a rendered frame before
 # calculating the crop. Otherwise the flash can expand outside the frame
 # between camera fitting and the next screenshot.
 await RenderingServer.frame_post_draw
 if not _fit_camera_to_visible_hero(hero):
  return false
 # Keep the original two-frame total so a short attack clip does not end
 # before the movement assertion; only the second frame uses the fitted camera.
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
 var equipped: Dictionary = controller.get("equipped_nodes")
 var weapon_visual: Node3D = equipped.get("mainhand") as Node3D
 var chest_visual: Node3D = equipped.get("ChestSocket") as Node3D
 if not is_instance_valid(weapon_visual) or not is_instance_valid(chest_visual):
  _fail("Missing inventory meshes in screenshot: " + label)
  return false
 var weapon_bounds: Dictionary = _visible_mesh_bounds(weapon_visual)
 var chest_bounds: Dictionary = _visible_mesh_bounds(chest_visual)
 if weapon_bounds.is_empty() or chest_bounds.is_empty():
  _fail("Invisible or empty weapon/chest geometry in screenshot: " + label)
  return false
 # This is a geometry/framing sanity limit, not a claim of aesthetic quality.
 if weapon_glb_distance > 3.5:
  _fail("Weapon anchor far away from imported hero: %s, %f" % [label, weapon_glb_distance])
  return false
 var flash_metrics: Dictionary = {}
 if pose in ["front_attack", "side_attack"]:
  var motion: Node3D = hero.get_node_or_null("HeroCombatMotion") as Node3D
  var fx_root: Node3D = motion.get_node_or_null("AttackFlash") as Node3D if motion != null else null
  var flash: MeshInstance3D = motion.get("magic_flash") as MeshInstance3D if motion != null else null
  if fx_root == null or flash == null:
   _fail("Missing combat flash in screenshot: " + label)
   return false
  if fx_root.position.z <= 0.0 or float(motion.get("attack_fx_forward")) <= 0.0:
   _fail("Imported GLB attack effect appears behind its hero: " + label)
   return false
  if flash.scale.x > 1.181 or flash.scale.y > 1.181 or flash.scale.z > 1.181:
   _fail("Combat flash obscures equipment with excessive scale: " + label)
   return false
  flash_metrics = {
   "origin_hero_local_m": _vec3_metrics(fx_root.position),
   "pulse_scale": snappedf(flash.scale.x, 0.001),
   "faces_imported_forward": true
  }
 results.append({
  "image": label + ".png",
  "class": CLASSES[class_index],
  "pose": pose,
  "imported_bones": skel.get_bone_count(),
  "weapon_bone": skel.get_node("RightHandSocket").bone_name,
  "visible_meshes": visible_meshes,
  "weapon_anchor_distance_to_hero_m": snappedf(weapon_glb_distance, 0.001),
  "weapon_bounds": weapon_bounds,
  "chest_bounds": chest_bounds,
  "weapon_to_chest_center_distance_m": snappedf(weapon_visual.global_position.distance_to(chest_visual.global_position), 0.001),
  "attack_flash": flash_metrics,
  "camera_view_height_m": snappedf(camera.size, 0.001),
  "camera_view_width_m": snappedf(camera.size * (float(frame.get_width()) / maxf(1.0, float(frame.get_height()))), 0.001),
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

func _capture_four_hero_formation() -> int:
 # Four practical combat roles, including Death Knight's distinct 24-bone rig.
 # The formation remains temporary QA data; no class setup or save is altered.
 var lineup: Array[int] = [0, 6, 11, 2]
 var roles: Array[int] = [0, 1, 1, 2]
 for index in range(4):
  team.class_ids[index] = lineup[index]
  team.role_ids[index] = roles[index]
 team.create_team()
 await process_frame
 if team.heroes.size() != 4:
  _fail("Formation QA requires exactly four heroes")
  return -1
 for index in range(4):
  var hero: Node3D = team.heroes[index]
  hero.visible = true
  var view: Node3D = hero.get_node_or_null("ChibiGLBVisual") as Node3D
  var controller: Node3D = hero.get_node_or_null("EquipmentController") as Node3D
  if view == null or controller == null:
   _fail("Formation hero missing imported visual or equipment controller")
   return -1
  view.set_process(false)
  if not bool(controller.call("equip_weapon", ADAPTER.weapon_type_for_class(team.class_ids[index]), 5)):
   _fail("Formation mythic weapon could not be equipped at slot " + str(index))
   return -1
  if not bool(controller.call("equip_armor_slot", "ChestSocket", team.class_ids[index], 5)):
   _fail("Formation mythic chest armor could not be equipped at slot " + str(index))
   return -1
 # Elevated 4-hero battle view separates front and back row silhouettes.
 camera.position = Vector3(0.0, 10.0, 12.0)
 camera.look_at(Vector3(0.0, 1.2, 0.0), Vector3.UP)
 var captured := 0
 for action in ["Idle", "Walk", "Attack", "Dodge"]:
  for hero in team.heroes:
   var view: Node3D = hero.get_node("ChibiGLBVisual") as Node3D
   var player: AnimationPlayer = view.get("animation_player") as AnimationPlayer
   var skeleton: Skeleton3D = view.get("imported_skeleton") as Skeleton3D
   if player == null or skeleton == null:
    _fail("Four-hero formation lacks imported animation")
    return -1
   view.call("play_clip", action)
   var selected: String = str(player.current_animation)
   if not (selected == action or selected.begins_with(action + "_")):
    _fail("Formation selected unexpected animation: " + selected)
    return -1
   var animation: Animation = player.get_animation(selected)
   var range_seconds: float = 1.4 if action == "Idle" else 1.1 if action == "Walk" else 0.95 if action == "Attack" else 0.90
   player.seek(maxf(0.0, animation.length - 0.45 * range_seconds), true)
   player.pause()
   skeleton.force_update_all_bone_transforms()
  await RenderingServer.frame_post_draw
  if not _fit_camera_to_visible_hero(team, true):
   return -1
  await RenderingServer.frame_post_draw
  var snapshot: Image = root.get_texture().get_image()
  if snapshot == null or snapshot.is_empty():
   _fail("Formation screenshot readback empty for " + action)
   return -1
  var name: String = "formation_mythic_" + action.to_lower() + ".png"
  if snapshot.save_png(OUTPUT + "/" + name) != OK:
   _fail("Formation screenshot could not be written: " + name)
   return -1
  var anchor_count := 0
  for hero in team.heroes:
   var controller: Node3D = hero.get_node("EquipmentController") as Node3D
   var anchor: Node3D = controller.call("_socket", "RightHandSocket") as Node3D
   if anchor == null or anchor.get_child_count() != 1:
    _fail("Formation contains missing or duplicate weapon during " + action)
    return -1
   anchor_count += 1
  results.append({"image": name, "class": "formation", "pose": action.to_lower(),
   "hero_count": 4, "class_ids": [0,6,11,2], "weapon_anchors": anchor_count,
   "width": snapshot.get_width(), "height": snapshot.get_height()})
  print("TITAN_FORMATION_VISUAL_QA_FRAME pose=%s weapons=%d" % [action, anchor_count])
  captured += 1
 return captured


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
  # The gallery is for character geometry only, not UI or passive companions.
  # The live battle retains both; only this isolated QA camera hides them.
  for qa_hidden in ["HeroHealthBar", "PassivePet"]:
   var extra: Node3D = hero.get_node_or_null(qa_hidden) as Node3D
   if extra != null:
    extra.visible = false
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
  # Freeze only the automatic combat selector in this isolated screenshot scene.
  # Manual AnimationPlayer playback must not be overridden before readback.
  chibi.set_process(false)
  # Front and attack frames for every class; side view for the hero and death
  # knight. Screenshots use real GLB body and actual rarity-5 equipment.
  chibi.call("play_clip", "Idle")
  if not await _capture(CLASSES[i] + "_front_idle", hero, "front_idle", i):
   return
  pictures += 1
  var weapon_socket: Node3D = ctrl.call("_socket", "RightHandSocket") as Node3D
  var active_weapon: Node3D = weapon_socket.get_child(0) as Node3D if weapon_socket != null and weapon_socket.get_child_count() == 1 else null
  if active_weapon == null:
   _fail("Missing bone-bound weapon before attack: " + CLASSES[i])
   return
  var weapon_before: Transform3D = active_weapon.global_transform
  hero.get_node("HeroCombatMotion").call("play_attack")
  chibi.call("play_clip", "Attack")
  var clip: Animation = animator.get_animation(animator.current_animation)
  var midpoint: float = maxf(0.0, clip.length - 0.45)
  animator.seek(midpoint, true)
  if not await _capture(CLASSES[i] + "_front_attack", hero, "front_attack", i):
   return
  pictures += 1
  # A still weapon despite an imported attack pose is a rendering regression.
  var weapon_after: Transform3D = active_weapon.global_transform
  if weapon_before.is_equal_approx(weapon_after):
   _fail("Equipped weapon stayed static during attack: " + CLASSES[i])
   return
  # Also capture imported Walk and Dodge for all classes. Keep the original
  # animation at its active movement interval, including DK's 24-bone rig.
  for moving_pose in ["Walk", "Dodge"]:
   chibi.call("play_clip", moving_pose)
   var moving_name: String = str(animator.current_animation)
   if not (moving_name == moving_pose or moving_name.begins_with(moving_pose + "_")):
    _fail("Wrong imported animation for %s / %s: %s" % [CLASSES[i], moving_pose, moving_name])
    return
   var moving_clip: Animation = animator.get_animation(moving_name)
   if moving_clip == null or moving_clip.get_track_count() == 0:
    _fail("Empty moving animation for %s / %s" % [CLASSES[i], moving_pose])
    return
   var motion_window: float = 1.1 if moving_pose == "Walk" else 0.9
   animator.seek(maxf(0.0, moving_clip.length - 0.45 * motion_window), true)
   var moving_label: String = "front_" + moving_pose.to_lower()
   if not await _capture(CLASSES[i] + "_" + moving_label, hero, moving_label, i):
    return
   pictures += 1
  # Restore attack pose for consistent side-by-side attack visuals.
  chibi.call("play_clip", "Attack")
  animator.seek(midpoint, true)
  # Every class gets a side view, revealing weapon/armor overlap on Android.
  hero.rotation.y = PI * 0.5
  if not await _capture(CLASSES[i] + "_side_attack", hero, "side_attack", i):
   return
  pictures += 1
  hero.rotation.y = 0.0
  # Compare original rarity progression on both large-sword hero classes.
  # The production battle still keeps its normal quality and inventory state.
  if i in [0, 11]:
   for sampled_quality in [0, 3]:
    if not bool(ctrl.call("equip_weapon", ADAPTER.weapon_type_for_class(i), sampled_quality)):
     _fail("Cannot preview sampled sword rarity")
     return
    for socket_name in ADAPTER.SOCKETS:
     if socket_name in ["RightHandSocket", "LeftHandSocket"]:
      continue
     if not bool(ctrl.call("equip_armor_slot", socket_name, i, sampled_quality)):
      _fail("Cannot preview sampled armor rarity")
      return
    await process_frame
    chibi.call("play_clip", "Idle")
    var label: String = CLASSES[i] + "_front_rarity_" + str(sampled_quality)
    if not await _capture(label, hero, "front_rarity_" + str(sampled_quality), i):
     return
    pictures += 1
 if not _build_contact_sheet("front_attack") or not _build_contact_sheet("side_attack") or not _build_contact_sheet("front_walk") or not _build_contact_sheet("front_dodge"):
  return
 var team_captures: int = await _capture_four_hero_formation()
 if team_captures != 4:
  return
 pictures += team_captures
 var file := FileAccess.open(OUTPUT + "/manifest.json", FileAccess.WRITE)
 if file == null:
  _fail("Cannot write QA manifest")
  return
 file.store_string(JSON.stringify({
   "generator": "Godot 4.7.2 live imported GLB equipment QA",
   "image_count": pictures, "class_count": CLASSES.size(),
   "formation_capture_count": team_captures, "formation_classes": ["warrior", "mage", "death_knight", "druid"],
   "contact_sheets": ["overview_front_attack.png", "overview_side_attack.png", "overview_front_walk.png", "overview_front_dodge.png"],
   "contact_sheet_order": CLASSES,
   "real_android_device_tested": false, "renders": results
  }, "  "))
 file.close()
 print("TITAN_EQUIPMENT_VISUAL_QA_OK images=%d classes=%d" % [pictures, CLASSES.size()])
 quit(0)
