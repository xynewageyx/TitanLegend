class_name BossAura
extends Node3D
# Lightweight animated aura: only primitive meshes, no particles or shaders.
var phase: float = 0.0
var crystals: Array[Node3D] = []
var element_color: Color = Color.CYAN
var fusion: bool = false

func configure(element: int, is_fusion: bool) -> void:
 fusion = is_fusion
 var palette: Array[Color] = [Color("#ff642d"), Color("#36baf5"), Color("#b8a16b"), Color("#58d276"), Color("#ffe49c"), Color("#a76bee"), Color("#b4f7e7"), Color("#9cddff"), Color("#719dff"), Color("#f23f9d")]
 element_color = palette[clampi(element, 0, palette.size() - 1)]
 _build()

func _build() -> void:
 var count: int = 10 if fusion else 6
 for i in range(count):
  var pivot := Node3D.new()
  add_child(pivot)
  var shard := VisualFactory.sphere(pivot, 0.18 if fusion else 0.13, Vector3.ZERO, Color("#f44ee5") if fusion and i % 3 == 0 else element_color)
  var mat := StandardMaterial3D.new()
  mat.albedo_color = Color("#f44ee5") if fusion and i % 3 == 0 else element_color
  mat.emission_enabled = true
  mat.emission = mat.albedo_color
  mat.emission_energy_multiplier = 1.7
  shard.material_override = mat
  crystals.append(pivot)

func _process(delta: float) -> void:
 phase += delta
 var count: int = crystals.size()
 if count == 0:
  return
 for i in range(count):
  var angle: float = phase * (0.95 if fusion else 0.65) + TAU * float(i) / float(count)
  var radius: float = 3.0 if fusion else 2.65
  var crystal: Node3D = crystals[i]
  crystal.position = Vector3(cos(angle) * radius, 3.1 + sin(phase * 1.8 + float(i)) * 0.35, sin(angle) * radius)
  crystal.scale = Vector3.ONE * (1.0 + 0.18 * sin(phase * 2.4 + float(i)))
