extends SceneTree
## Inspect imported forest GLB scenes in Godot 4.7.2, without assuming
## the GLB's mesh resources equal the imported engine mesh representation.
const ENEMIES := [
    "forest_01_mooshuepfer", "forest_02_pilzling",
    "forest_03_wurzelkrabbler", "forest_04_blattfuchs",
    "forest_05_dorneneber", "forest_06_rankenwerfer",
    "forest_elite_01_rindenwaechter", "forest_elite_02_moosbestie",
    "forest_boss_01_wurzelkoenig"
]

func _initialize() -> void:
    call_deferred("_inspect")

func _inspect() -> void:
    var failures: Array[String] = []
    print("enemy,mesh_instances,surfaces,material_slots,skin_instances,animations")
    for enemy in ENEMIES:
        var scene := load("res://assets/enemies/forest/%s.glb" % enemy) as PackedScene
        if scene == null:
            failures.append("%s: cannot load imported GLB" % enemy)
            continue
        var instance := scene.instantiate()
        if instance == null:
            failures.append("%s: cannot instantiate imported GLB" % enemy)
            continue
        root.add_child(instance)
        var counts := {"meshes": 0, "surfaces": 0, "materials": 0, "skinned": 0, "animations": 0}
        _visit(instance, counts)
        print("%s,%d,%d,%d,%d,%d" % [enemy, counts.meshes, counts.surfaces, counts.materials, counts.skinned, counts.animations])
        if counts.meshes == 0 or counts.surfaces == 0:
            failures.append("%s: imported scene has no mesh surfaces" % enemy)
        instance.queue_free()
    if not failures.is_empty():
        for failure in failures:
            printerr("FOREST IMPORT INSPECTION FAILED: ", failure)
        quit(1)
        return
    print("FOREST IMPORT INSPECTION PASSED: %d scenes" % ENEMIES.size())
    quit(0)

func _visit(node: Node, counts: Dictionary) -> void:
    if node is MeshInstance3D:
        var mesh_node := node as MeshInstance3D
        if mesh_node.mesh != null:
            counts.meshes += 1
            counts.surfaces += mesh_node.mesh.get_surface_count()
            counts.materials += mesh_node.mesh.get_surface_count()
            if mesh_node.skin != null or mesh_node.skeleton != NodePath(""):
                counts.skinned += 1
    if node is AnimationPlayer:
        counts.animations += (node as AnimationPlayer).get_animation_list().size()
    for child in node.get_children():
        _visit(child, counts)
