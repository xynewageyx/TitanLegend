class_name MobDetails
extends RefCounted
# Additional low-poly silhouettes, built only once per spawned mob.
# Palette follows the ten elemental biomes; no textures or particles needed.
const COLORS: Array[Color] = [Color("#ff713b"), Color("#3dc3ed"), Color("#c49a68"), Color("#6cc56d"), Color("#ffe8a0"), Color("#9967c9"), Color("#c7ecdf"), Color("#8bd8ff"), Color("#739dff"), Color("#e66caf")]

static func decorate(parent: Node3D, biome: int, variant: int) -> void:
 var primary: Color = COLORS[clampi(biome, 0, COLORS.size() - 1)]
 var dark: Color = primary.darkened(0.48)
 var light: Color = primary.lightened(0.38)
 var kind: int = posmod(variant, 4)
 if kind == 0: # Horned beast
  for side in [-1.0, 1.0]:
   var horn: MeshInstance3D = VisualFactory.cylinder(parent, 0.55, 0.13, Vector3(side * 0.44, 1.62, -0.13), light)
   horn.rotation.z = side * 0.48
  VisualFactory.box(parent, Vector3(0.55, 0.22, 0.46), Vector3(0, 0.75, -0.67), dark)
 elif kind == 1: # Crystal crawler
  for side in [-1.0, 1.0]:
   for j in range(2):
    var spike: MeshInstance3D = VisualFactory.cylinder(parent, 0.7 + 0.2 * j, 0.17, Vector3(side * 0.5, 1.0, 0.1 + j * 0.3), light)
    spike.rotation.z = side * 0.5
  VisualFactory.sphere(parent, 0.24, Vector3(0, 1.55, -0.2), light)
 elif kind == 2: # Armored guardian
  VisualFactory.box(parent, Vector3(1.2, 0.24, 0.7), Vector3(0, 1.12, 0), dark)
  VisualFactory.box(parent, Vector3(0.6, 0.2, 0.55), Vector3(0, 1.48, -0.18), light)
  for side in [-1.0, 1.0]:
   VisualFactory.box(parent, Vector3(0.3, 0.58, 0.34), Vector3(side * 0.68, 0.68, 0), dark)
 else: # Elemental wisp
  for j in range(3):
   var angle: float = TAU * float(j) / 3.0
   VisualFactory.sphere(parent, 0.17, Vector3(cos(angle) * 0.68, 1.1 + 0.25 * sin(angle), sin(angle) * 0.5), light)
  VisualFactory.sphere(parent, 0.32, Vector3(0, 1.62, 0), dark)
 # Elemental chest insignia, readable from the front camera.
 var gem: MeshInstance3D = VisualFactory.sphere(parent, 0.13, Vector3(0, 0.9, -0.64), light)
 var mat: StandardMaterial3D = StandardMaterial3D.new()
 mat.albedo_color = light
 mat.emission_enabled = true
 mat.emission = primary
 mat.emission_energy_multiplier = 0.65
 gem.material_override = mat
