extends Node3D
signal biome_changed(biome: int)
enum BiomeType { FIRE, WATER, EARTH, NATURE, LIGHT, SHADOW, WIND, ICE, LIGHTNING, CHAOS }
const NAMES = ["Vulkanskaverne", "Kristallgrotte", "Steinernes Hochland", "Uralter Wald", "Himmlisches Reich", "Schattenabgrund", "Himmelswinde", "Frostgipfel", "Donnerplateau", "Chaosriss"]
const COLORS = [Color("#a53e22"), Color("#297da8"), Color("#9b815e"), Color("#356e37"), Color("#d4bd75"), Color("#60468b"), Color("#7aa7b6"), Color("#a5d7e9"), Color("#476de2"), Color("#9a254a")]
@export var environment_node: WorldEnvironment
@export var sun_light: DirectionalLight3D
var current_biome: int = -1
var terrain: Node3D
func _ready() -> void:
 terrain = Node3D.new()
 terrain.name = "GeneratedTerrain"
 add_child(terrain)
 set_biome(BiomeType.NATURE)
func update_biome_from_stage(stage: int) -> void:
 var index: int = (floori(float(stage - 1) / 100.0) + 3) % 10
 set_biome(index)
func set_biome(biome: int) -> void:
 if biome == current_biome:
  return
 current_biome = clampi(biome, 0, 9)
 if environment_node:
  if environment_node.environment == null:
   environment_node.environment = Environment.new()
  var env: Environment = environment_node.environment
  env.background_mode = Environment.BG_COLOR
  env.background_color = COLORS[current_biome].darkened(0.65)
  env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
  env.ambient_light_color = COLORS[current_biome].lightened(0.35)
  env.ambient_light_energy = 0.65 if current_biome in [0, 5, 9] else 0.85
  env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
 if sun_light:
  sun_light.light_color = COLORS[current_biome].lightened(0.65)
  sun_light.light_energy = 0.85 if current_biome in [0, 5, 9] else 1.2
 for child in terrain.get_children():
  child.queue_free()
 generate_terrain()
 biome_changed.emit(current_biome)
func generate_terrain() -> void:
 var ground_color: Color = COLORS[current_biome].darkened(0.4)
 VisualFactory.box(terrain, Vector3(38, 0.35, 75), Vector3(0, -0.3, -12), ground_color)
 var path_color: Color = [Color("#51423d"), Color("#4c8798"), Color("#978267"), Color("#8e785b"), Color("#e2d7ad"), Color("#453b5a"), Color("#a4b8b8"), Color("#b9d9e8"), Color("#61688b"), Color("#62425b")][current_biome]
 VisualFactory.box(terrain, Vector3(7, 0.06, 75), Vector3(0, -0.08, -12), path_color)
 var rng: RandomNumberGenerator = RandomNumberGenerator.new()
 rng.seed = 241
 for i in range(44):
  var side: float = -1.0 if i % 2 == 0 else 1.0
  var x: float = side * rng.randf_range(5.5, 17.0)
  var z: float = rng.randf_range(-43.0, 18.0)
  if current_biome == BiomeType.NATURE:
   VisualFactory.cylinder(terrain, 2.8, 0.35, Vector3(x, 1.4, z), Color("#68452c"))
   VisualFactory.sphere(terrain, 1.55, Vector3(x, 3.55, z), Color("#277a40"))
   VisualFactory.sphere(terrain, 1.1, Vector3(x - 0.75, 3.1, z), Color("#328c4a"))
   VisualFactory.sphere(terrain, 1.1, Vector3(x + 0.75, 3.1, z), Color("#2c7540"))
   if i % 4 == 0:
    VisualFactory.sphere(terrain, 0.52, Vector3(x + 1.3, 0.35, z + 0.5), Color("#777a69"))
  elif current_biome in [BiomeType.WATER, BiomeType.LIGHT, BiomeType.ICE, BiomeType.WIND, BiomeType.LIGHTNING]:
   VisualFactory.box(terrain, Vector3(0.9, rng.randf_range(1.5, 3.5), 0.9), Vector3(x, 1.1, z), COLORS[current_biome].lightened(0.3))
  else:
   VisualFactory.sphere(terrain, rng.randf_range(0.6, 1.5), Vector3(x, 0.5, z), COLORS[current_biome].lightened(0.15))

 # Geringe Anzahl zusaetzlicher Objekte, damit Android fluessig bleibt.
 _add_biome_details()

 # Elementare Landmarken als sichtbare Unterscheidung der Gebiete.
 DesignDetails.scenery(terrain, current_biome)
 if current_biome == 3:
  NatureArt.forest(terrain)

func _add_biome_details() -> void:
 var rng := RandomNumberGenerator.new()
 rng.seed = 35000 + current_biome
 for i in range(18):
  var side: float = -1.0 if i % 2 == 0 else 1.0
  var x: float = side * rng.randf_range(6.0, 16.0)
  var z: float = rng.randf_range(-42.0, 18.0)
  var at := Vector3(x, 0.25, z)
  match current_biome:
   BiomeType.FIRE:
    VisualFactory.box(terrain, Vector3(1.6, 0.2, 1.3), at, Color("#e46b28"))
    if i % 3 == 0:
     VisualFactory.cylinder(terrain, 2.6, 0.65, at + Vector3(0, 1.2, 0), Color("#3a3031"))
   BiomeType.WATER:
    VisualFactory.sphere(terrain, 0.75, at, Color("#3b9fb7"))
    if i % 3 == 0:
     VisualFactory.cylinder(terrain, 2.4, 0.4, at + Vector3(0, 1.0, 0), Color("#80e4ed"))
   BiomeType.EARTH:
    VisualFactory.box(terrain, Vector3(1.5, 1.0, 1.3), at + Vector3(0, 0.4, 0), Color("#73634f"))
   BiomeType.NATURE:
    VisualFactory.sphere(terrain, 0.35, at, Color("#83b64c"))
   BiomeType.LIGHT:
    VisualFactory.cylinder(terrain, 2.5, 0.45, at + Vector3(0, 1.0, 0), Color("#e6d9ac"))
   BiomeType.SHADOW:
    var spike := VisualFactory.cylinder(terrain, 2.0, 0.45, at + Vector3(0, 0.9, 0), Color("#352b4c"))
    spike.rotation.z = 0.2
   BiomeType.WIND:
    VisualFactory.sphere(terrain, 0.6, at + Vector3(0, 1.4, 0), Color("#b3d9da"))
   BiomeType.ICE:
    VisualFactory.cylinder(terrain, 2.7, 0.4, at + Vector3(0, 1.2, 0), Color("#d4f2fa"))
   BiomeType.LIGHTNING:
    VisualFactory.box(terrain, Vector3(0.7, 2.5, 0.7), at + Vector3(0, 1.1, 0), Color("#5668aa"))
    VisualFactory.sphere(terrain, 0.25, at + Vector3(0, 2.6, 0), Color("#c1ddff"))
   BiomeType.CHAOS:
    var fragment := VisualFactory.box(terrain, Vector3(0.9, 1.2, 0.8), at + Vector3(0, 1.0, 0), Color("#b84d83"))
    fragment.rotation.z = 0.35
