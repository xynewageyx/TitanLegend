extends SceneTree
# Godot headless test: build cosmetic details for all eleven classes and
# every role without scene textures, animation clips or gameplay systems.
const UPGRADE = preload("res://scripts/hero_visual_upgrade.gd")

func _initialize() -> void:
 call_deferred("_run_tests")

func _run_tests() -> void:
 for class_id in range(11):
  for role_id in range(3):
   var hero := Node3D.new()
   hero.name = "HeroVisualTest"
   root.add_child(hero)
   var head := MeshInstance3D.new()
   head.name = "HeroHead"
   hero.add_child(head)
   var hair := MeshInstance3D.new()
   hair.name = "HeroHair"
   hero.add_child(hair)
   UPGRADE.decorate(hero, class_id, role_id, 1)
   if head.material_override == null or hair.material_override == null:
    _fail("Missing class-specific face/hair tint: %d/%d" % [class_id, role_id])
    return
   var mesh_count: int = 0
   for child in hero.get_children():
    if child is CollisionShape3D or child is CollisionObject3D:
     _fail("Cosmetic detail unexpectedly created a collision shape")
     return
    if child is MeshInstance3D:
     mesh_count += 1
   if mesh_count < 5:
    _fail("Class %d role %d did not receive visible details" % [class_id, role_id])
    return
   root.remove_child(hero)
   hero.free()
 print("Titan Legends: 11 classes x 3 role variants visually initialized.")
 quit(0)

func _fail(message: String) -> void:
 push_error(message)
 quit(1)
