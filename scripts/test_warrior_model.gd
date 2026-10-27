extends Node3D
# Update 219: original lightweight Android test character, not a final hero asset.
# Visual only. The AnimationPlayer exposes the five imported-model states.
var body: Node3D
var animator: AnimationPlayer

func _ready() -> void:
 body = Node3D.new()
 body.name = "Body"
 add_child(body)
 _sphere(body, "Torso", Vector3(0, 1.22, 0), Vector3(0.52, 0.68, 0.34), Color("#466ba0"))
 _sphere(body, "Head", Vector3(0, 2.04, 0), Vector3(0.31, 0.33, 0.30), Color("#e6b48b"))
 _sphere(body, "Hair", Vector3(0, 2.27, 0.03), Vector3(0.32, 0.13, 0.31), Color("#332a36"))
 for side in [-1.0, 1.0]:
  _sphere(body, "Shoulder", Vector3(side * 0.55, 1.64, 0), Vector3(0.25, 0.24, 0.26), Color("#aab8c9"))
  _sphere(body, "Arm", Vector3(side * 0.62, 1.13, 0), Vector3(0.16, 0.47, 0.18), Color("#39547a"))
  _sphere(body, "Boot", Vector3(side * 0.24, 0.36, -0.09), Vector3(0.21, 0.43, 0.25), Color("#292f42"))
 _sphere(body, "Belt", Vector3(0, 0.81, 0), Vector3(0.51, 0.14, 0.36), Color("#bfa369"))
 _sphere(body, "Sword", Vector3(0.81, 1.20, -0.12), Vector3(0.07, 0.72, 0.09), Color("#c9e2e8"))
 animator = AnimationPlayer.new()
 animator.name = "AnimationPlayer"
 add_child(animator)
 var library := AnimationLibrary.new()
 library.add_animation("Idle", _clip(1.2, 0.04, 0.0, false, true))
 library.add_animation("Run", _clip(0.65, 0.10, 0.14, false, true))
 library.add_animation("Attack", _clip(0.42, 0.05, -0.55, false, false))
 library.add_animation("Hit", _clip(0.30, -0.09, 0.22, false, false))
 library.add_animation("Defeat", _clip(0.48, -0.40, 0.0, true, false))
 animator.add_animation_library("", library)
 animator.play("Idle")

func _sphere(parent: Node3D, part_name: String, at: Vector3, size: Vector3, tint: Color) -> void:
 var node := MeshInstance3D.new()
 node.name = part_name
 var mesh := SphereMesh.new()
 mesh.radius = 0.5
 mesh.height = 1.0
 mesh.radial_segments = 10
 mesh.rings = 5
 node.mesh = mesh
 node.scale = size * 2.0
 node.position = at
 var mat := StandardMaterial3D.new()
 mat.albedo_color = tint
 mat.roughness = 0.78
 node.material_override = mat
 parent.add_child(node)

func _clip(duration: float, bob: float, lean: float, fall: bool, looped: bool) -> Animation:
 var clip := Animation.new()
 clip.length = duration
 clip.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
 var track := clip.add_track(Animation.TYPE_VALUE)
 clip.track_set_path(track, NodePath("Body:position"))
 clip.track_insert_key(track, 0.0, Vector3.ZERO)
 clip.track_insert_key(track, duration * 0.5, Vector3(0.0, bob, 0.0))
 clip.track_insert_key(track, duration, Vector3(0.0, -0.30 if fall else 0.0, 0.0))
 var turn := clip.add_track(Animation.TYPE_VALUE)
 clip.track_set_path(turn, NodePath("Body:rotation"))
 clip.track_insert_key(turn, 0.0, Vector3.ZERO)
 clip.track_insert_key(turn, duration * 0.5, Vector3(lean, 0.0, 0.0))
 clip.track_insert_key(turn, duration, Vector3(0.0, 0.0, -1.25 if fall else 0.0))
 return clip
