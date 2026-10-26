extends RefCounted
# Additional low-poly armor layers and class silhouettes for portrait Android.
# Cosmetic only: no hitboxes, active pet skills or combat stat changes.
const METAL := Color("#aebbc8")
const LEATHER := Color("#4d3c32")
const CLOTH := Color("#303a58")
const GOLD := Color("#dfbd71")

static func _box(hero: Node3D, size: Vector3, at: Vector3, tint: Color) -> void:
 VisualFactory.box(hero, size, at, tint)

static func _gem(hero: Node3D, at: Vector3, tint: Color) -> void:
 var node: MeshInstance3D = VisualFactory.sphere(hero, 0.09, at, tint)
 node.scale = Vector3(1.0, 1.35, 0.6)
 var mat: StandardMaterial3D = VisualFactory.material(tint)
 mat.emission_enabled = true
 mat.emission = tint
 mat.emission_energy_multiplier = 0.5
 node.material_override = mat

static func decorate(hero: Node3D, class_id: int, role_id: int, slot: int) -> void:
 if not is_instance_valid(hero):
  return
 # Layered boots, bracers and shoulder seams improve readability at small sizes.
 var armor: Color = METAL if role_id == 0 else LEATHER
 for side in [-1.0, 1.0]:
  _box(hero, Vector3(0.28, 0.31, 0.36), Vector3(side * 0.22, 0.24, -0.06), armor)
  _box(hero, Vector3(0.32, 0.09, 0.43), Vector3(side * 0.22, 0.12, -0.17), armor.darkened(0.18))
  _box(hero, Vector3(0.17, 0.29, 0.19), Vector3(side * 0.53, 1.03, -0.04), armor.lightened(0.15))
  _box(hero, Vector3(0.33, 0.06, 0.22), Vector3(side * 0.48, 1.68, -0.07), GOLD.darkened(0.18))
 # A rear cloak outline; the face and weapon remain unobstructed from camera -Z.
 if class_id in [1, 2, 3, 4, 6, 7, 8, 9]:
  var cloak_colors: Array[Color] = [
   Color("#f1dba3"), Color("#35563d"), Color("#426e74"),
   Color("#394f32"), Color("#25416e"), Color("#3b254f"),
   Color("#593b79"), Color("#e2dbce")
  ]
  var cloak_classes: Array[int] = [1, 2, 3, 4, 6, 7, 8, 9]
  var cloak: Color = cloak_colors[cloak_classes.find(class_id)]
  _box(hero, Vector3(0.83, 1.23, 0.07), Vector3(0, 0.96, 0.43), cloak)
  for side in [-1.0, 1.0]:
   _box(hero, Vector3(0.07, 0.9, 0.11), Vector3(side * 0.41, 0.91, 0.48), cloak.darkened(0.23))
 match class_id:
  0: # Warrior: crossguard and weighty shoulder plates.
   _box(hero, Vector3(0.36, 0.09, 0.15), Vector3(0.73, 0.96, -0.12), GOLD)
   _box(hero, Vector3(0.28, 0.32, 0.27), Vector3(-0.49, 1.72, -0.08), METAL)
  1: # Paladin: radiant centerline and plate trim.
   _box(hero, Vector3(0.10, 0.46, 0.08), Vector3(0, 1.43, -0.53), GOLD)
   _gem(hero, Vector3(0, 1.61, -0.56), Color("#fff0a8"))
  2: # Druid: leaf clasp and uneven bark armor.
   _gem(hero, Vector3(0, 1.47, -0.53), Color("#76f09a"))
   _box(hero, Vector3(0.35, 0.10, 0.19), Vector3(-0.4, 1.75, -0.21), Color("#79573c"))
  3: # Shaman: leather charms and turquoise accents.
   for side in [-1.0, 1.0]:
    _gem(hero, Vector3(side * 0.33, 1.44, -0.48), Color("#5ae5d5"))
  4: # Hunter: visible arrows over the shoulder.
   for arrow in range(3):
    _box(hero, Vector3(0.045, 0.43, 0.045), Vector3(-0.49 + float(arrow) * 0.09, 2.12, 0.47), Color("#d7b27b"))
  5: # Rogue: asymmetric shoulder leather and forearm blades.
   _box(hero, Vector3(0.35, 0.20, 0.30), Vector3(-0.50, 1.70, -0.05), Color("#3c354e"))
   _box(hero, Vector3(0.06, 0.47, 0.07), Vector3(0.60, 1.03, -0.25), METAL)
  6: # Mage: waist rune and staff fitting.
   _gem(hero, Vector3(0, 1.02, -0.45), Color("#7cdbff"))
   _box(hero, Vector3(0.20, 0.11, 0.20), Vector3(0.66, 2.24, -0.06), GOLD)
  7: # Warlock: jagged chest bands.
   _box(hero, Vector3(0.59, 0.08, 0.08), Vector3(0, 1.53, -0.47), Color("#744799"))
   _gem(hero, Vector3(0, 1.38, -0.54), Color("#b85aeb"))
  8: # Summoner: paired focus crystals.
   for side in [-1.0, 1.0]:
    _gem(hero, Vector3(side * 0.40, 1.68, -0.34), Color("#d69aff"))
  9: # Priest: gold stole hem and clasp.
   _box(hero, Vector3(0.66, 0.07, 0.07), Vector3(0, 0.65, -0.47), GOLD)
   _gem(hero, Vector3(0, 1.62, -0.52), Color("#fff5bd"))
  10: # Brawler: thick knuckle guards.
   for side in [-1.0, 1.0]:
    _box(hero, Vector3(0.25, 0.15, 0.22), Vector3(side * 0.54, 0.80, -0.20), Color("#aa6b4a"))
 # Individual tiny collar pin, deterministic by party slot.
 if slot >= 0 and slot < 4:
  _gem(hero, Vector3(-0.31 + float(slot) * 0.055, 1.77, -0.28), GOLD)
