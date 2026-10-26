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
 # 12 areas x 100 stages; ten elements intentionally repeat in areas 11 and 12.
 # Later areas remain distinct through stage-based enemy and boss progression.
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
 VisualFactory.box(terrain, Vector3(48, 0.35, 160), Vector3(0, -0.3, -36), ground_color)
 var path_color: Color = [Color("#51423d"), Color("#4c8798"), Color("#978267"), Color("#8e785b"), Color("#e2d7ad"), Color("#453b5a"), Color("#a4b8b8"), Color("#b9d9e8"), Color("#61688b"), Color("#62425b")][current_biome]
 VisualFactory.box(terrain, Vector3(7, 0.06, 160), Vector3(0, -0.08, -36), path_color)
 var rng: RandomNumberGenerator = RandomNumberGenerator.new()
 rng.seed = 241 + current_biome * 997
 for i in range(44):
  var side: float = -1.0 if i % 2 == 0 else 1.0
  var x: float = side * rng.randf_range(5.5, 17.0)
  var z: float = rng.randf_range(-43.0, 18.0)
  if current_biome == BiomeType.NATURE:
   var tree_scale: float = rng.randf_range(0.75, 1.3)
   var leaf_tint: Color = Color("#277a40").lerp(Color("#489e54"), rng.randf())
   VisualFactory.cylinder(terrain, 2.8 * tree_scale, 0.35 * tree_scale, Vector3(x, 1.4 * tree_scale, z), Color("#68452c"))
   VisualFactory.sphere(terrain, 1.55 * tree_scale, Vector3(x, 3.55 * tree_scale, z), leaf_tint)
   VisualFactory.sphere(terrain, 1.1 * tree_scale, Vector3(x - 0.75 * tree_scale, 3.1 * tree_scale, z), leaf_tint.lightened(0.1))
   VisualFactory.sphere(terrain, 1.1 * tree_scale, Vector3(x + 0.75 * tree_scale, 3.1 * tree_scale, z), leaf_tint.darkened(0.08))
   if i % 4 == 0:
    VisualFactory.sphere(terrain, 0.52, Vector3(x + 1.3, 0.35, z + 0.5), Color("#777a69"))
  elif current_biome in [BiomeType.WATER, BiomeType.LIGHT, BiomeType.ICE, BiomeType.WIND, BiomeType.LIGHTNING]:
   var crystal_height: float = rng.randf_range(1.5, 3.5)
   var crystal_width: float = rng.randf_range(0.55, 1.05)
   var crystal_color: Color = COLORS[current_biome].lerp(Color.WHITE, rng.randf_range(0.12, 0.42))
   VisualFactory.box(terrain, Vector3(crystal_width, crystal_height, crystal_width), Vector3(x, crystal_height * 0.5, z), crystal_color)
  else:
   VisualFactory.sphere(terrain, rng.randf_range(0.6, 1.5), Vector3(x, 0.5, z), COLORS[current_biome].lightened(0.15))

 # Geringe Anzahl zusaetzlicher Objekte, damit Android fluessig bleibt.
 _add_biome_details()

 # Distinct, low-cost roadside accents for every element (outside the 7m path).
 _add_element_roadside_accents()

 # Elementare Landmarken als sichtbare Unterscheidung der Gebiete.
 DesignDetails.scenery(terrain, current_biome)
 if current_biome == 3:
  NatureArt.forest(terrain)
  _add_forest_depth()
  _add_forest_variation()
  _add_forest_pines()
  _add_forest_path_details()

func _add_forest_depth() -> void:
 # Fill distant forest edges without extra physics bodies or textures.
 # Fixed random seed prevents scenery rearranging when returning to a zone.
 var rng := RandomNumberGenerator.new()
 rng.seed = 483721
 for i in range(24):
  var side: float = -1.0 if i % 2 == 0 else 1.0
  var x: float = side * rng.randf_range(5.7, 22.0)
  var z: float = rng.randf_range(-105.0, -46.0)
  var size: float = rng.randf_range(0.85, 1.45)
  var bark: Color = Color("#634a32").lerp(Color("#826041"), rng.randf())
  var foliage: Color = Color("#1f5c37").lerp(Color("#419657"), rng.randf())
  VisualFactory.cylinder(terrain, 2.9 * size, 0.29 * size, Vector3(x, 1.45 * size, z), bark)
  VisualFactory.sphere(terrain, 1.4 * size, Vector3(x, 3.45 * size, z), foliage)
  VisualFactory.sphere(terrain, 0.9 * size, Vector3(x + side * 0.55 * size, 3.05 * size, z + 0.35), foliage.lightened(0.08))
 # Low-detail undergrowth creates depth without hiding the road or heroes.
 for i in range(18):
  var side: float = -1.0 if i % 2 == 0 else 1.0
  var x: float = side * rng.randf_range(4.9, 18.0)
  var z: float = rng.randf_range(-95.0, 14.0)
  var radius: float = rng.randf_range(0.24, 0.56)
  VisualFactory.sphere(terrain, radius, Vector3(x, radius * 0.7, z), Color("#286b39").lerp(Color("#55a14c"), rng.randf()))

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

func _add_element_roadside_accents() -> void:
 # Shared geometry budget, distinct palette and silhouette per element.
 var rng := RandomNumberGenerator.new()
 rng.seed = 61200 + current_biome
 for i in range(16):
  var side: float = -1.0 if i % 2 == 0 else 1.0
  var x: float = side * rng.randf_range(4.8, 8.8)
  var z: float = rng.randf_range(-68.0, 12.0)
  var at := Vector3(x, 0.18, z)
  match current_biome:
   BiomeType.NATURE:
    VisualFactory.sphere(terrain, 0.38, at + Vector3(0.0, 0.18, 0.0), Color("#3d8948"))
    VisualFactory.sphere(terrain, 0.22, at + Vector3(0.35, 0.13, 0.2), Color("#91b957"))
   BiomeType.FIRE:
    VisualFactory.box(terrain, Vector3(0.9, 0.14, 0.65), at, Color("#ec742e"))
   BiomeType.WATER:
    VisualFactory.sphere(terrain, 0.42, at, Color("#56c2d6"))
   BiomeType.EARTH:
    VisualFactory.box(terrain, Vector3(0.85, 0.48, 0.7), at, Color("#87755b"))
   BiomeType.LIGHT:
    VisualFactory.sphere(terrain, 0.36, at + Vector3(0.0, 0.48, 0.0), Color("#f2df9e"))
   BiomeType.SHADOW:
    VisualFactory.cylinder(terrain, 1.0, 0.26, at + Vector3(0.0, 0.4, 0.0), Color("#59416f"))
   BiomeType.WIND:
    VisualFactory.sphere(terrain, 0.3, at + Vector3(0.0, 0.9, 0.0), Color("#b1dde0"))
   BiomeType.ICE:
    VisualFactory.cylinder(terrain, 0.85, 0.27, at + Vector3(0.0, 0.35, 0.0), Color("#bdeaf5"))
   BiomeType.LIGHTNING:
    VisualFactory.box(terrain, Vector3(0.28, 1.1, 0.28), at + Vector3(0.0, 0.5, 0.0), Color("#829af0"))
   BiomeType.CHAOS:
    var shard := VisualFactory.box(terrain, Vector3(0.5, 0.8, 0.4), at + Vector3(0.0, 0.4, 0.0), Color("#c257a1"))
    shard.rotation.z = 0.32

func _add_forest_variation() -> void:
 # Deterministic roadside stones and flower clusters, outside the walking lane.
 var rng := RandomNumberGenerator.new()
 rng.seed = 20261026
 for i in range(18):
  var side: float = -1.0 if i % 2 == 0 else 1.0
  var x: float = side * rng.randf_range(5.2, 12.0)
  var z: float = rng.randf_range(-80.0, 12.0)
  if i % 3 == 0:
   var rock := VisualFactory.sphere(terrain, rng.randf_range(0.32, 0.62), Vector3(x, 0.28, z), Color("#89927b"))
   rock.scale = Vector3(1.3, 0.62, 0.9)
  else:
   var foliage := Color("#367d48").lerp(Color("#8dbd57"), rng.randf())
   for leaf in range(3):
    VisualFactory.sphere(terrain, 0.19, Vector3(x + float(leaf - 1) * 0.25, 0.19, z), foliage)
   if i % 3 == 1:
    VisualFactory.sphere(terrain, 0.11, Vector3(x, 0.42, z), Color("#f0d37e"))

func _add_forest_pines() -> void:
 # Low-poly conifers add distinct tall silhouettes in the background.
 var rng := RandomNumberGenerator.new()
 rng.seed = 20261027
 for i in range(12):
  var side: float = -1.0 if i % 2 == 0 else 1.0
  var x: float = side * rng.randf_range(8.0, 20.0)
  var z: float = rng.randf_range(-100.0, 8.0)
  var size: float = rng.randf_range(0.85, 1.35)
  VisualFactory.cylinder(terrain, 2.8 * size, 0.25 * size, Vector3(x, 1.4 * size, z), Color("#725039"))
  for tier in range(3):
   var crown := CylinderMesh.new()
   crown.height = (1.5 - float(tier) * 0.15) * size
   crown.bottom_radius = (1.1 - float(tier) * 0.23) * size
   crown.top_radius = 0.04 * size
   crown.radial_segments = 7
   var canopy := MeshInstance3D.new()
   canopy.mesh = crown
   canopy.material_override = VisualFactory.material(Color("#306d44").lightened(float(tier) * 0.06))
   canopy.position = Vector3(x, (2.55 + float(tier) * 0.70) * size, z)
   terrain.add_child(canopy)

func _add_forest_path_details() -> void:
 # Uneven soil and stepping stones break up the flat road without blocking movement.
 var rng := RandomNumberGenerator.new()
 rng.seed = 20261028
 for i in range(28):
  var x: float = rng.randf_range(-2.85, 2.85)
  var z: float = rng.randf_range(-100.0, 17.0)
  var width: float = rng.randf_range(0.32, 0.92)
  var patch := VisualFactory.sphere(terrain, width, Vector3(x, -0.035, z), Color("#aa9271").lerp(Color("#77654f"), rng.randf()))
  patch.scale = Vector3(1.4, 0.055, rng.randf_range(0.75, 1.5))
 for i in range(18):
  var side: float = -1.0 if i % 2 == 0 else 1.0
  var x: float = side * rng.randf_range(3.8, 4.5)
  var z: float = rng.randf_range(-95.0, 15.0)
  var stone := VisualFactory.sphere(terrain, rng.randf_range(0.18, 0.42), Vector3(x, 0.04, z), Color("#9b9680"))
  stone.scale = Vector3(1.25, 0.35, 0.85)
