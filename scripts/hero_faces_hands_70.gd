extends RefCounted
# Update 70: lightweight facial features and glove details; visual only.
static func decorate(hero: Node3D, class_id: int) -> void:
 var skin_tone: Color = Color("#dba982")
 var trim: Color = Color("#c4d3e2")
 match class_id:
  0, 1: trim = Color("#dfbd6e")
  2, 3, 4: trim = Color("#75c994")
  5, 7, 8: trim = Color("#ad8cdb")
  6: trim = Color("#7ebfe9")
  9: trim = Color("#fff0b6")
  10: trim = Color("#bd876b")
 # Nose and brows create a readable face without expensive textures.
 VisualFactory.sphere(hero, 0.065, Vector3(0.0, 1.91, -0.30), skin_tone)
 for side in [-1.0, 1.0]:
  VisualFactory.box(hero, Vector3(0.115, 0.025, 0.035), Vector3(side * 0.115, 2.045, -0.265), trim.darkened(0.55))
  # Gloves and knuckles sit near the existing forearms.
  VisualFactory.sphere(hero, 0.145, Vector3(side * 0.49, 0.81, -0.06), trim.darkened(0.28))
  for finger in range(3):
   VisualFactory.sphere(hero, 0.045, Vector3(side * (0.42 + float(finger) * 0.065), 0.725, -0.175), trim.lightened(0.12))
 # A subtle collar softens the head-to-body transition.
 VisualFactory.sphere(hero, 0.17, Vector3(0.0, 1.76, 0.02), trim.darkened(0.2))
