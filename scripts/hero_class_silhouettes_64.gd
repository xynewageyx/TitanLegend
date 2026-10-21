extends RefCounted
# Update 64: lightweight class-specific silhouettes built from primitive meshes.
# Decorative only: no hitboxes, statistics, skill order or pet behavior changed.
static func decorate(hero: Node3D, class_id: int) -> void:
 var metal: Color = Color("#a8b5c8")
 var gold: Color = Color("#e6c76d")
 var green: Color = Color("#4ebd79")
 var purple: Color = Color("#8c65d1")
 match class_id:
  0: # Krieger: broad plate shoulders and a helmet crest
   _shoulders(hero, metal, 0.39)
   VisualFactory.box(hero, Vector3(0.18, 0.36, 0.58), Vector3(0, 2.37, 0), Color("#b33e3e"))
  1: # Paladin: golden tabard and halo-like crown
   _shoulders(hero, gold, 0.34)
   VisualFactory.box(hero, Vector3(0.46, 0.67, 0.07), Vector3(0, 1.08, -0.40), gold)
   _crown(hero, gold)
  2: # Druide: branching wooden antlers and leaf mantle
   _horns(hero, Color("#75543b"), 0.52)
   _shoulders(hero, green, 0.29)
   VisualFactory.sphere(hero, 0.16, Vector3(0, 1.34, -0.45), green)
  3: # Schamane: twin shoulder totems and turquoise beads
   for side in [-1.0, 1.0]:
    VisualFactory.cylinder(hero, 0.55, 0.13, Vector3(side * 0.56, 1.89, 0.16), Color("#705037"))
    VisualFactory.sphere(hero, 0.12, Vector3(side * 0.56, 2.21, 0.16), Color("#54d9ed"))
   VisualFactory.sphere(hero, 0.15, Vector3(0, 1.28, -0.44), Color("#54d9ed"))
  4: # Jaeger: hood, back quiver and shoulder leather
   _shoulders(hero, Color("#486443"), 0.26)
   VisualFactory.box(hero, Vector3(0.29, 0.78, 0.24), Vector3(-0.40, 1.57, 0.38), Color("#68472e"))
  5: # Schurke: asymmetric pauldrons and dark face mask
   VisualFactory.box(hero, Vector3(0.45, 0.18, 0.48), Vector3(-0.49, 1.67, 0), Color("#34314b"))
   VisualFactory.box(hero, Vector3(0.47, 0.16, 0.09), Vector3(0, 1.87, -0.27), Color("#29253d"))
  6: # Magier: high collar and arcane floating-looking gems
   _collar(hero, Color("#426bd0"))
   VisualFactory.sphere(hero, 0.14, Vector3(0, 2.42, 0), Color("#77d9ff"))
  7: # Hexer: dark horns and violet amulet
   _horns(hero, Color("#50346c"), 0.38)
   _collar(hero, Color("#51305e"))
   VisualFactory.sphere(hero, 0.14, Vector3(0, 1.29, -0.48), purple)
  8: # Beschwoerer: rune shoulderstones and violet crystal
   _shoulders(hero, purple, 0.30)
   for side in [-1.0, 1.0]:
    VisualFactory.sphere(hero, 0.13, Vector3(side * 0.59, 1.99, 0), Color("#d29cff"))
   VisualFactory.sphere(hero, 0.18, Vector3(0, 1.32, -0.46), purple)
  9: # Priester: ceremonial light stole and diadem
   _crown(hero, Color("#fff0ad"))
   for side in [-1.0, 1.0]:
    VisualFactory.box(hero, Vector3(0.12, 0.86, 0.08), Vector3(side * 0.20, 1.17, -0.43), Color("#f4e3a6"))
  10: # Raufbold: reinforced fist guards and bare shoulder silhouette
   for side in [-1.0, 1.0]:
    VisualFactory.box(hero, Vector3(0.31, 0.29, 0.32), Vector3(side * 0.49, 0.79, -0.09), Color("#9b593e"))
    VisualFactory.box(hero, Vector3(0.29, 0.10, 0.33), Vector3(side * 0.49, 0.91, -0.09), gold)

static func _shoulders(hero: Node3D, tint: Color, radius: float) -> void:
 for side in [-1.0, 1.0]:
  VisualFactory.sphere(hero, radius, Vector3(side * 0.49, 1.64, 0.05), tint)

static func _horns(hero: Node3D, tint: Color, width: float) -> void:
 for side in [-1.0, 1.0]:
  VisualFactory.box(hero, Vector3(0.12, 0.42, 0.14), Vector3(side * width, 2.33, 0.03), tint)
  VisualFactory.sphere(hero, 0.10, Vector3(side * width, 2.57, 0.03), tint.lightened(0.15))

static func _crown(hero: Node3D, tint: Color) -> void:
 VisualFactory.box(hero, Vector3(0.56, 0.10, 0.40), Vector3(0, 2.24, 0), tint)
 VisualFactory.sphere(hero, 0.11, Vector3(0, 2.34, -0.20), tint.lightened(0.25))

static func _collar(hero: Node3D, tint: Color) -> void:
 for side in [-1.0, 1.0]:
  VisualFactory.box(hero, Vector3(0.17, 0.41, 0.28), Vector3(side * 0.30, 1.78, 0.02), tint)
