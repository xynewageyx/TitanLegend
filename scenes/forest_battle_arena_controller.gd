extends Node3D
## Standalone preview of battle-only arena visibility.
## The gameplay battle controller can call start_battle()/end_battle() later.
var _arena: Node3D

func start_battle() -> void:
    if is_instance_valid(_arena):
        return
    _arena = Node3D.new()
    _arena.name = "TemporaryBattleArena"
    add_child(_arena)
    var disk := CylinderMesh.new()
    disk.top_radius = 6.0
    disk.bottom_radius = 6.0
    disk.height = 0.12
    disk.radial_segments = 32
    var surface := MeshInstance3D.new()
    surface.mesh = disk
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.68, 0.57, 0.39)
    surface.material_override = material
    _arena.add_child(surface)
    _arena.position = Vector3(0, 0.08, 26)
    get_parent().get_node("Camera3D").focus_battle(Vector3(0, 0, 26))

func end_battle() -> void:
    get_parent().get_node("Camera3D").restore_exploration()
    if is_instance_valid(_arena):
        _arena.queue_free()
        _arena = null
