extends RefCounted
class_name HeroDetail44
# Procedural, lightweight visual upgrades. No combat-stat changes.
static func decorate(hero: Node3D, class_id: int) -> void:
 var armor: Color = Color("#8e9eb1")
 match class_id:
  1, 9: armor = Color("#e3c77e")
  2, 4: armor = Color("#70b58b")
  3, 6: armor = Color("#78b9e8")
  5, 7, 8: armor = Color("#b08ad2")
  10: armor = Color("#bb8664")
 # Shoulder plates and chest emblem give each silhouette more definition.
 VisualFactory.sphere(hero, 0.27, Vector3(-0.48, 1.57, 0.0), armor)
 VisualFactory.sphere(hero, 0.27, Vector3(0.48, 1.57, 0.0), armor)
 VisualFactory.box(hero, Vector3(0.42, 0.39, 0.10), Vector3(0.0, 1.37, -0.36), armor.lightened(0.18))
 VisualFactory.box(hero, Vector3(0.54, 0.10, 0.43), Vector3(0.0, 0.77, 0.0), Color("#343744"))
 # Face is toward negative Z, the direction of the battlefield.
 VisualFactory.sphere(hero, 0.052, Vector3(-0.105, 1.97, -0.264), Color("#202a3a"))
 VisualFactory.sphere(hero, 0.052, Vector3(0.105, 1.97, -0.264), Color("#202a3a"))
 if class_id in [0, 1, 10]:
  VisualFactory.box(hero, Vector3(0.71, 0.13, 0.64), Vector3(0.0, 2.20, 0.0), armor.lightened(0.12))
 elif class_id in [6, 7, 8, 9]:
  VisualFactory.sphere(hero, 0.16, Vector3(0.0, 2.25, 0.0), armor.lightened(0.30))
 else:
  VisualFactory.box(hero, Vector3(0.44, 0.12, 0.43), Vector3(0.0, 2.20, 0.0), armor.darkened(0.14))

 # Update 46: compact class emblems, reused static meshes only.
 var emblem_color: Color = armor.lightened(0.35)
 if class_id in [0, 1, 10]:
  VisualFactory.box(hero, Vector3(0.13, 0.31, 0.055), Vector3(0, 1.38, -0.425), emblem_color)
  VisualFactory.box(hero, Vector3(0.29, 0.10, 0.055), Vector3(0, 1.38, -0.435), emblem_color)
 elif class_id in [4, 5]:
  VisualFactory.box(hero, Vector3(0.31, 0.065, 0.06), Vector3(0, 1.42, -0.425), emblem_color)
  VisualFactory.box(hero, Vector3(0.17, 0.065, 0.06), Vector3(0, 1.29, -0.425), emblem_color)
 else:
  VisualFactory.sphere(hero, 0.095, Vector3(0, 1.38, -0.425), emblem_color)

 # Update 62: visible boots, gloves and class-colored shoulder insignia.
 for side in [-1.0, 1.0]:
  VisualFactory.box(hero, Vector3(0.32, 0.19, 0.48), Vector3(side * 0.2, 0.09, -0.11), armor.darkened(0.45))
  VisualFactory.sphere(hero, 0.14, Vector3(side * 0.48, 0.86, -0.08), armor.lightened(0.12))
  VisualFactory.box(hero, Vector3(0.11, 0.22, 0.07), Vector3(side * 0.48, 1.62, -0.20), emblem_color)
 if class_id in [2, 3, 4]:
  # Nature-oriented classes wear a compact leaf crest.
  VisualFactory.sphere(hero, 0.12, Vector3(0.0, 1.56, -0.44), Color("#68d68a"))
 elif class_id in [6, 7, 8, 9]:
  # Arcane classes have a crystal on the forehead.
  VisualFactory.sphere(hero, 0.09, Vector3(0.0, 2.09, -0.26), emblem_color)
