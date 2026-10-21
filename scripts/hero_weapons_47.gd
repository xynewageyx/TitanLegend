class_name HeroWeapons47
extends RefCounted
# Lightweight class-specific equipment, parented to the moving weapon arm.
static func equip(arm: Node3D, class_id: int) -> void:
 var metal: Color = Color("#dce5ee")
 var gold: Color = Color("#dfbc62")
 var wood: Color = Color("#785332")
 var violet: Color = Color("#ac8aff")
 match class_id:
  0, 1: # Krieger / Paladin: blade and crossguard
   VisualFactory.box(arm, Vector3(0.12, 0.85, 0.09), Vector3(0.10, -0.30, -0.25), metal)
   VisualFactory.box(arm, Vector3(0.39, 0.10, 0.14), Vector3(0.10, -0.65, -0.25), gold)
   VisualFactory.box(arm, Vector3(0.10, 0.28, 0.10), Vector3(0.10, -0.85, -0.25), wood)
  2, 3: # Druide / Schamane: branch staff with elemental stone
   VisualFactory.cylinder(arm, 1.3, 0.055, Vector3(0.10, -0.30, -0.25), wood)
   VisualFactory.sphere(arm, 0.19, Vector3(0.10, 0.37, -0.25), Color("#72e9b0") if class_id == 2 else Color("#75d9ff"))
  4: # Jaeger: bow body, bow tips, string
   VisualFactory.box(arm, Vector3(0.075, 1.12, 0.10), Vector3(0.10, -0.25, -0.30), wood)
   VisualFactory.sphere(arm, 0.10, Vector3(0.10, 0.31, -0.30), gold)
   VisualFactory.sphere(arm, 0.10, Vector3(0.10, -0.81, -0.30), gold)
   VisualFactory.box(arm, Vector3(0.025, 1.05, 0.025), Vector3(0.10, -0.25, -0.48), metal)
  5: # Schurke: twin short blades
   for side in [-1.0, 1.0]:
    VisualFactory.box(arm, Vector3(0.065, 0.52, 0.08), Vector3(0.10 + side * 0.13, -0.25, -0.30), metal)
    VisualFactory.box(arm, Vector3(0.19, 0.07, 0.11), Vector3(0.10 + side * 0.13, -0.54, -0.30), wood)
  6, 7, 8, 9: # Zauberklassen: staff and floating focus
   VisualFactory.cylinder(arm, 1.25, 0.055, Vector3(0.10, -0.32, -0.27), wood)
   var gem: Color = Color("#65cfff") if class_id == 6 else violet if class_id in [7, 8] else Color("#fff1a3")
   VisualFactory.sphere(arm, 0.20, Vector3(0.10, 0.37, -0.27), gem)
  10: # Raufbold: reinforced gauntlet
   VisualFactory.box(arm, Vector3(0.32, 0.34, 0.31), Vector3(0, -0.61, -0.10), Color("#a77a55"))
   for x in [-0.09, 0.09]:
    VisualFactory.sphere(arm, 0.065, Vector3(x, -0.76, -0.28), metal)

static func decorate_pet(pet: Node3D, class_id: int) -> void:
 # Visual only: pets do not receive attacks, cooldowns or combat scripts.
 var tone: Color = Color("#8fe4b3") if class_id in [2, 4] else Color("#a3d5ff") if class_id in [3, 6] else Color("#e2bbff") if class_id in [7, 8] else Color("#ffe3a0")
 if class_id in [2, 4, 5]:
  for side in [-1.0, 1.0]:
   VisualFactory.sphere(pet, 0.13, Vector3(side * 0.23, 0.96, 0.03), tone)
 elif class_id in [3, 6, 7, 8]:
  VisualFactory.sphere(pet, 0.13, Vector3(0, 1.15, 0), tone)
  VisualFactory.sphere(pet, 0.08, Vector3(0.20, 0.68, 0.03), tone)
 else:
  VisualFactory.box(pet, Vector3(0.34, 0.09, 0.30), Vector3(0, 1.01, 0), tone)
