extends RefCounted
# Update 125: class-specific lightweight silhouette details for portrait Android.
# Cosmetic only: no collision, damage, healing or gameplay effects.
static func decorate(hero: Node3D, class_id: int) -> void:
 var metal: Color = Color("#b8c5d4")
 var gold: Color = Color("#e8c568")
 var dark: Color = Color("#394252")
 match class_id:
  0: # Krieger: crest and heavy brow guard
   VisualFactory.box(hero, Vector3(0.12, 0.32, 0.48), Vector3(0, 2.31, 0), metal)
   VisualFactory.box(hero, Vector3(0.62, 0.10, 0.18), Vector3(0, 2.10, -0.26), dark)
  1: # Paladin: gilded crown and emblem
   VisualFactory.box(hero, Vector3(0.64, 0.10, 0.18), Vector3(0, 2.17, -0.10), gold)
   VisualFactory.sphere(hero, 0.10, Vector3(0, 2.28, -0.13), gold.lightened(0.3))
   VisualFactory.box(hero, Vector3(0.12, 0.30, 0.06), Vector3(0, 1.38, -0.38), gold)
  2: # Druide: leaf-shaped antler tips
   for side in [-1.0, 1.0]:
    VisualFactory.cylinder(hero, 0.43, 0.055, Vector3(side * 0.25, 2.33, 0), Color("#7a5937"))
    var leaf: MeshInstance3D = VisualFactory.sphere(hero, 0.13, Vector3(side * 0.30, 2.55, -0.04), Color("#72c26b"))
    leaf.scale = Vector3(0.65, 1.6, 0.5)
  3: # Schamane: ritual beads
   for side in [-1.0, 1.0]:
    VisualFactory.sphere(hero, 0.10, Vector3(side * 0.31, 1.83, -0.04), Color("#56d6d3"))
    VisualFactory.sphere(hero, 0.07, Vector3(side * 0.32, 1.67, -0.06), gold)
  4: # Jaeger: pointed hood and feather
   var hood: MeshInstance3D = VisualFactory.sphere(hero, 0.33, Vector3(0, 2.13, 0.13), Color("#365d3d"))
   hood.scale = Vector3(1.05, 0.63, 0.85)
   VisualFactory.box(hero, Vector3(0.08, 0.36, 0.07), Vector3(0.25, 2.37, 0.0), Color("#c7c78b"))
  5: # Schurke: dark half-mask and side hood
   VisualFactory.box(hero, Vector3(0.52, 0.13, 0.07), Vector3(0, 1.91, -0.32), Color("#29293d"))
   for side in [-1.0, 1.0]:
    VisualFactory.sphere(hero, 0.13, Vector3(side * 0.29, 2.06, 0.03), Color("#39344e"))
  6: # Magier: high hat with contrasting band
   VisualFactory.cylinder(hero, 0.43, 0.26, Vector3(0, 2.37, 0.08), Color("#3558a0"))
   VisualFactory.cylinder(hero, 0.06, 0.37, Vector3(0, 2.17, 0.08), gold)
  7: # Hexer: shadow horns
   for side in [-1.0, 1.0]:
    VisualFactory.cylinder(hero, 0.42, 0.08, Vector3(side * 0.24, 2.37, 0.05), Color("#59316f"))
    VisualFactory.sphere(hero, 0.08, Vector3(side * 0.24, 2.60, 0.05), Color("#a96fd2"))
  8: # Beschwoerer: glowing runic forehead gem
   VisualFactory.sphere(hero, 0.105, Vector3(0, 2.08, -0.30), Color("#db9fff"))
   for side in [-1.0, 1.0]:
    VisualFactory.sphere(hero, 0.065, Vector3(side * 0.23, 2.13, -0.20), Color("#a67dd3"))
  9: # Priester: luminous halo and white mantle pins
   VisualFactory.cylinder(hero, 0.045, 0.33, Vector3(0, 2.43, 0.08), gold)
   for side in [-1.0, 1.0]:
    VisualFactory.sphere(hero, 0.11, Vector3(side * 0.42, 1.63, -0.12), Color("#fff0bb"))
  10: # Raufbold: headband and knuckle guards
   VisualFactory.box(hero, Vector3(0.61, 0.11, 0.15), Vector3(0, 2.08, -0.20), Color("#a44c3e"))
   for side in [-1.0, 1.0]:
    VisualFactory.sphere(hero, 0.17, Vector3(side * 0.53, 0.76, -0.11), Color("#865346"))
