extends RefCounted
class_name HeroVisualUpgrade

# Update: more recognizable 3D heroes, without new textures, particles,
# collisions, gameplay stats or per-frame mesh creation.
# Geometry is created once whenever a hero's class or role changes.
const SKIN_TONES := [
 Color("#e9bc96"), Color("#b77d5e"), Color("#d9a47e"), Color("#a96950")
]
const HAIR_TONES := [
 Color("#392d2c"), Color("#805538"), Color("#242d3f"), Color("#c1a16c")
]
const CLASS_TRIM := [
 Color("#c5d1dd"), Color("#f0d37b"), Color("#7ed6a0"),
 Color("#72d8e6"), Color("#92bb6c"), Color("#9b91bd"),
 Color("#79bdff"), Color("#a578e4"), Color("#d09bfa"),
 Color("#fff2ba"), Color("#dca070")
]

static func decorate(hero: Node3D, class_id: int, role_id: int, slot: int) -> void:
 if not is_instance_valid(hero) or class_id < 0 or class_id >= CLASS_TRIM.size():
  return
 var accent: Color = CLASS_TRIM[class_id]
 # Identifiable faces also in four-hero groups with matching classes.
 var head: MeshInstance3D = hero.get_node_or_null("HeroHead") as MeshInstance3D
 if head != null:
  head.material_override = VisualFactory.material(SKIN_TONES[posmod(slot + class_id, SKIN_TONES.size())])
 var hair: MeshInstance3D = hero.get_node_or_null("HeroHair") as MeshInstance3D
 if hair != null:
  hair.material_override = VisualFactory.material(HAIR_TONES[posmod(slot + class_id * 2, HAIR_TONES.size())])
 # A subtle face highlight is visible even under the class headgear.
 _plate(hero, Vector3(0.0, 1.87, -0.292), Vector3(0.105, 0.025, 0.025), Color("#8f594c"))
 _plate(hero, Vector3(0.0, 1.02, -0.375), Vector3(0.57, 0.085, 0.085), accent.darkened(0.35))
 _role_detail(hero, role_id, accent)
 _class_detail(hero, class_id, accent)

static func _plate(parent: Node3D, at: Vector3, size: Vector3, color: Color) -> void:
 VisualFactory.box(parent, size, at, color)

static func _jewel(parent: Node3D, at: Vector3, color: Color, radius: float = 0.10) -> void:
 var gem: MeshInstance3D = VisualFactory.sphere(parent, radius, at, color)
 gem.scale = Vector3(1.0, 1.2, 0.55)
 var material: StandardMaterial3D = VisualFactory.material(color)
 material.emission_enabled = true
 material.emission = color
 material.emission_energy_multiplier = 0.6
 gem.material_override = material

static func _role_detail(hero: Node3D, role_id: int, accent: Color) -> void:
 match role_id:
  0: # Tank: reinforced shoulders and shield-shaped breastplate.
   for side in [-1.0, 1.0]:
    _plate(hero, Vector3(side * 0.54, 1.69, -0.10), Vector3(0.23, 0.19, 0.34), accent.darkened(0.22))
   _plate(hero, Vector3(0, 1.42, -0.44), Vector3(0.43, 0.35, 0.08), accent.lightened(0.10))
   _plate(hero, Vector3(0, 1.37, -0.49), Vector3(0.09, 0.36, 0.035), accent.darkened(0.28))
  1: # Damage dealer: asymmetric shoulder strap and compact crest.
   _plate(hero, Vector3(-0.25, 1.54, -0.37), Vector3(0.12, 0.48, 0.05), accent.darkened(0.25))
   _jewel(hero, Vector3(0.18, 1.47, -0.44), accent, 0.105)
  2: # Healer: hanging ceremonial stole and luminous clasp.
   for side in [-1.0, 1.0]:
    _plate(hero, Vector3(side * 0.21, 1.14, -0.43), Vector3(0.12, 0.66, 0.055), accent)
   _jewel(hero, Vector3(0, 1.51, -0.48), accent.lightened(0.23), 0.13)

static func _class_detail(hero: Node3D, class_id: int, accent: Color) -> void:
 match class_id:
  0: # Warrior: crested helm, armored collar, riveted chest.
   _plate(hero, Vector3(0, 2.49, 0.03), Vector3(0.13, 0.31, 0.50), Color("#b74c42"))
   for side in [-1.0, 1.0]:
    _jewel(hero, Vector3(side * 0.37, 1.66, -0.30), accent.darkened(0.1), 0.07)
  1: # Paladin: sun insignia and luminous gold shoulder trim.
   _plate(hero, Vector3(0, 1.45, -0.51), Vector3(0.35, 0.07, 0.05), accent)
   _plate(hero, Vector3(0, 1.45, -0.52), Vector3(0.07, 0.36, 0.05), accent)
   for side in [-1.0, 1.0]:
    _jewel(hero, Vector3(side * 0.49, 1.70, -0.26), Color("#fff6b0"), 0.075)
  2: # Druid: leaf-clasp, bark bands and small antler shoots.
   _jewel(hero, Vector3(0, 1.33, -0.47), Color("#66ee90"), 0.13)
   for side in [-1.0, 1.0]:
    _plate(hero, Vector3(side * 0.49, 0.98, -0.07), Vector3(0.18, 0.12, 0.22), Color("#79543d"))
    _plate(hero, Vector3(side * 0.40, 2.57, 0.05), Vector3(0.09, 0.28, 0.11), Color("#79543d"))
  3: # Shaman: turquoise ritual beads, totem bands.
   for side in [-1.0, 1.0]:
    _jewel(hero, Vector3(side * 0.32, 1.63, -0.32), Color("#54dfda"), 0.095)
    _plate(hero, Vector3(side * 0.49, 0.95, -0.05), Vector3(0.20, 0.11, 0.24), Color("#765942"))
  4: # Hunter: feathered quiver and angled leather harness.
   _plate(hero, Vector3(-0.43, 2.02, 0.35), Vector3(0.21, 0.40, 0.11), Color("#7c5537"))
   for n in range(3):
    _plate(hero, Vector3(-0.55 + float(n) * 0.11, 2.30, 0.38), Vector3(0.055, 0.21, 0.06), Color("#e8d7a9"))
   _plate(hero, Vector3(0.27, 1.36, -0.37), Vector3(0.10, 0.58, 0.05), accent.darkened(0.24))
  5: # Rogue: sharp split brow and a diagonal night-leather strap.
   _plate(hero, Vector3(0, 1.95, -0.33), Vector3(0.46, 0.10, 0.05), Color("#191a31"))
   _plate(hero, Vector3(-0.25, 1.36, -0.40), Vector3(0.10, 0.63, 0.05), Color("#594365"))
   _jewel(hero, Vector3(-0.21, 1.31, -0.45), accent, 0.075)
  6: # Mage: crystal hat clasp and two rune-backed shoulder clasps.
   _jewel(hero, Vector3(0, 2.30, -0.33), Color("#84e5ff"), 0.13)
   for side in [-1.0, 1.0]:
    _plate(hero, Vector3(side * 0.35, 1.80, -0.11), Vector3(0.15, 0.28, 0.22), Color("#304c90"))
  7: # Warlock: shadow-banded cuirass and violet horn tips.
   _plate(hero, Vector3(0, 1.44, -0.44), Vector3(0.56, 0.09, 0.07), Color("#412454"))
   _jewel(hero, Vector3(0, 1.30, -0.48), Color("#e06afa"), 0.145)
   for side in [-1.0, 1.0]:
    _jewel(hero, Vector3(side * 0.43, 2.55, 0.04), accent, 0.075)
  8: # Summoner: purple binding sigil surrounded by two side stones.
   _jewel(hero, Vector3(0, 1.36, -0.50), Color("#d7a0ff"), 0.15)
   for side in [-1.0, 1.0]:
    _plate(hero, Vector3(side * 0.33, 1.35, -0.46), Vector3(0.11, 0.30, 0.05), accent.darkened(0.18))
  9: # Priest: white-gold stole pin and paired light accents.
   _plate(hero, Vector3(0, 1.38, -0.49), Vector3(0.10, 0.43, 0.07), Color("#fff6d5"))
   _plate(hero, Vector3(0, 1.44, -0.51), Vector3(0.34, 0.10, 0.05), accent)
   for side in [-1.0, 1.0]:
    _jewel(hero, Vector3(side * 0.34, 1.79, -0.16), Color("#fff1a3"), 0.065)
  10: # Brawler: double wrap bands and chunky knuckle studs.
   for side in [-1.0, 1.0]:
    _plate(hero, Vector3(side * 0.49, 0.93, -0.23), Vector3(0.28, 0.10, 0.08), Color("#dbb18d"))
    for stud in range(2):
     _jewel(hero, Vector3(side * (0.43 + float(stud) * 0.10), 0.77, -0.24), accent, 0.052)
