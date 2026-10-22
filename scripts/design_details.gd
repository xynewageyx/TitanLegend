class_name DesignDetails
extends RefCounted
# Zusätzliche, rein prozedurale 3D-Designteile ohne externe Assets.
# Keine aktiven Pet-Angriffe: Begleiter bleiben dekorativ und passiv.

static func hero(parent: Node3D, role: int) -> void:
 var metal := Color("#b7c4ce")
 var gold := Color("#d9b55f")
 var leather := Color("#5e392d")
 # Schulterpanzer und Gürtel geben den Figuren eine lesbare Silhouette.
 VisualFactory.box(parent, Vector3(1.2, 0.25, 0.55), Vector3(0, 1.62, 0), metal if role == 0 else leather)
 VisualFactory.box(parent, Vector3(0.84, 0.16, 0.62), Vector3(0, 0.82, 0), gold)
 if role == 0: # Krieger
  VisualFactory.box(parent, Vector3(0.28, 0.18, 0.7), Vector3(0.72, 0.96, -0.08), gold)
  VisualFactory.box(parent, Vector3(0.18, 0.2, 0.75), Vector3(-0.7, 1.1, -0.25), metal)
 elif role == 1: # Magier
  VisualFactory.sphere(parent, 0.18, Vector3(0, 2.57, 0), Color("#7de9ff"))
  VisualFactory.box(parent, Vector3(0.55, 0.16, 0.22), Vector3(0, 1.38, -0.33), gold)
 elif role == 2: # Jaeger
  VisualFactory.box(parent, Vector3(0.14, 1.0, 0.22), Vector3(-0.55, 1.4, 0.35), leather)
  for i in range(3):
   VisualFactory.cylinder(parent, 0.7, 0.035, Vector3(-0.65 + i * 0.1, 1.85, 0.36), gold)
 else: # Heiler
  VisualFactory.box(parent, Vector3(0.18, 0.9, 0.16), Vector3(0, 1.35, -0.36), gold)
  VisualFactory.box(parent, Vector3(0.58, 0.17, 0.16), Vector3(0, 1.35, -0.38), gold)

static func pet(parent: Node3D, role: int) -> void:
 var accent: Color = [Color("#ffa247"), Color("#72d6ff"), Color("#c49bff"), Color("#a3ff91")][role]
 VisualFactory.sphere(parent, 0.14, Vector3(-0.28, 0.54, 0.12), accent)
 VisualFactory.sphere(parent, 0.14, Vector3(0.28, 0.54, 0.12), accent)
 if role == 0: # gehoernter Erdgeist
  VisualFactory.cylinder(parent, 0.34, 0.09, Vector3(0, 1.04, 0), Color("#bcb1a1"))
 elif role == 1: # Wassergeist
  VisualFactory.sphere(parent, 0.17, Vector3(0, 1.12, 0), accent)
 elif role == 2: # Schattengeist
  VisualFactory.box(parent, Vector3(0.65, 0.1, 0.2), Vector3(0, 0.62, 0.16), accent)
 else: # Naturfee
  VisualFactory.sphere(parent, 0.18, Vector3(-0.35, 0.8, 0.2), accent)
  VisualFactory.sphere(parent, 0.18, Vector3(0.35, 0.8, 0.2), accent)

static func enemy(parent: Node3D, biome: int, boss: bool, variant: int) -> void:
 var accent: Color = [Color("#ff7c3d"), Color("#72e4ff"), Color("#cfac77"), Color("#a1ff77"), Color("#ffeaa4"), Color("#c88bff"), Color("#b7ecf2"), Color("#b5f3ff"), Color("#8daaff"), Color("#ff528b")][clampi(biome, 0, 9)]
 if boss:
  # Titanen: Krone, Schulterplatten, Brustkern und Hörner.
  VisualFactory.box(parent, Vector3(2.6, 0.45, 1.3), Vector3(0, 3.7, 0), accent.darkened(0.3))
  VisualFactory.sphere(parent, 0.48, Vector3(0, 2.55, -2.04), accent)
  for side in [-1.0, 1.0]:
   VisualFactory.cylinder(parent, 1.3, 0.28, Vector3(side * 1.15, 5.0, 0), accent)
   VisualFactory.sphere(parent, 0.42, Vector3(side * 1.65, 3.6, 0), accent.darkened(0.2))
 else:
  # Unterschiedliche Silhouetten für die normalen Mobwellen.
  if variant % 3 == 0:
   for side in [-1.0, 1.0]:
    VisualFactory.cylinder(parent, 0.65, 0.13, Vector3(side * 0.46, 1.24, 0), accent)
  elif variant % 3 == 1:
   VisualFactory.sphere(parent, 0.32, Vector3(0, 1.22, 0.15), accent.darkened(0.35))
   VisualFactory.sphere(parent, 0.13, Vector3(0, 1.42, -0.24), accent)
  else:
   VisualFactory.box(parent, Vector3(1.35, 0.16, 0.25), Vector3(0, 0.9, 0.1), accent)

static func scenery(parent: Node3D, biome: int) -> void:
 # Landmarken außerhalb des Laufwegs, pro Element unterschiedlich.
 var accent: Color = [Color("#d85024"), Color("#53b8da"), Color("#b4a07a"), Color("#57aa53"), Color("#e6c77c"), Color("#7752b5"), Color("#8fc4d1"), Color("#c2eafa"), Color("#688fff"), Color("#cf3a69")][clampi(biome, 0, 9)]
 for side in [-1.0, 1.0]:
  for i in range(5):
   var x: float = side * (9.0 + float(i % 2) * 3.5)
   var z: float = -35.0 + float(i) * 11.0
   if biome == 3: # Natur: gewaltige uralte Baumstaemme
    VisualFactory.cylinder(parent, 6.0, 0.9, Vector3(x, 3.0, z), Color("#60422b"))
    VisualFactory.sphere(parent, 3.1, Vector3(x, 7.0, z), accent)
   elif biome == 0: # Feuer: Basaltsaeulen und Glut
    VisualFactory.cylinder(parent, 3.0 + i * 0.35, 0.9, Vector3(x, 1.8, z), Color("#423c3b"))
    VisualFactory.sphere(parent, 0.55, Vector3(x, 3.6 + i * 0.35, z), accent)
   elif biome == 1: # Wasser: Kristallsaeulen
    VisualFactory.box(parent, Vector3(1.3, 3.5, 1.3), Vector3(x, 1.75, z), accent)
   elif biome == 2: # Erde: Monolithen
    VisualFactory.box(parent, Vector3(1.8, 4.0, 1.4), Vector3(x, 2.0, z), accent.darkened(0.3))
   elif biome == 4: # Licht: goldene Tempelsaeulen
    VisualFactory.cylinder(parent, 4.5, 0.48, Vector3(x, 2.25, z), accent)
   elif biome == 5: # Schatten: dunkle Spitzen
    VisualFactory.cylinder(parent, 4.5, 0.6, Vector3(x, 2.25, z), accent.darkened(0.55))
   elif biome == 6: # Wind: helle schwebende Steine
    VisualFactory.box(parent, Vector3(2.0, 0.65, 1.5), Vector3(x, 2.0 + float(i % 3), z), accent)
    VisualFactory.sphere(parent, 0.55, Vector3(x, 3.2 + float(i % 3), z), Color("#f2ffff"))
   elif biome == 7: # Eis: Frostspitzen
    VisualFactory.cylinder(parent, 5.0 + float(i % 2), 0.75, Vector3(x, 2.5, z), accent)
    VisualFactory.sphere(parent, 0.5, Vector3(x, 5.2, z), Color("#ffffff"))
   elif biome == 8: # Blitz: Energietuerme
    VisualFactory.cylinder(parent, 4.4, 0.5, Vector3(x, 2.2, z), Color("#263e70"))
    VisualFactory.sphere(parent, 0.65, Vector3(x, 4.6, z), accent)
   else: # Chaos: zerbrochene Obelisken
    VisualFactory.box(parent, Vector3(1.4, 4.2, 1.4), Vector3(x, 2.1, z), Color("#382333"))
    VisualFactory.sphere(parent, 0.72, Vector3(x, 4.6, z), accent)
