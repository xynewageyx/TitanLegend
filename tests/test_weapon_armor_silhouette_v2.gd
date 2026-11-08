extends SceneTree
## Source-level and runtime QA for 12 original weapons and armor at six rarities.
## No imported game assets or saved inventory state needed.
const WEAPON = preload("res://scripts/weapons/procedural_weapon_preview.gd")
const ARMOR = preload("res://scripts/equipment/chibi_armor_piece.gd")

func _initialize() -> void:
    call_deferred("_run")

func _fail(reason: String) -> void:
    push_error(reason)
    quit(1)

func _check_parts(item: Node3D, tag: String) -> int:
    var mesh_count := 0
    for child in item.get_children():
        var mesh := child as MeshInstance3D
        if mesh == null or mesh.mesh == null:
            _fail("Invalid mesh in " + tag)
            return -1
        if mesh.mesh.get_surface_count() <= 0:
            _fail("Empty mesh surface in " + tag)
            return -1
        var material := mesh.material_override as StandardMaterial3D
        if material == null:
            _fail("Missing StandardMaterial3D in " + tag)
            return -1
        if material.emission_enabled and material.emission_energy_multiplier > 0.40:
            _fail("Excessive weapon glow in " + tag)
            return -1
        mesh_count += 1
    return mesh_count

func _run() -> void:
    var weapon_tests := 0
    var armor_tests := 0
    var new_poly_blades := 0
    for kind in range(12):
        var last_mesh_count := 0
        var starter_count := 0
        for tier in range(6):
            var weapon: Node3D = WEAPON.new()
            weapon.weapon_type = kind
            weapon.rarity = tier
            root.add_child(weapon)
            var parts := _check_parts(weapon, "weapon=%d quality=%d" % [kind, tier])
            if parts <= 0 or parts > 24:
                _fail("Invalid or excessive weapon mesh count %d for %d/%d" % [parts, kind, tier])
                return
            if tier == 0:
                starter_count = parts
            if parts < last_mesh_count:
                _fail("Higher rarity removed weapon details for %d/%d" % [kind, tier])
                return
            if tier == 5 and parts < starter_count + 5:
                _fail("Mythic weapon lacks evolved details for type %d" % kind)
                return
            if kind in [0, 1, 2, 4, 5, 10]:
                var found_poly := false
                for piece in weapon.get_children():
                    if (piece as MeshInstance3D).mesh is ArrayMesh:
                        found_poly = true
                if not found_poly:
                    _fail("Expected sculpted faceted outline instead of block: " + str(kind))
                    return
                new_poly_blades += 1
            last_mesh_count = parts
            weapon_tests += 1
            root.remove_child(weapon)
            weapon.free()
    for hero_class in [0, 11]:
        for armor_slot in range(13):
            var last_parts := 0
            for tier in range(6):
                var armor: Node3D = ARMOR.new()
                armor.class_id = hero_class
                armor.slot_index = armor_slot
                armor.rarity = tier
                root.add_child(armor)
                var parts := _check_parts(armor, "class=%d armor=%d rarity=%d" % [hero_class, armor_slot, tier])
                if parts <= 0 or parts < last_parts:
                    _fail("Armor lost its rarity details at %d/%d/%d" % [hero_class, armor_slot, tier])
                    return
                if armor_slot == 1:
                    var shaped_shell := armor.get_node_or_null("CurvedChestShell") as MeshInstance3D
                    if shaped_shell == null or not (shaped_shell.mesh is ArrayMesh):
                        _fail("Chest armor still uses an unshaped box/ellipsoid for class %d" % hero_class)
                        return
                    if shaped_shell.mesh.get_surface_count() != 1:
                        _fail("Curved chest shell lacks a valid triangle surface")
                        return
                    var bounds: AABB = shaped_shell.mesh.get_aabb()
                    if bounds.size.x < 0.30 or bounds.size.y < 0.20 or bounds.size.z < 0.15:
                        _fail("Curved chest shell has invalid proportions")
                        return
                if hero_class == 11:
                    var base_part := armor.get_child(0) as MeshInstance3D
                    var base_mat := base_part.material_override as StandardMaterial3D
                    if base_mat.albedo_color.r > 0.70 or base_mat.albedo_color.g > 0.70 or base_mat.albedo_color.b > 0.70:
                        _fail("Death Knight armor still has overexposed base material")
                        return
                last_parts = parts
                armor_tests += 1
                root.remove_child(armor)
                armor.free()
    print("TITAN_SILHOUETTE_V2_OK weapons=%d armors=%d faceted=%d rarities=6" %
        [weapon_tests, armor_tests, new_poly_blades])
    quit(0)
