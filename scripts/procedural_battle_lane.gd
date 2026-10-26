extends Node3D
## Lightweight procedural battle lane for portrait Android devices.
## Visual-only: does not modify combat, targeting, team roles or stage logic.

@export var lane_length: float = 52.0
@export var lane_width: float = 5.0
@export var biome_element: String = "NATURE"

var _ground: MeshInstance3D
var _path: MeshInstance3D
var _decor: Node3D

const PALETTES := {
	"FIRE": [Color("#55382d"), Color("#b76d43"), Color("#754437")],
	"WATER": [Color("#315c69"), Color("#7cc8cf"), Color("#43899b")],
	"NATURE": [Color("#52874c"), Color("#d8c19a"), Color("#2d6c43")],
	"LIGHT": [Color("#b7a77a"), Color("#f5e9c4"), Color("#ddd4a0")],
	"SHADOW": [Color("#39314f"), Color("#77658f"), Color("#4a3a69")]
}

func _ready() -> void:
	_ground = _make_box("Ground", Vector3(lane_width * 3.4, 0.25, lane_length), Vector3(0, -0.19, -lane_length * 0.3))
	_path = _make_box("Path", Vector3(lane_width, 0.04, lane_length), Vector3(0, -0.035, -lane_length * 0.3))
	_decor = Node3D.new()
	_decor.name = "LandscapeDecor"
	add_child(_decor)
	var rng := RandomNumberGenerator.new()
	rng.seed = 4272
	for i in range(36):
		var side := -1.0 if i % 2 == 0 else 1.0
		var offset := rng.randf_range(0.5, 5.0)
		var z := rng.randf_range(-lane_length * 0.8, lane_length * 0.2)
		var rock := _make_box("Rock_%02d" % i, Vector3(rng.randf_range(0.4, 1.1), rng.randf_range(0.3, 0.9), rng.randf_range(0.4, 1.0)), Vector3(side * (lane_width * 0.6 + offset), 0.18, z))
		rock.reparent(_decor)
	set_element(biome_element)

func set_element(element: String) -> void:
	biome_element = element.to_upper()
	var palette: Array = PALETTES.get(biome_element, PALETTES["NATURE"])
	if _ground == null:
		return
	_apply_color(_ground, palette[0])
	_apply_color(_path, palette[1])
	for child in _decor.get_children():
		if child is MeshInstance3D:
			_apply_color(child, palette[2])

func _make_box(label: String, size: Vector3, at: Vector3) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = label
	var box := BoxMesh.new()
	box.size = size
	mesh_instance.mesh = box
	mesh_instance.position = at
	add_child(mesh_instance)
	return mesh_instance

func _apply_color(target: MeshInstance3D, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.95
	target.material_override = material
