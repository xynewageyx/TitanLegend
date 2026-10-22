class_name BossArt
extends RefCounted
# Prozedurale Titan-Silhouetten. Keine externen Assets erforderlich.
const PALETTE = [Color("#ff632d"), Color("#40c8fa"), Color("#b59b70"), Color("#59bd68"), Color("#ffe18b"), Color("#9c65dc"), Color("#c4f4f6"), Color("#a9ecff"), Color("#6a8eff"), Color("#f03c76")]

static func build(parent: Node3D, element: int, fused: bool) -> void:
 var color: Color = PALETTE[clampi(element, 0, 9)]
 var dark: Color = color.darkened(0.48)
 # Schwere Beine und Panzerung als erkennbare Titan-Silhouette.
 for side in [-1.0, 1.0]:
  VisualFactory.cylinder(parent, 2.0, 0.42, Vector3(side * 0.92, 0.9, 0), dark)
  VisualFactory.box(parent, Vector3(1.0, 0.65, 1.3), Vector3(side * 0.92, 0.22, -0.22), dark)
  VisualFactory.sphere(parent, 0.6, Vector3(side * 1.45, 3.6, 0), color)
  VisualFactory.cylinder(parent, 1.8, 0.22, Vector3(side * 1.7, 2.65, 0), dark)
 VisualFactory.box(parent, Vector3(2.1, 0.8, 1.1), Vector3(0, 3.4, 0), dark)
 VisualFactory.sphere(parent, 0.4, Vector3(0, 3.5, -0.68), color.lightened(0.35))
 # Individuelle Element-Merkmale.
 match element:
  0: # Feuer: Lavahörner und Glutkrone
   for side in [-1.0, 1.0]:
    VisualFactory.cylinder(parent, 2.2, 0.32, Vector3(side * 0.75, 5.6, 0), color)
  1: # Wasser: Rückenflossen und Tropfenkristalle
   for i in range(3):
    VisualFactory.sphere(parent, 0.42 + i * 0.14, Vector3(-1.2 + i * 1.2, 5.3, 0.3), color.lightened(0.3))
  2: # Erde: Steinplatten und Schulterschilde
   for side in [-1.0, 1.0]:
    VisualFactory.box(parent, Vector3(1.4, 1.0, 1.5), Vector3(side * 1.5, 4.0, 0), dark)
  3: # Natur: Geweih und Blattkrone
   for side in [-1.0, 1.0]:
    VisualFactory.cylinder(parent, 2.3, 0.16, Vector3(side * 0.9, 5.65, 0), Color("#7a4a2b"))
    VisualFactory.sphere(parent, 0.72, Vector3(side * 1.2, 6.35, 0), color)
  4: # Licht: Heiligenschein
   for i in range(8):
    var angle: float = TAU * float(i) / 8.0
    VisualFactory.sphere(parent, 0.2, Vector3(cos(angle) * 1.4, 5.6 + sin(angle) * 1.4, 0), color)
  5: # Schatten: dunkle Schwingen
   for side in [-1.0, 1.0]:
    VisualFactory.box(parent, Vector3(1.8, 2.6, 0.18), Vector3(side * 2.4, 3.7, 0.6), dark)
  6: # Wind: schwebende Wolkenfragmente
   for side in [-1.0, 1.0]:
    VisualFactory.sphere(parent, 0.75, Vector3(side * 2.5, 4.4, 0), color.lightened(0.35))
  7: # Eis: Stachelkrone
   for i in range(5):
    VisualFactory.cylinder(parent, 1.4 + float(i % 2) * 0.5, 0.2, Vector3(-1.2 + float(i) * 0.6, 5.55, 0), color.lightened(0.3))
  8: # Blitz: Energiekugeln
   for side in [-1.0, 1.0]:
    VisualFactory.sphere(parent, 0.55, Vector3(side * 2.3, 3.6, -0.5), color.lightened(0.45))
  9: # Chaos: asymmetrische Dornen
   VisualFactory.cylinder(parent, 3.0, 0.28, Vector3(-1.2, 5.4, 0), dark)
   VisualFactory.cylinder(parent, 1.8, 0.48, Vector3(1.3, 5.0, 0), color)
 # Update 63: element-specific silhouette parts, readable even without textures.
 # Kept close to the body so portrait-mode cameras do not crop the boss.
 match element:
  0: # Fire: broad molten back spines
   for i in range(3):
    VisualFactory.cylinder(parent, 1.2 + float(i) * 0.35, 0.3, Vector3(-0.8 + float(i) * 0.8, 4.5, 0.85), color)
  1: # Water: fin-like shoulder lobes and floating droplets
   for side in [-1.0, 1.0]:
    VisualFactory.box(parent, Vector3(0.25, 1.45, 1.25), Vector3(side * 1.8, 4.35, 0.65), color)
    VisualFactory.sphere(parent, 0.24, Vector3(side * 1.85, 5.25, -0.35), color.lightened(0.45))
  2: # Earth: massive asymmetrical stone fists
   VisualFactory.box(parent, Vector3(1.1, 1.15, 1.0), Vector3(-1.75, 2.15, -0.35), dark)
   VisualFactory.box(parent, Vector3(0.85, 1.4, 1.15), Vector3(1.7, 2.05, -0.35), color.darkened(0.3))
  3: # Nature: root shoulders and layered leaf crown
   for side in [-1.0, 1.0]:
    VisualFactory.cylinder(parent, 1.3, 0.18, Vector3(side * 1.75, 4.6, 0.25), Color("#765133"))
    VisualFactory.sphere(parent, 0.44, Vector3(side * 1.8, 5.1, 0.3), color.lightened(0.2))
  4: # Light: tall shoulder crests
   for side in [-1.0, 1.0]:
    VisualFactory.cylinder(parent, 1.5, 0.24, Vector3(side * 1.5, 4.75, 0), color.lightened(0.5))
  5: # Shadow: jagged dark armor
   for side in [-1.0, 1.0]:
    VisualFactory.box(parent, Vector3(0.5, 1.4, 0.5), Vector3(side * 1.5, 4.65, 0.15), dark)
  6: # Wind: detached orbiting-looking fragments
   for side in [-1.0, 1.0]:
    VisualFactory.sphere(parent, 0.35, Vector3(side * 2.1, 5.05, -0.4), color.lightened(0.55))
  7: # Ice: crystalline shoulders
   for side in [-1.0, 1.0]:
    VisualFactory.cylinder(parent, 1.9, 0.22, Vector3(side * 1.4, 4.7, 0), color.lightened(0.55))
  8: # Lightning: charged shoulder coils
   for side in [-1.0, 1.0]:
    VisualFactory.sphere(parent, 0.36, Vector3(side * 1.75, 4.6, -0.45), color.lightened(0.6))
    VisualFactory.cylinder(parent, 0.85, 0.13, Vector3(side * 1.8, 5.15, 0), color)
  9: # Chaos: deliberately unbalanced shoulders
   VisualFactory.box(parent, Vector3(1.2, 1.45, 0.85), Vector3(-1.5, 4.5, 0.2), dark)
   VisualFactory.sphere(parent, 0.7, Vector3(1.7, 4.7, -0.2), color.lightened(0.35))
 # Update 62: distinct armor silhouette, glowing eyes and articulated claws.
 for side in [-1.0, 1.0]:
  VisualFactory.box(parent, Vector3(0.72, 0.28, 0.92), Vector3(side * 1.7, 4.12, -0.3), dark)
  VisualFactory.sphere(parent, 0.16, Vector3(side * 0.36, 4.78, -0.53), color.lightened(0.65))
  for claw in range(3):
   VisualFactory.cylinder(parent, 0.48, 0.09, Vector3(side * (1.42 + float(claw) * 0.18), 1.72, -0.58), color.lightened(0.25))
 for plate in range(3):
  VisualFactory.box(parent, Vector3(1.65 - float(plate) * 0.18, 0.16, 0.3), Vector3(0, 2.7 + float(plate) * 0.36, -0.66), color.darkened(0.23))
 if fused:
  # Zehnter Boss: größerer Energiekern, zusätzliche Krone und violette Fusionsteile.
  VisualFactory.sphere(parent, 0.75, Vector3(0, 3.5, -1.0), Color("#ff4ce2"))
  for side in [-1.0, 1.0]:
   VisualFactory.sphere(parent, 0.65, Vector3(side * 2.5, 4.9, 0), Color("#ff4ce2"))
 add_anatomy(parent, element, fused)
 add_element_identity(parent, element, fused)
 add_limb_profiles(parent, element, fused)


# Update 69: Additional silhouette-defining anatomy. Each element has its own
# recognizable shape even with monochrome materials and on small phone screens.
static func add_anatomy(parent: Node3D, element: int, fused: bool) -> void:
 var e: int = clampi(element, 0, 9)
 var c: Color = PALETTE[e]
 var stone: Color = c.darkened(0.55)
 match e:
  0: # Fire: wide volcanic jaws and split horn crest.
   VisualFactory.box(parent, Vector3(1.65, 0.5, 1.15), Vector3(0, 4.3, -0.7), stone)
   for side in [-1.0, 1.0]:
    VisualFactory.cylinder(parent, 1.55, 0.38, Vector3(side * 1.0, 5.3, -0.2), c)
    VisualFactory.sphere(parent, 0.45, Vector3(side * 1.6, 3.35, -0.6), c)
  1: # Water: manta-like side fins and broad flowing crown.
   VisualFactory.box(parent, Vector3(3.6, 0.22, 1.2), Vector3(0, 4.7, 0.5), c)
   for side in [-1.0, 1.0]:
    VisualFactory.sphere(parent, 0.72, Vector3(side * 2.45, 4.25, 0.5), c.lightened(0.25))
  2: # Earth: squat armored torso and towering boulder shoulders.
   VisualFactory.box(parent, Vector3(3.5, 1.6, 1.65), Vector3(0, 3.65, 0.2), stone)
   for side in [-1.0, 1.0]:
    VisualFactory.box(parent, Vector3(1.2, 1.8, 1.45), Vector3(side * 1.8, 4.2, 0), c)
  3: # Nature: twisted branches and low hanging foliage.
   for side in [-1.0, 1.0]:
    var branch: MeshInstance3D = VisualFactory.cylinder(parent, 2.1, 0.17, Vector3(side * 1.3, 5.3, 0), Color('#65452d'))
    branch.rotation.z = side * 0.52
    VisualFactory.sphere(parent, 0.72, Vector3(side * 2.05, 6.0, 0), c)
  4: # Light: tall guardian silhouette with a radiant crown.
   VisualFactory.cylinder(parent, 1.75, 0.35, Vector3(0, 5.65, 0), c.lightened(0.45))
   for side in [-1.0, 1.0]:
    VisualFactory.box(parent, Vector3(0.4, 2.0, 0.6), Vector3(side * 2.0, 4.1, 0), c)
  5: # Shadow: angular wings and a narrow pointed faceplate.
   VisualFactory.box(parent, Vector3(0.8, 1.1, 0.55), Vector3(0, 4.65, -0.72), stone)
   for side in [-1.0, 1.0]:
    var wing: MeshInstance3D = VisualFactory.box(parent, Vector3(1.25, 3.0, 0.16), Vector3(side * 2.55, 4.3, 0.7), stone)
    wing.rotation.z = side * 0.3
  6: # Wind: light open body with floating shoulders.
   for side in [-1.0, 1.0]:
    VisualFactory.sphere(parent, 0.75, Vector3(side * 2.6, 3.7, 0), c)
    VisualFactory.sphere(parent, 0.42, Vector3(side * 1.9, 5.6, 0), c.lightened(0.5))
   VisualFactory.sphere(parent, 0.68, Vector3(0, 5.55, 0), c.lightened(0.4))
  7: # Ice: large crystalline crown and wedge-shaped shoulder armor.
   for i in range(5):
    VisualFactory.cylinder(parent, 1.7 + float(i % 2) * 0.8, 0.32, Vector3(-1.1 + float(i) * 0.55, 5.7, 0), c.lightened(0.35))
   for side in [-1.0, 1.0]:
    VisualFactory.box(parent, Vector3(1.15, 0.95, 1.2), Vector3(side * 1.65, 4.4, 0), c)
  8: # Lightning: antennae and detached charge coils.
   for side in [-1.0, 1.0]:
    var antenna: MeshInstance3D = VisualFactory.cylinder(parent, 2.1, 0.15, Vector3(side * 0.85, 5.6, 0), c)
    antenna.rotation.z = side * 0.42
    VisualFactory.sphere(parent, 0.48, Vector3(side * 2.3, 4.25, -0.2), c.lightened(0.6))
  9: # Chaos: deliberately uneven horns, arms and shoulder bulk.
   VisualFactory.box(parent, Vector3(1.65, 1.5, 1.2), Vector3(-1.75, 4.2, 0), stone)
   VisualFactory.sphere(parent, 0.9, Vector3(1.8, 4.55, 0), c)
   VisualFactory.cylinder(parent, 2.8, 0.28, Vector3(-0.9, 5.65, 0), c)
   VisualFactory.cylinder(parent, 1.1, 0.5, Vector3(1.0, 5.1, 0), stone)
 if fused:
  # Distinct crown shared by fusion titans, without altering collision or HP.
  for side in [-1.0, 1.0]:
   VisualFactory.sphere(parent, 0.42, Vector3(side * 1.4, 6.55, 0), Color('#f65cff'))

# Update 135: readable front-facing element crests and face silhouettes.
# These are decorative meshes only and never affect combat or collision.
static func add_element_identity(parent: Node3D, element: int, fused: bool) -> void:
 var e: int = clampi(element, 0, 9)
 var glow: Color = PALETTE[e].lightened(0.4)
 var shade: Color = PALETTE[e].darkened(0.65)
 # A dark faceplate gives bright eyes contrast on small portrait screens.
 VisualFactory.box(parent, Vector3(1.05, 0.55, 0.22), Vector3(0, 4.78, -0.78), shade)
 for side in [-1.0, 1.0]:
  VisualFactory.sphere(parent, 0.17 if not fused else 0.22, Vector3(side * 0.32, 4.83, -0.93), glow)
 # A large chest emblem gives each element a different readable outline.
 match e:
  0: # Lava fissure
   for side in [-1.0, 1.0]:
    var lava: MeshInstance3D = VisualFactory.box(parent, Vector3(0.18, 0.85, 0.10), Vector3(side * 0.27, 3.34, -0.80), glow)
    lava.rotation.z = side * 0.32
  1: # Water droplets
   for side in [-1.0, 1.0]:
    VisualFactory.sphere(parent, 0.28, Vector3(side * 0.34, 3.35, -0.84), glow)
  2: # Stone slab
   VisualFactory.box(parent, Vector3(0.95, 0.65, 0.15), Vector3(0, 3.4, -0.83), shade)
   VisualFactory.box(parent, Vector3(0.35, 0.65, 0.17), Vector3(0, 3.4, -0.94), glow)
  3: # Leaf-like split crest
   for side in [-1.0, 1.0]:
    var leaf: MeshInstance3D = VisualFactory.box(parent, Vector3(0.24, 0.75, 0.12), Vector3(side * 0.25, 3.4, -0.82), glow)
    leaf.rotation.z = -side * 0.52
  4: # Radiant cross
   VisualFactory.box(parent, Vector3(0.20, 0.90, 0.12), Vector3(0, 3.42, -0.85), glow)
   VisualFactory.box(parent, Vector3(0.78, 0.18, 0.12), Vector3(0, 3.52, -0.86), glow)
  5: # Dark twin crescents
   for side in [-1.0, 1.0]:
    var crescent: MeshInstance3D = VisualFactory.box(parent, Vector3(0.19, 0.85, 0.13), Vector3(side * 0.3, 3.4, -0.83), glow)
    crescent.rotation.z = -side * 0.42
  6: # Wind chevrons
   for y in [3.18, 3.52]:
    for side in [-1.0, 1.0]:
     var gust: MeshInstance3D = VisualFactory.box(parent, Vector3(0.45, 0.12, 0.12), Vector3(side * 0.21, y, -0.84), glow)
     gust.rotation.z = side * 0.40
  7: # Ice crystal diamond
   var crystal: MeshInstance3D = VisualFactory.box(parent, Vector3(0.57, 0.57, 0.15), Vector3(0, 3.42, -0.85), glow)
   crystal.rotation.z = PI / 4.0
  8: # Lightning zigzag
   for i in range(3):
    var bolt: MeshInstance3D = VisualFactory.box(parent, Vector3(0.18, 0.43, 0.13), Vector3((0.18 if i % 2 == 0 else -0.18), 3.7 - float(i) * 0.3, -0.85), glow)
    bolt.rotation.z = 0.50
  9: # Asymmetric chaos emblem
   VisualFactory.sphere(parent, 0.30, Vector3(-0.22, 3.55, -0.85), glow)
   var spike: MeshInstance3D = VisualFactory.box(parent, Vector3(0.20, 0.95, 0.15), Vector3(0.29, 3.33, -0.84), glow)
   spike.rotation.z = -0.58
 if fused:
  VisualFactory.sphere(parent, 0.20, Vector3(0, 4.2, -0.91), Color("#ff4ce2"))

# Update 136: distinctive limb and torso outlines. Decorative only; combat
# collision, damage and animation timing remain untouched.
static func add_limb_profiles(parent: Node3D, element: int, fused: bool) -> void:
 var e: int = clampi(element, 0, 9)
 var c: Color = PALETTE[e]
 var shade: Color = c.darkened(0.38)
 match e:
  0: # Fire: angular forearm armor and molten shin plates.
   for side in [-1.0, 1.0]:
    VisualFactory.box(parent, Vector3(0.68, 1.1, 0.68), Vector3(side * 1.75, 2.65, -0.35), shade)
    VisualFactory.box(parent, Vector3(0.46, 0.85, 0.22), Vector3(side * 0.93, 1.0, -0.48), c)
  1: # Water: smooth fins along arms and calves.
   for side in [-1.0, 1.0]:
    var fin: MeshInstance3D = VisualFactory.box(parent, Vector3(0.28, 1.65, 0.85), Vector3(side * 1.92, 2.8, 0.35), c.lightened(0.2))
    fin.rotation.z = side * 0.22
    VisualFactory.sphere(parent, 0.37, Vector3(side * 0.95, 1.4, -0.32), c)
  2: # Earth: wide stone torso and thick lower legs.
   VisualFactory.box(parent, Vector3(2.9, 1.15, 1.5), Vector3(0, 2.65, 0.18), shade)
   for side in [-1.0, 1.0]:
    VisualFactory.box(parent, Vector3(0.94, 1.15, 1.0), Vector3(side * 0.93, 1.12, -0.08), shade)
  3: # Nature: long root-like forearms and wooden leg guards.
   for side in [-1.0, 1.0]:
    var root: MeshInstance3D = VisualFactory.cylinder(parent, 1.55, 0.24, Vector3(side * 1.75, 2.8, -0.3), Color('#765133'))
    root.rotation.z = side * 0.20
    VisualFactory.cylinder(parent, 1.2, 0.26, Vector3(side * 0.95, 1.1, -0.3), shade)
  4: # Light: slim plated limbs and tall waist guard.
   VisualFactory.box(parent, Vector3(1.15, 1.1, 0.62), Vector3(0, 2.7, -0.25), c.lightened(0.3))
   for side in [-1.0, 1.0]:
    VisualFactory.box(parent, Vector3(0.32, 1.5, 0.48), Vector3(side * 1.68, 2.85, -0.3), c)
  5: # Shadow: thin clawed arms and pointed knee guards.
   for side in [-1.0, 1.0]:
    var blade: MeshInstance3D = VisualFactory.box(parent, Vector3(0.3, 1.8, 0.5), Vector3(side * 1.78, 2.55, -0.38), shade)
    blade.rotation.z = side * 0.22
    VisualFactory.box(parent, Vector3(0.6, 0.75, 0.7), Vector3(side * 0.92, 1.2, -0.4), shade)
  6: # Wind: floating limb segments separated by visible gaps.
   for side in [-1.0, 1.0]:
    VisualFactory.sphere(parent, 0.42, Vector3(side * 1.75, 2.55, -0.2), c.lightened(0.35))
    VisualFactory.sphere(parent, 0.38, Vector3(side * 0.94, 1.12, -0.2), c.lightened(0.25))
  7: # Ice: sharp forearm crystals and broad angular boots.
   for side in [-1.0, 1.0]:
    VisualFactory.cylinder(parent, 1.65, 0.34, Vector3(side * 1.72, 2.65, -0.32), c.lightened(0.35))
    VisualFactory.box(parent, Vector3(0.86, 0.7, 1.1), Vector3(side * 0.94, 0.38, -0.3), c)
  8: # Lightning: separated conductive bands along limbs.
   for side in [-1.0, 1.0]:
    for y in [2.2, 2.8, 3.3]:
     VisualFactory.sphere(parent, 0.28, Vector3(side * 1.74, y, -0.35), c.lightened(0.55))
  9: # Chaos: intentionally uneven arms and legs.
   VisualFactory.box(parent, Vector3(1.05, 1.7, 1.0), Vector3(-1.75, 2.6, -0.3), shade)
   VisualFactory.cylinder(parent, 1.85, 0.24, Vector3(1.8, 2.6, -0.3), c)
   VisualFactory.box(parent, Vector3(1.0, 1.2, 1.1), Vector3(-0.92, 1.2, -0.1), shade)
 if fused:
  # A small extra fusion accent, without changing hitboxes.
  VisualFactory.sphere(parent, 0.3, Vector3(0, 2.75, -0.92), Color('#ff4ce2'))
