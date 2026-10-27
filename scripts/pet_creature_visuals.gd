extends RefCounted
# Lightweight original creature silhouettes, built once per companion.
# Purely visual: no attacks, collision, timers or damage.
static func decorate(pet: Node3D, element: int, species: int) -> void:
 var palette: Array[Color] = [
  Color("#f27d43"), Color("#54bce2"), Color("#72c46c"),
  Color("#f3d87b"), Color("#9876cf"), Color("#b1e7f0"),
  Color("#8ddce0"), Color("#6b9cf0"), Color("#ae966d"), Color("#db70bc")
 ]
 var tint: Color = palette[clampi(element, 0, 9)]
 var body: MeshInstance3D = VisualFactory.sphere(pet, 0.33, Vector3(0, 0.43, 0.10), tint)
 body.scale = Vector3(0.94, 0.82, 1.38)
 var muzzle: MeshInstance3D = VisualFactory.sphere(pet, 0.20, Vector3(0, 0.69, -0.29), tint.lightened(0.24))
 muzzle.scale = Vector3(1.05, 0.68, 1.45)
 for side in [-1.0, 1.0]:
  var foot: MeshInstance3D = VisualFactory.sphere(pet, 0.13, Vector3(side * 0.24, 0.15, -0.13), tint.darkened(0.22))
  foot.scale = Vector3(1.1, 0.68, 1.35)
  var horn: MeshInstance3D = VisualFactory.cylinder(pet, 0.34, 0.105, Vector3(side * 0.20, 0.99, 0.04), tint.lightened(0.35))
  horn.rotation.z = side * 0.32
  VisualFactory.sphere(pet, 0.048, Vector3(side * 0.11, 0.78, -0.46), Color("#16242c"))
 var tail: MeshInstance3D = VisualFactory.sphere(pet, 0.19, Vector3(0, 0.46, 0.53), tint.darkened(0.14))
 tail.scale = Vector3(0.65, 0.65, 1.85)
 # Elemental dorsal crests are silhouettes rather than active skills.
 for i in range(3):
  var crest: MeshInstance3D = VisualFactory.sphere(pet, 0.14 - float(i) * 0.02, Vector3(0, 0.80 - float(i) * 0.10, 0.24 + float(i) * 0.20), tint.lightened(0.4))
  crest.scale = Vector3(0.62, 1.5, 0.60)
 # High-contrast facial details remain readable at Android portrait scale.
 # Place the nose and eye highlights in front of the muzzle, with no lighting effects.
 var nose := VisualFactory.sphere(pet, 0.085, Vector3(0, 0.67, -0.55), tint.darkened(0.52))
 nose.scale = Vector3(1.05, 0.70, 0.70)
 for side in [-1.0, 1.0]:
  var eye_highlight := VisualFactory.sphere(pet, 0.023, Vector3(side * 0.095 - 0.014, 0.80, -0.502), Color("#ffffff"))
  eye_highlight.scale = Vector3(0.72, 0.95, 0.65)
 # Static elemental ornaments: no particles, attacks, timers or gameplay damage.
 # Reuse inexpensive low-poly geometry for Android portrait performance.
 match clampi(element, 0, 9):
  0: # Fire: three warm flame-shaped dorsal crystals.
   for n in range(3):
    var flame := VisualFactory.cylinder(pet, 0.29 + float(n) * 0.05, 0.09, Vector3((float(n) - 1.0) * 0.20, 1.03, 0.17), tint.lightened(0.30))
    flame.rotation.z = (float(n) - 1.0) * 0.25
  1: # Water: translucent-looking blue droplets (opaque for mobile).
   for n in range(3):
    var drop := VisualFactory.sphere(pet, 0.12, Vector3((float(n) - 1.0) * 0.31, 0.91, 0.10), tint.lightened(0.38))
    drop.scale = Vector3(0.65, 1.6, 0.65)
  2: # Nature: paired leaf-like fins.
   for side in [-1.0, 1.0]:
    var leaf := VisualFactory.sphere(pet, 0.19, Vector3(side * 0.30, 0.87, 0.10), tint.lightened(0.25))
    leaf.scale = Vector3(0.48, 1.6, 0.82)
    leaf.rotation.z = side * 0.42
  3: # Light: bright crown.
   for side in [-1.0, 1.0]:
    var ray := VisualFactory.cylinder(pet, 0.30, 0.06, Vector3(side * 0.20, 1.12, 0.03), tint.lightened(0.55))
    ray.rotation.z = side * 0.35
  4: # Shadow: dark shoulder spikes.
   for side in [-1.0, 1.0]:
    var shadow_spike := VisualFactory.cylinder(pet, 0.36, 0.10, Vector3(side * 0.34, 0.89, 0.06), tint.darkened(0.40))
    shadow_spike.rotation.z = side * 0.52
  5: # Wind: thin sweeping feather fins.
   for side in [-1.0, 1.0]:
    var wind_fin := VisualFactory.sphere(pet, 0.20, Vector3(side * 0.34, 0.78, 0.18), tint.lightened(0.45))
    wind_fin.scale = Vector3(1.5, 0.24, 0.70)
  6: # Ice: three tall frozen crystals.
   for n in range(3):
    var ice_crystal := VisualFactory.cylinder(pet, 0.30 + float(n % 2) * 0.13, 0.08, Vector3((float(n) - 1.0) * 0.23, 1.00, 0.08), tint.lightened(0.42))
    ice_crystal.rotation.z = (float(n) - 1.0) * 0.20
  7: # Lightning: angular bolt silhouette.
   for side in [-1.0, 1.0]:
    var bolt := VisualFactory.box(pet, Vector3(0.11, 0.35, 0.10), Vector3(side * 0.23, 1.01, 0.02), tint.lightened(0.48))
    bolt.rotation.z = side * 0.45
  8: # Earth: heavy shoulder stones.
   for side in [-1.0, 1.0]:
    VisualFactory.box(pet, Vector3(0.25, 0.28, 0.29), Vector3(side * 0.34, 0.84, 0.12), tint.darkened(0.25))
  9: # Chaos: asymmetric violet shards.
   for n in range(3):
    var chaos_shard := VisualFactory.box(pet, Vector3(0.12, 0.28 + float(n) * 0.08, 0.11), Vector3((float(n) - 1.0) * 0.24, 1.03, 0.07), tint.lightened(0.24))
    chaos_shard.rotation.z = float(n - 1) * 0.38
 # Distinct animal profiles: fox, turtle, stag, owl and drake families.
 # All anatomy is static geometry; elemental affinity remains passive.
 match clampi(species, 0, 9):
  0: # Fox: pointed ears, long snout and a full tail.
   for side in [-1.0, 1.0]:
    var ear := VisualFactory.cylinder(pet, 0.38, 0.13, Vector3(side * 0.22, 1.12, -0.19), tint.darkened(0.12))
    ear.rotation.z = side * 0.25
   var fox_tail := VisualFactory.sphere(pet, 0.25, Vector3(0.0, 0.58, 0.70), tint.lightened(0.20))
   fox_tail.scale = Vector3(0.78, 0.84, 1.7)
   fox_tail.name = "AnimatedTail"
   var fox_tip := VisualFactory.sphere(pet, 0.15, Vector3(0, 0.61, 0.98), tint.lightened(0.62))
   fox_tip.scale = Vector3(0.78, 0.80, 1.35)
  1: # Turtle: layered oval shell with a bright rim and visible feet.
   var shell := VisualFactory.sphere(pet, 0.43, Vector3(0, 0.52, 0.18), tint.darkened(0.28))
   shell.scale = Vector3(1.25, 0.55, 1.22)
   var shell_rim := VisualFactory.sphere(pet, 0.40, Vector3(0, 0.42, 0.18), tint.lightened(0.14))
   shell_rim.scale = Vector3(1.34, 0.26, 1.32)
   for offset in [-0.22, 0.22]:
    var shell_plate := VisualFactory.sphere(pet, 0.19, Vector3(offset, 0.73, 0.19), tint.darkened(0.40))
    shell_plate.scale = Vector3(1.15, 0.25, 1.50)
   for side in [-1.0, 1.0]:
    VisualFactory.sphere(pet, 0.14, Vector3(side * 0.34, 0.15, 0.43), tint)
  2: # Stag: forked antlers and narrow muzzle.
   for side in [-1.0, 1.0]:
    var antler := VisualFactory.cylinder(pet, 0.53, 0.065, Vector3(side * 0.24, 1.23, -0.08), tint.lightened(0.38))
    antler.rotation.z = side * 0.38
    var branch := VisualFactory.cylinder(pet, 0.24, 0.048, Vector3(side * 0.40, 1.36, -0.08), tint.lightened(0.38))
    branch.rotation.z = -side * 0.48
    var antler_tip := VisualFactory.cylinder(pet, 0.21, 0.038, Vector3(side * 0.49, 1.49, -0.08), tint.lightened(0.44))
    antler_tip.rotation.z = side * 0.19
  3: # Owl: round facial disk, wings and feather tufts.
   for side in [-1.0, 1.0]:
    var wing := VisualFactory.sphere(pet, 0.25, Vector3(side * 0.33, 0.55, 0.13), tint.darkened(0.18))
    wing.scale = Vector3(0.52, 1.3, 0.82)
    wing.name = "AnimatedWingLeft" if side < 0.0 else "AnimatedWingRight"
    VisualFactory.sphere(pet, 0.16, Vector3(side * 0.14, 0.80, -0.35), tint.lightened(0.44))
    VisualFactory.sphere(pet, 0.07, Vector3(side * 0.14, 0.81, -0.47), Color("#1c2731"))
   var beak := VisualFactory.sphere(pet, 0.10, Vector3(0, 0.66, -0.48), Color("#e5ba67"))
   beak.scale = Vector3(0.64, 1.18, 1.1)
   var owl_brow := VisualFactory.sphere(pet, 0.23, Vector3(0, 0.98, -0.29), tint.darkened(0.28))
   owl_brow.scale = Vector3(1.45, 0.30, 0.50)
  4: # Drake: broad side wings and a ridged tail.
   for side in [-1.0, 1.0]:
    var wing := VisualFactory.sphere(pet, 0.32, Vector3(side * 0.43, 0.65, 0.19), tint.darkened(0.24))
    wing.scale = Vector3(1.45, 0.24, 0.95)
    wing.rotation.z = side * 0.23
    wing.name = "AnimatedWingLeft" if side < 0.0 else "AnimatedWingRight"
   for ridge in range(3):
    var spine := VisualFactory.cylinder(pet, 0.20, 0.09, Vector3(0, 0.89, 0.34 + float(ridge) * 0.19), tint.lightened(0.36))
    spine.rotation.x = -0.30

  5: # Wolf: tall ears, long muzzle and thick tail.
   for side in [-1.0, 1.0]:
    var wolf_ear := VisualFactory.cylinder(pet, 0.47, 0.14, Vector3(side * 0.23, 1.13, -0.20), tint.darkened(0.30))
    wolf_ear.rotation.z = side * 0.16
   var wolf_muzzle := VisualFactory.sphere(pet, 0.20, Vector3(0, 0.65, -0.52), tint.lightened(0.12))
   wolf_muzzle.scale = Vector3(0.75, 0.54, 1.35)
   var wolf_tail := VisualFactory.sphere(pet, 0.24, Vector3(0, 0.60, 0.69), tint.darkened(0.15))
   wolf_tail.scale = Vector3(0.7, 0.9, 1.7)
   wolf_tail.name = "AnimatedTail"
   var wolf_chest := VisualFactory.sphere(pet, 0.24, Vector3(0, 0.48, -0.34), tint.lightened(0.42))
   wolf_chest.scale = Vector3(0.88, 1.28, 0.55)
  6: # Golem: broad rocky shoulders and angular crown.
   var golem_chest := VisualFactory.box(pet, Vector3(0.80, 0.58, 0.65), Vector3(0, 0.52, 0.10), tint.darkened(0.25))
   VisualFactory.box(pet, Vector3(0.24, 0.25, 0.08), Vector3(0, 0.61, -0.31), tint.lightened(0.58))
   for side in [-1.0, 1.0]:
    VisualFactory.box(pet, Vector3(0.30, 0.40, 0.32), Vector3(side * 0.49, 0.54, 0.10), tint.lightened(0.12))
   VisualFactory.box(pet, Vector3(0.44, 0.18, 0.33), Vector3(0, 1.04, -0.06), tint.lightened(0.25))
  7: # Lynx: cheek tufts, high ears and a short tail.
   for side in [-1.0, 1.0]:
    var lynx_ear := VisualFactory.cylinder(pet, 0.40, 0.11, Vector3(side * 0.23, 1.13, -0.20), tint.darkened(0.22))
    lynx_ear.rotation.z = side * 0.22
    var cheek := VisualFactory.sphere(pet, 0.16, Vector3(side * 0.23, 0.68, -0.33), tint.lightened(0.30))
    cheek.scale = Vector3(1.2, 0.7, 0.8)
   var lynx_tail := VisualFactory.sphere(pet, 0.16, Vector3(0, 0.43, 0.57), tint.darkened(0.38))
   lynx_tail.scale = Vector3(0.9, 0.8, 0.85)
   lynx_tail.name = "AnimatedTail"
   for side in [-1.0, 1.0]:
    var lynx_tuft := VisualFactory.cylinder(pet, 0.18, 0.045, Vector3(side * 0.25, 1.35, -0.20), tint.darkened(0.48))
  8: # Phoenix: raised feather crest, sweeping wings and fan tail.
   for side in [-1.0, 1.0]:
    var phoenix_wing := VisualFactory.sphere(pet, 0.34, Vector3(side * 0.48, 0.66, 0.06), tint.lightened(0.22))
    phoenix_wing.scale = Vector3(1.60, 0.25, 0.86)
    phoenix_wing.rotation.z = side * 0.35
    phoenix_wing.name = "AnimatedWingLeft" if side < 0.0 else "AnimatedWingRight"
   for feather in range(3):
    var plume := VisualFactory.sphere(pet, 0.13, Vector3((float(feather) - 1.0) * 0.17, 1.14, -0.06), tint.lightened(0.45))
    plume.scale = Vector3(0.60, 2.0, 0.58)
    var tail_feather := VisualFactory.sphere(pet, 0.15, Vector3((float(feather) - 1.0) * 0.19, 0.53, 0.76), tint.lightened(0.18))
    tail_feather.scale = Vector3(0.55, 0.65, 2.10)
  9: # Serpent: long curved-looking body, hood and raised head.
   var serpent_body := VisualFactory.sphere(pet, 0.36, Vector3(0, 0.35, 0.24), tint.darkened(0.18))
   serpent_body.scale = Vector3(1.1, 0.55, 1.65)
   var serpent_neck := VisualFactory.cylinder(pet, 0.67, 0.20, Vector3(0, 0.81, -0.24), tint)
   serpent_neck.rotation.x = -0.22
   var hood := VisualFactory.sphere(pet, 0.31, Vector3(0, 0.95, -0.28), tint.lightened(0.16))
   hood.scale = Vector3(1.40, 1.08, 0.48)
   for side in [-1.0, 1.0]:
    VisualFactory.sphere(pet, 0.085, Vector3(side * 0.16, 1.02, -0.44), Color("#14232c"))
