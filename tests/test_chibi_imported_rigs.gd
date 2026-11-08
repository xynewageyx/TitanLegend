extends SceneTree
const BRIDGE = preload("res://scripts/rig/titan_skeleton_bridge.gd")
const CLASSES := ["warrior", "paladin", "druid", "shaman", "hunter", "rogue", "mage", "warlock", "summoner", "priest", "brawler", "death_knight"]

func _initialize() -> void:
 var inspected := 0
 var skeletons := 0
 for hero_class in CLASSES:
  var path: String = "res://assets/heroes/chibi/" + str(hero_class) + ".glb"
  if not ResourceLoader.exists(path):
   print("RIG MODEL ABSENT: ", hero_class)
   continue
  var scene: PackedScene = load(path) as PackedScene
  assert(scene != null, "GLB cannot be loaded: " + hero_class)
  var model: Node = scene.instantiate()
  assert(model != null)
  inspected += 1
  var skeleton: Skeleton3D = BRIDGE.find_skeleton(model)
  if skeleton == null:
   print("RIG NO SKELETON: ", hero_class)
  else:
   skeletons += 1
   var report: Dictionary = BRIDGE.audit(skeleton)
   print("RIG AUDIT: ", hero_class, " bones=", skeleton.get_bone_count(), " found=", report["found"].keys(), " missing=", report["missing"])
  model.free()
 print("PASS: imported chibi GLB audit completed; inspected=", inspected, " skeletons=", skeletons)
 quit()
