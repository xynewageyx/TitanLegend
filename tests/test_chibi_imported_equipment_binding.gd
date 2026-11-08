extends SceneTree
## Runtime smoke: real twelve-class GLBs must drive inventory weapon/armor sockets.
const BRIDGE = preload("res://scripts/rig/titan_skeleton_bridge.gd")
const ADAPTER = preload("res://scripts/equipment/formation_equipment_adapter.gd")
const IMPORTED = preload("res://scripts/equipment/chibi_imported_equipment_sockets.gd")
const CLASSES := ["warrior", "paladin", "druid", "shaman", "hunter", "rogue", "mage", "warlock", "summoner", "priest", "brawler", "death_knight"]

func _initialize() -> void:
 call_deferred("_run")

func _fail(message: String) -> void:
 push_error(message)
 quit(1)

func _run() -> void:
 var inspected: int = 0
 for hero_class in CLASSES:
  var hero := Node3D.new()
  root.add_child(hero)
  ADAPTER.install(hero)
  var path: String = "res://assets/heroes/chibi/" + str(hero_class) + ".glb"
  if not ResourceLoader.exists(path):
   _fail("Missing chibi GLB: " + str(hero_class))
   return
  var scene: PackedScene = load(path) as PackedScene
  if scene == null:
   _fail("GLB could not load: " + str(hero_class))
   return
  # Match the actual game hierarchy: EquipmentController locates imported
  # anchors via hero/ChibiGLBVisual.imported_skeleton.
  var chibi := Node3D.new()
  chibi.name = "ChibiGLBVisual"
  chibi.set_script(preload("res://scripts/chibi_glb_visual.gd"))
  hero.add_child(chibi)
  chibi.configure(inspected)
  chibi.set_process(false) # This standalone smoke fixture has no combat team.
  var skeleton: Skeleton3D = chibi.get("imported_skeleton") as Skeleton3D
  if skeleton == null or not bool(chibi.get_meta("imported_equipment_sockets_ready", false)):
   _fail("ChibiGLBVisual did not install inventory bone anchors: " + str(hero_class))
   return
  var controller: Node3D = hero.get_node("EquipmentController") as Node3D
  for slot in ADAPTER.SOCKETS:
   var marker: Node3D = IMPORTED.resolve(skeleton, str(slot))
   if marker == null or controller.call("_socket", str(slot)) != marker:
    _fail("Equipment controller is not using imported bone: " + str(hero_class) + " / " + str(slot))
    return
  var child_count: int = skeleton.get_child_count()
  if not IMPORTED.install(skeleton, hero) or skeleton.get_child_count() != child_count:
   _fail("Imported socket installation is not idempotent: " + str(hero_class))
   return
  var hand_name: String = IMPORTED.selected_bone(skeleton, "RightHandSocket")
  if hero_class == "death_knight" and hand_name != "Hand_R_2":
   _fail("Death Knight sword is not on the 24-bone hand")
   return
  if not bool(controller.call("equip_weapon", ADAPTER.weapon_type_for_class(inspected), 5)):
   _fail("Cannot equip imported weapon: " + str(hero_class))
   return
  if not bool(controller.call("equip_armor_slot", "ChestSocket", inspected, 5)):
   _fail("Cannot equip imported armor: " + str(hero_class))
   return
  await process_frame
  var hand: Node3D = IMPORTED.resolve(skeleton, "RightHandSocket")
  var chest: Node3D = IMPORTED.resolve(skeleton, "ChestSocket")
  if hand.get_child_count() != 1 or chest.get_child_count() != 1:
   _fail("Missing or duplicate bone-bound equipment: " + str(hero_class))
   return
  # Refreshing unchanged inventory must retain each live Node3D, not allocate
  # new meshes or briefly display a second weapon in the same frame.
  var first_equipped: Dictionary = controller.get("equipped_nodes")
  var first_weapon: Node3D = first_equipped["mainhand"] as Node3D
  var first_chest: Node3D = first_equipped["ChestSocket"] as Node3D
  for refresh in range(3):
   if not bool(controller.call("equip_weapon", ADAPTER.weapon_type_for_class(inspected), 5)):
    _fail("Refreshing unchanged weapon failed: " + str(hero_class))
    return
   if not bool(controller.call("equip_armor_slot", "ChestSocket", inspected, 5)):
    _fail("Refreshing unchanged armor failed: " + str(hero_class))
    return
   var repeated: Dictionary = controller.get("equipped_nodes")
   if repeated["mainhand"] != first_weapon or repeated["ChestSocket"] != first_chest:
    _fail("Unchanged equipment was recreated: " + str(hero_class))
    return
   if hand.get_child_count() != 1 or chest.get_child_count() != 1:
    _fail("Equipment refresh duplicated an attached mesh: " + str(hero_class))
    return
  # A real rarity upgrade must replace exactly one visual synchronously,
  # preserving the imported bone anchor and unrelated equipment.
  if not bool(controller.call("equip_weapon", ADAPTER.weapon_type_for_class(inspected), 4)):
   _fail("Replacing weapon failed: " + str(hero_class))
   return
  if not bool(controller.call("equip_armor_slot", "ChestSocket", inspected, 4)):
   _fail("Replacing armor failed: " + str(hero_class))
   return
  var upgraded: Dictionary = controller.get("equipped_nodes")
  if upgraded["mainhand"] == first_weapon or upgraded["ChestSocket"] == first_chest:
   _fail("Changed rarity did not replace visual: " + str(hero_class))
   return
  if first_weapon.get_parent() != null or first_chest.get_parent() != null:
   _fail("Replaced visual remains in a live socket: " + str(hero_class))
   return
  if hand.get_child_count() != 1 or chest.get_child_count() != 1:
   _fail("Rarity switch created overlapping equipment: " + str(hero_class))
   return
  await process_frame
  if hand.get_child_count() != 1 or chest.get_child_count() != 1:
   _fail("Rarity switch lost bone attachments: " + str(hero_class))
   return
  hero.queue_free()
  await process_frame
  inspected += 1
 if inspected != 12:
  _fail("Did not inspect all twelve classes")
  return
 print("PASS: imported chibi equipment sockets bound to all 12 animated GLB rigs")
 quit(0)
