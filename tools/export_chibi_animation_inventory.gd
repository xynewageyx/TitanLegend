extends SceneTree
## Inspect imported Godot animation libraries and tracks; does not claim Unity retargeting.
const HEROES := ["brawler", "druid", "hunter", "mage", "paladin", "priest", "rogue", "shaman", "summoner", "warlock", "warrior"]


func _initialize() -> void:
    var entries: Array[Dictionary] = []
    var errors: Array[String] = []
    for hero_id in HEROES:
        var scene_path := "res://assets/heroes/chibi/%s.glb" % hero_id
        var packed := load(scene_path) as PackedScene
        if packed == null:
            errors.append("Cannot load " + scene_path)
            continue
        var root := packed.instantiate()
        var players: Array[AnimationPlayer] = []
        _find_players(root, players)
        var clips: Array[Dictionary] = []
        for player in players:
            for animation_name in player.get_animation_list():
                var animation := player.get_animation(animation_name)
                if animation == null:
                    continue
                var tracks: Array[Dictionary] = []
                for index in range(animation.get_track_count()):
                    tracks.append({
                        "path": str(animation.track_get_path(index)),
                        "type": animation.track_get_type(index),
                        "key_count": animation.track_get_key_count(index)
                    })
                var fingerprint_parts: Array[String] = []
                for index in range(animation.get_track_count()):
                    fingerprint_parts.append(str(animation.track_get_path(index)))
                    fingerprint_parts.append(str(animation.track_get_type(index)))
                    fingerprint_parts.append(str(animation.track_get_interpolation_type(index)))
                    for key_index in range(animation.track_get_key_count(index)):
                        fingerprint_parts.append(str(animation.track_get_key_time(index, key_index)))
                        fingerprint_parts.append(var_to_str(animation.track_get_key_value(index, key_index)))
                        fingerprint_parts.append(str(animation.track_get_key_transition(index, key_index)))
                clips.append({
                    "keyframe_fingerprint_sha256": ("|".join(fingerprint_parts)).sha256_text(),
                    "player_path": str(root.get_path_to(player)),
                    "name": str(animation_name),
                    "duration": animation.length,
                    "tracks": tracks
                })
        entries.append({"hero": hero_id, "scene": scene_path, "animation_players": players.size(), "clips": clips})
        root.free()
    var output := "build/chibi_animation_inventory.json"
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://build"))
    var file := FileAccess.open(output, FileAccess.WRITE)
    if file == null:
        push_error("Cannot write animation inventory")
        quit(1)
        return
    file.store_string(JSON.stringify({
        "schema_version": 1,
        "source": "imported_godot_scenes",
        "heroes": entries,
        "errors": errors,
        "unity_retargeting_verified": false
    }, "  ") + "\n")
    file.close()
    print("Chibi animation inventory: %d hero(s), %d error(s)" % [entries.size(), errors.size()])
    for message in errors:
        push_error(message)
    quit(1 if not errors.is_empty() else 0)


func _find_players(node: Node, players: Array[AnimationPlayer]) -> void:
    if node is AnimationPlayer:
        players.append(node as AnimationPlayer)
    for child in node.get_children():
        _find_players(child, players)
