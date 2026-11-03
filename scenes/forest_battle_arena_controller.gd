extends Node3D
## Temporary forest battle stage for the isolated Android preview.
## No arena geometry is present during exploration.
const ARENA_CENTER := Vector3(0.0, 0.0, 26.0)
const ARENA_RADIUS := 6.0
var _arena: Node3D

func start_battle() -> void:
    if is_instance_valid(_arena):
        return
    _arena = Node3D.new()
    _arena.name = "TemporaryBattleArena"
    add_child(_arena)
    _arena.position = ARENA_CENTER

    # Warm meadow clearing with a narrow raised stone rim.
    var floor_mesh := CylinderMesh.new()
    floor_mesh.top_radius = ARENA_RADIUS
    floor_mesh.bottom_radius = ARENA_RADIUS
    floor_mesh.height = 0.16
    floor_mesh.radial_segments = 48
    var floor_node := MeshInstance3D.new()
    floor_node.name = "MeadowBattleFloor"
    floor_node.mesh = floor_mesh
    floor_node.position.y = 0.10
    var floor_material := StandardMaterial3D.new()
    floor_material.albedo_color = Color(0.42, 0.61, 0.30)
    floor_material.roughness = 1.0
    floor_node.material_override = floor_material
    _arena.add_child(floor_node)

    # One instanced mesh for all boundary stones, rather than 16 draw calls.
    var stone_mesh := SphereMesh.new()
    stone_mesh.radial_segments = 8
    stone_mesh.rings = 4
    var stone_material := StandardMaterial3D.new()
    stone_material.albedo_color = Color(0.72, 0.68, 0.54)
    stone_material.roughness = 1.0
    stone_mesh.material = stone_material
    var stones := MultiMesh.new()
    stones.transform_format = MultiMesh.TRANSFORM_3D
    stones.mesh = stone_mesh
    stones.instance_count = 16
    for i in range(stones.instance_count):
        var angle := TAU * float(i) / float(stones.instance_count)
        var radius := ARENA_RADIUS + 0.12
        var stone_transform := Transform3D(Basis.IDENTITY, Vector3(cos(angle) * radius, 0.20, sin(angle) * radius))
        stone_transform.basis = stone_transform.basis.scaled(Vector3(0.65, 0.30, 0.50))
        stones.set_instance_transform(i, stone_transform)
    var stone_instances := MultiMeshInstance3D.new()
    stone_instances.name = "InstancedBoundaryStones"
    stone_instances.multimesh = stones
    _arena.add_child(stone_instances)

    get_parent().get_node("Camera3D").focus_battle(ARENA_CENTER)

func end_battle() -> void:
    get_parent().get_node("Camera3D").restore_exploration()
    if is_instance_valid(_arena):
        _arena.queue_free()
        _arena = null
