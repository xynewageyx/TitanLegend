extends SceneTree
## Godot 4.7.2 display-only QA: real boss meshes/motion + real CameraFollow boss branch.
## Captures active-boss and warning telegraph with a clearly marked HUD QA overlay.
const BOSS_ART = preload("res://scripts/boss_art.gd")
const BOSS_MOTION = preload("res://scripts/boss_motion.gd")
const ADAPTER = preload("res://scripts/equipment/formation_equipment_adapter.gd")
const CAMERA_SCRIPT = preload("res://scripts/camera_follow.gd")
const QA_STATE = preload("res://tools/boss_camera_qa_state.gd")
const OUTPUT := "res://build/boss_gameplay_camera_qa"
var stage: Node3D
var team: Node3D
var enemy_spawn: Node3D
var boss_state: Node3D
var camera: Camera3D
var overlay: CanvasLayer
var production_hud: Control

func _initialize() -> void:
 call_deferred("_run")

func _fail(message: String) -> void:
 push_error("BOSS_CAMERA_QA: " + message)
 quit(1)

func _descendants(node: Node) -> Array[Node]:
 var all: Array[Node] = []
 for child in node.get_children():
  all.append(child)
  all.append_array(_descendants(child))
 return all

func _screen_box(node: Node3D) -> Dictionary:
 var left := INF
 var right := -INF
 var top := INF
 var bottom := -INF
 var found := false
 var behind := 0
 for child in _descendants(node):
  var mesh: MeshInstance3D = child as MeshInstance3D
  if mesh == null or mesh.mesh == null or not mesh.is_visible_in_tree():
   continue
  var aabb: AABB = mesh.get_aabb()
  for i in range(8):
   var position: Vector3 = mesh.global_transform * aabb.get_endpoint(i)
   if camera.is_position_behind(position):
    behind += 1
    continue
   var px: Vector2 = camera.unproject_position(position)
   left = minf(left, px.x)
   right = maxf(right, px.x)
   top = minf(top, px.y)
   bottom = maxf(bottom, px.y)
   found = true
 if not found:
  return {"valid": false, "reason": "no projected visible mesh"}
 var width: float = float(root.get_visible_rect().size.x)
 var height: float = float(root.get_visible_rect().size.y)
 var clipped_left: float = maxf(left, 0)
 var clipped_top: float = maxf(top, 0)
 var clipped_right: float = minf(right, width)
 var clipped_bottom: float = minf(bottom, height)
 var coverage: float = maxf(0, clipped_right - clipped_left) * maxf(0, clipped_bottom - clipped_top) / maxf(1.0, (right-left) * (bottom-top))
 return {"valid": true, "viewport_fraction": snappedf(coverage, 0.0001),
  "bbox_px": [snappedf(left,0.1),snappedf(top,0.1),snappedf(right-left,0.1),snappedf(bottom-top,0.1)],
  "behind_vertices": behind}

func _make_stage() -> bool:
 stage = Node3D.new()
 stage.name = "BossGameplayCameraQA"
 root.add_child(stage)
 var env := WorldEnvironment.new()
 var settings := Environment.new()
 settings.background_mode = Environment.BG_COLOR
 settings.background_color = Color("#162637")
 settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
 settings.ambient_light_color = Color.WHITE
 settings.ambient_light_energy = 0.7
 env.environment = settings
 stage.add_child(env)
 var sun := DirectionalLight3D.new()
 sun.rotation_degrees = Vector3(-50,-30,0)
 stage.add_child(sun)
 var team_script: Script = load("res://scripts/team_formation.gd")
 if team_script == null:
  return false
 team = team_script.new() as Node3D
 team.name = "EquipmentQATeam"
 team.position = Vector3(0,0,3) # matches scenes/main.tscn
 stage.add_child(team)
 team.set_process(false)
 var lineup: Array[int] = [0,6,11,2]
 var roles: Array[int] = [0,1,1,2]
 for i in range(4):
  team.class_ids[i] = lineup[i]
  team.role_ids[i] = roles[i]
 team.create_team()
 for i in range(team.heroes.size()):
  var hero: Node3D = team.heroes[i]
  var controller: Node3D = hero.get_node("EquipmentController") as Node3D
  if not bool(controller.call("equip_weapon", ADAPTER.weapon_type_for_class(lineup[i]), 5)):
   return false
  if not bool(controller.call("equip_armor_slot", "ChestSocket", lineup[i], 5)):
   return false
  var visual: Node3D = hero.get_node("ChibiGLBVisual") as Node3D
  visual.set_process(false)
 enemy_spawn = Node3D.new()
 enemy_spawn.name = "EnemySpawn"
 enemy_spawn.position = Vector3(0,0,-8) # matches scenes/main.tscn
 stage.add_child(enemy_spawn)
 boss_state = Node3D.new()
 boss_state.name = "BossState"
 boss_state.set_script(QA_STATE)
 stage.add_child(boss_state)
 camera = Camera3D.new()
 camera.name = "RealBossGameplayCamera"
 camera.set_script(CAMERA_SCRIPT)
 camera.set("target_path",NodePath("../EquipmentQATeam"))
 camera.set("enemy_spawn_path",NodePath("../EnemySpawn"))
 camera.set("battle_manager_path",NodePath("../BossState"))
 stage.add_child(camera)
 camera.set_process(false)
 # Use real production UIManager._make_hud() controls through a QA-only subclass.
 # Values are fixed diagnostic state; production BattleManager is not running.
 overlay = CanvasLayer.new()
 overlay.name = "BossHudProductionWidgetsQA"
 stage.add_child(overlay)
 var hud_script: Script = load("res://tools/boss_camera_real_hud_qa.gd") as Script
 if hud_script == null:
  push_error("Cannot dynamically load production HUD adapter")
  return false
 production_hud = Control.new()
 production_hud.name = "UIManagerWidgetsPreview"
 production_hud.set_script(hud_script)
 overlay.add_child(production_hud)

 return true

func _changed_pixels(a: Image, b: Image) -> int:
 if a == null or b == null or a.get_size() != b.get_size():
  return -1
 var first: Image = a.duplicate()
 var second: Image = b.duplicate()
 first.convert(Image.FORMAT_RGB8)
 second.convert(Image.FORMAT_RGB8)
 var pixels_a: PackedByteArray = first.get_data()
 var pixels_b: PackedByteArray = second.get_data()
 var changed := 0
 for i in range(0, pixels_a.size(), 3):
  if absi(int(pixels_a[i]) - int(pixels_b[i])) > 24 or absi(int(pixels_a[i+1]) - int(pixels_b[i+1])) > 24 or absi(int(pixels_a[i+2]) - int(pixels_b[i+2])) > 24:
   changed += 1
 return changed


func _snapshot(filename: String) -> bool:
 await RenderingServer.frame_post_draw
 var image: Image = root.get_texture().get_image()
 return image != null and not image.is_empty() and image.save_png(OUTPUT + "/" + filename) == OK

func _run() -> void:
 if DisplayServer.get_name() == "headless":
  _fail("Needs a real display renderer")
  return
 DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
 if not _make_stage():
  _fail("Cannot build four equipped original heroes")
  return
 await process_frame
 var output: Array[Dictionary] = []
 for scenario in [
  {"name":"fire", "element":0, "fusion":false, "scale":0.63},
  {"name":"earth", "element":2, "fusion":true, "scale":0.61}
 ]:
  var boss := Node3D.new()
  boss.name = "Boss"
  boss.scale = Vector3.ONE * float(scenario["scale"])
  enemy_spawn.add_child(boss)
  BOSS_ART.build(boss, int(scenario["element"]), bool(scenario["fusion"]))
  var motion: Node3D = Node3D.new()
  motion.name = "BossMotion"
  motion.set_script(BOSS_MOTION)
  boss.add_child(motion)
  motion.call("configure",boss,int(scenario["element"]),bool(scenario["fusion"]))
  motion.set_process(false)
  # The real CameraFollow._desired_view() boss branch is evaluated in _ready.
  camera.set_process(false)
  var view: Dictionary = camera.call("_desired_view")
  camera.global_position = view["position"]
  camera.look_at(view["focus"],Vector3.UP)
  await RenderingServer.frame_post_draw
  var baseline_box: Dictionary = _screen_box(boss)
  var hero_boxes: Array[Dictionary] = []
  for hero in team.heroes:
   hero_boxes.append(_screen_box(hero.get_node("ChibiGLBVisual")))
  if not bool(baseline_box.get("valid",false)):
   _fail("Boss cannot be projected")
   return
  for hero_box in hero_boxes:
   if not bool(hero_box.get("valid",false)):
    _fail("Team hero not projected")
    return
  production_hud.call("set_boss_qa_values", str(scenario["name"]).capitalize() + "-Titan", false)
  await process_frame
  var hud_layout: Dictionary = production_hud.call("get_qa_layout")
  if not bool(hud_layout.get("boss_health_visible", false)) or not bool(hud_layout.get("boss_timer_visible", false)) or not bool(hud_layout.get("chat_visible", false)):
   _fail("Real UIManager boss HP, countdown or chat widgets are not visible")
   return
  var idle_image: String = "boss_" + str(scenario["name"]) + "_idle.png"
  if not await _snapshot(idle_image):
   _fail("Cannot render " + idle_image)
   return
  var idle_pixels: Image = Image.load_from_file(OUTPUT + "/" + idle_image)
  motion.call("attack_windup")
  motion.call("_process",0.12)
  var warning: MeshInstance3D = motion.get("warning_ring") as MeshInstance3D
  if warning == null or not warning.visible:
   _fail("Missing real boss windup ring")
   return
  # Compare while the diagnostic HUD warning is still hidden, so the real
  # in-world 3D windup must visibly change at least one substantial pixel area.
  await RenderingServer.frame_post_draw
  var warning_pixels: Image = root.get_texture().get_image()
  var windup_delta: int = _changed_pixels(idle_pixels,warning_pixels)
  if windup_delta < 20:
   _fail("Original 3D boss windup invisible (changed pixels " + str(windup_delta) + ")")
   return
  production_hud.call("set_boss_qa_values", str(scenario["name"]).capitalize() + "-Titan", true)
  var warning_image: String = "boss_" + str(scenario["name"]) + "_windup.png"
  if not await _snapshot(warning_image):
   _fail("Cannot render " + warning_image)
   return
  var hud_warning_layout: Dictionary = production_hud.call("get_qa_layout")
  if not str(hud_warning_layout.get("boss_name", "")).contains("Unterbrechen"):
   _fail("Production boss label failed to display cast warning")
   return
  production_hud.call("set_boss_qa_values", str(scenario["name"]).capitalize() + "-Titan", false)
  var warning_box: Dictionary = _screen_box(boss)
  output.append({"scenario":scenario["name"],"element":scenario["element"],
   "fusion":scenario["fusion"],"idle_image":idle_image,"windup_image":warning_image,
   "hud_layout":hud_layout,"hud_warning_layout":hud_warning_layout,
   "boss_body_box":baseline_box,"boss_warning_box":warning_box,
   "hero_boxes":hero_boxes,"boss_warning_visible":warning.visible,
   "windup_changed_pixels_without_hud_text":windup_delta,
   "camera_position":[camera.position.x,camera.position.y,camera.position.z],
   "fov_degrees":camera.fov})
  enemy_spawn.remove_child(boss)
  boss.queue_free()
  await process_frame
 var summary := {"valid":output.size()==2,"source_camera":"res://scripts/camera_follow.gd",
  "boss_art_source":"res://scripts/boss_art.gd","boss_motion_source":"res://scripts/boss_motion.gd",
  "hero_count":4,"scenarios":output,"screenshots":4,
  "ui":"Production UIManager._make_hud widgets through QA subclass with fixed diagnostic boss values",
  "hud_widget_source":"res://scripts/ui_manager.gd", "hud_production_widgets_rendered":true,
  "real_android_device_tested":false,"hud_production_validated":false,
  "hud_battle_state_live":false,
  "limitations":"True UIManager widget layout but QA-supplied battle values; no production HUD _ready wiring, boss timer progression or physical Android device"}
 var file := FileAccess.open(OUTPUT + "/boss_camera_report.json",FileAccess.WRITE)
 if file == null:
  _fail("Cannot save boss report")
  return
 file.store_string(JSON.stringify(summary,"  ")+"\n")
 file.close()
 print("TITAN_BOSS_CAMERA_QA_OK scenarios=2 images=4")
 quit(0)
