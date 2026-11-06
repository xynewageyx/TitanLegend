extends SceneTree
## Non-mutating audit of actual project character scenes and imported GLB rigs.
## Run after Godot import:
## godot --headless --path . --script res://tools/audit_hero_equipment_rigs.gd
const SOCKETS := [
    "RightHandSocket", "LeftHandSocket", "HeadSocket", "ChestSocket", "BackSocket",
    "ShoulderLeftSocket", "ShoulderRightSocket", "ArmLeftSocket", "ArmRightSocket",
    "GloveLeftSocket", "GloveRightSocket", "LegLeftSocket", "LegRightSocket",
    "BootLeftSocket", "BootRightSocket"
]
var scene_count := 0
var skeleton_count := 0
var socket_count := 0
var findings: Array[String] = []

func _initialize() -> void:
    _walk("res://assets/heroes")
    _walk("res://scenes")
    print("Equipment rig audit: %d scenes, %d skeletons, %d sockets" % [scene_count, skeleton_count, socket_count])
    for finding in findings:
        print(finding)
    # Missing sockets are reported, not a hard failure: many scenes aren't hero rigs.
    quit(0)

func _walk(folder: String) -> void:
    var dir := DirAccess.open(folder)
    if dir == null:
        findings.append("Directory unavailable: " + folder)
        return
    dir.list_dir_begin()
    var subdirs: Array[String] = []
    var scenes: Array[String] = []
    while true:
        var name := dir.get_next()
        if name.is_empty():
            break
        if name.begins_with("."):
            continue
        if dir.current_is_dir():
            subdirs.append(folder.path_join(name))
        elif name.ends_with(".tscn") or name.ends_with(".scn") or name.ends_with(".glb") or name.ends_with(".gltf"):
            scenes.append(folder.path_join(name))
    dir.list_dir_end()
    subdirs.sort()
    scenes.sort()
    for path in scenes:
        _audit_scene(path)
    for path in subdirs:
        _walk(path)

func _audit_scene(path: String) -> void:
    if not ResourceLoader.exists(path, "PackedScene"):
        return
    var packed := ResourceLoader.load(path, "PackedScene") as PackedScene
    if packed == null:
        findings.append("Unable to load: " + path)
        return
    var instance := packed.instantiate()
    if instance == null:
        findings.append("Unable to instantiate: " + path)
        return
    scene_count += 1
    _audit_node(instance, path)
    instance.free()

func _audit_node(node: Node, path: String) -> void:
    if node is Skeleton3D:
        skeleton_count += 1
        var found: Dictionary = {}
        _collect_sockets(node, found)
        var missing: Array[String] = []
        for name in SOCKETS:
            if found.has(name):
                socket_count += 1
            else:
                missing.append(name)
        findings.append("%s | Skeleton3D=%s | bones=%d | missing=%s" % [
            path, str(node.get_path()), node.get_bone_count(), ",".join(missing)
        ])
    for child in node.get_children():
        _audit_node(child, path)

func _collect_sockets(node: Node, found: Dictionary) -> void:
    if node.name in SOCKETS:
        found[str(node.name)] = true
    for child in node.get_children():
        if child is Skeleton3D and child != node:
            continue
        _collect_sockets(child, found)
