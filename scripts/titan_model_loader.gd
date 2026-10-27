extends RefCounted
class_name TitanModelLoader

# Update 214: optional, reusable Godot 4.x 3D model loader.
# This module does not modify combat logic, roles, stats or companion behavior.
const MODEL_ROOT := "res://assets/models/"

static func attach_model(host: Node3D, model_id: String, scale_factor: float = 1.0) -> Node3D:
	if not is_instance_valid(host):
		return null
	if not _valid_id(model_id):
		push_warning("TitanModelLoader: invalid model id")
		return null
	var path := MODEL_ROOT + model_id + ".glb"
	if not ResourceLoader.exists(path):
		path = MODEL_ROOT + model_id + ".tscn"
	if not ResourceLoader.exists(path):
		return null
	var resource := load(path) as PackedScene
	if resource == null:
		push_warning("TitanModelLoader: model is not a PackedScene: " + path)
		return null
	var instance := resource.instantiate() as Node3D
	if instance == null:
		push_warning("TitanModelLoader: model root must be Node3D: " + path)
		return null
	instance.name = "TitanImportedModel"
	instance.scale = Vector3.ONE * clampf(scale_factor, 0.05, 10.0)
	host.add_child(instance)
	return instance

static func play_animation(model: Node3D, animation_name: StringName) -> bool:
	if not is_instance_valid(model):
		return false
	var player := _find_animation_player(model)
	if player == null or not player.has_animation(animation_name):
		return false
	player.play(animation_name)
	return true

static func _find_animation_player(root: Node) -> AnimationPlayer:
	if root is AnimationPlayer:
		return root as AnimationPlayer
	for child in root.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null

static func _valid_id(model_id: String) -> bool:
	if model_id.is_empty() or model_id.contains("..") or model_id.begins_with("/"):
		return false
	for character in model_id:
		if not (character.to_lower() in "abcdefghijklmnopqrstuvwxyz0123456789_-/"):
			return false
	return true
