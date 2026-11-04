extends SceneTree
## Run: godot --headless --path . --script res://tools/export_skeleton3d_inventory.gd -- --output build/skeleton3d_inventory.json
## Metadata only. No mesh surfaces, textures, animation keyframes, or original assets exported.

var _entries: Array[Dictionary] = []
var _warnings: Array[String] = []
var _seen: Dictionary = {}


func _initialize() -> void:
    var args := OS.get_cmdline_user_args()
    var output := "user://skeleton3d_inventory.json"
    for i in range(args.size() - 1):
        if args[i] == "--output":
            output = args[i + 1]
    _scan_directory("res://")
    _entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
        return str(a["scene"]) + ":" + str(a["node_path"]) < str(b["scene"]) + ":" + str(b["node_path"])
    )
    var result := {
        "schema_version": 1,
        "engine_version": Engine.get_version_info().get("string", "unknown"),
        "skeleton_count": _entries.size(),
        "skeletons": _entries,
        "warnings": _warnings,
        "notes": "Rest transforms are recorded, but matching Unity bind poses is NOT verified."
    }
    var directory := output.get_base_dir()
    if not directory.is_empty() and not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(directory)):
        DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
    var file := FileAccess.open(output, FileAccess.WRITE)
    if file == null:
        push_error("Cannot write skeleton inventory: %s (error %s)" % [output, FileAccess.get_open_error()])
        quit(1)
        return
    file.store_string(JSON.stringify(result, "  ") + "\n")
    file.close()
    print("Skeleton3D inventory: %d skeleton(s), %d warning(s), output=%s" % [_entries.size(), _warnings.size(), output])
    quit(0)


func _scan_directory(folder: String) -> void:
    var dir := DirAccess.open(folder)
    if dir == null:
        _warnings.append("Cannot open: " + folder)
        return
    dir.list_dir_begin()
    var folders: Array[String] = []
    var scenes: Array[String] = []
    while true:
        var item := dir.get_next()
        if item.is_empty():
            break
        if item.begins_with("."):
            continue
        if dir.current_is_dir():
            if item not in ["addons", ".godot", "build"]:
                folders.append(folder.path_join(item))
        elif item.ends_with(".tscn") or item.ends_with(".scn"):
            scenes.append(folder.path_join(item))
    dir.list_dir_end()
    folders.sort()
    scenes.sort()
    for scene_path in scenes:
        _scan_scene(scene_path)
    for subfolder in folders:
        _scan_directory(subfolder)


func _scan_scene(path: String) -> void:
    var packed := ResourceLoader.load(path, "PackedScene") as PackedScene
    if packed == null:
        _warnings.append("Cannot load scene: " + path)
        return
    var root := packed.instantiate()
    if root == null:
        _warnings.append("Cannot instantiate scene: " + path)
        return
    _scan_node(root, root, path)
    root.free()


func _scan_node(node: Node, root: Node, scene_path: String) -> void:
    if node is Skeleton3D:
        var skeleton := node as Skeleton3D
        var bones: Array[Dictionary] = []
        for index in range(skeleton.get_bone_count()):
            var parent_index := skeleton.get_bone_parent(index)
            var parent_name: Variant = null
            if parent_index >= 0:
                parent_name = skeleton.get_bone_name(parent_index)
            var rest := skeleton.get_bone_rest(index)
            bones.append({
                "index": index,
                "name": skeleton.get_bone_name(index),
                "parent": parent_name,
                "parent_index": parent_index,
                "rest_origin": [rest.origin.x, rest.origin.y, rest.origin.z],
                "rest_basis": [
                    [rest.basis.x.x, rest.basis.x.y, rest.basis.x.z],
                    [rest.basis.y.x, rest.basis.y.y, rest.basis.y.z],
                    [rest.basis.z.x, rest.basis.z.y, rest.basis.z.z]
                ]
            })
        _entries.append({
            "scene": scene_path,
            "node_path": str(root.get_path_to(skeleton)),
            "bones": bones
        })
    for child in node.get_children():
        _scan_node(child, root, scene_path)
