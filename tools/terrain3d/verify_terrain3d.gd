extends SceneTree

func _initialize() -> void:
    var available := ClassDB.class_exists("Terrain3D")
    print("Terrain3D native class registered: ", available)
    if not available:
        push_error("Terrain3D extension did not register its native class")
        quit(1)
        return
    var terrain := ClassDB.instantiate("Terrain3D")
    if terrain == null:
        push_error("Terrain3D native class could not be instantiated")
        quit(2)
        return
    print("Terrain3D native object created: ", terrain.get_class())
    terrain.free()
    quit(0)
