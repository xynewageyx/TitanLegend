class_name ClassVisuals
extends RefCounted
# Zusaetzliche wiedererkennbare Silhouetten fuer alle elf Klassen.
static func decorate(hero: Node3D, class_id: int) -> void:
 var metal := Color("#b8c7ce")
 var gold := Color("#edcb6b")
 match class_id:
  0: # Krieger: breite Schulterpanzer und Schild
   VisualFactory.box(hero, Vector3(1.25, 0.25, 0.65), Vector3(0, 1.63, 0), metal)
  1: # Paladin: goldene Ruestung, Lichtaura
   VisualFactory.box(hero, Vector3(1.15, 0.35, 0.68), Vector3(0, 1.52, 0), gold)
   VisualFactory.sphere(hero, 0.19, Vector3(0, 2.6, 0), Color("#fff7a2"))
  2: # Druide: Geweih und Blattschmuck
   for side in [-1.0, 1.0]:
    VisualFactory.cylinder(hero, 0.85, 0.065, Vector3(side * 0.3, 2.52, 0), Color("#79543a"))
   VisualFactory.sphere(hero, 0.23, Vector3(0, 1.42, -0.43), Color("#56da6e"))
  3: # Schamane: Totem und Perlen
   VisualFactory.cylinder(hero, 2.4, 0.09, Vector3(0.75, 1.35, 0), Color("#806045"))
   VisualFactory.sphere(hero, 0.25, Vector3(0.75, 2.57, 0), Color("#6ce6e4"))
  4: # Jaeger: Schulterschutz und Kocher
   VisualFactory.box(hero, Vector3(0.45, 0.7, 0.36), Vector3(-0.45, 1.47, 0.3), Color("#6c4931"))
  5: # Schurke: dunkle Kapuze und Dolche
   VisualFactory.sphere(hero, 0.39, Vector3(0, 2.06, 0.13), Color("#26233b"))
   for side in [-1.0, 1.0]:
    VisualFactory.box(hero, Vector3(0.08, 0.7, 0.12), Vector3(side * 0.7, 0.96, -0.2), metal)
  6: # Magier: Runenkristall
   VisualFactory.sphere(hero, 0.33, Vector3(0.66, 2.46, 0), Color("#59e3ff"))
  7: # Hexer: dunkle Schulterhoerner
   for side in [-1.0, 1.0]:
    VisualFactory.cylinder(hero, 0.85, 0.12, Vector3(side * 0.52, 1.95, 0), Color("#5c2c8b"))
   VisualFactory.sphere(hero, 0.24, Vector3(0.66, 2.46, 0), Color("#cf52f3"))
  8: # Beschwoerer: schwebende Fokussteine
   for side in [-1.0, 1.0]:
    VisualFactory.sphere(hero, 0.21, Vector3(side * 0.8, 2.25, 0), Color("#ba85ff"))
  9: # Priester: Heiligenschein
   VisualFactory.sphere(hero, 0.29, Vector3(0, 2.64, 0), Color("#fff2b6"))
  10: # Raufbold: grosse Panzerhandschuhe
   for side in [-1.0, 1.0]:
    VisualFactory.box(hero, Vector3(0.44, 0.42, 0.46), Vector3(side * 0.57, 0.95, -0.14), Color("#9b5e43"))
