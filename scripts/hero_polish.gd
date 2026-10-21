class_name HeroPolish
extends RefCounted
# Additive silhouette, facial and weapon detailing; procedural and Android friendly.
static func decorate(hero: Node3D, role: int) -> void:
 var steel := Color("#cbd7e1")
 var brass := Color("#e2b957")
 var dark := Color("#283244")
 # Gesicht blickt in Richtung -Z.
 for x in [-0.115, 0.115]:
  VisualFactory.sphere(hero, 0.045, Vector3(x, 1.99, -0.269), dark)
 VisualFactory.box(hero, Vector3(0.13, 0.035, 0.035), Vector3(0, 1.82, -0.284), Color("#824b43"))
 # Handschuhe, Knieschutz und Stiefel.
 for side in [-1.0, 1.0]:
  VisualFactory.sphere(hero, 0.145, Vector3(side * 0.49, 0.85, -0.04), dark)
  VisualFactory.box(hero, Vector3(0.31, 0.23, 0.37), Vector3(side * 0.20, 0.36, -0.08), steel.darkened(0.25))
  VisualFactory.box(hero, Vector3(0.32, 0.19, 0.47), Vector3(side * 0.20, 0.12, -0.12), dark)
 if role == 0:
  # Krieger: Federbusch, Wappen, Schildbuckel und Schwertknauf.
  VisualFactory.box(hero, Vector3(0.14, 0.49, 0.54), Vector3(0, 2.44, 0.02), Color("#b9382f"))
  VisualFactory.sphere(hero, 0.18, Vector3(-0.67, 1.18, -0.33), brass)
  VisualFactory.sphere(hero, 0.13, Vector3(0.73, 0.68, -0.05), brass)
  VisualFactory.box(hero, Vector3(0.14, 0.15, 0.68), Vector3(0, 1.45, -0.37), brass)
 elif role == 1:
  # Magier: Kapuze, Zierkragen und Kristallringe.
  VisualFactory.sphere(hero, 0.37, Vector3(0, 2.13, 0.14), Color("#23376b"))
  VisualFactory.box(hero, Vector3(0.95, 0.14, 0.66), Vector3(0, 1.72, 0), brass)
  for y in [1.8, 2.05]:
   VisualFactory.sphere(hero, 0.12, Vector3(0.66, y, 0), Color("#80e9ff"))
 elif role == 2:
  # Jaeger: Haar, Kocher und Pfeilspitzen.
  VisualFactory.sphere(hero, 0.31, Vector3(0, 2.19, 0.09), Color("#493021"))
  VisualFactory.box(hero, Vector3(0.29, 0.83, 0.27), Vector3(-0.49, 1.48, 0.35), Color("#59402a"))
  for i in range(3):
   VisualFactory.sphere(hero, 0.07, Vector3(-0.67 + i * 0.11, 2.25, 0.35), steel)
  VisualFactory.box(hero, Vector3(0.77, 0.15, 0.36), Vector3(0, 1.46, 0), Color("#3e6340"))
 else:
  # Heiler: Diadem, Schrein-Symbol und helle Schultern.
  VisualFactory.box(hero, Vector3(0.61, 0.09, 0.12), Vector3(0, 2.20, -0.19), brass)
  VisualFactory.sphere(hero, 0.105, Vector3(0, 2.23, -0.25), Color("#fff7b4"))
  VisualFactory.box(hero, Vector3(0.16, 0.57, 0.10), Vector3(0, 1.36, -0.43), brass)
  VisualFactory.box(hero, Vector3(0.52, 0.14, 0.10), Vector3(0, 1.39, -0.45), brass)
  for side in [-1.0, 1.0]:
   VisualFactory.sphere(hero, 0.21, Vector3(side * 0.49, 1.64, 0), Color("#f7e8c1"))
