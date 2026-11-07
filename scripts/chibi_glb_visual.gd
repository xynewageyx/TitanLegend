extends Node3D
## Imported original chibi base mesh; preserve existing gameplay and equipment nodes.
const NAMES := ["warrior", "paladin", "druid", "shaman", "hunter", "rogue", "mage", "warlock", "summoner", "priest", "brawler", "death_knight"]
var animation_player: AnimationPlayer
var active_clip: String = ""

func configure(class_id: int) -> void:
 var index: int = clampi(class_id, 0, NAMES.size() - 1)
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
 if animation_player == null or clip == active_clip:
  return
 for name in animation_player.get_animation_list():
  if String(name).ends_with(clip):
   animation_player.play(name, 0.15)
   active_clip = clip
   return

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
