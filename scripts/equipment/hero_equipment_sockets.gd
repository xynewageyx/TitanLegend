extends Node3D
## Attach equipment visuals to existing hero marker nodes without changing combat logic.
## Expected optional Marker3D children: RightHandSocket, LeftHandSocket,
## HeadSocket, ChestSocket, BackSocket. Works with animated markers.
const WEAPON_PREVIEW = preload("res://scripts/weapons/procedural_weapon_preview.gd")
const IMPORTED_SOCKETS = preload("res://scripts/equipment/chibi_imported_equipment_sockets.gd")
const ARMOR_PREVIEW = preload("res://scripts/equipment/chibi_armor_piece.gd")
const HAIR_PREVIEW = preload("res://scripts/equipment/procedural_hairstyle.gd")
const SLOT_NAMES := ["HeadSocket", "ChestSocket", "BackSocket", "ShoulderLeftSocket", "ShoulderRightSocket", "ArmLeftSocket", "ArmRightSocket", "GloveLeftSocket", "GloveRightSocket", "LegLeftSocket", "LegRightSocket", "BootLeftSocket", "BootRightSocket"]
var equipped_nodes: Dictionary = {}
# Keep already equipped meshes alive across inventory refreshes, avoiding
# unnecessary GPU/scene churn on Android while still following a changed socket.
func _same_visual(key: String, socket: Node3D, expected: Dictionary) -> bool:
    if not equipped_nodes.has(key):
        return false
    var visual: Node3D = equipped_nodes[key] as Node3D
    if not is_instance_valid(visual) or visual.is_queued_for_deletion():
        return false
    if visual.get_parent() != socket:
        return false
    for property_name in expected:
        if visual.get(property_name) != expected[property_name]:
            return false
    return true

func _socket(name: String) -> Node3D:
    # Prefer animated bone attachments over static formation markers.
    var hero := get_parent()
    if hero is Node3D:
        # The original GLB model drives the visible character when available.
        # Prefer its animated 8-/24-bone sockets, then the helper 18-bone rig.
        var chibi := hero.get_node_or_null("ChibiGLBVisual")
        if chibi != null:
            var imported: Skeleton3D = chibi.get("imported_skeleton") as Skeleton3D
            var glb_socket: Node3D = IMPORTED_SOCKETS.resolve(imported, name)
            if glb_socket != null:
                return glb_socket
        var skeleton := hero.get_node_or_null("LiveFormationRig/Skeleton3D") as Skeleton3D
        if skeleton == null:
            skeleton = hero.find_child("Skeleton3D", true, false) as Skeleton3D
        if skeleton != null:
            var attached := skeleton.get_node_or_null(NodePath(name)) as BoneAttachment3D
            if attached != null:
                return attached
    var found := find_child(name, true, false)
    if found is Node3D:
        return found as Node3D
    # Animated bone sockets may be siblings of this equipment controller.
    if hero is Node3D:
        found = hero.find_child(name, true, false)
    return found as Node3D if found is Node3D else null
func equip_weapon(weapon_type: int, rarity: int, offhand: bool = false) -> bool:
    var socket := _socket("LeftHandSocket" if offhand else "RightHandSocket")
    if socket == null:
        push_warning("Titan Legends: missing weapon socket")
        return false
    var key := "offhand" if offhand else "mainhand"
    var safe_type: int = clampi(weapon_type, 0, 11)
    var safe_rarity: int = clampi(rarity, 0, 5)
    if _same_visual(key, socket, {"weapon_type": safe_type, "rarity": safe_rarity}):
        if not offhand:
            _set_legacy_mainhand_visible(false)
        return true
    _clear(key)
    var visual := Node3D.new()
    visual.set_script(WEAPON_PREVIEW)
    visual.set("weapon_type", safe_type)
    visual.set("rarity", safe_rarity)
    # Match the authored grip to the moving hand joint without interfering
    # with main's equipment-refresh caching and instant mesh deduplication.
    visual.position = -WEAPON_PREVIEW.grip_local_point(safe_type)
    socket.add_child(visual)
    equipped_nodes[key] = visual
    if not offhand:
        _set_legacy_mainhand_visible(false)
    return true
func equip_armor_slot(slot: String, hero_class: int, rarity: int) -> bool:
    if not SLOT_NAMES.has(slot):
        return false
    var socket := _socket(slot)
    if socket == null:
        push_warning("Titan Legends: missing armor socket " + slot)
        return false
    var safe_class: int = clampi(hero_class, 0, 11)
    var safe_rarity: int = clampi(rarity, 0, 5)
    var slot_index: int = SLOT_NAMES.find(slot)
    if _same_visual(slot, socket, {"slot_index": slot_index, "class_id": safe_class, "rarity": safe_rarity}):
        return true
    _clear(slot)
    var visual := Node3D.new()
    visual.set_script(ARMOR_PREVIEW)
    visual.set("slot_index", slot_index)
    visual.set("class_id", safe_class)
    visual.set("rarity", safe_rarity)
    socket.add_child(visual)
    equipped_nodes[slot] = visual
    return true
func unequip(slot: String) -> void:
    _clear(slot)
## Only the older weapon-prop groups are hidden, never the hero's body,
## shield, active offhand or other class accessories. Restore the fallbacks on
## unequip so an inventory/UI failure does not leave the character unarmed.
func _set_legacy_mainhand_visible(should_show: bool) -> void:
    var hero := get_parent()
    if hero == null:
        return
    for path in [
        "HeroCombatMotion/AnimatedRightArm/LegacyWeaponVisual",
        "LegacyRoleWeapon"
    ]:
        var legacy: Node3D = hero.get_node_or_null(NodePath(path)) as Node3D
        if legacy != null:
            legacy.visible = should_show

func _clear(slot: String) -> void:
    if equipped_nodes.has(slot):
        var node: Node = equipped_nodes[slot]
        if is_instance_valid(node):
            # A deferred queue_free alone leaves the old mesh attached until
            # the frame ends, overlapping the replacement for one frame.
            if node is Node3D:
                (node as Node3D).visible = false
            if node.get_parent() != null:
                node.get_parent().remove_child(node)
            node.queue_free()
        equipped_nodes.erase(slot)
    if slot == "mainhand":
        _set_legacy_mainhand_visible(true)

## Hair is cosmetic. It does not change combat or armor slot state.
func equip_hairstyle(style: int, color: Color = Color("#694333")) -> bool:
    var socket := _socket("HeadSocket")
    if socket == null:
        push_warning("Titan Legends: missing HeadSocket for hairstyle")
        return false
    var safe_style: int = clampi(style, 0, 2)
    if _same_visual("hair", socket, {"style": safe_style, "hair_color": color}):
        return true
    _clear("hair")
    var visual := Node3D.new()
    visual.set_script(HAIR_PREVIEW)
    visual.set("style", safe_style)
    visual.set("hair_color", color)
    socket.add_child(visual)
    equipped_nodes["hair"] = visual
    return true
